////////////////////////////////////////////////////////////////////////////
//                           **** DSDPACK ****                            //
//         Lossless DSD (Direct Stream Digital) Audio Compressor          //
//                Copyright (c) 2013 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// pack_dsd.c

// This module actually handles the compression of the DSD audio data.

#ifdef ENABLE_DSD

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "wavpack_local.h"

///////////////////////////// executable code ////////////////////////////////

// This function initializes everything required to pack WavPack DSD bitstreams
// and must be called BEFORE any other function in this module.

void pack_dsd_init (WavpackContext *wpc)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];

    wps->sample_index = 0;
}

// Pack an entire block of samples (either mono or stereo) into a completed
// WavPack block. This function is actually a shell for pack_samples() and
// performs tasks like handling any shift required by the format, preprocessing
// of floating point data or integer data over 24 bits wide, and implementing
// the "extra" mode (via the extra?.c modules). It is assumed that there is
// sufficient space for the completed block at "wps->blockbuff" and that
// "wps->blockend" points to the end of the available space. A return value of
// FALSE indicates an error.

// Pack an entire block of samples (either mono or stereo) into a completed
// WavPack block. It is assumed that there is sufficient space for the
// completed block at "wps->blockbuff" and that "wps->blockend" points to the
// end of the available space. A return value of FALSE indicates an error.
// Any unsent metadata is transmitted first, then required metadata for this
// block is sent, and finally the compressed integer data is sent. If a "wpx"
// stream is required for floating point data or large integer data, then this
// must be handled outside this function. To find out how much data was written
// the caller must look at the ckSize field of the written WavpackHeader, NOT
// the one in the WavpackStream.

static int encode_buffer_high (WavpackStream *wps, int32_t *buffer, int num_samples, unsigned char *destination);
static int encode_buffer_fast (WavpackStream *wps, int32_t *buffer, int num_samples, unsigned char *destination);

int pack_dsd_block (WavpackContext *wpc, int32_t *buffer)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags, mult = wpc->dsd_multiplier, data_count;
    uint32_t sample_count = wps->wphdr.block_samples;
    unsigned char *dsd_encoding, dsd_power = 0;
    int32_t res;

    // This code scans stereo data to check whether it can be stored as mono data
    // (i.e., all L/R samples identical).

    if (!(flags & MONO_FLAG)) {
        int32_t *sptr, *dptr, i;

        for (sptr = buffer, i = 0; i < (int32_t) sample_count; sptr += 2, i++)
            if ((sptr [0] ^ sptr [1]) & 0xff)
                break;

        if (i == sample_count) {
            wps->wphdr.flags = flags |= FALSE_STEREO;
            dptr = buffer;
            sptr = buffer;

            for (i = sample_count; i--; sptr++)
                *dptr++ = *sptr++;
        }
        else
            wps->wphdr.flags = flags &= ~FALSE_STEREO;
    }

    wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
    memcpy (wps->blockbuff, &wps->wphdr, sizeof (WavpackHeader));

    if (wpc->metacount) {
        WavpackMetadata *wpmdp = wpc->metadata;

        while (wpc->metacount) {
            copy_metadata (wpmdp, wps->blockbuff, wps->blockend);
            wpc->metabytes -= wpmdp->byte_length;
            free_metadata (wpmdp++);
            wpc->metacount--;
        }

        free (wpc->metadata);
        wpc->metadata = NULL;
    }

    if (!sample_count)
        return TRUE;

    send_general_metadata (wpc);
    memcpy (&wps->wphdr, wps->blockbuff, sizeof (WavpackHeader));

    dsd_encoding = wps->blockbuff + ((WavpackHeader *) wps->blockbuff)->ckSize + 12;

    while (mult >>= 1)
        dsd_power++;

    *dsd_encoding++ = dsd_power;

    if (wpc->config.flags & CONFIG_HIGH_FLAG) {
        int fast_res = encode_buffer_fast (wps, buffer, sample_count, dsd_encoding);

        res = encode_buffer_high (wps, buffer, sample_count, dsd_encoding);

        if ((fast_res != -1) && (res == -1 || res > fast_res))
            res = encode_buffer_fast (wps, buffer, sample_count, dsd_encoding);
    }
    else
        res = encode_buffer_fast (wps, buffer, sample_count, dsd_encoding);

    if (res == -1) {
        int num_samples = sample_count * ((flags & MONO_DATA) ? 1 : 2);
        uint32_t crc = 0xffffffff;

        *dsd_encoding++ = 0;

        data_count = num_samples + 2;

        while (num_samples--)
            crc += (crc << 1) + (*dsd_encoding++ = *buffer++);

        ((WavpackHeader *) wps->blockbuff)->crc = crc;
    }
    else
        data_count = res + 1;

    if (data_count) {
        unsigned char *cptr = wps->blockbuff + ((WavpackHeader *) wps->blockbuff)->ckSize + 8;

        if (data_count & 1) {
            cptr [data_count + 4] = 0;
            *cptr++ = ID_DSD_BLOCK | ID_LARGE | ID_ODD_SIZE;
            data_count++;
        }
        else
            *cptr++ = ID_DSD_BLOCK | ID_LARGE;

        *cptr++ = data_count >> 1;
        *cptr++ = data_count >> 9;
        *cptr++ = data_count >> 17;
        ((WavpackHeader *) wps->blockbuff)->ckSize += data_count + 4;
    }

    wps->sample_index += sample_count;
    return TRUE;
}

/*------------------------------------------------------------------------------------------------------------------------*/

// #define DSD_BYTE_READY(low,high) (((low) >> 24) == ((high) >> 24))
// #define DSD_BYTE_READY(low,high) (!(((low) ^ (high)) >> 24))
#define DSD_BYTE_READY(low,high) (!(((low) ^ (high)) & 0xff000000))

#define MAX_HISTORY_BITS    5
#define MAX_PROBABILITY     0xa0    // set to 0xff to disable RLE encoding for probabilities table

#if (MAX_PROBABILITY < 0xff)

static int rle_encode (unsigned char *src, int bcount, unsigned char *destination)
{
    int max_rle_zeros = 0xff - MAX_PROBABILITY;
    unsigned char *dp = destination;
    int zcount = 0;

    while (bcount--) {
        if (*src) {
            while (zcount) {
                *dp++ = MAX_PROBABILITY + (zcount > max_rle_zeros ? max_rle_zeros : zcount);
                zcount -= (zcount > max_rle_zeros ? max_rle_zeros : zcount);
            }

            *dp++ = *src++;
        }
        else {
            zcount++;
            src++;
        }
    }

    while (zcount) {
        *dp++ = MAX_PROBABILITY + (zcount > max_rle_zeros ? max_rle_zeros : zcount);
        zcount -= (zcount > max_rle_zeros ? max_rle_zeros : zcount);
    }

    *dp++ = 0;

    return (int)(dp - destination);
}

#endif

static void calculate_probabilities (int hist [256], unsigned char probs [256], unsigned short prob_sums [256])
{
    int divisor, min_value, max_value, sum_values;
    int min_hits = 0x7fffffff, max_hits = 0, i;

    for (i = 0; i < 256; ++i) {
        if (hist [i] < min_hits) min_hits = hist [i];
        if (hist [i] > max_hits) max_hits = hist [i];
    }

    if (max_hits == 0) {
        memset (probs, 0, sizeof (*probs) * 256);
        memset (prob_sums, 0, sizeof (*prob_sums) * 256);
        return;
    }

//  fprintf (stderr, "process_histogram(): hits = %d to %d\n", min_hits, max_hits);

    if (max_hits > MAX_PROBABILITY)
        divisor = ((max_hits << 8) + (MAX_PROBABILITY >> 1)) / MAX_PROBABILITY;
    else
        divisor = 0;

    while (1) {
        min_value = 0x7fffffff; max_value = 0; sum_values = 0;

        for (i = 0; i < 256; ++i) {
            int value;

            if (hist [i]) {
                if (divisor) {
                    if (!(value = ((hist [i] << 8) + (divisor >> 1)) / divisor))
                        value = 1;
                }
                else
                    value = hist [i];

                if (value < min_value) min_value = value;
                if (value > max_value) max_value = value;
            }
            else
                value = 0;

            prob_sums [i] = sum_values += value;
            probs [i] = value;
        }

        if (max_value > MAX_PROBABILITY) {
            divisor++;
            continue;
        }

#if 0   // this code reduces probability values when they are completely redundant (i.e., common divisor), but
        // this doesn't really happen often enough to make it worthwhile

        if (min_value > 1) {
            for (i = 0; i < 256; ++i)
                if (probs [i] % min_value)
                    break;

            if (i == 256) {
                for (i = 0; i < 256; ++i) {
                    prob_sums [i] /= min_value;
                    probs [i] /= min_value;
                }

                // fprintf (stderr, "fixed min_value = %d, divisor = %d, probs_sum = %d\n", min_value, divisor, prob_sums [255]);
            }
        }
#endif

        break;
    }
}

static int encode_buffer_fast (WavpackStream *wps, int32_t *buffer, int num_samples, unsigned char *destination)
{
    uint32_t flags = wps->wphdr.flags, crc = 0xffffffff;
    unsigned int low = 0, high = 0xffffffff, mult;
    unsigned short (*summed_probabilities) [256];
    unsigned char (*probabilities) [256];
    unsigned char *dp = destination, *ep;
    int history_bins, bc, p0 = 0, p1 = 0;
    int total_summed_probabilities = 0;
    int (*histogram) [256];
    int32_t *bp = buffer;
    char history_bits;

    if (!(flags & MONO_DATA))
        num_samples *= 2;

    if (num_samples < 280)
        return -1;
    else if (num_samples < 560)
        history_bits = 0;
    else if (num_samples < 1725)
        history_bits = 1;
    else if (num_samples < 5000)
        history_bits = 2;
    else if (num_samples < 14000)
        history_bits = 3;
    else if (num_samples < 28000)
        history_bits = 4;
    else if (num_samples < 76000)
        history_bits = 5;
    else if (num_samples < 130000)
        history_bits = 6;
    else if (num_samples < 300000)
        history_bits = 7;
    else
        history_bits = 8;

    if (history_bits > MAX_HISTORY_BITS)
        history_bits = MAX_HISTORY_BITS;

    history_bins = 1 << history_bits;
    histogram = malloc (sizeof (*histogram) * history_bins);
    memset (histogram, 0, sizeof (*histogram) * history_bins);
    probabilities = malloc (sizeof (*probabilities) * history_bins);
    summed_probabilities = malloc (sizeof (*summed_probabilities) * history_bins);

    bc = num_samples;

    if (flags & MONO_DATA)
        while (bc--) {
            crc += (crc << 1) + (*bp & 0xff);
            histogram [p0] [*bp & 0xff]++;
            p0 = *bp++ & (history_bins-1);
        }
    else
        while (bc--) {
            crc += (crc << 1) + (*bp & 0xff);
            histogram [p0] [*bp & 0xff]++;
            p0 = p1;
            p1 = *bp++ & (history_bins-1);
        }

    for (p0 = 0; p0 < history_bins; p0++) {
        calculate_probabilities (histogram [p0], probabilities [p0], summed_probabilities [p0]);
        total_summed_probabilities += summed_probabilities [p0] [255];
    }

    ((WavpackHeader *) wps->blockbuff)->crc = crc;

    // This code detects the case where the required value lookup tables grow silly big and cuts them back down. This would
    // normally only happen with large blocks or poorly compressible data. The target is to guarantee that the total memory
    // required for all three decode tables will be 2K bytes per history bin.

    while (total_summed_probabilities > history_bins * 1280) {
        int max_sum = 0, sum_values = 0, largest_bin = 0;

        for (p0 = 0; p0 < history_bins; ++p0)
            if (summed_probabilities [p0] [255] > max_sum) {
                max_sum = summed_probabilities [p0] [255];
                largest_bin = p0;
            }

        total_summed_probabilities -= max_sum;
        p0 = largest_bin;

        for (p1 = 0; p1 < 256; ++p1)
            summed_probabilities [p0] [p1] = sum_values += probabilities [p0] [p1] = (probabilities [p0] [p1] + 1) >> 1;

        total_summed_probabilities += summed_probabilities [p0] [255];
        // fprintf (stderr, "processed bin 0x%02x, bin: %d --> %d, new sum = %d\n",
        //     p0, max_sum, summed_probabilities [p0] [255], total_summed_probabilities);
    }

    free (histogram);
    bp = buffer;
    bc = num_samples;
    *dp++ = 1;
    *dp++ = history_bits;
    *dp++ = MAX_PROBABILITY;
    ep = destination + num_samples - 10;

#if (MAX_PROBABILITY < 0xff)
    dp += rle_encode ((unsigned char *) probabilities, sizeof (*probabilities) * history_bins, dp);
#else
    memcpy (dp, probabilities, sizeof (*probabilities) * history_bins);
    dp += sizeof (*probabilities) * history_bins;
#endif

    p0 = p1 = 0;

    while (dp < ep && bc--) {

        mult = (high - low) / summed_probabilities [p0] [255];

        if (!mult) {
            high = low;

            while (DSD_BYTE_READY (high, low)) {
                *dp++ = high >> 24;
                high = (high << 8) | 0xff;
                low <<= 8;
            }

            mult = (high - low) / summed_probabilities [p0] [255];
        }

        if (*bp & 0xff)
            low += summed_probabilities [p0] [(*bp & 0xff)-1] * mult;

        high = low + probabilities [p0] [*bp & 0xff] * mult - 1;

        while (DSD_BYTE_READY (high, low)) {
            *dp++ = high >> 24;
            high = (high << 8) | 0xff;
            low <<= 8;
        }

        if (flags & MONO_DATA)
            p0 = *bp++ & (history_bins-1);
        else {
            p0 = p1;
            p1 = *bp++ & (history_bins-1);
        }
    }

    high = low;

    while (DSD_BYTE_READY (high, low)) {
        *dp++ = high >> 24;
        high = (high << 8) | 0xff;
        low <<= 8;
    }

    free (summed_probabilities);
    free (probabilities);

    if (dp < ep)
        return (int)(dp - destination);
    else
        return -1;
}

/*------------------------------------------------------------------------------------------------------------------------*/

#define PTABLE_BITS 8
#define PTABLE_BINS (1<<PTABLE_BITS)
#define PTABLE_MASK (PTABLE_BINS-1)

#define INITIAL_TERM (1536/PTABLE_BINS)

#define UP   0x010000fe
#define DOWN 0x00010000
#define DECAY 8

#define PRECISION 20
#define VALUE_ONE (1 << PRECISION)
#define PRECISION_USE 12

#define RATE_S 20

static void init_ptable (int *table, int rate_i, int rate_s)
{
    int value = 0x808000, rate = rate_i << 8, c, i;

    for (c = (rate + 128) >> 8; c--;)
        value += (DOWN - value) >> DECAY;

    for (i = 0; i < PTABLE_BINS/2; ++i) {
        table [i] = value;
        table [PTABLE_BINS-1-i] = 0x100ffff - value;

        if (value > 0x010000) {
            rate += (rate * rate_s + 128) >> 8;

            for (c = (rate + 64) >> 7; c--;)
                value += (DOWN - value) >> DECAY;
        }
    }
}

static int normalize_ptable (int *ptable)
{
    int rate = 0, min_error, error_sum, i;
    int ntable [PTABLE_BINS];

    init_ptable (ntable, rate, RATE_S);

    for (min_error = i = 0; i < PTABLE_BINS; ++i)
        min_error += abs (ptable [i] - ntable [i]) >> 8;

    while (1) {
        init_ptable (ntable, ++rate, RATE_S);

        for (error_sum = i = 0; i < PTABLE_BINS; ++i)
            error_sum += abs (ptable [i] - ntable [i]) >> 8;

        if (error_sum < min_error)
            min_error = error_sum;
        else
            break;
    }

    return rate - 1;
}

static int encode_buffer_high (WavpackStream *wps, int32_t *buffer, int num_samples, unsigned char *destination)
{
    int channel, stereo = (wps->wphdr.flags & MONO_DATA) ? 0 : 1;
    uint32_t crc = 0xffffffff, high = 0xffffffff, low = 0;
    unsigned char *dp = destination, *ep;
    DSDfilters *sp;

    if (num_samples * (stereo + 1) < 280)
        return -1;

    *dp++ = 3;
    ep = destination + num_samples * (stereo + 1) - 10;

    if (!wps->sample_index) {
        if (!wps->dsd.ptable)
            wps->dsd.ptable = malloc (PTABLE_BINS * sizeof (*wps->dsd.ptable));

        init_ptable (wps->dsd.ptable, INITIAL_TERM, RATE_S);

        for (channel = 0; channel < 2; ++channel) {
            sp = wps->dsd.filters + channel;

            sp->filter1 = sp->filter2 = sp->filter3 = sp->filter4 = sp->filter5 = VALUE_ONE / 2;
            sp->filter6 = sp->factor = 0;
        }

        *dp++ = INITIAL_TERM;
        *dp++ = RATE_S;
    }
    else {
        int rate = normalize_ptable (wps->dsd.ptable);
        init_ptable (wps->dsd.ptable, rate, RATE_S);
        *dp++ = rate;
        *dp++ = RATE_S;
    }

    for (channel = 0; channel <= stereo; ++channel) {
        sp = wps->dsd.filters + channel;

        *dp = sp->filter1 >> (PRECISION - 8);
        sp->filter1 = *dp++ << (PRECISION - 8);

        *dp = sp->filter2 >> (PRECISION - 8);
        sp->filter2 = *dp++ << (PRECISION - 8);

        *dp = sp->filter3 >> (PRECISION - 8);
        sp->filter3 = *dp++ << (PRECISION - 8);

        *dp = sp->filter4 >> (PRECISION - 8);
        sp->filter4 = *dp++ << (PRECISION - 8);

        *dp = sp->filter5 >> (PRECISION - 8);
        sp->filter5 = *dp++ << (PRECISION - 8);

        *dp++ = sp->factor;
        *dp++ = sp->factor >> 8;
        sp->filter6 = 0;
        sp->factor = (sp->factor << 16) >> 16;
    }

    sp = wps->dsd.filters;

    while (dp < ep && num_samples--) {
        int bitcount = 8;

        crc += (crc << 1) + (sp->byte = *buffer++ & 0xff);
        sp [0].value = sp [0].filter1 - sp [0].filter5 + ((sp [0].filter6 * sp [0].factor) >> 2);

        if (stereo) {
            crc += (crc << 1) + (sp [1].byte = *buffer++ & 0xff);
            sp [1].value = sp [1].filter1 - sp [1].filter5 + ((sp [1].filter6 * sp [1].factor) >> 2);
        }

        while (bitcount--) {
            int32_t *pp = wps->dsd.ptable + ((sp [0].value >> (PRECISION - PRECISION_USE)) & PTABLE_MASK);

            if (sp [0].byte & 0x80) {
                high = low + ((high - low) >> 8) * (*pp >> 16);
                *pp += (UP - *pp) >> DECAY;
                sp [0].filter0 = -1;
            }
            else {
                low += 1 + ((high - low) >> 8) * (*pp >> 16);
                *pp += (DOWN - *pp) >> DECAY;
                sp [0].filter0 = 0;
            }

            while (DSD_BYTE_READY (high, low)) {
                *dp++ = high >> 24;
                high = (high << 8) | 0xff;
                low <<= 8;
            }

            sp [0].value += sp [0].filter6 << 3;
            sp [0].factor += (((sp [0].value ^ sp [0].filter0) >> 31) | 1) & ((sp [0].value ^ (sp [0].value - (sp [0].filter6 << 4))) >> 31);
            sp [0].filter1 += ((sp [0].filter0 & VALUE_ONE) - sp [0].filter1) >> 6;
            sp [0].filter2 += ((sp [0].filter0 & VALUE_ONE) - sp [0].filter2) >> 4;
            sp [0].filter3 += (sp [0].filter2 - sp [0].filter3) >> 4;
            sp [0].filter4 += (sp [0].filter3 - sp [0].filter4) >> 4;
            sp [0].value = (sp [0].filter4 - sp [0].filter5) >> 4;
            sp [0].filter5 += sp [0].value;
            sp [0].filter6 += (sp [0].value - sp [0].filter6) >> 3;
            sp [0].value = sp [0].filter1 - sp [0].filter5 + ((sp [0].filter6 * sp [0].factor) >> 2);
            sp [0].byte <<= 1;

            if (!stereo)
                continue;

            pp = wps->dsd.ptable + ((sp [1].value >> (PRECISION - PRECISION_USE)) & PTABLE_MASK);

            if (sp [1].byte & 0x80) {
                high = low + ((high - low) >> 8) * (*pp >> 16);
                *pp += (UP - *pp) >> DECAY;
                sp [1].filter0 = -1;
            }
            else {
                low += 1 + ((high - low) >> 8) * (*pp >> 16);
                *pp += (DOWN - *pp) >> DECAY;
                sp [1].filter0 = 0;
            }

            while (DSD_BYTE_READY (high, low)) {
                *dp++ = high >> 24;
                high = (high << 8) | 0xff;
                low <<= 8;
            }

            sp [1].value += sp [1].filter6 << 3;
            sp [1].factor += (((sp [1].value ^ sp [1].filter0) >> 31) | 1) & ((sp [1].value ^ (sp [1].value - (sp [1].filter6 << 4))) >> 31);
            sp [1].filter1 += ((sp [1].filter0 & VALUE_ONE) - sp [1].filter1) >> 6;
            sp [1].filter2 += ((sp [1].filter0 & VALUE_ONE) - sp [1].filter2) >> 4;
            sp [1].filter3 += (sp [1].filter2 - sp [1].filter3) >> 4;
            sp [1].filter4 += (sp [1].filter3 - sp [1].filter4) >> 4;
            sp [1].value = (sp [1].filter4 - sp [1].filter5) >> 4;
            sp [1].filter5 += sp [1].value;
            sp [1].filter6 += (sp [1].value - sp [1].filter6) >> 3;
            sp [1].value = sp [1].filter1 - sp [1].filter5 + ((sp [1].filter6 * sp [1].factor) >> 2);
            sp [1].byte <<= 1;
        }

        sp [0].factor -= (sp->factor + 512) >> 10;

        if (stereo)
            sp [1].factor -= (sp [1].factor + 512) >> 10;
    }

    ((WavpackHeader *) wps->blockbuff)->crc = crc;
    high = low;

    while (DSD_BYTE_READY (high, low)) {
        *dp++ = high >> 24;
        high = (high << 8) | 0xff;
        low <<= 8;
    }

    if (dp < ep)
        return (int)(dp - destination);
    else
        return -1;
}

#endif      // ENABLE_DSD

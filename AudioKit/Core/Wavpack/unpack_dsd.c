////////////////////////////////////////////////////////////////////////////
//                           **** DSDPACK ****                            //
//         Lossless DSD (Direct Stream Digital) Audio Compressor          //
//                Copyright (c) 2013 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack_dsd.c

// This module actually handles the uncompression of the DSD audio data.

#ifdef ENABLE_DSD

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "wavpack_local.h"

///////////////////////////// executable code ////////////////////////////////

// This function initialzes the main range-encoded data for DSD audio samples

static int init_dsd_block_fast (WavpackStream *wps, WavpackMetadata *wpmd);
static int init_dsd_block_high (WavpackStream *wps, WavpackMetadata *wpmd);
static int decode_fast (WavpackStream *wps, int32_t *output, int sample_count);
static int decode_high (WavpackStream *wps, int32_t *output, int sample_count);

int init_dsd_block (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];

    if (wpmd->byte_length < 2)
        return FALSE;

    wps->dsd.byteptr = wpmd->data;
    wps->dsd.endptr = wps->dsd.byteptr + wpmd->byte_length;
    wpc->dsd_multiplier = 1 << *wps->dsd.byteptr++;
    wps->dsd.mode = *wps->dsd.byteptr++;

    if (!wps->dsd.mode) {
        if (wps->dsd.endptr - wps->dsd.byteptr != wps->wphdr.block_samples * (wps->wphdr.flags & MONO_DATA ? 1 : 2)) {
            return FALSE;
        }

        wps->dsd.ready = 1;
        return TRUE;
    }

    if (wps->dsd.mode == 1)
        return init_dsd_block_fast (wps, wpmd);
    else if (wps->dsd.mode == 3)
        return init_dsd_block_high (wps, wpmd);
    else
        return FALSE;
}

int32_t unpack_dsd_samples (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags;

    // don't attempt to decode past the end of the block, but watch out for overflow!

    if (wps->sample_index + sample_count > GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples &&
        GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples - wps->sample_index < sample_count)
            sample_count = (uint32_t) (GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples - wps->sample_index);

    if (GET_BLOCK_INDEX (wps->wphdr) > wps->sample_index || wps->wphdr.block_samples < sample_count)
        wps->mute_error = TRUE;

    if (!wps->mute_error) {
        if (!wps->dsd.mode) {
            int total_samples = sample_count * ((flags & MONO_DATA) ? 1 : 2);
            int32_t *bptr = buffer;

            if (wps->dsd.endptr - wps->dsd.byteptr < total_samples)
                total_samples = (int)(wps->dsd.endptr - wps->dsd.byteptr);

            while (total_samples--)
                wps->crc += (wps->crc << 1) + (*bptr++ = *wps->dsd.byteptr++);
        }
        else if (wps->dsd.mode == 1) {
            if (!decode_fast (wps, buffer, sample_count))
                wps->mute_error = TRUE;
        }
        else if (!decode_high (wps, buffer, sample_count))
            wps->mute_error = TRUE;
    }

    if (wps->mute_error) {
        int samples_to_null;
        if (wpc->reduced_channels == 1 || wpc->config.num_channels == 1 || (flags & MONO_FLAG))
            samples_to_null = sample_count;
        else
            samples_to_null = sample_count * 2;

        while (samples_to_null--)
            *buffer++ = 0x55;

        wps->sample_index += sample_count;
        return sample_count;
    }

    if (flags & FALSE_STEREO) {
        int32_t *dptr = buffer + sample_count * 2;
        int32_t *sptr = buffer + sample_count;
        int32_t c = sample_count;

        while (c--) {
            *--dptr = *--sptr;
            *--dptr = *sptr;
        }
    }

    wps->sample_index += sample_count;

    return sample_count;
}

/*------------------------------------------------------------------------------------------------------------------------*/

// #define DSD_BYTE_READY(low,high) (((low) >> 24) == ((high) >> 24))
// #define DSD_BYTE_READY(low,high) (!(((low) ^ (high)) >> 24))
#define DSD_BYTE_READY(low,high) (!(((low) ^ (high)) & 0xff000000))
#define MAX_HISTORY_BITS    5

static int init_dsd_block_fast (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char history_bits, max_probability;
    int total_summed_probabilities = 0, i;

    if (wps->dsd.byteptr == wps->dsd.endptr)
        return FALSE;

    history_bits = *wps->dsd.byteptr++;

    if (wps->dsd.byteptr == wps->dsd.endptr || history_bits > MAX_HISTORY_BITS)
        return FALSE;

    wps->dsd.history_bins = 1 << history_bits;

    wps->dsd.value_lookup = malloc (sizeof (*wps->dsd.value_lookup) * wps->dsd.history_bins);
    memset (wps->dsd.value_lookup, 0, sizeof (*wps->dsd.value_lookup) * wps->dsd.history_bins);
    wps->dsd.summed_probabilities = malloc (sizeof (*wps->dsd.summed_probabilities) * wps->dsd.history_bins);
    wps->dsd.probabilities = malloc (sizeof (*wps->dsd.probabilities) * wps->dsd.history_bins);

    max_probability = *wps->dsd.byteptr++;

    if (max_probability < 0xff) {
        unsigned char *outptr = (unsigned char *) wps->dsd.probabilities;
        unsigned char *outend = outptr + sizeof (*wps->dsd.probabilities) * wps->dsd.history_bins;

        while (outptr < outend && wps->dsd.byteptr < wps->dsd.endptr) {
            int code = *wps->dsd.byteptr++;

            if (code > max_probability) {
                int zcount = code - max_probability;

                while (outptr < outend && zcount--)
                    *outptr++ = 0;
            }
            else if (code)
                *outptr++ = code;
            else
                break;
        }

        if (outptr < outend || (wps->dsd.byteptr < wps->dsd.endptr && *wps->dsd.byteptr++))
            return FALSE;
    }
    else if (wps->dsd.endptr - wps->dsd.byteptr > (int) sizeof (*wps->dsd.probabilities) * wps->dsd.history_bins) {
        memcpy (wps->dsd.probabilities, wps->dsd.byteptr, sizeof (*wps->dsd.probabilities) * wps->dsd.history_bins);
        wps->dsd.byteptr += sizeof (*wps->dsd.probabilities) * wps->dsd.history_bins;
    }
    else
        return FALSE;

    for (wps->dsd.p0 = 0; wps->dsd.p0 < wps->dsd.history_bins; ++wps->dsd.p0) {
        int32_t sum_values;
        unsigned char *vp;

        for (sum_values = i = 0; i < 256; ++i)
            wps->dsd.summed_probabilities [wps->dsd.p0] [i] = sum_values += wps->dsd.probabilities [wps->dsd.p0] [i];

        if (sum_values) {
            total_summed_probabilities += sum_values;
            vp = wps->dsd.value_lookup [wps->dsd.p0] = malloc (sum_values);

            for (i = 0; i < 256; i++) {
                int c = wps->dsd.probabilities [wps->dsd.p0] [i];

                while (c--)
                    *vp++ = i;
            }
        }
    }

    if (wps->dsd.endptr - wps->dsd.byteptr < 4 || total_summed_probabilities > wps->dsd.history_bins * 1280)
        return FALSE;

    for (i = 4; i--;)
        wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;

    wps->dsd.p0 = wps->dsd.p1 = 0;
    wps->dsd.low = 0; wps->dsd.high = 0xffffffff;
    wps->dsd.ready = 1;

    return TRUE;
}

static int decode_fast (WavpackStream *wps, int32_t *output, int sample_count)
{
    int total_samples = sample_count;

    if (!(wps->wphdr.flags & MONO_DATA))
        total_samples *= 2;

    while (total_samples--) {
        int mult, index, code, i;

        if (!wps->dsd.summed_probabilities [wps->dsd.p0] [255])
            return 0;

        mult = (wps->dsd.high - wps->dsd.low) / wps->dsd.summed_probabilities [wps->dsd.p0] [255];

        if (!mult) {
            if (wps->dsd.endptr - wps->dsd.byteptr >= 4)
                for (i = 4; i--;)
                    wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;

            wps->dsd.low = 0;
            wps->dsd.high = 0xffffffff;
            mult = wps->dsd.high / wps->dsd.summed_probabilities [wps->dsd.p0] [255];

            if (!mult)
                return 0;
        }

        index = (wps->dsd.value - wps->dsd.low) / mult;

        if (index >= wps->dsd.summed_probabilities [wps->dsd.p0] [255])
            return 0;

        if ((*output++ = code = wps->dsd.value_lookup [wps->dsd.p0] [index]))
            wps->dsd.low += wps->dsd.summed_probabilities [wps->dsd.p0] [code-1] * mult;

        wps->dsd.high = wps->dsd.low + wps->dsd.probabilities [wps->dsd.p0] [code] * mult - 1;
        wps->crc += (wps->crc << 1) + code;

        if (wps->wphdr.flags & MONO_DATA)
            wps->dsd.p0 = code & (wps->dsd.history_bins-1);
        else {
            wps->dsd.p0 = wps->dsd.p1;
            wps->dsd.p1 = code & (wps->dsd.history_bins-1);
        }

        while (DSD_BYTE_READY (wps->dsd.high, wps->dsd.low) && wps->dsd.byteptr < wps->dsd.endptr) {
            wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;
            wps->dsd.high = (wps->dsd.high << 8) | 0xff;
            wps->dsd.low <<= 8;
        }
    }

    return sample_count;
}

/*------------------------------------------------------------------------------------------------------------------------*/

#define PTABLE_BITS 8
#define PTABLE_BINS (1<<PTABLE_BITS)
#define PTABLE_MASK (PTABLE_BINS-1)

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

static int init_dsd_block_high (WavpackStream *wps, WavpackMetadata *wpmd)
{
    uint32_t flags = wps->wphdr.flags;
    int channel, rate_i, rate_s, i;

    if (wps->dsd.endptr - wps->dsd.byteptr < ((flags & MONO_DATA) ? 13 : 20))
        return FALSE;

    rate_i = *wps->dsd.byteptr++;
    rate_s = *wps->dsd.byteptr++;

    if (rate_s != RATE_S)
        return FALSE;

    wps->dsd.ptable = malloc (PTABLE_BINS * sizeof (*wps->dsd.ptable));
    init_ptable (wps->dsd.ptable, rate_i, rate_s);

    for (channel = 0; channel < ((flags & MONO_DATA) ? 1 : 2); ++channel) {
        DSDfilters *sp = wps->dsd.filters + channel;

        sp->filter1 = *wps->dsd.byteptr++ << (PRECISION - 8);
        sp->filter2 = *wps->dsd.byteptr++ << (PRECISION - 8);
        sp->filter3 = *wps->dsd.byteptr++ << (PRECISION - 8);
        sp->filter4 = *wps->dsd.byteptr++ << (PRECISION - 8);
        sp->filter5 = *wps->dsd.byteptr++ << (PRECISION - 8);
        sp->filter6 = 0;
        sp->factor = *wps->dsd.byteptr++ & 0xff;
        sp->factor |= (*wps->dsd.byteptr++ << 8) & 0xff00;
        sp->factor = (sp->factor << 16) >> 16;
    }

    wps->dsd.high = 0xffffffff;
    wps->dsd.low = 0x0;

    for (i = 4; i--;)
        wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;

    wps->dsd.ready = 1;

    return TRUE;
}

static int decode_high (WavpackStream *wps, int32_t *output, int sample_count)
{
    int total_samples = sample_count, stereo = (wps->wphdr.flags & MONO_DATA) ? 0 : 1;
    DSDfilters *sp = wps->dsd.filters;

    while (total_samples--) {
        int bitcount = 8;

        sp [0].value = sp [0].filter1 - sp [0].filter5 + ((sp [0].filter6 * sp [0].factor) >> 2);

        if (stereo)
            sp [1].value = sp [1].filter1 - sp [1].filter5 + ((sp [1].filter6 * sp [1].factor) >> 2);

        while (bitcount--) {
            int32_t *pp = wps->dsd.ptable + ((sp [0].value >> (PRECISION - PRECISION_USE)) & PTABLE_MASK);
            uint32_t split = wps->dsd.low + ((wps->dsd.high - wps->dsd.low) >> 8) * (*pp >> 16);

            if (wps->dsd.value <= split) {
                wps->dsd.high = split;
                *pp += (UP - *pp) >> DECAY;
                sp [0].filter0 = -1;
            }
            else {
                wps->dsd.low = split + 1;
                *pp += (DOWN - *pp) >> DECAY;
                sp [0].filter0 = 0;
            }

            while (DSD_BYTE_READY (wps->dsd.high, wps->dsd.low) && wps->dsd.byteptr < wps->dsd.endptr) {
                wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;
                wps->dsd.high = (wps->dsd.high << 8) | 0xff;
                wps->dsd.low <<= 8;
            }

            sp [0].value += sp [0].filter6 << 3;
            sp [0].byte = (sp [0].byte << 1) | (sp [0].filter0 & 1);
            sp [0].factor += (((sp [0].value ^ sp [0].filter0) >> 31) | 1) & ((sp [0].value ^ (sp [0].value - (sp [0].filter6 << 4))) >> 31);
            sp [0].filter1 += ((sp [0].filter0 & VALUE_ONE) - sp [0].filter1) >> 6;
            sp [0].filter2 += ((sp [0].filter0 & VALUE_ONE) - sp [0].filter2) >> 4;
            sp [0].filter3 += (sp [0].filter2 - sp [0].filter3) >> 4;
            sp [0].filter4 += (sp [0].filter3 - sp [0].filter4) >> 4;
            sp [0].value = (sp [0].filter4 - sp [0].filter5) >> 4;
            sp [0].filter5 += sp [0].value;
            sp [0].filter6 += (sp [0].value - sp [0].filter6) >> 3;
            sp [0].value = sp [0].filter1 - sp [0].filter5 + ((sp [0].filter6 * sp [0].factor) >> 2);

            if (!stereo)
                continue;

            pp = wps->dsd.ptable + ((sp [1].value >> (PRECISION - PRECISION_USE)) & PTABLE_MASK);
            split = wps->dsd.low + ((wps->dsd.high - wps->dsd.low) >> 8) * (*pp >> 16);

            if (wps->dsd.value <= split) {
                wps->dsd.high = split;
                *pp += (UP - *pp) >> DECAY;
                sp [1].filter0 = -1;
            }
            else {
                wps->dsd.low = split + 1;
                *pp += (DOWN - *pp) >> DECAY;
                sp [1].filter0 = 0;
            }

            while (DSD_BYTE_READY (wps->dsd.high, wps->dsd.low) && wps->dsd.byteptr < wps->dsd.endptr) {
                wps->dsd.value = (wps->dsd.value << 8) | *wps->dsd.byteptr++;
                wps->dsd.high = (wps->dsd.high << 8) | 0xff;
                wps->dsd.low <<= 8;
            }

            sp [1].value += sp [1].filter6 << 3;
            sp [1].byte = (sp [1].byte << 1) | (sp [1].filter0 & 1);
            sp [1].factor += (((sp [1].value ^ sp [1].filter0) >> 31) | 1) & ((sp [1].value ^ (sp [1].value - (sp [1].filter6 << 4))) >> 31);
            sp [1].filter1 += ((sp [1].filter0 & VALUE_ONE) - sp [1].filter1) >> 6;
            sp [1].filter2 += ((sp [1].filter0 & VALUE_ONE) - sp [1].filter2) >> 4;
            sp [1].filter3 += (sp [1].filter2 - sp [1].filter3) >> 4;
            sp [1].filter4 += (sp [1].filter3 - sp [1].filter4) >> 4;
            sp [1].value = (sp [1].filter4 - sp [1].filter5) >> 4;
            sp [1].filter5 += sp [1].value;
            sp [1].filter6 += (sp [1].value - sp [1].filter6) >> 3;
            sp [1].value = sp [1].filter1 - sp [1].filter5 + ((sp [1].filter6 * sp [1].factor) >> 2);
        }

        wps->crc += (wps->crc << 1) + (*output++ = sp [0].byte & 0xff);
        sp [0].factor -= (sp [0].factor + 512) >> 10;

        if (stereo) {
            wps->crc += (wps->crc << 1) + (*output++ = wps->dsd.filters [1].byte & 0xff);
            wps->dsd.filters [1].factor -= (wps->dsd.filters [1].factor + 512) >> 10;
        }
    }

    return sample_count;
}

/*------------------------------------------------------------------------------------------------------------------------*/

#if 0

// 80 term DSD decimation filter
// < 1 dB down at 20 kHz
// > 108 dB stopband attenuation (fs/16)

static const int32_t decm_filter [] = {
    4, 17, 56, 147, 336, 693, 1320, 2359,
    4003, 6502, 10170, 15392, 22623, 32389, 45275, 61920,
    82994, 109174, 141119, 179431, 224621, 277068, 336983, 404373,
    479004, 560384, 647741, 740025, 835917, 933849, 1032042, 1128551,
    1221329, 1308290, 1387386, 1456680, 1514425, 1559128, 1589610, 1605059,
    1605059, 1589610, 1559128, 1514425, 1456680, 1387386, 1308290, 1221329,
    1128551, 1032042, 933849, 835917, 740025, 647741, 560384, 479004,
    404373, 336983, 277068, 224621, 179431, 141119, 109174, 82994,
    61920, 45275, 32389, 22623, 15392, 10170, 6502, 4003,
    2359, 1320, 693, 336, 147, 56, 17, 4,
};

#define NUM_FILTER_TERMS 80

#else

// 56 term decimation filter
// < 0.5 dB down at 20 kHz
// > 100 dB stopband attenuation (fs/12)

static const int32_t decm_filter [] = {
    4, 17, 56, 147, 336, 692, 1315, 2337,
    3926, 6281, 9631, 14216, 20275, 28021, 37619, 49155,
    62616, 77870, 94649, 112551, 131049, 149507, 167220, 183448,
    197472, 208636, 216402, 220385, 220385, 216402, 208636, 197472,
    183448, 167220, 149507, 131049, 112551, 94649, 77870, 62616,
    49155, 37619, 28021, 20275, 14216, 9631, 6281, 3926,
    2337, 1315, 692, 336, 147, 56, 17, 4,
};

#define NUM_FILTER_TERMS 56

#endif

#define HISTORY_BYTES ((NUM_FILTER_TERMS+7)/8)

typedef struct {
    unsigned char delay [HISTORY_BYTES];
} DecimationChannel;

typedef struct {
    int32_t conv_tables [HISTORY_BYTES] [256];
    DecimationChannel *chans;
    int num_channels;
} DecimationContext;

void *decimate_dsd_init (int num_channels)
{
    DecimationContext *context = malloc (sizeof (DecimationContext));
    double filter_sum = 0, filter_scale;
    int skipped_terms, i, j;

    if (!context)
        return context;

    memset (context, 0, sizeof (*context));
    context->num_channels = num_channels;
    context->chans = malloc (num_channels * sizeof (DecimationChannel));

    if (!context->chans) {
        free (context);
        return NULL;
    }

    for (i = 0; i < NUM_FILTER_TERMS; ++i)
        filter_sum += decm_filter [i];

    filter_scale = ((1 << 23) - 1) / filter_sum * 16.0;
    // fprintf (stderr, "convolution, %d terms, %f sum, %f scale\n", NUM_FILTER_TERMS, filter_sum, filter_scale);

    for (skipped_terms = i = 0; i < NUM_FILTER_TERMS; ++i) {
        int scaled_term = (int) floor (decm_filter [i] * filter_scale + 0.5);

        if (scaled_term) {
            for (j = 0; j < 256; ++j)
                if (j & (0x80 >> (i & 0x7)))
                    context->conv_tables [i >> 3] [j] += scaled_term;
                else
                    context->conv_tables [i >> 3] [j] -= scaled_term;
        }
        else
            skipped_terms++;
    }

    // fprintf (stderr, "%d terms skipped\n", skipped_terms);

    decimate_dsd_reset (context);

    return context;
}

void decimate_dsd_reset (void *decimate_context)
{
    DecimationContext *context = (DecimationContext *) decimate_context;
    int chan = 0, i;

    if (!context)
        return;

    for (chan = 0; chan < context->num_channels; ++chan)
        for (i = 0; i < HISTORY_BYTES; ++i)
            context->chans [chan].delay [i] = 0x55;
}

void decimate_dsd_run (void *decimate_context, int32_t *samples, int num_samples)
{
    DecimationContext *context = (DecimationContext *) decimate_context;
    int chan = 0;

    if (!context)
        return;

    while (num_samples) {
        DecimationChannel *sp = context->chans + chan;
        int sum = 0;

#if (HISTORY_BYTES == 10)
        sum += context->conv_tables [0] [sp->delay [0] = sp->delay [1]];
        sum += context->conv_tables [1] [sp->delay [1] = sp->delay [2]];
        sum += context->conv_tables [2] [sp->delay [2] = sp->delay [3]];
        sum += context->conv_tables [3] [sp->delay [3] = sp->delay [4]];
        sum += context->conv_tables [4] [sp->delay [4] = sp->delay [5]];
        sum += context->conv_tables [5] [sp->delay [5] = sp->delay [6]];
        sum += context->conv_tables [6] [sp->delay [6] = sp->delay [7]];
        sum += context->conv_tables [7] [sp->delay [7] = sp->delay [8]];
        sum += context->conv_tables [8] [sp->delay [8] = sp->delay [9]];
        sum += context->conv_tables [9] [sp->delay [9] = *samples];
#elif (HISTORY_BYTES == 7)
        sum += context->conv_tables [0] [sp->delay [0] = sp->delay [1]];
        sum += context->conv_tables [1] [sp->delay [1] = sp->delay [2]];
        sum += context->conv_tables [2] [sp->delay [2] = sp->delay [3]];
        sum += context->conv_tables [3] [sp->delay [3] = sp->delay [4]];
        sum += context->conv_tables [4] [sp->delay [4] = sp->delay [5]];
        sum += context->conv_tables [5] [sp->delay [5] = sp->delay [6]];
        sum += context->conv_tables [6] [sp->delay [6] = *samples];
#else
        int i;

        for (i = 0; i < HISTORY_BYTES-1; ++i)
            sum += context->conv_tables [i] [sp->delay [i] = sp->delay [i+1]];

        sum += context->conv_tables [i] [sp->delay [i] = *samples];
#endif

        *samples++ = sum >> 4;

        if (++chan == context->num_channels) {
            num_samples--;
            chan = 0;
        }
    }
}

void decimate_dsd_destroy (void *decimate_context)
{
    DecimationContext *context = (DecimationContext *) decimate_context;

    if (!context)
        return;

    if (context->chans)
        free (context->chans);

    free (context);
}

#endif      // ENABLE_DSD

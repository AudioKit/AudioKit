////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack3.c

// This module provides unpacking for WavPack files prior to version 4.0,
// not including "raw" files. As these modes are all obsolete and are no
// longer written, this code will not be fully documented other than the
// global functions. However, full documenation is provided in the version
// 3.97 source code. Note that this module does only the low-level sample
// unpacking; the actual opening of the file (and obtaining information
// from it) is handled in the unpack3_open.c module.

#ifdef ENABLE_LEGACY

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"
#include "unpack3.h"

#define ATTEMPT_ERROR_MUTING

static int bs_open_read3 (Bitstream3 *bs, WavpackStreamReader64 *reader, void *id);
static uint32_t bs_unused_bytes (Bitstream3 *bs);
static unsigned char *bs_unused_data (Bitstream3 *bs);
static void init_words3 (WavpackStream3 *wps);

//////////////////////////////// local macros /////////////////////////////////

#define apply_weight_n(bits, weight, sample) ((weight * sample + (1 << (bits - 1))) >> bits)

#define update_weight_n(bits, weight, source, result) \
    if (source && result) { \
        if ((source ^ result) >= 0) { if (weight++ == (1 << bits)) weight--; } \
        else if (weight-- == min_weight) weight++; \
    }

#define apply_weight24(weight, sample) (((((sample & 0xffff) * weight) >> 7) + \
    (((sample & ~0xffff) >> 7) * weight) + 1) >> 1)

#define update_weight2(weight, source, result) \
    if (source && result) { \
        if ((source ^ result) >= 0) { if (weight++ == 256) weight--; } \
        else if (weight-- == min_weight) weight++; \
    }

//////////////////////////////// local tables ///////////////////////////////

// These three tables specify the characteristics of the decorrelation filters.
// Each term represents one layer of the sequential filter, where positive
// values indicate the relative sample involved from the same channel (1=prev)
// while -1 and -2 indicate cross channel decorrelation (in stereo only). The
// "simple_terms" table is no longer used for writing, but is kept for older
// file decoding.

static const signed char extreme_terms [] = { 1,1,1,2,4,-1,1,2,3,6,-2,8,5,7,4,1,2,3 };
static const signed char default_terms [] = { 1,1,1,-1,2,1,-2 };
static const signed char simple_terms []  = { 1,1,1,1 };

///////////////////////////// executable code ////////////////////////////////

// This function initializes everything required to unpack WavPack
// bitstreams and must be called before any unpacking is performed. Note
// that the (WavpackHeader3 *) in the WavpackStream3 struct must be valid.

void unpack_init3 (WavpackStream3 *wps)
{
    int flags = wps->wphdr.flags;
    struct decorr_pass *dpp;
    int ti;

    CLEAR (wps->decorr_passes);
    CLEAR (wps->dc);

    if (flags & EXTREME_DECORR) {
        for (dpp = wps->decorr_passes, ti = 0; ti < sizeof (extreme_terms); ti++)
            if (extreme_terms [sizeof (extreme_terms) - ti - 1] > 0 || (flags & CROSS_DECORR))
                dpp++->term = extreme_terms [sizeof (extreme_terms) - ti - 1];
    }
    else if (flags & NEW_DECORR_FLAG) {
        for (dpp = wps->decorr_passes, ti = 0; ti < sizeof (default_terms); ti++)
            if (default_terms [sizeof (default_terms) - ti - 1] > 0 || (flags & CROSS_DECORR))
                dpp++->term = default_terms [sizeof (default_terms) - ti - 1];
    }
    else
        for (dpp = wps->decorr_passes, ti = 0; ti < sizeof (simple_terms); ti++)
            dpp++->term = simple_terms [sizeof (simple_terms) - ti - 1];

    wps->num_terms = (int)(dpp - wps->decorr_passes);
    init_words3 (wps);
}

#ifndef NO_SEEKING

// This function returns the size (in bytes) required to save the unpacking
// context. Note that the (WavpackHeader3 *) in the WavpackStream3 struct
// must be valid.

static int unpack_size (WavpackStream3 *wps)
{
    int flags = wps->wphdr.flags, byte_sum = 0, tcount;
    struct decorr_pass *dpp;

    byte_sum += sizeof (wps->wvbits);

    if (flags & WVC_FLAG)
        byte_sum += sizeof (wps->wvcbits);

    if (wps->wphdr.version == 3) {
        if (wps->wphdr.bits)
            byte_sum += sizeof (wps->w4);
        else
            byte_sum += sizeof (wps->w1);

        byte_sum += sizeof (wps->w3) + sizeof (wps->dc.crc);
    }
    else
        byte_sum += sizeof (wps->w2);

    if (wps->wphdr.bits)
        byte_sum += sizeof (wps->dc.error);
    else
        byte_sum += sizeof (wps->dc.sum_level) + sizeof (wps->dc.left_level) +
            sizeof (wps->dc.right_level) + sizeof (wps->dc.diff_level);

    if (flags & OVER_20)
        byte_sum += sizeof (wps->dc.last_extra_bits) + sizeof (wps->dc.extra_bits_count);

    if (!(flags & EXTREME_DECORR)) {
        byte_sum += sizeof (wps->dc.sample);
        byte_sum += sizeof (wps->dc.weight);
    }

    if (flags & (HIGH_FLAG | NEW_HIGH_FLAG))
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
            if (dpp->term > 0) {
                byte_sum += sizeof (dpp->samples_A [0]) * dpp->term;
                byte_sum += sizeof (dpp->weight_A);

                if (!(flags & MONO_FLAG)) {
                    byte_sum += sizeof (dpp->samples_B [0]) * dpp->term;
                    byte_sum += sizeof (dpp->weight_B);
                }
            }
            else {
                byte_sum += sizeof (dpp->samples_A [0]) + sizeof (dpp->samples_B [0]);
                byte_sum += sizeof (dpp->weight_A) + sizeof (dpp->weight_B);
            }
        }

    return byte_sum;
}

// This function saves the unpacking context at the specified pointer and
// returns the updated pointer. The actual amount of data required can be
// determined beforehand by calling unpack_size() but must be allocated by
// the caller.

static void *unpack_save (WavpackStream3 *wps, void *destin)
{
    int flags = wps->wphdr.flags, tcount;
    struct decorr_pass *dpp;

    SAVE (destin, wps->wvbits);

    if (flags & WVC_FLAG)
        SAVE (destin, wps->wvcbits);

    if (wps->wphdr.version == 3) {
        if (wps->wphdr.bits) {
            SAVE (destin, wps->w4);
        }
        else {
            SAVE (destin, wps->w1);
        }

        SAVE (destin, wps->w3);
        SAVE (destin, wps->dc.crc);
    }
    else
        SAVE (destin, wps->w2);

    if (wps->wphdr.bits) {
        SAVE (destin, wps->dc.error);
    }
    else {
        SAVE (destin, wps->dc.sum_level);
        SAVE (destin, wps->dc.left_level);
        SAVE (destin, wps->dc.right_level);
        SAVE (destin, wps->dc.diff_level);
    }

    if (flags & OVER_20) {
        SAVE (destin, wps->dc.last_extra_bits);
        SAVE (destin, wps->dc.extra_bits_count);
    }

    if (!(flags & EXTREME_DECORR)) {
        SAVE (destin, wps->dc.sample);
        SAVE (destin, wps->dc.weight);
    }

    if (flags & (HIGH_FLAG | NEW_HIGH_FLAG))
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
            if (dpp->term > 0) {
                int count = dpp->term;
                int index = wps->dc.m;

                SAVE (destin, dpp->weight_A);

                while (count--) {
                    SAVE (destin, dpp->samples_A [index]);
                    index = (index + 1) & (MAX_TERM - 1);
                }

                if (!(flags & MONO_FLAG)) {
                    count = dpp->term;
                    index = wps->dc.m;

                    SAVE (destin, dpp->weight_B);

                    while (count--) {
                        SAVE (destin, dpp->samples_B [index]);
                        index = (index + 1) & (MAX_TERM - 1);
                    }
                }
            }
            else {
                SAVE (destin, dpp->weight_A);
                SAVE (destin, dpp->weight_B);
                SAVE (destin, dpp->samples_A [0]);
                SAVE (destin, dpp->samples_B [0]);
            }
        }

    return destin;
}

#endif

// This monster actually unpacks the WavPack bitstream(s) into the specified
// buffer as longs, and serves as an extension to WavpackUnpackSamples().
// Note that WavPack files created prior to version 4.0 could only contain 16
// or 24 bit values, and these values are right-justified in the 32-bit values.
// So, if the original file contained 16-bit values, then the range of the
// returned longs would be +/- 32K. For maximum clarity, the function is
// broken up into segments that handle various modes. This makes for a few
// extra infrequent flag checks, but makes the code easier to follow because
// the nesting does not become so deep. For maximum efficiency, the conversion
// is isolated to tight loops that handle an entire buffer.

static int32_t FASTCALL get_word1 (WavpackStream3 *wps, int chan);
static int32_t FASTCALL get_old_word1 (WavpackStream3 *wps, int chan);
static int32_t FASTCALL get_word2 (WavpackStream3 *wps, int chan);
static int32_t FASTCALL get_word3 (WavpackStream3 *wps, int chan);
static int32_t FASTCALL get_word4 (WavpackStream3 *wps, int chan, int32_t *correction);

int32_t unpack_samples3 (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count)
{
    WavpackStream3 *wps = (WavpackStream3 *) wpc->stream3;
    int shift = wps->wphdr.shift, flags = wps->wphdr.flags, min_weight = 0, m = wps->dc.m, tcount;
#ifndef NO_SEEKING
    int points_index = wps->sample_index / (((uint32_t) wpc->total_samples >> 8) + 1);
#endif
    int32_t min_value, max_value, min_shifted, max_shifted;
    int32_t correction [2], crc = wps->dc.crc;
    struct decorr_pass *dpp;
    int32_t read_word, *bptr;
    int32_t sample [2] [2];
    int weight [2] [1];
    unsigned int i;

#ifdef ATTEMPT_ERROR_MUTING
    int32_t mute_limit = (flags & BYTES_3) ? 8388608 : 32768;
    int mute_block = 0;

    if (wps->wphdr.bits && !(flags & WVC_FLAG)) {
        if (wps->wphdr.version < 3)
            mute_limit *= 4;
        else
            mute_limit *= 2;
    }
#endif

    if (wps->sample_index + sample_count > wpc->total_samples)
        sample_count = (uint32_t) (wpc->total_samples - wps->sample_index);

    if (!sample_count)
        return 0;

    if (!wps->sample_index) {
        unpack_init3 (wps);

        bs_open_read3 (&wps->wvbits, wpc->reader, wpc->wv_in);

        if (wpc->wvc_flag)
            bs_open_read3 (&wps->wvcbits, wpc->reader, wpc->wvc_in);
    }

#ifndef NO_SEEKING
    if (!wps->index_points [points_index].saved) {

        if (!wps->unpack_data)
            wps->unpack_data = (unsigned char *) malloc (256 * (wps->unpack_size = unpack_size (wps)));

        wps->index_points [points_index].sample_index = wps->sample_index;
        unpack_save (wps, wps->unpack_data + points_index * wps->unpack_size);
        wps->index_points [points_index].saved = TRUE;
    }
#endif

    memcpy (sample, wps->dc.sample, sizeof (sample));
    memcpy (weight, wps->dc.weight, sizeof (weight));

    if (wps->wphdr.bits) {
        if (flags & (NEW_DECORR_FLAG | EXTREME_DECORR))
            min_weight = -256;
    }
    else
        if (flags & NEW_DECORR_FLAG)
            min_weight = (flags & EXTREME_DECORR) ? -512 : -256;

    if (flags & BYTES_3) {
        min_shifted = (min_value = -8388608 >> shift) << shift;
        max_shifted = (max_value = 8388607 >> shift) << shift;
    }
    else {
        min_shifted = (min_value = -32768 >> shift) << shift;
        max_shifted = (max_value = 32767 >> shift) << shift;
    }

    ///////////////// handle version 3 lossless mono data /////////////////////

    if (wps->wphdr.version == 3 && !wps->wphdr.bits && (flags & MONO_FLAG)) {
        if (flags & FAST_FLAG) {
            if (flags & OVER_20)
                for (bptr = buffer, i = 0; i < sample_count; ++i) {
                    int32_t temp;

                    if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                        break;

                    sample [0] [0] += sample [0] [1] += read_word;
                    getbits (&temp, 4, &wps->wvbits);
                    crc = crc * 3 + (temp = (temp & 0xf) + (sample [0] [0] << 4));
                    *bptr++ = temp;
                }
            else
                for (bptr = buffer, i = 0; i < sample_count; ++i) {
                    if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                        break;

                    crc = crc * 3 + (sample [0] [0] += sample [0] [1] += read_word);
                    *bptr++ = sample [0] [0] << shift;
                }
        }
        else if (flags & HIGH_FLAG)
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t temp;

                if (flags & NEW_HIGH_FLAG) {
                    if ((read_word = get_word1 (wps, 0)) == WORD_EOF)
                        break;
                }
                else {
                    if ((read_word = get_old_word1 (wps, 0)) == WORD_EOF)
                        break;
                }

                if (flags & EXTREME_DECORR)
                    for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                        int32_t sam = dpp->samples_A [m];

                        temp = apply_weight_n (9, dpp->weight_A, sam) + read_word;
                        update_weight_n (9, dpp->weight_A, sam, read_word);
                        dpp->samples_A [(m + dpp->term) & (MAX_TERM - 1)] = read_word = temp;
                    }
                else
                    for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                        int32_t sam = dpp->samples_A [m];

                        temp = apply_weight_n (8, dpp->weight_A, sam) + read_word;
                        update_weight_n (8, dpp->weight_A, sam, read_word);
                        dpp->samples_A [(m + dpp->term) & (MAX_TERM - 1)] = read_word = temp;
                    }

                m = (m + 1) & (MAX_TERM - 1);

                if (flags & OVER_20) {
                    if (wps->dc.extra_bits_count < 8 || !getbit (&wps->wvbits)) {
                        getbits (&temp, 4, &wps->wvbits);

                        if ((temp &= 0xf) != wps->dc.last_extra_bits) {
                            wps->dc.last_extra_bits = temp;
                            wps->dc.extra_bits_count = 0;
                        }
                        else
                            ++wps->dc.extra_bits_count;
                    }

                    crc = crc * 3 + (temp = wps->dc.last_extra_bits + (read_word << 4));
                    *bptr++ = temp;
                }
                else {
                    crc = crc * 3 + read_word;
                    *bptr++ = read_word << shift;
                }
            }
        else
            for (bptr = buffer, i = 0; i < sample_count; ++i) {

                int32_t temp;

                if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                    break;

                temp = sample [0] [0] + ((sample [0] [1] * weight [0] [0] + 128) >> 8) + read_word;

                if ((sample [0] [1] >= 0) == (read_word > 0)) {
                    if (weight [0] [0]++ == 256)
                        weight [0] [0]--;
                }
                else if (weight [0] [0]-- == 0)
                    weight [0] [0]++;

                sample [0] [0] += (sample [0] [1] = temp - sample [0] [0]);

                if (flags & OVER_20) {
                    if (wps->dc.extra_bits_count < 8 || !getbit (&wps->wvbits)) {
                        getbits (&temp, 4, &wps->wvbits);

                        if ((temp &= 0xf) != wps->dc.last_extra_bits) {
                            wps->dc.last_extra_bits = temp;
                            wps->dc.extra_bits_count = 0;
                        }
                        else
                            ++wps->dc.extra_bits_count;
                    }

                    crc = crc * 3 + (*bptr++ = temp = wps->dc.last_extra_bits + (sample [0] [0] << 4));
                }
                else {
                    crc = crc * 3 + sample [0] [0];
                    *bptr++ = sample [0] [0] << shift;
                }
            }
    }

    //////////////// handle version 3 lossless stereo data ////////////////////

    else if (wps->wphdr.version == 3 && !wps->wphdr.bits && !(flags & MONO_FLAG)) {
        int32_t left_level = wps->dc.left_level, right_level = wps->dc.right_level;
        int32_t sum_level = wps->dc.sum_level, diff_level = wps->dc.diff_level;

        if (flags & FAST_FLAG) {
            if (flags & OVER_20)
                for (bptr = buffer, i = 0; i < sample_count; ++i) {
                    int32_t sum, diff, temp;

                    read_word = get_word3 (wps, 0);

                    if (read_word == WORD_EOF)
                        break;

                    sum = (read_word << 1) | ((diff = get_word3 (wps, 1)) & 1);
                    sample [0] [0] += sample [0] [1] += ((sum + diff) >> 1);
                    sample [1] [0] += sample [1] [1] += ((sum - diff) >> 1);
                    getbits (&temp, 8, &wps->wvbits);
                    crc = crc * 3 + (*bptr++ = (sample [0] [0] << 4) + ((temp >> 4) & 0xf));
                    crc = crc * 3 + (*bptr++ = (sample [1] [0] << 4) + (temp & 0xf));
                }
            else
                for (bptr = buffer, i = 0; i < sample_count; ++i) {
                    int32_t sum, diff;

                    read_word = get_word3 (wps, 0);

                    if (read_word == WORD_EOF)
                        break;

                    sum = (read_word << 1) | ((diff = get_word3 (wps, 1)) & 1);
                    sample [0] [1] += ((sum + diff) >> 1);
                    sample [1] [1] += ((sum - diff) >> 1);
                    crc = crc * 3 + (sample [0] [0] += sample [0] [1]);
                    crc = crc * 3 + (sample [1] [0] += sample [1] [1]);
                    *bptr++ = sample [0] [0] << shift;
                    *bptr++ = sample [1] [0] << shift;
                }
        }
        else if (flags & HIGH_FLAG) {
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t sum, left, right, diff, left2, right2, extra_bits, next_word;

                if (flags & CROSS_DECORR) {
                    left = get_word1 (wps, 0);

                    if (left == WORD_EOF)
                        break;

                    right = get_word1 (wps, 1);
                }
                else {
                    if (flags & NEW_HIGH_FLAG) {
                        read_word = get_word1 (wps, 0);

                        if (read_word == WORD_EOF)
                            break;

                        next_word = get_word1 (wps, 1);

                        if (right_level > left_level) {
                            if (left_level + right_level < sum_level + diff_level && right_level < diff_level) {
                                sum = (right = read_word) + (left = next_word);
                                diff = left - right;
                            }
                            else {
                                diff = read_word;

                                if (sum_level < left_level) {
                                    sum = (next_word << 1) | (diff & 1);
                                    left = (sum + diff) >> 1;
                                    right = (sum - diff) >> 1;
                                }
                                else
                                    sum = next_word + (right = (left = next_word) - diff);
                            }
                        }
                        else {
                            if (left_level + right_level < sum_level + diff_level && left_level < diff_level) {
                                sum = (left = read_word) + (right = next_word);
                                diff = left - right;
                            }
                            else {
                                diff = read_word;

                                if (sum_level < right_level) {
                                    sum = (next_word << 1) | (diff & 1);
                                    left = (sum + diff) >> 1;
                                    right = (sum - diff) >> 1;
                                }
                                else
                                    sum = (left = diff + (right = next_word)) + next_word;
                            }
                        }
                    }
                    else {
                        read_word = get_old_word1 (wps, 0);

                        if (read_word == WORD_EOF)
                            break;

                        next_word = get_old_word1 (wps, 1);

                        if (sum_level <= right_level && sum_level <= left_level) {
                            sum = (next_word << 1) | (read_word & 1);
                            left = (sum + read_word) >> 1;
                            right = (sum - read_word) >> 1;
                        }
                        else if (left_level <= right_level)
                            sum = next_word + (right = (left = next_word) - read_word);
                        else
                            sum = next_word + (left = read_word + (right = next_word));

                        diff = left - right;
                    }

                    sum_level = sum_level - (sum_level >> 8) + labs (sum >> 1);
                    left_level = left_level - (left_level >> 8) + labs (left);
                    right_level = right_level - (right_level >> 8) + labs (right);
                    diff_level = diff_level - (diff_level >> 8) + labs (diff);

                    if (flags & JOINT_STEREO) {
                        left = diff;
                        right = sum >> 1;
                    }
                }

                if (flags & EXTREME_DECORR) {
                    for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
                        if (dpp->term > 0) {
                            int32_t sam_A = dpp->samples_A [m], sam_B = dpp->samples_B [m];
                            int k = (m + dpp->term) & (MAX_TERM - 1);

                            left2 = apply_weight_n (9, dpp->weight_A, sam_A) + left;
                            right2 = apply_weight_n (9, dpp->weight_B, sam_B) + right;

                            update_weight_n (9, dpp->weight_A, sam_A, left);
                            update_weight_n (9, dpp->weight_B, sam_B, right);

                            dpp->samples_A [k] = left = left2;
                            dpp->samples_B [k] = right = right2;
                        }
                        else if (dpp->term == -1) {
                            left2 = left + apply_weight_n (9, dpp->weight_A, dpp->samples_A [0]);
                            update_weight_n (9, dpp->weight_A, dpp->samples_A [0], left);
                            left = left2;
                            right2 = right + apply_weight_n (9, dpp->weight_B, left);
                            update_weight_n (9, dpp->weight_B, left, right);
                            dpp->samples_A [0] = right = right2;
                        }
                        else {
                            right2 = right + apply_weight_n (9, dpp->weight_A, dpp->samples_A [0]);
                            update_weight_n (9, dpp->weight_A, dpp->samples_A [0], right);
                            right = right2;
                            left2 = left + apply_weight_n (9, dpp->weight_B, right);
                            update_weight_n (9, dpp->weight_B, right, left);
                            dpp->samples_A [0] = left = left2;
                        }
                }
                else {
                    for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
                        if (dpp->term > 0) {
                            int32_t sam_A = dpp->samples_A [m], sam_B = dpp->samples_B [m];
                            int k = (m + dpp->term) & (MAX_TERM - 1);

                            left2 = apply_weight_n (8, dpp->weight_A, sam_A) + left;
                            right2 = apply_weight_n (8, dpp->weight_B, sam_B) + right;

                            update_weight_n (8, dpp->weight_A, sam_A, left);
                            update_weight_n (8, dpp->weight_B, sam_B, right);

                            dpp->samples_A [k] = left = left2;
                            dpp->samples_B [k] = right = right2;
                        }
                        else if (dpp->term == -1) {
                            left2 = left + apply_weight_n (8, dpp->weight_A, dpp->samples_A [0]);
                            update_weight_n (8, dpp->weight_A, dpp->samples_A [0], left);
                            left = left2;
                            right2 = right + apply_weight_n (8, dpp->weight_B, left);
                            update_weight_n (8, dpp->weight_B, left, right);
                            dpp->samples_A [0] = right = right2;
                        }
                        else {
                            right2 = right + apply_weight_n (8, dpp->weight_A, dpp->samples_A [0]);
                            update_weight_n (8, dpp->weight_A, dpp->samples_A [0], right);
                            right = right2;
                            left2 = left + apply_weight_n (8, dpp->weight_B, right);
                            update_weight_n (8, dpp->weight_B, right, left);
                            dpp->samples_A [0] = left = left2;
                        }
                }

                m = (m + 1) & (MAX_TERM - 1);

                if (flags & JOINT_STEREO) {
                    sum = (right << 1) | ((diff = left) & 1);
                    right = (sum - diff) >> 1;
                    left = (sum + diff) >> 1;
                }

                if (flags & OVER_20) {
                    if (wps->dc.extra_bits_count < 8 || !getbit (&wps->wvbits)) {
                        getbits (&extra_bits, 8, &wps->wvbits);

                        if ((extra_bits &= 0xff) != wps->dc.last_extra_bits) {
                            wps->dc.last_extra_bits = extra_bits;
                            wps->dc.extra_bits_count = 0;
                        }
                        else
                            ++wps->dc.extra_bits_count;
                    }

                    crc = crc * 3 + (*bptr++ = left = (left << 4) + (wps->dc.last_extra_bits >> 4));
                    crc = crc * 3 + (*bptr++ = right = (right << 4) + (wps->dc.last_extra_bits & 0xf));
                }
                else {
                    crc = crc * 9 + left * 3 + right;
                    *bptr++ = left << shift;
                    *bptr++ = right << shift;
                }
            }
        }
        else
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t sum, left, right, left2, right2, extra_bits;

                read_word = get_word3 (wps, 0);

                if (read_word == WORD_EOF)
                    break;

                if (sum_level <= right_level && sum_level <= left_level) {
                    sum = (get_word3 (wps, 1) << 1) | (read_word & 1);
                    left = (sum + read_word) >> 1;
                    right = (sum - read_word) >> 1;
                }
                else if (left_level <= right_level) {
                    right = (left = get_word3 (wps, 1)) - read_word;
                    sum = left + right;
                }
                else {
                    left = read_word + (right = get_word3 (wps, 1));
                    sum = right + left;
                }

                sum_level = sum_level - (sum_level >> 8) + labs (sum >> 1);
                left_level = left_level - (left_level >> 8) + labs (left);
                right_level = right_level - (right_level >> 8) + labs (right);

                left2 = sample [0] [0] + ((sample [0] [1] * weight [0] [0] + 128) >> 8) + left;
                right2 = sample [1] [0] + ((sample [1] [1] * weight [1] [0] + 128) >> 8) + right;

                if ((sample [0] [1] >= 0) == (left > 0)) {
                    if (weight [0] [0]++ == 256)
                        weight [0] [0]--;
                }
                else if (weight [0] [0]-- == 0)
                    weight [0] [0]++;

                if ((sample [1] [1] >= 0) == (right > 0)) {
                    if (weight [1] [0]++ == 256)
                        weight [1] [0]--;
                }
                else if (weight [1] [0]-- == 0)
                    weight [1] [0]++;

                sample [0] [0] += (sample [0] [1] = left2 - sample [0] [0]);
                sample [1] [0] += (sample [1] [1] = right2 - sample [1] [0]);

                if (flags & OVER_20) {
                    if (wps->dc.extra_bits_count < 8 || !getbit (&wps->wvbits)) {
                        getbits (&extra_bits, 8, &wps->wvbits);

                        if ((extra_bits &= 0xff) != wps->dc.last_extra_bits) {
                            wps->dc.last_extra_bits = extra_bits;
                            wps->dc.extra_bits_count = 0;
                        }
                        else
                            ++wps->dc.extra_bits_count;
                    }

                    crc = crc * 3 + (*bptr++ = left2 = (sample [0] [0] << 4) + (wps->dc.last_extra_bits >> 4));
                    crc = crc * 3 + (*bptr++ = right2 = (sample [1] [0] << 4) + (wps->dc.last_extra_bits & 0xf));
                }
                else {
                    crc = crc * 9 + sample [0] [0] * 3 + sample [1] [0];
                    *bptr++ = sample [0] [0] << shift;
                    *bptr++ = sample [1] [0] << shift;
                }
            }

        wps->dc.left_level = left_level;
        wps->dc.right_level = right_level;
        wps->dc.sum_level = sum_level;
        wps->dc.diff_level = diff_level;
    }

    //////////////// handle version 3 lossy/hybrid mono data //////////////////

    else if (wps->wphdr.version == 3 && wps->wphdr.bits && (flags & MONO_FLAG)) {
        if (flags & FAST_FLAG)
            for (bptr = buffer, i = 0; i < sample_count; ++i) {

                if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                    break;

                crc = crc * 3 + (sample [0] [0] += sample [0] [1] += read_word);

                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [0] [0] << shift;
            }
        else if (flags & (HIGH_FLAG | NEW_HIGH_FLAG))
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t temp;

                read_word = (flags & NEW_HIGH_FLAG) ?
                    get_word4 (wps, 0, correction) : get_word3 (wps, 0);

                if (read_word == WORD_EOF)
                    break;

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                    int32_t sam = dpp->samples_A [m];

                    temp = apply_weight24 (dpp->weight_A, sam) + read_word;
                    update_weight2 (dpp->weight_A, sam, read_word);
                    dpp->samples_A [(m + dpp->term) & (MAX_TERM - 1)] = read_word = temp;
                }

                m = (m + 1) & (MAX_TERM - 1);

                if (flags & WVC_FLAG) {
                    if (flags & LOSSY_SHAPE) {
                        crc = crc * 3 + (read_word += correction [0] + wps->dc.error [0]);
                        wps->dc.error [0] = -correction [0];
                    }
                    else
                        crc = crc * 3 + (read_word += correction [0]);

                    *bptr++ = read_word << shift;
                }
                else {
                    crc = crc * 3 + read_word;

                    if (read_word < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (read_word < -mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = min_shifted;
                    }
                    else if (read_word > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (read_word > mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = max_shifted;
                    }
                    else
                        *bptr++ = read_word << shift;
                }
            }
        else
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t new_sample;

                if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                    break;

                new_sample = sample [0] [0] + ((sample [0] [1] * weight [0] [0] + 128) >> 8) + read_word;

                if ((sample [0] [1] >= 0) == (read_word > 0)) {
                    if (weight [0] [0]++ == 256)
                        weight [0] [0]--;
                }
                else if (weight [0] [0]-- == 0)
                    weight [0] [0]++;

                sample [0] [1] = new_sample - sample [0] [0];
                crc = crc * 3 + (sample [0] [0] = new_sample);

                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [0] [0] << shift;
            }
    }

    //////////////// handle version 3 lossy/hybrid stereo data ////////////////

    else if (wps->wphdr.version == 3 && wps->wphdr.bits && !(flags & MONO_FLAG)) {
        if (flags & FAST_FLAG)
            for (bptr = buffer, i = 0; i < sample_count; ++i) {

                if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                    break;

                crc = crc * 3 + (sample [0] [0] += sample [0] [1] += read_word);

                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [0] [0] << shift;

                crc = crc * 3 + (sample [1] [0] += sample [1] [1] += get_word3 (wps, 1));

                if (sample [1] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [1] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [1] [0] << shift;
            }
        else if (flags & (HIGH_FLAG | NEW_HIGH_FLAG))
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t left, right, left2, right2, sum, diff;

                if (flags & NEW_HIGH_FLAG) {
                    left = get_word4 (wps, 0, correction);
                    right = get_word4 (wps, 1, correction + 1);
                }
                else {
                    left = get_word3 (wps, 0);
                    right = get_word3 (wps, 1);
                }

                if (left == WORD_EOF)
                    break;

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                    int32_t sam_A = dpp->samples_A [m], sam_B = dpp->samples_B [m];
                    int k = (m + dpp->term) & (MAX_TERM - 1);

                    left2 = apply_weight24 (dpp->weight_A, sam_A) + left;
                    update_weight2 (dpp->weight_A, sam_A, left);
                    dpp->samples_A [k] = left = left2;

                    right2 = apply_weight24 (dpp->weight_B, sam_B) + right;
                    update_weight2 (dpp->weight_B, sam_B, right);
                    dpp->samples_B [k] = right = right2;
                }

                m = (m + 1) & (MAX_TERM - 1);

                if (flags & WVC_FLAG) {
                    if (flags & LOSSY_SHAPE) {
                        left += correction [0] + wps->dc.error [0];
                        right += correction [1] + wps->dc.error [1];
                        wps->dc.error [0] = -correction [0];
                        wps->dc.error [1] = -correction [1];
                    }
                    else {
                        left += correction [0];
                        right += correction [1];
                    }
                }

                if (flags & JOINT_STEREO) {
                    right = ((sum = (right << 1) | (left & 1)) - (diff = left)) >> 1;
                    left = (sum + diff) >> 1;
                }

                crc = crc * 9 + left * 3 + right;

                if (flags & WVC_FLAG) {
                    *bptr++ = left << shift;
                    *bptr++ = right << shift;
                }
                else {
                    if (left < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (left < -mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = min_shifted;
                    }
                    else if (left > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (left > mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = max_shifted;
                    }
                    else
                        *bptr++ = left << shift;

                    if (right < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (right < -mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = min_shifted;
                    }
                    else if (right > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                        if (right > mute_limit)
                            mute_block = 1;
#endif
                        *bptr++ = max_shifted;
                    }
                    else
                        *bptr++ = right << shift;
                }
            }
        else
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t new_sample;

                if ((read_word = get_word3 (wps, 0)) == WORD_EOF)
                    break;

                new_sample = sample [0] [0] + ((sample [0] [1] * weight [0] [0] + 128) >> 8) + read_word;

                if ((sample [0] [1] >= 0) == (read_word > 0)) {
                    if (weight [0] [0]++ == 256)
                        weight [0] [0]--;
                }
                else if (weight [0] [0]-- == 0)
                    weight [0] [0]++;

                sample [0] [1] = new_sample - sample [0] [0];
                crc = crc * 3 + (sample [0] [0] = new_sample);

                read_word = get_word3 (wps, 1);
                new_sample = sample [1] [0] + ((sample [1] [1] * weight [1] [0] + 128) >> 8) + read_word;

                if ((sample [1] [1] >= 0) == (read_word > 0)) {
                    if (weight [1] [0]++ == 256)
                        weight [1] [0]--;
                }
                else if (weight [1] [0]-- == 0)
                    weight [1] [0]++;

                sample [1] [1] = new_sample - sample [1] [0];
                crc = crc * 3 + (sample [1] [0] = new_sample);

                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [0] [0] << shift;

                if (sample [1] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = min_shifted;
                }
                else if (sample [1] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] > mute_limit)
                        mute_block = 1;
#endif
                    *bptr++ = max_shifted;
                }
                else
                    *bptr++ = sample [1] [0] << shift;
            }
    }

    //////////////////// finally, handle version 2 data ///////////////////////

    else if (wps->wphdr.version == 2 && (flags & MONO_FLAG))
        for (bptr = buffer, i = 0; i < sample_count; ++i) {
            if ((read_word = get_word2 (wps, 0)) == WORD_EOF)
                break;

            sample [0] [0] += sample [0] [1] += read_word;

            if (wps->wphdr.bits) {
                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    sample [0] [0] = min_value;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    sample [0] [0] = max_value;
                }
            }

            *bptr++ = sample [0] [0] << shift;
        }
    else if (wps->wphdr.version < 3 && !(flags & MONO_FLAG))
        for (bptr = buffer, i = 0; i < sample_count; ++i) {
            int32_t sum, diff;

            read_word = get_word2 (wps, 0);

            if (read_word == WORD_EOF)
                break;

            sum = (read_word << 1) | ((diff = get_word2 (wps, 1)) & 1);
            sample [0] [0] += sample [0] [1] += ((sum + diff) >> 1);
            sample [1] [0] += sample [1] [1] += ((sum - diff) >> 1);

            if (wps->wphdr.bits) {
                if (sample [0] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    sample [0] [0] = min_value;
                }
                else if (sample [0] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [0] [0] > mute_limit)
                        mute_block = 1;
#endif
                    sample [0] [0] = max_value;
                }

                if (sample [1] [0] < min_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] < -mute_limit)
                        mute_block = 1;
#endif
                    sample [1] [0] = min_value;
                }
                else if (sample [1] [0] > max_value) {
#ifdef ATTEMPT_ERROR_MUTING
                    if (sample [1] [0] > mute_limit)
                        mute_block = 1;
#endif
                    sample [1] [0] = max_value;
                }
            }

            *bptr++ = sample [0] [0] << shift;
            *bptr++ = sample [1] [0] << shift;
        }
    else
        i = 0;  /* can't get here, but suppresses warning */

#ifdef ATTEMPT_ERROR_MUTING
    if (!wps->wphdr.bits || (flags & WVC_FLAG)) {
        int32_t *eptr = buffer + sample_count * ((flags & MONO_FLAG) ? 1 : 2);

        for (bptr = buffer; bptr < eptr; bptr += 3)
            if (*bptr > mute_limit || *bptr < -mute_limit) {
                mute_block = 1;
                break;
            }
    }

    if (mute_block)
        memset (buffer, 0, sizeof (*buffer) * sample_count * ((flags & MONO_FLAG) ? 1 : 2));
#endif

    if (i && (wps->sample_index += i) == wpc->total_samples) {

        if (wps->wphdr.version == 3 && crc != (wpc->wvc_flag ? wps->wphdr.crc2 : wps->wphdr.crc))
            wpc->crc_errors++;

        if (wpc->open_flags & OPEN_WRAPPER) {
            unsigned char *temp = malloc (1024);
            uint32_t bcount;

            if (bs_unused_bytes (&wps->wvbits)) {
                wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + bs_unused_bytes (&wps->wvbits));
                memcpy (wpc->wrapper_data + wpc->wrapper_bytes, bs_unused_data (&wps->wvbits), bs_unused_bytes (&wps->wvbits));
                wpc->wrapper_bytes += bs_unused_bytes (&wps->wvbits);
            }

            while (1) {
                bcount = wpc->reader->read_bytes (wpc->wv_in, temp, 1024);

                if (!bcount)
                    break;

                wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + bcount);
                memcpy (wpc->wrapper_data + wpc->wrapper_bytes, temp, bcount);
                wpc->wrapper_bytes += bcount;
            }

            free (temp);

            if (wpc->wrapper_bytes > 16) {
                int c;

                for (c = 0; c < 16 && wpc->wrapper_data [c] == 0xff; ++c);

                if (c == 16) {
                    memmove (wpc->wrapper_data, wpc->wrapper_data + 16, wpc->wrapper_bytes - 16);
                    wpc->wrapper_bytes -= 16;
                }
                else {
                    free (wpc->wrapper_data);
                    wpc->wrapper_data = NULL;
                    wpc->wrapper_bytes = 0;
                }
            }
        }
    }

    memcpy (wps->dc.sample, sample, sizeof (sample));
    memcpy (wps->dc.weight, weight, sizeof (weight));
    wps->dc.crc = crc;
    wps->dc.m = m;

    return i;
}

// This function initializes everything required to receive words with this
// module and must be called BEFORE any other function in this module.

static void init_words3 (WavpackStream3 *wps)
{
    CLEAR (wps->w1);
    CLEAR (wps->w2);
    CLEAR (wps->w3);
    CLEAR (wps->w4);

    if (wps->wphdr.flags & MONO_FLAG)
        wps->w4.bitrate = wps->wphdr.bits - 768;
    else
        wps->w4.bitrate = (wps->wphdr.bits / 2) - 768;
}

static int32_t FASTCALL get_word1 (WavpackStream3 *wps, int chan)
{
    uint32_t tmp1, tmp2, avalue;
    unsigned int ones_count;
    int k;

    if ((wps->wphdr.flags & EXTREME_DECORR) && !(wps->wphdr.flags & OVER_20)) {
        if (wps->w1.zeros_acc) {
            if (--wps->w1.zeros_acc)
                return 0;
        }
        else if (wps->w1.ave_level [0] [0] < 0x20 && wps->w1.ave_level [0] [1] < 0x20) {
            int32_t mask;
            int cbits;

            for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

            if (cbits == 33)
                return WORD_EOF;

            if (cbits < 2)
                wps->w1.zeros_acc = cbits;
            else {
                for (mask = 1, wps->w1.zeros_acc = 0; --cbits; mask <<= 1)
                    if (getbit (&wps->wvbits))
                        wps->w1.zeros_acc |= mask;

                wps->w1.zeros_acc |= mask;
            }

            if (wps->w1.zeros_acc)
                return 0;
        }
    }

    // count consecutive ones in bitstream, > 25 indicates error (or EOF)

    for (ones_count = 0; ones_count < 25 && getbit (&wps->wvbits); ++ones_count);

    if (ones_count == 25)
        return WORD_EOF;

    k = (wps->w1.ave_level [0] [chan] + (wps->w1.ave_level [0] [chan] >> 3) + 0x40) >> 7;
    k = count_bits (k);

    if (k & ~31)
        return WORD_EOF;

    if (ones_count == 0) {
        getbits (&avalue, k, &wps->wvbits);
        avalue &= bitmask [k];
    }
    else {
        tmp1 = bitset [k];
        k = (wps->w1.ave_level [1] [chan] + (wps->w1.ave_level [1] [chan] >> 4) + 0x20) >> 6;
        k = count_bits (k);

        if (k & ~31)
            return WORD_EOF;

        if (ones_count == 1) {
            getbits (&avalue, k, &wps->wvbits);
            avalue &= bitmask [k];
        }
        else {
            tmp2 = bitset [k];

            // If the ones count is exactly 24, then next 24 bits are literal

            if (ones_count == 24) {
                getbits (&avalue, 24, &wps->wvbits);
                avalue &= 0xffffff;
            }
            else {
                k = (wps->w1.ave_level [2] [chan] + 0x10) >> 5;
                k = count_bits (k);

                if (k & ~31)
                    return WORD_EOF;

                getbits (&avalue, k, &wps->wvbits);
                avalue = (avalue & bitmask [k]) + (bitset [k] * (ones_count - 2));
            }

            wps->w1.ave_level [2] [chan] -= ((wps->w1.ave_level [2] [chan] + 0x8) >> 4);
            wps->w1.ave_level [2] [chan] += avalue;
            avalue += tmp2;
        }

        wps->w1.ave_level [1] [chan] -= ((wps->w1.ave_level [1] [chan] + 0x10) >> 5);
        wps->w1.ave_level [1] [chan] += avalue;
        avalue += tmp1;
    }

    wps->w1.ave_level [0] [chan] -= ((wps->w1.ave_level [0] [chan] + 0x20) >> 6);
    wps->w1.ave_level [0] [chan] += avalue;

    return (avalue && getbit (&wps->wvbits)) ? -(int32_t)avalue : avalue;
}

#define NUM_SAMPLES 128

static int32_t FASTCALL get_old_word1 (WavpackStream3 *wps, int chan)
{
    uint32_t avalue;
    unsigned int bc;
    int k;

    if (!wps->w1.index [chan]) {

        int guess_k = (wps->w1.ave_k [chan] + 128) >> 8, ones;

        for (ones = 0; ones < 72 && getbit (&wps->wvbits); ++ones);

        if (ones == 72)
            return WORD_EOF;

        if (ones % 3 == 1)
            wps->w1.k_value [chan] = guess_k - (ones / 3) - 1;
        else
            wps->w1.k_value [chan] = guess_k + ones - ((ones + 1) / 3);

        wps->w1.ave_k [chan] -= (wps->w1.ave_k [chan] + 0x10) >> 5;
        wps->w1.ave_k [chan] += wps->w1.k_value [chan] << 3;
    }

    if (++wps->w1.index [chan] == NUM_SAMPLES)
        wps->w1.index [chan] = 0;

    k = wps->w1.k_value [chan];
    getbits (&avalue, k, &wps->wvbits);

    for (bc = 0; bc < 32 && getbit (&wps->wvbits); ++bc);

    if (bc == 32 || (k & ~31))
        return WORD_EOF;

    avalue = (avalue & bitmask [k]) + bitset [k] * bc;
    return (avalue && getbit (&wps->wvbits)) ? -(int32_t)avalue : avalue;
}

static int32_t FASTCALL get_word2 (WavpackStream3 *wps, int chan)
{
    int cbits, delta_dbits, dbits;
    int32_t value, mask = 1;

    cbits = 0;

    while (getbit (&wps->wvbits))
        if ((cbits += 2) == 50)
            return WORD_EOF;

    if (getbit (&wps->wvbits))
        cbits++;

    if (cbits == 0)
        delta_dbits = 0;
    else if (cbits & 1) {
        delta_dbits = (cbits + 1) / 2;

        if (wps->w2.last_delta_sign [chan] > 0)
            delta_dbits *= -1;

        wps->w2.last_delta_sign [chan] = delta_dbits;
    }
    else {
        delta_dbits = cbits / 2;

        if (wps->w2.last_delta_sign [chan] <= 0)
            delta_dbits *= -1;
    }

    dbits = (wps->w2.last_dbits [chan] += delta_dbits);

    if (dbits < 0 || dbits > 20)
        return WORD_EOF;

    if (!dbits)
        return 0L;

    if (wps->wphdr.bits) {
        for (value = 1L << (dbits - 1); --dbits; mask <<= 1)
            if (dbits < wps->wphdr.bits && getbit (&wps->wvbits))
                value |= mask;
    }
    else
        for (value = 1L << (dbits - 1); --dbits; mask <<= 1)
            if (getbit (&wps->wvbits))
                value |= mask;

    return getbit (&wps->wvbits) ? -(int32_t)value : value;
}

static int32_t FASTCALL get_word3 (WavpackStream3 *wps, int chan)
{
    int cbits, delta_dbits, dbits;
    int32_t value;

    for (cbits = 0; cbits < 72 && getbit (&wps->wvbits); ++cbits);

    if (cbits == 72)
        return WORD_EOF;

    if (cbits || getbit (&wps->wvbits))
        ++cbits;

    if (!((cbits + 1) % 3))
        delta_dbits = (cbits + 1) / 3;
    else
        delta_dbits = -(cbits - cbits / 3);

    if (chan) {
        dbits = (wps->w3.ave_dbits [1] >> 8) + 1 + delta_dbits;
        wps->w3.ave_dbits [1] -= (wps->w3.ave_dbits [1] + 0x10) >> 5;
        wps->w3.ave_dbits [1] += dbits << 3;
    }
    else {
        dbits = (wps->w3.ave_dbits [0] >> 8) + 1 + delta_dbits;
        wps->w3.ave_dbits [0] -= (wps->w3.ave_dbits [0] + 0x10) >> 5;
        wps->w3.ave_dbits [0] += dbits << 3;
    }

    if (dbits < 0 || dbits > 24)
        return WORD_EOF;

    if (!dbits)
        return 0L;

    if (wps->wphdr.bits && dbits > wps->wphdr.bits) {
        getbits (&value, wps->wphdr.bits, &wps->wvbits);

        if (value & bitset [wps->wphdr.bits - 1])
            return -(int32_t)(value & bitmask [wps->wphdr.bits]) << (dbits - wps->wphdr.bits);
        else
            return ((value & bitmask [wps->wphdr.bits - 1]) | bitset [wps->wphdr.bits - 1]) << (dbits - wps->wphdr.bits);
    }
    else {
        getbits (&value, dbits, &wps->wvbits);

        if (value & bitset [dbits - 1])
            return -(int32_t)(value & bitmask [dbits]);
        else
            return (value & bitmask [dbits - 1]) | bitset [dbits - 1];
    }
}

static int FASTCALL wp3_log2 (uint32_t avalue);

static int32_t FASTCALL get_word4 (WavpackStream3 *wps, int chan, int32_t *correction)
{
    uint32_t base, ones_count, avalue;
    int32_t value, low, mid, high;
    int bitcount;

    // count consecutive ones in bitstream, > 25 indicates error (or EOF)

    for (ones_count = 0; ones_count < 25 && getbit (&wps->wvbits); ++ones_count);

    if (ones_count == 25)
        return WORD_EOF;

    // if the ones count is exactly 24, then we switch to non-unary method

    if (ones_count == 24) {
        int32_t mask;
        int cbits;

        for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

        if (cbits == 33)
            return WORD_EOF;

        if (cbits < 2)
            ones_count = cbits;
        else {
            for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                if (getbit (&wps->wvbits))
                    ones_count |= mask;

            ones_count |= mask;
        }

        ones_count += 24;
    }

    if (!chan) {
        int slow_log_0, slow_log_1, balance;

        if (wps->wphdr.flags & MONO_FLAG) {
            wps->w4.bits_acc [0] += wps->w4.bitrate + wp3_log2 (wps->w4.fast_level [0]) - wp3_log2 (wps->w4.slow_level [0]) + (3 << 8);

            if (wps->w4.bits_acc [0] < 0)
                wps->w4.bits_acc [0] = 0;
        }
        else {
            slow_log_0 = wp3_log2 (wps->w4.slow_level [0]);
            slow_log_1 = wp3_log2 (wps->w4.slow_level [1]);

            if (wps->wphdr.flags & JOINT_STEREO)
                balance = (slow_log_1 - slow_log_0 + 257) >> 1;
            else
                balance = (slow_log_1 - slow_log_0 + 1) >> 1;

            wps->w4.bits_acc [0] += wps->w4.bitrate - balance + wp3_log2 (wps->w4.fast_level [0]) - slow_log_0 + (3 << 8);
            wps->w4.bits_acc [1] += wps->w4.bitrate + balance + wp3_log2 (wps->w4.fast_level [1]) - slow_log_1 + (3 << 8);

            if (wps->w4.bits_acc [0] + wps->w4.bits_acc [1] < 0)
                wps->w4.bits_acc [0] = wps->w4.bits_acc [1] = 0;
            else if (wps->w4.bits_acc [0] < 0) {
                wps->w4.bits_acc [1] += wps->w4.bits_acc [0];
                wps->w4.bits_acc [0] = 0;
            }
            else if (wps->w4.bits_acc [1] < 0) {
                wps->w4.bits_acc [0] += wps->w4.bits_acc [1];
                wps->w4.bits_acc [1] = 0;
            }
        }
    }

    base = (wps->w4.fast_level [chan] + 48) / 96;
    bitcount = wps->w4.bits_acc [chan] >> 8;
    wps->w4.bits_acc [chan] &= 0xff;

    if (!base) {
        if (ones_count)
            high = low = mid = (getbit (&wps->wvbits)) ? -(int32_t)ones_count : ones_count;
        else
            high = low = mid = 0;
    }
    else {
        mid = (ones_count * 2 + 1) * base;
        if (getbit (&wps->wvbits)) mid = -mid;
        low = mid - base;
        high = mid + base - 1;

        while (bitcount--) {
            if (getbit (&wps->wvbits))
                mid = (high + (low = mid) + 1) >> 1;
            else
                mid = ((high = mid - 1) + low + 1) >> 1;

            if (high == low)
                break;
        }
    }

    wps->w4.fast_level [chan] -= ((wps->w4.fast_level [chan] + 0x10) >> 5);
    wps->w4.fast_level [chan] += (avalue = labs (mid));
    wps->w4.slow_level [chan] -= ((wps->w4.slow_level [chan] + 0x80) >> 8);
    wps->w4.slow_level [chan] += avalue;

    if (bs_is_open (&wps->wvcbits)) {

        if (high != low) {
            uint32_t maxcode = high - low;
            int bitcount = count_bits (maxcode);
            uint32_t extras = (1L << bitcount) - maxcode - 1;

            getbits (&avalue, bitcount - 1, &wps->wvcbits);
            avalue &= bitmask [bitcount - 1];

            if (avalue >= extras) {
                avalue = (avalue << 1) - extras;

                if (getbit (&wps->wvcbits))
                    ++avalue;
            }

            value = (mid < 0) ? high - avalue : avalue + low;

            if (correction)
                *correction = value - mid;
        }
        else if (correction)
            *correction = 0;
    }

    return mid;
}

// This function calculates an approximate base-2 logarithm (with 8 bits of
// fraction) from the supplied value. Using logarithms makes comparing
// signal level values and calculating fractional bitrates much easier.

static int FASTCALL wp3_log2 (uint32_t avalue)
{
    int dbits;

    if ((avalue += avalue >> 9) < (1 << 8)) {
        dbits = nbits_table [avalue];
        return (dbits << 8) + ((avalue << (9 - dbits)) & 0xff);
    }
    else {
        if (avalue < (1L << 16))
            dbits = nbits_table [avalue >> 8] + 8;
        else if (avalue < (1L << 24))
            dbits = nbits_table [avalue >> 16] + 16;
        else
            dbits = nbits_table [avalue >> 24] + 24;

        return (dbits << 8) + ((avalue >> (dbits - 9)) & 0xff);
    }
}

static void bs_read3 (Bitstream3 *bs)
{
    uint32_t bytes_read;

    bytes_read = bs->reader->read_bytes (bs->id, bs->buf, bs->bufsiz);
    bs->end = bs->buf + bytes_read;
    bs->fpos += bytes_read;

    if (bs->end == bs->buf) {
        memset (bs->buf, -1, bs->bufsiz);
        bs->end += bs->bufsiz;
    }

    bs->ptr = bs->buf;
}

// Open the specified BitStream and associate with the specified file. The
// "bufsiz" field of the structure must be preset with the desired buffer
// size and the file's read pointer must be set to where the desired bit
// data is located.  A return value of TRUE indicates an error in
// allocating buffer space.

static int bs_open_read3 (Bitstream3 *bs, WavpackStreamReader64 *reader, void *id)
{
    bs->fpos = (bs->reader = reader)->get_pos (bs->id = id);

    if (!bs->buf)
        bs->buf = (unsigned char *) malloc (bs->bufsiz);

    bs->end = bs->buf + bs->bufsiz;
    bs->ptr = bs->end - 1;
    bs->sr = bs->bc = 0;
    bs->error = bs->buf ? 0 : 1;
    bs->wrap = bs_read3;
    return bs->error;
}

static uint32_t bs_unused_bytes (Bitstream3 *bs)
{
    if (bs->bc < 8) {
        bs->bc += 8;
        bs->ptr++;
    }

    return (uint32_t)(bs->end - bs->ptr);
}

static unsigned char *bs_unused_data (Bitstream3 *bs)
{
    if (bs->bc < 8) {
        bs->bc += 8;
        bs->ptr++;
    }

    return bs->ptr;
}

#endif  // ENABLE_LEGACY


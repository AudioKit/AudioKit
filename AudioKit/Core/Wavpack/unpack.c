////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack.c

// This module actually handles the decompression of the audio data, except for
// the entropy decoding which is handled by the read_words.c module. For better
// efficiency, the conversion is isolated to tight loops that handle an entire
// buffer.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

#ifdef OPT_ASM_X86
    #define DECORR_STEREO_PASS_CONT unpack_decorr_stereo_pass_cont_x86
    #define DECORR_STEREO_PASS_CONT_AVAILABLE unpack_cpu_has_feature_x86(CPU_FEATURE_MMX)
    #define DECORR_MONO_PASS_CONT unpack_decorr_mono_pass_cont_x86
#elif defined(OPT_ASM_X64) && (defined (_WIN64) || defined(__CYGWIN__) || defined(__MINGW64__))
    #define DECORR_STEREO_PASS_CONT unpack_decorr_stereo_pass_cont_x64win
    #define DECORR_STEREO_PASS_CONT_AVAILABLE 1
    #define DECORR_MONO_PASS_CONT unpack_decorr_mono_pass_cont_x64win
#elif defined(OPT_ASM_X64)
    #define DECORR_STEREO_PASS_CONT unpack_decorr_stereo_pass_cont_x64
    #define DECORR_STEREO_PASS_CONT_AVAILABLE 1
    #define DECORR_MONO_PASS_CONT unpack_decorr_mono_pass_cont_x64
#elif defined(OPT_ASM_ARM)
    #define DECORR_STEREO_PASS_CONT unpack_decorr_stereo_pass_cont_armv7
    #define DECORR_STEREO_PASS_CONT_AVAILABLE 1
    #define DECORR_MONO_PASS_CONT unpack_decorr_mono_pass_cont_armv7
#endif

#ifdef DECORR_STEREO_PASS_CONT
extern void DECORR_STEREO_PASS_CONT (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count, int32_t long_math);
extern void DECORR_MONO_PASS_CONT (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count, int32_t long_math);
#endif

// This flag provides the functionality of terminating the decoding and muting
// the output when a lossy sample appears to be corrupt. This is automatic
// for lossless files because a corrupt sample is unambigious, but for lossy
// data it might be possible for this to falsely trigger (although I have never
// seen it).

#define LOSSY_MUTE

///////////////////////////// executable code ////////////////////////////////

// This monster actually unpacks the WavPack bitstream(s) into the specified
// buffer as 32-bit integers or floats (depending on orignal data). Lossy
// samples will be clipped to their original limits (i.e. 8-bit samples are
// clipped to -128/+127) but are still returned in longs. It is up to the
// caller to potentially reformat this for the final output including any
// multichannel distribution, block alignment or endian compensation. The
// function unpack_init() must have been called and the entire WavPack block
// must still be visible (although wps->blockbuff will not be accessed again).
// For maximum clarity, the function is broken up into segments that handle
// various modes. This makes for a few extra infrequent flag checks, but
// makes the code easier to follow because the nesting does not become so
// deep. For maximum efficiency, the conversion is isolated to tight loops
// that handle an entire buffer. The function returns the total number of
// samples unpacked, which can be less than the number requested if an error
// occurs or the end of the block is reached.

static void decorr_stereo_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count);
static void decorr_mono_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count);
static void fixup_samples (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count);

int32_t unpack_samples (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags, crc = wps->crc, i;
    int32_t mute_limit = (int32_t)((1L << ((flags & MAG_MASK) >> MAG_LSB)) + 2);
    int32_t correction [2], read_word, *bptr;
    struct decorr_pass *dpp;
    int tcount, m = 0;

    // don't attempt to decode past the end of the block, but watch out for overflow!

    if (wps->sample_index + sample_count > GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples &&
        GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples - wps->sample_index < sample_count)
            sample_count = (uint32_t) (GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples - wps->sample_index);

    if (GET_BLOCK_INDEX (wps->wphdr) > wps->sample_index || wps->wphdr.block_samples < sample_count)
        wps->mute_error = TRUE;

    if (wps->mute_error) {
        if (wpc->reduced_channels == 1 || wpc->config.num_channels == 1 || (flags & MONO_FLAG))
            memset (buffer, 0, sample_count * 4);
        else
            memset (buffer, 0, sample_count * 8);

        wps->sample_index += sample_count;
        return sample_count;
    }

    if ((flags & HYBRID_FLAG) && !wps->block2buff)
        mute_limit = (mute_limit * 2) + 128;

    //////////////// handle lossless or hybrid lossy mono data /////////////////

    if (!wps->block2buff && (flags & MONO_DATA)) {
        int32_t *eptr = buffer + sample_count;

        if (flags & HYBRID_FLAG) {
            i = sample_count;

            for (bptr = buffer; bptr < eptr;)
                if ((*bptr++ = get_word (wps, 0, NULL)) == WORD_EOF) {
                    i = (uint32_t)(bptr - buffer);
                    break;
                }
        }
        else
            i = get_words_lossless (wps, buffer, sample_count);

#ifdef DECORR_MONO_PASS_CONT
        if (sample_count < 16)
            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
                decorr_mono_pass (dpp, buffer, sample_count);
        else
            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                int pre_samples = (dpp->term > MAX_TERM) ? 2 : dpp->term;

                decorr_mono_pass (dpp, buffer, pre_samples);

                DECORR_MONO_PASS_CONT (dpp, buffer + pre_samples, sample_count - pre_samples,
                    ((flags & MAG_MASK) >> MAG_LSB) > 15);
            }
#else
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
            decorr_mono_pass (dpp, buffer, sample_count);
#endif

#ifndef LOSSY_MUTE
        if (!(flags & HYBRID_FLAG))
#endif
        for (bptr = buffer; bptr < eptr; ++bptr) {
            if (labs (bptr [0]) > mute_limit) {
                i = (uint32_t)(bptr - buffer);
                break;
            }

            crc = crc * 3 + bptr [0];
        }
#ifndef LOSSY_MUTE
        else
            for (bptr = buffer; bptr < eptr; ++bptr)
                crc = crc * 3 + bptr [0];
#endif
    }

    /////////////// handle lossless or hybrid lossy stereo data ///////////////

    else if (!wps->block2buff && !(flags & MONO_DATA)) {
        int32_t *eptr = buffer + (sample_count * 2);

        if (flags & HYBRID_FLAG) {
            i = sample_count;

            for (bptr = buffer; bptr < eptr; bptr += 2)
                if ((bptr [0] = get_word (wps, 0, NULL)) == WORD_EOF ||
                    (bptr [1] = get_word (wps, 1, NULL)) == WORD_EOF) {
                        i = (uint32_t)(bptr - buffer) / 2;
                        break;
                }
        }
        else
            i = get_words_lossless (wps, buffer, sample_count);

#ifdef DECORR_STEREO_PASS_CONT
        if (sample_count < 16 || !DECORR_STEREO_PASS_CONT_AVAILABLE) {
            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
                decorr_stereo_pass (dpp, buffer, sample_count);

            m = sample_count & (MAX_TERM - 1);
        }
        else
            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                int pre_samples = (dpp->term < 0 || dpp->term > MAX_TERM) ? 2 : dpp->term;

                decorr_stereo_pass (dpp, buffer, pre_samples);

                DECORR_STEREO_PASS_CONT (dpp, buffer + pre_samples * 2, sample_count - pre_samples,
                    ((flags & MAG_MASK) >> MAG_LSB) >= 16);
            }
#else
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
            decorr_stereo_pass (dpp, buffer, sample_count);

        m = sample_count & (MAX_TERM - 1);
#endif

        if (flags & JOINT_STEREO)
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                bptr [0] += (bptr [1] -= (bptr [0] >> 1));
                crc += (crc << 3) + (bptr [0] << 1) + bptr [0] + bptr [1];
            }
        else
            for (bptr = buffer; bptr < eptr; bptr += 2)
                crc += (crc << 3) + (bptr [0] << 1) + bptr [0] + bptr [1];

#ifndef LOSSY_MUTE
        if (!(flags & HYBRID_FLAG))
#endif
        for (bptr = buffer; bptr < eptr; bptr += 16)
            if (labs (bptr [0]) > mute_limit || labs (bptr [1]) > mute_limit) {
                i = (uint32_t)(bptr - buffer) / 2;
                break;
            }
    }

    /////////////////// handle hybrid lossless mono data ////////////////////

    else if ((flags & HYBRID_FLAG) && (flags & MONO_DATA))
        for (bptr = buffer, i = 0; i < sample_count; ++i) {

            if ((read_word = get_word (wps, 0, correction)) == WORD_EOF)
                break;

            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                int32_t sam, temp;
                int k;

                if (dpp->term > MAX_TERM) {
                    if (dpp->term & 1)
                        sam = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                    else
                        sam = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

                    dpp->samples_A [1] = dpp->samples_A [0];
                    k = 0;
                }
                else {
                    sam = dpp->samples_A [m];
                    k = (m + dpp->term) & (MAX_TERM - 1);
                }

                temp = apply_weight (dpp->weight_A, sam) + read_word;
                update_weight (dpp->weight_A, dpp->delta, sam, read_word);
                dpp->samples_A [k] = read_word = temp;
            }

            m = (m + 1) & (MAX_TERM - 1);

            if (flags & HYBRID_SHAPE) {
                int shaping_weight = (wps->dc.shaping_acc [0] += wps->dc.shaping_delta [0]) >> 16;
                int32_t temp = -apply_weight (shaping_weight, wps->dc.error [0]);

                if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                    if (temp == wps->dc.error [0])
                        temp = (temp < 0) ? temp + 1 : temp - 1;

                    wps->dc.error [0] = temp - correction [0];
                }
                else
                    wps->dc.error [0] = -correction [0];

                read_word += correction [0] - temp;
            }
            else
                read_word += correction [0];

            crc += (crc << 1) + read_word;

            if (labs (read_word) > mute_limit)
                break;

            *bptr++ = read_word;
        }

    //////////////////// handle hybrid lossless stereo data ///////////////////

    else if (wps->block2buff && !(flags & MONO_DATA))
        for (bptr = buffer, i = 0; i < sample_count; ++i) {
            int32_t left, right, left2, right2;
            int32_t left_c = 0, right_c = 0;

            if ((left = get_word (wps, 0, correction)) == WORD_EOF ||
                (right = get_word (wps, 1, correction + 1)) == WORD_EOF)
                    break;

            if (flags & CROSS_DECORR) {
                left_c = left + correction [0];
                right_c = right + correction [1];

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                    int32_t sam_A, sam_B;

                    if (dpp->term > 0) {
                        if (dpp->term > MAX_TERM) {
                            if (dpp->term & 1) {
                                sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                                sam_B = 2 * dpp->samples_B [0] - dpp->samples_B [1];
                            }
                            else {
                                sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;
                                sam_B = (3 * dpp->samples_B [0] - dpp->samples_B [1]) >> 1;
                            }
                        }
                        else {
                            sam_A = dpp->samples_A [m];
                            sam_B = dpp->samples_B [m];
                        }

                        left_c += apply_weight (dpp->weight_A, sam_A);
                        right_c += apply_weight (dpp->weight_B, sam_B);
                    }
                    else if (dpp->term == -1) {
                        left_c += apply_weight (dpp->weight_A, dpp->samples_A [0]);
                        right_c += apply_weight (dpp->weight_B, left_c);
                    }
                    else {
                        right_c += apply_weight (dpp->weight_B, dpp->samples_B [0]);

                        if (dpp->term == -3)
                            left_c += apply_weight (dpp->weight_A, dpp->samples_A [0]);
                        else
                            left_c += apply_weight (dpp->weight_A, right_c);
                    }
                }

                if (flags & JOINT_STEREO)
                    left_c += (right_c -= (left_c >> 1));
            }

            for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
                int32_t sam_A, sam_B;

                if (dpp->term > 0) {
                    int k;

                    if (dpp->term > MAX_TERM) {
                        if (dpp->term & 1) {
                            sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                            sam_B = 2 * dpp->samples_B [0] - dpp->samples_B [1];
                        }
                        else {
                            sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;
                            sam_B = (3 * dpp->samples_B [0] - dpp->samples_B [1]) >> 1;
                        }

                        dpp->samples_A [1] = dpp->samples_A [0];
                        dpp->samples_B [1] = dpp->samples_B [0];
                        k = 0;
                    }
                    else {
                        sam_A = dpp->samples_A [m];
                        sam_B = dpp->samples_B [m];
                        k = (m + dpp->term) & (MAX_TERM - 1);
                    }

                    left2 = apply_weight (dpp->weight_A, sam_A) + left;
                    right2 = apply_weight (dpp->weight_B, sam_B) + right;

                    update_weight (dpp->weight_A, dpp->delta, sam_A, left);
                    update_weight (dpp->weight_B, dpp->delta, sam_B, right);

                    dpp->samples_A [k] = left = left2;
                    dpp->samples_B [k] = right = right2;
                }
                else if (dpp->term == -1) {
                    left2 = left + apply_weight (dpp->weight_A, dpp->samples_A [0]);
                    update_weight_clip (dpp->weight_A, dpp->delta, dpp->samples_A [0], left);
                    left = left2;
                    right2 = right + apply_weight (dpp->weight_B, left2);
                    update_weight_clip (dpp->weight_B, dpp->delta, left2, right);
                    dpp->samples_A [0] = right = right2;
                }
                else {
                    right2 = right + apply_weight (dpp->weight_B, dpp->samples_B [0]);
                    update_weight_clip (dpp->weight_B, dpp->delta, dpp->samples_B [0], right);
                    right = right2;

                    if (dpp->term == -3) {
                        right2 = dpp->samples_A [0];
                        dpp->samples_A [0] = right;
                    }

                    left2 = left + apply_weight (dpp->weight_A, right2);
                    update_weight_clip (dpp->weight_A, dpp->delta, right2, left);
                    dpp->samples_B [0] = left = left2;
                }
            }

            m = (m + 1) & (MAX_TERM - 1);

            if (!(flags & CROSS_DECORR)) {
                left_c = left + correction [0];
                right_c = right + correction [1];

                if (flags & JOINT_STEREO)
                    left_c += (right_c -= (left_c >> 1));
            }

            if (flags & JOINT_STEREO)
                left += (right -= (left >> 1));

            if (flags & HYBRID_SHAPE) {
                int shaping_weight;
                int32_t temp;

                correction [0] = left_c - left;
                shaping_weight = (wps->dc.shaping_acc [0] += wps->dc.shaping_delta [0]) >> 16;
                temp = -apply_weight (shaping_weight, wps->dc.error [0]);

                if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                    if (temp == wps->dc.error [0])
                        temp = (temp < 0) ? temp + 1 : temp - 1;

                    wps->dc.error [0] = temp - correction [0];
                }
                else
                    wps->dc.error [0] = -correction [0];

                left = left_c - temp;
                correction [1] = right_c - right;
                shaping_weight = (wps->dc.shaping_acc [1] += wps->dc.shaping_delta [1]) >> 16;
                temp = -apply_weight (shaping_weight, wps->dc.error [1]);

                if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                    if (temp == wps->dc.error [1])
                        temp = (temp < 0) ? temp + 1 : temp - 1;

                    wps->dc.error [1] = temp - correction [1];
                }
                else
                    wps->dc.error [1] = -correction [1];

                right = right_c - temp;
            }
            else {
                left = left_c;
                right = right_c;
            }

            if (labs (left) > mute_limit || labs (right) > mute_limit)
                break;

            crc += (crc << 3) + (left << 1) + left + right;
            *bptr++ = left;
            *bptr++ = right;
        }
    else
        i = 0;  /* this line can't execute, but suppresses compiler warning */

    if (i != sample_count) {
        memset (buffer, 0, sample_count * (flags & MONO_FLAG ? 4 : 8));
        wps->mute_error = TRUE;
        i = sample_count;

        if (bs_is_open (&wps->wvxbits))
            bs_close_read (&wps->wvxbits);
    }

    if (m)
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++)
            if (dpp->term > 0 && dpp->term <= MAX_TERM) {
                int32_t temp_A [MAX_TERM], temp_B [MAX_TERM];
                int k;

                memcpy (temp_A, dpp->samples_A, sizeof (dpp->samples_A));
                memcpy (temp_B, dpp->samples_B, sizeof (dpp->samples_B));

                for (k = 0; k < MAX_TERM; k++) {
                    dpp->samples_A [k] = temp_A [m];
                    dpp->samples_B [k] = temp_B [m];
                    m = (m + 1) & (MAX_TERM - 1);
                }
            }

    fixup_samples (wpc, buffer, i);

    if ((flags & FLOAT_DATA) && (wpc->open_flags & OPEN_NORMALIZE))
        WavpackFloatNormalize (buffer, (flags & MONO_DATA) ? i : i * 2,
            127 - wps->float_norm_exp + wpc->norm_offset);

    if (flags & FALSE_STEREO) {
        int32_t *dptr = buffer + i * 2;
        int32_t *sptr = buffer + i;
        int32_t c = i;

        while (c--) {
            *--dptr = *--sptr;
            *--dptr = *sptr;
        }
    }

    wps->sample_index += i;
    wps->crc = crc;

    return i;
}

// General function to perform mono decorrelation pass on specified buffer
// (although since this is the reverse function it might technically be called
// "correlation" instead). This version handles all sample resolutions and
// weight deltas. The dpp->samples_X[] data is returned normalized for term
// values 1-8.

static void decorr_mono_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count)
{
    int32_t delta = dpp->delta, weight_A = dpp->weight_A;
    int32_t *bptr, *eptr = buffer + sample_count, sam_A;
    int m, k;

    switch (dpp->term) {

        case 17:
            for (bptr = buffer; bptr < eptr; bptr++) {
                sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                dpp->samples_A [1] = dpp->samples_A [0];
                dpp->samples_A [0] = apply_weight (weight_A, sam_A) + bptr [0];
                update_weight (weight_A, delta, sam_A, bptr [0]);
                bptr [0] = dpp->samples_A [0];
            }

            break;

        case 18:
            for (bptr = buffer; bptr < eptr; bptr++) {
                sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;
                dpp->samples_A [1] = dpp->samples_A [0];
                dpp->samples_A [0] = apply_weight (weight_A, sam_A) + bptr [0];
                update_weight (weight_A, delta, sam_A, bptr [0]);
                bptr [0] = dpp->samples_A [0];
            }

            break;

        default:
            for (m = 0, k = dpp->term & (MAX_TERM - 1), bptr = buffer; bptr < eptr; bptr++) {
                sam_A = dpp->samples_A [m];
                dpp->samples_A [k] = apply_weight (weight_A, sam_A) + bptr [0];
                update_weight (weight_A, delta, sam_A, bptr [0]);
                bptr [0] = dpp->samples_A [k];
                m = (m + 1) & (MAX_TERM - 1);
                k = (k + 1) & (MAX_TERM - 1);
            }

            if (m) {
                int32_t temp_samples [MAX_TERM];

                memcpy (temp_samples, dpp->samples_A, sizeof (dpp->samples_A));

                for (k = 0; k < MAX_TERM; k++, m++)
                    dpp->samples_A [k] = temp_samples [m & (MAX_TERM - 1)];
            }

            break;
    }

    dpp->weight_A = weight_A;
}

// General function to perform stereo decorrelation pass on specified buffer
// (although since this is the reverse function it might technically be called
// "correlation" instead). This version handles all sample resolutions and
// weight deltas. The dpp->samples_X[] data is *not* returned normalized for
// term values 1-8, so it should be normalized if it is going to be used to
// call this function again.

static void decorr_stereo_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count)
{
    int32_t *bptr, *eptr = buffer + (sample_count * 2);
    int m, k;

    switch (dpp->term) {
        case 17:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam, tmp;

                sam = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                dpp->samples_A [1] = dpp->samples_A [0];
                bptr [0] = dpp->samples_A [0] = apply_weight (dpp->weight_A, sam) + (tmp = bptr [0]);
                update_weight (dpp->weight_A, dpp->delta, sam, tmp);

                sam = 2 * dpp->samples_B [0] - dpp->samples_B [1];
                dpp->samples_B [1] = dpp->samples_B [0];
                bptr [1] = dpp->samples_B [0] = apply_weight (dpp->weight_B, sam) + (tmp = bptr [1]);
                update_weight (dpp->weight_B, dpp->delta, sam, tmp);
            }

            break;

        case 18:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam, tmp;

                sam = dpp->samples_A [0] + ((dpp->samples_A [0] - dpp->samples_A [1]) >> 1);
                dpp->samples_A [1] = dpp->samples_A [0];
                bptr [0] = dpp->samples_A [0] = apply_weight (dpp->weight_A, sam) + (tmp = bptr [0]);
                update_weight (dpp->weight_A, dpp->delta, sam, tmp);

                sam = dpp->samples_B [0] + ((dpp->samples_B [0] - dpp->samples_B [1]) >> 1);
                dpp->samples_B [1] = dpp->samples_B [0];
                bptr [1] = dpp->samples_B [0] = apply_weight (dpp->weight_B, sam) + (tmp = bptr [1]);
                update_weight (dpp->weight_B, dpp->delta, sam, tmp);
            }

            break;

        default:
            for (m = 0, k = dpp->term & (MAX_TERM - 1), bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam;

                sam = dpp->samples_A [m];
                dpp->samples_A [k] = apply_weight (dpp->weight_A, sam) + bptr [0];
                update_weight (dpp->weight_A, dpp->delta, sam, bptr [0]);
                bptr [0] = dpp->samples_A [k];

                sam = dpp->samples_B [m];
                dpp->samples_B [k] = apply_weight (dpp->weight_B, sam) + bptr [1];
                update_weight (dpp->weight_B, dpp->delta, sam, bptr [1]);
                bptr [1] = dpp->samples_B [k];

                m = (m + 1) & (MAX_TERM - 1);
                k = (k + 1) & (MAX_TERM - 1);
            }

            break;

        case -1:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam;

                sam = bptr [0] + apply_weight (dpp->weight_A, dpp->samples_A [0]);
                update_weight_clip (dpp->weight_A, dpp->delta, dpp->samples_A [0], bptr [0]);
                bptr [0] = sam;
                dpp->samples_A [0] = bptr [1] + apply_weight (dpp->weight_B, sam);
                update_weight_clip (dpp->weight_B, dpp->delta, sam, bptr [1]);
                bptr [1] = dpp->samples_A [0];
            }

            break;

        case -2:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam;

                sam = bptr [1] + apply_weight (dpp->weight_B, dpp->samples_B [0]);
                update_weight_clip (dpp->weight_B, dpp->delta, dpp->samples_B [0], bptr [1]);
                bptr [1] = sam;
                dpp->samples_B [0] = bptr [0] + apply_weight (dpp->weight_A, sam);
                update_weight_clip (dpp->weight_A, dpp->delta, sam, bptr [0]);
                bptr [0] = dpp->samples_B [0];
            }

            break;

        case -3:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam_A, sam_B;

                sam_A = bptr [0] + apply_weight (dpp->weight_A, dpp->samples_A [0]);
                update_weight_clip (dpp->weight_A, dpp->delta, dpp->samples_A [0], bptr [0]);
                sam_B = bptr [1] + apply_weight (dpp->weight_B, dpp->samples_B [0]);
                update_weight_clip (dpp->weight_B, dpp->delta, dpp->samples_B [0], bptr [1]);
                bptr [0] = dpp->samples_B [0] = sam_A;
                bptr [1] = dpp->samples_A [0] = sam_B;
            }

            break;
    }
}

// This is a helper function for unpack_samples() that applies several final
// operations. First, if the data is 32-bit float data, then that conversion
// is done in the float.c module (whether lossy or lossless) and we return.
// Otherwise, if the extended integer data applies, then that operation is
// executed first. If the unpacked data is lossy (and not corrected) then
// it is clipped and shifted in a single operation. Otherwise, if it's
// lossless then the last step is to apply the final shift (if any).

static void fixup_samples (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags;
    int lossy_flag = (flags & HYBRID_FLAG) && !wps->block2buff;
    int shift = (flags & SHIFT_MASK) >> SHIFT_LSB;

    if (flags & FLOAT_DATA) {
        float_values (wps, buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2);
        return;
    }

    if (flags & INT32_DATA) {
        uint32_t count = (flags & MONO_DATA) ? sample_count : sample_count * 2;
        int sent_bits = wps->int32_sent_bits, zeros = wps->int32_zeros;
        int ones = wps->int32_ones, dups = wps->int32_dups;
        uint32_t data, mask = (1 << sent_bits) - 1;
        int32_t *dptr = buffer;

        if (bs_is_open (&wps->wvxbits)) {
            uint32_t crc = wps->crc_x;

            while (count--) {
//              if (sent_bits) {
                    getbits (&data, sent_bits, &wps->wvxbits);
                    *dptr = (*dptr << sent_bits) | (data & mask);
//              }

                if (zeros)
                    *dptr <<= zeros;
                else if (ones)
                    *dptr = ((*dptr + 1) << ones) - 1;
                else if (dups)
                    *dptr = ((*dptr + (*dptr & 1)) << dups) - (*dptr & 1);

                crc = crc * 9 + (*dptr & 0xffff) * 3 + ((*dptr >> 16) & 0xffff);
                dptr++;
            }

            wps->crc_x = crc;
        }
        else if (!sent_bits && (zeros + ones + dups)) {
            while (lossy_flag && (flags & BYTES_STORED) == 3 && shift < 8) {
                if (zeros)
                    zeros--;
                else if (ones)
                    ones--;
                else if (dups)
                    dups--;
                else
                    break;

                shift++;
            }

            while (count--) {
                if (zeros)
                    *dptr <<= zeros;
                else if (ones)
                    *dptr = ((*dptr + 1) << ones) - 1;
                else if (dups)
                    *dptr = ((*dptr + (*dptr & 1)) << dups) - (*dptr & 1);

                dptr++;
            }
        }
        else
            shift += zeros + sent_bits + ones + dups;
    }

    if (lossy_flag) {
        int32_t min_value, max_value, min_shifted, max_shifted;

        switch (flags & BYTES_STORED) {
            case 0:
                min_shifted = (min_value = -128 >> shift) << shift;
                max_shifted = (max_value = 127 >> shift) << shift;
                break;

            case 1:
                min_shifted = (min_value = -32768 >> shift) << shift;
                max_shifted = (max_value = 32767 >> shift) << shift;
                break;

            case 2:
                min_shifted = (min_value = -8388608 >> shift) << shift;
                max_shifted = (max_value = 8388607 >> shift) << shift;
                break;

            case 3: default:    /* "default" suppresses compiler warning */
                min_shifted = (min_value = (int32_t) 0x80000000 >> shift) << shift;
                max_shifted = (max_value = (int32_t) 0x7fffffff >> shift) << shift;
                break;
        }

        if (!(flags & MONO_DATA))
            sample_count *= 2;

        while (sample_count--) {
            if (*buffer < min_value)
                *buffer++ = min_shifted;
            else if (*buffer > max_value)
                *buffer++ = max_shifted;
            else
                *buffer++ <<= shift;
        }
    }
    else if (shift) {
        if (!(flags & MONO_DATA))
            sample_count *= 2;

        while (sample_count--)
            *buffer++ <<= shift;
    }
}

// This function checks the crc value(s) for an unpacked block, returning the
// number of actual crc errors detected for the block. The block must be
// completely unpacked before this test is valid. For losslessly unpacked
// blocks of float or extended integer data the extended crc is also checked.
// Note that WavPack's crc is not a CCITT approved polynomial algorithm, but
// is a much simpler method that is virtually as robust for real world data.

int check_crc_error (WavpackContext *wpc)
{
    int result = 0, stream;

    for (stream = 0; stream < wpc->num_streams; stream++) {
        WavpackStream *wps = wpc->streams [stream];

        if (wps->crc != wps->wphdr.crc)
            ++result;
        else if (bs_is_open (&wps->wvxbits) && wps->crc_x != wps->crc_wvx)
            ++result;
    }

    return result;
}

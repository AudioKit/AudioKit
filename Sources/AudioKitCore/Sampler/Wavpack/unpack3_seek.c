////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack3_seek.c

// This module provides seeking support for WavPack files prior to version 4.0.

#ifdef ENABLE_LEGACY
#ifndef NO_SEEKING

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"
#include "unpack3.h"

static void *unpack_restore (WavpackStream3 *wps, void *source, int keep_resources);
static void bs_restore3 (Bitstream3 *bs);

// This is an extension for WavpackSeekSample (). Note that because WavPack
// files created prior to version 4.0 are not inherently seekable, this
// function could take a long time if a forward seek is requested to an
// area that has not been played (or seeked through) yet.

int seek_sample3 (WavpackContext *wpc, uint32_t desired_index)
{
    int points_index = desired_index / (((uint32_t) wpc->total_samples >> 8) + 1);
    WavpackStream3 *wps = (WavpackStream3 *) wpc->stream3;

    if (desired_index >= wpc->total_samples)
        return FALSE;

    while (points_index)
        if (wps->index_points [points_index].saved &&
            wps->index_points [points_index].sample_index <= desired_index)
                break;
        else
            points_index--;

    if (wps->index_points [points_index].saved)
        if (wps->index_points [points_index].sample_index > wps->sample_index ||
            wps->sample_index > desired_index) {
                wps->sample_index = wps->index_points [points_index].sample_index;
                unpack_restore (wps, wps->unpack_data + points_index * wps->unpack_size, TRUE);
        }

    if (desired_index > wps->sample_index) {
        int32_t *buffer = (int32_t *) malloc (1024 * (wps->wphdr.flags & MONO_FLAG ? 4 : 8));
        uint32_t samples_to_skip = desired_index - wps->sample_index;

        while (1) {
            if (samples_to_skip > 1024) {
                if (unpack_samples3 (wpc, buffer, 1024) == 1024)
                    samples_to_skip -= 1024;
                else
                    break;
            }
            else {
                samples_to_skip -= unpack_samples3 (wpc, buffer, samples_to_skip);
                break;
            }
        }

        free (buffer);

        if (samples_to_skip)
            return FALSE;
    }

    return TRUE;
}

// This function restores the unpacking context from the specified pointer
// and returns the updated pointer. After this call, unpack_samples() will
// continue where it left off immediately before unpack_save() was called.
// If the WavPack files and bitstreams might have been closed and reopened,
// then the "keep_resources" flag should be set to avoid using the "old"
// resources that were originally saved (and are probably now invalid).

static void *unpack_restore (WavpackStream3 *wps, void *source, int keep_resources)
{
    int flags = wps->wphdr.flags, tcount;
    struct decorr_pass *dpp;
    FILE *temp_file;
    unsigned char *temp_buf;

    unpack_init3 (wps);
    temp_file = wps->wvbits.id;
    temp_buf = wps->wvbits.buf;
    RESTORE (wps->wvbits, source);

    if (keep_resources) {
        wps->wvbits.id = temp_file;
        wps->wvbits.ptr += temp_buf - wps->wvbits.buf;
        wps->wvbits.end += temp_buf - wps->wvbits.buf;
        wps->wvbits.buf = temp_buf;
    }

    bs_restore3 (&wps->wvbits);

    if (flags & WVC_FLAG) {
        temp_file = wps->wvcbits.id;
        temp_buf = wps->wvcbits.buf;
        RESTORE (wps->wvcbits, source);

        if (keep_resources) {
            wps->wvcbits.id = temp_file;
            wps->wvcbits.ptr += temp_buf - wps->wvcbits.buf;
            wps->wvcbits.end += temp_buf - wps->wvcbits.buf;
            wps->wvcbits.buf = temp_buf;
        }

        bs_restore3 (&wps->wvcbits);
    }

    if (wps->wphdr.version == 3) {
        if (wps->wphdr.bits) {
            RESTORE (wps->w4, source);
        }
        else {
            RESTORE (wps->w1, source);
        }

        RESTORE (wps->w3, source);
        RESTORE (wps->dc.crc, source);
    }
    else
        RESTORE (wps->w2, source);

    if (wps->wphdr.bits) {
        RESTORE (wps->dc.error, source);
    }
    else {
        RESTORE (wps->dc.sum_level, source);
        RESTORE (wps->dc.left_level, source);
        RESTORE (wps->dc.right_level, source);
        RESTORE (wps->dc.diff_level, source);
    }

    if (flags & OVER_20) {
        RESTORE (wps->dc.last_extra_bits, source);
        RESTORE (wps->dc.extra_bits_count, source);
    }

    if (!(flags & EXTREME_DECORR)) {
        RESTORE (wps->dc.sample, source);
        RESTORE (wps->dc.weight, source);
    }

    if (flags & (HIGH_FLAG | NEW_HIGH_FLAG))
        for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount--; dpp++) {
            if (dpp->term > 0) {
                int count = dpp->term;
                int index = wps->dc.m;

                RESTORE (dpp->weight_A, source);

                while (count--) {
                    RESTORE (dpp->samples_A [index], source);
                    index = (index + 1) & (MAX_TERM - 1);
                }

                if (!(flags & MONO_FLAG)) {
                    count = dpp->term;
                    index = wps->dc.m;

                    RESTORE (dpp->weight_B, source);

                    while (count--) {
                        RESTORE (dpp->samples_B [index], source);
                        index = (index + 1) & (MAX_TERM - 1);
                    }
                }
            }
            else {
                RESTORE (dpp->weight_A, source);
                RESTORE (dpp->weight_B, source);
                RESTORE (dpp->samples_A [0], source);
                RESTORE (dpp->samples_B [0], source);
            }
        }

    return source;
}

// This function is called after a call to unpack_restore() has restored
// the BitStream structure to a previous state and causes any required data
// to be read from the file. This function is NOT supported for overlapped
// operation.

static void bs_restore3 (Bitstream3 *bs)
{
    uint32_t bytes_to_read = (uint32_t)(bs->end - bs->ptr - 1), bytes_read;

    bs->reader->set_pos_abs (bs->id, bs->fpos - bytes_to_read);

    if (bytes_to_read > 0) {

        bytes_read = bs->reader->read_bytes (bs->id, bs->ptr + 1, bytes_to_read);

        if (bytes_to_read != bytes_read)
            bs->end = bs->ptr + 1 + bytes_read;
    }
}

#endif      // NO_SEEKING
#endif      // ENABLE_LEGACY

////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack_seek.c

// This module provides the high-level API for unpacking audio data from
// a specific sample index (i.e., seeking).

#ifndef NO_SEEKING

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

///////////////////////////// executable code ////////////////////////////////

static int64_t find_sample (WavpackContext *wpc, void *infile, int64_t header_pos, int64_t sample);

// Seek to the specifed sample index, returning TRUE on success. Note that
// files generated with version 4.0 or newer will seek almost immediately.
// Older files can take quite long if required to seek through unplayed
// portions of the file, but will create a seek map so that reverse seeks
// (or forward seeks to already scanned areas) will be very fast. After a
// FALSE return the file should not be accessed again (other than to close
// it); this is a fatal error.

int WavpackSeekSample (WavpackContext *wpc, uint32_t sample)
{
    return WavpackSeekSample64 (wpc, sample);
}

int WavpackSeekSample64 (WavpackContext *wpc, int64_t sample)
{
    WavpackStream *wps = wpc->streams ? wpc->streams [wpc->current_stream = 0] : NULL;
    uint32_t bcount, samples_to_skip;//, samples_to_decode = 0;
    int32_t *buffer;

    if (wpc->total_samples == -1 || sample >= wpc->total_samples ||
        !wpc->reader->can_seek (wpc->wv_in) || (wpc->open_flags & OPEN_STREAMING) ||
        (wpc->wvc_flag && !wpc->reader->can_seek (wpc->wvc_in)))
            return FALSE;

#ifdef ENABLE_LEGACY
    if (wpc->stream3)
        return seek_sample3 (wpc, (uint32_t) sample);
#endif

#ifdef ENABLE_DSD
    if (wpc->decimation_context) {      // the decimation code needs some context to be sample accurate
        if (sample < 16) {
            samples_to_decode = (uint32_t) sample;
            sample = 0;
        }
        else {
            samples_to_decode = 16;
            sample -= 16;
        }
    }
#endif

    if (!wps->wphdr.block_samples || !(wps->wphdr.flags & INITIAL_BLOCK) || sample < GET_BLOCK_INDEX (wps->wphdr) ||
        sample >= GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples) {

            free_streams (wpc);
            wpc->filepos = find_sample (wpc, wpc->wv_in, wpc->filepos, sample);

            if (wpc->filepos == -1)
                return FALSE;

            if (wpc->wvc_flag) {
                wpc->file2pos = find_sample (wpc, wpc->wvc_in, 0, sample);

                if (wpc->file2pos == -1)
                    return FALSE;
            }
    }

    if (!wps->blockbuff) {
        wpc->reader->set_pos_abs (wpc->wv_in, wpc->filepos);
        wpc->reader->read_bytes (wpc->wv_in, &wps->wphdr, sizeof (WavpackHeader));
        WavpackLittleEndianToNative (&wps->wphdr, WavpackHeaderFormat);
        wps->blockbuff = malloc (wps->wphdr.ckSize + 8);
        memcpy (wps->blockbuff, &wps->wphdr, sizeof (WavpackHeader));

        if (wpc->reader->read_bytes (wpc->wv_in, wps->blockbuff + sizeof (WavpackHeader), wps->wphdr.ckSize - 24) !=
            wps->wphdr.ckSize - 24) {
                free_streams (wpc);
                return FALSE;
        }

        // render corrupt blocks harmless
        if (!WavpackVerifySingleBlock (wps->blockbuff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
            wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
            wps->wphdr.block_samples = 0;
            memcpy (wps->blockbuff, &wps->wphdr, 32);
        }

        SET_BLOCK_INDEX (wps->wphdr, GET_BLOCK_INDEX (wps->wphdr) - wpc->initial_index);
        memcpy (wps->blockbuff, &wps->wphdr, sizeof (WavpackHeader));
        wps->init_done = FALSE;

        if (wpc->wvc_flag) {
            wpc->reader->set_pos_abs (wpc->wvc_in, wpc->file2pos);
            wpc->reader->read_bytes (wpc->wvc_in, &wps->wphdr, sizeof (WavpackHeader));
            WavpackLittleEndianToNative (&wps->wphdr, WavpackHeaderFormat);
            wps->block2buff = malloc (wps->wphdr.ckSize + 8);
            memcpy (wps->block2buff, &wps->wphdr, sizeof (WavpackHeader));

            if (wpc->reader->read_bytes (wpc->wvc_in, wps->block2buff + sizeof (WavpackHeader), wps->wphdr.ckSize - 24) !=
                wps->wphdr.ckSize - 24) {
                    free_streams (wpc);
                    return FALSE;
            }

            // render corrupt blocks harmless
            if (!WavpackVerifySingleBlock (wps->block2buff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
                wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
                wps->wphdr.block_samples = 0;
                memcpy (wps->block2buff, &wps->wphdr, 32);
            }

            SET_BLOCK_INDEX (wps->wphdr, GET_BLOCK_INDEX (wps->wphdr) - wpc->initial_index);
            memcpy (wps->block2buff, &wps->wphdr, sizeof (WavpackHeader));
        }

        if (!wps->init_done && !unpack_init (wpc)) {
            free_streams (wpc);
            return FALSE;
        }

        wps->init_done = TRUE;
    }

    while (!wpc->reduced_channels && !(wps->wphdr.flags & FINAL_BLOCK)) {
        if (++wpc->current_stream == wpc->num_streams) {

            if (wpc->num_streams == wpc->max_streams) {
                free_streams (wpc);
                return FALSE;
            }

            wpc->streams = realloc (wpc->streams, (wpc->num_streams + 1) * sizeof (wpc->streams [0]));
            wps = wpc->streams [wpc->num_streams++] = malloc (sizeof (WavpackStream));
            CLEAR (*wps);
            bcount = read_next_header (wpc->reader, wpc->wv_in, &wps->wphdr);

            if (bcount == (uint32_t) -1) {
                free_streams (wpc);
                return FALSE;
            }

            wps->blockbuff = malloc (wps->wphdr.ckSize + 8);
            memcpy (wps->blockbuff, &wps->wphdr, 32);

            if (wpc->reader->read_bytes (wpc->wv_in, wps->blockbuff + 32, wps->wphdr.ckSize - 24) !=
                wps->wphdr.ckSize - 24) {
                    free_streams (wpc);
                    return FALSE;
            }

            // render corrupt blocks harmless
            if (!WavpackVerifySingleBlock (wps->blockbuff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
                wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
                wps->wphdr.block_samples = 0;
                memcpy (wps->blockbuff, &wps->wphdr, 32);
            }

            wps->init_done = FALSE;

            if (wpc->wvc_flag && !read_wvc_block (wpc)) {
                free_streams (wpc);
                return FALSE;
            }

            if (!wps->init_done && !unpack_init (wpc)) {
                free_streams (wpc);
                return FALSE;
            }

            wps->init_done = TRUE;
        }
        else
            wps = wpc->streams [wpc->current_stream];
    }

    if (sample < wps->sample_index) {
        for (wpc->current_stream = 0; wpc->current_stream < wpc->num_streams; wpc->current_stream++)
            if (!unpack_init (wpc))
                return FALSE;
            else
                wpc->streams [wpc->current_stream]->init_done = TRUE;
    }

    samples_to_skip = (uint32_t) (sample - wps->sample_index);

    if (samples_to_skip > 131072) {
        free_streams (wpc);
        return FALSE;
    }

    if (samples_to_skip) {
        buffer = malloc (samples_to_skip * 8);

        for (wpc->current_stream = 0; wpc->current_stream < wpc->num_streams; wpc->current_stream++)
#ifdef ENABLE_DSD
            if (wpc->streams [wpc->current_stream]->wphdr.flags & DSD_FLAG)
                unpack_dsd_samples (wpc, buffer, samples_to_skip);
            else
#endif
                unpack_samples (wpc, buffer, samples_to_skip);

        free (buffer);
    }

    wpc->current_stream = 0;

#ifdef ENABLE_DSD
    if (wpc->decimation_context)
        decimate_dsd_reset (wpc->decimation_context);

    if (samples_to_decode) {
        buffer = malloc (samples_to_decode * wpc->config.num_channels * 4);

        if (buffer) {
            WavpackUnpackSamples (wpc, buffer, samples_to_decode);
            free (buffer);
        }
    }
#endif

    return TRUE;
}

// Find a valid WavPack header, searching either from the current file position
// (or from the specified position if not -1) and store it (endian corrected)
// at the specified pointer. The return value is the exact file position of the
// header, although we may have actually read past it. Because this function
// is used for seeking to a specific audio sample, it only considers blocks
// that contain audio samples for the initial stream to be valid.

#define BUFSIZE 4096

static int64_t find_header (WavpackStreamReader64 *reader, void *id, int64_t filepos, WavpackHeader *wphdr)
{
    unsigned char *buffer = malloc (BUFSIZE), *sp = buffer, *ep = buffer;

    if (filepos != (uint32_t) -1 && reader->set_pos_abs (id, filepos)) {
        free (buffer);
        return -1;
    }

    while (1) {
        int bleft;

        if (sp < ep) {
            bleft = (int)(ep - sp);
            memcpy (buffer, sp, bleft);
            ep -= (sp - buffer);
            sp = buffer;
        }
        else {
            if (sp > ep)
                if (reader->set_pos_rel (id, (int32_t)(sp - ep), SEEK_CUR)) {
                    free (buffer);
                    return -1;
                }

            sp = ep = buffer;
            bleft = 0;
        }

        ep += reader->read_bytes (id, ep, BUFSIZE - bleft);

        if (ep - sp < 32) {
            free (buffer);
            return -1;
        }

        while (sp + 32 <= ep)
            if (*sp++ == 'w' && *sp == 'v' && *++sp == 'p' && *++sp == 'k' &&
                !(*++sp & 1) && sp [2] < 16 && !sp [3] && (sp [2] || sp [1] || *sp >= 24) && sp [5] == 4 &&
                sp [4] >= (MIN_STREAM_VERS & 0xff) && sp [4] <= (MAX_STREAM_VERS & 0xff) && sp [18] < 3 && !sp [19]) {
                    memcpy (wphdr, sp - 4, sizeof (*wphdr));
                    WavpackLittleEndianToNative (wphdr, WavpackHeaderFormat);

                    if (wphdr->block_samples && (wphdr->flags & INITIAL_BLOCK)) {
                        free (buffer);
                        return reader->get_pos (id) - (ep - sp + 4);
                    }

                    if (wphdr->ckSize > 1024)
                        sp += wphdr->ckSize - 1024;
            }
    }
}

// Find the WavPack block that contains the specified sample. If "header_pos"
// is zero, then no information is assumed except the total number of samples
// in the file and its size in bytes. If "header_pos" is non-zero then we
// assume that it is the file position of the valid header image contained in
// the first stream and we can limit our search to either the portion above
// or below that point. If a .wvc file is being used, then this must be called
// for that file also.

static int64_t find_sample (WavpackContext *wpc, void *infile, int64_t header_pos, int64_t sample)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int64_t file_pos1 = 0, file_pos2 = wpc->reader->get_length (infile);
    int64_t sample_pos1 = 0, sample_pos2 = wpc->total_samples;
    double ratio = 0.96;
    int file_skip = 0;

    if (sample >= wpc->total_samples)
        return -1;

    if (header_pos && wps->wphdr.block_samples) {
        if (GET_BLOCK_INDEX (wps->wphdr) > sample) {
            sample_pos2 = GET_BLOCK_INDEX (wps->wphdr);
            file_pos2 = header_pos;
        }
        else if (GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples <= sample) {
            sample_pos1 = GET_BLOCK_INDEX (wps->wphdr);
            file_pos1 = header_pos;
        }
        else
            return header_pos;
    }

    while (1) {
        double bytes_per_sample;
        int64_t seek_pos;

        bytes_per_sample = (double) file_pos2 - file_pos1;
        bytes_per_sample /= sample_pos2 - sample_pos1;
        seek_pos = file_pos1 + (file_skip ? 32 : 0);
        seek_pos += (int64_t)(bytes_per_sample * (sample - sample_pos1) * ratio);
        seek_pos = find_header (wpc->reader, infile, seek_pos, &wps->wphdr);

        if (seek_pos != (int64_t) -1)
            SET_BLOCK_INDEX (wps->wphdr, GET_BLOCK_INDEX (wps->wphdr) - wpc->initial_index);

        if (seek_pos == (int64_t) -1 || seek_pos >= file_pos2) {
            if (ratio > 0.0) {
                if ((ratio -= 0.24) < 0.0)
                    ratio = 0.0;
            }
            else
                return -1;
        }
        else if (GET_BLOCK_INDEX (wps->wphdr) > sample) {
            sample_pos2 = GET_BLOCK_INDEX (wps->wphdr);
            file_pos2 = seek_pos;
        }
        else if (GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples <= sample) {

            if (seek_pos == file_pos1)
                file_skip = 1;
            else {
                sample_pos1 = GET_BLOCK_INDEX (wps->wphdr);
                file_pos1 = seek_pos;
            }
        }
        else
            return seek_pos;
    }
}

#endif


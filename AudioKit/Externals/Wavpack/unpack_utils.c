////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack_utils.c

// This module provides the high-level API for unpacking audio data from
// WavPack files. It manages the buffers used to interleave the data passed
// back to the application from the individual streams. The actual audio
// stream decompression is handled in the unpack.c module.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

///////////////////////////// executable code ////////////////////////////////

// Unpack the specified number of samples from the current file position.
// Note that "samples" here refers to "complete" samples, which would be
// 2 longs for stereo files or even more for multichannel files, so the
// required memory at "buffer" is 4 * samples * num_channels bytes. The
// audio data is returned right-justified in 32-bit longs in the endian
// mode native to the executing processor. So, if the original data was
// 16-bit, then the values returned would be +/-32k. Floating point data
// can also be returned if the source was floating point data (and this
// can be optionally normalized to +/-1.0 by using the appropriate flag
// in the call to WavpackOpenFileInput ()). The actual number of samples
// unpacked is returned, which should be equal to the number requested unless
// the end of fle is encountered or an error occurs. After all samples have
// been unpacked then 0 will be returned.

uint32_t WavpackUnpackSamples (WavpackContext *wpc, int32_t *buffer, uint32_t samples)
{
    WavpackStream *wps = wpc->streams ? wpc->streams [wpc->current_stream = 0] : NULL;
    int num_channels = wpc->config.num_channels, file_done = FALSE;
    uint32_t bcount, samples_unpacked = 0, samples_to_unpack;
    int32_t *bptr = buffer;

#ifdef ENABLE_LEGACY
    if (wpc->stream3)
        return unpack_samples3 (wpc, buffer, samples);
#endif

    while (samples) {

        // if the current block has no audio, or it's not the first block of a multichannel
        // sequence, or the sample we're on is past the last sample in this block...we need
        // to free up the streams and read the next block

        if (!wps->wphdr.block_samples || !(wps->wphdr.flags & INITIAL_BLOCK) ||
            wps->sample_index >= GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples) {

                int64_t nexthdrpos;

                if (wpc->wrapper_bytes >= MAX_WRAPPER_BYTES)
                    break;

                free_streams (wpc);
                nexthdrpos = wpc->reader->get_pos (wpc->wv_in);
                bcount = read_next_header (wpc->reader, wpc->wv_in, &wps->wphdr);

                if (bcount == (uint32_t) -1)
                    break;

                wpc->filepos = nexthdrpos + bcount;

                // allocate the memory for the entire raw block and read it in

                wps->blockbuff = malloc (wps->wphdr.ckSize + 8);

                if (!wps->blockbuff)
                    break;

                memcpy (wps->blockbuff, &wps->wphdr, 32);

                if (wpc->reader->read_bytes (wpc->wv_in, wps->blockbuff + 32, wps->wphdr.ckSize - 24) !=
                    wps->wphdr.ckSize - 24) {
                        strcpy (wpc->error_message, "can't read all of last block!");
                        wps->wphdr.block_samples = 0;
                        wps->wphdr.ckSize = 24;
                        break;
                }

                // render corrupt blocks harmless
                if (!WavpackVerifySingleBlock (wps->blockbuff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
                    wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
                    wps->wphdr.block_samples = 0;
                    memcpy (wps->blockbuff, &wps->wphdr, 32);
                }

                // potentially adjusting block_index must be done AFTER verifying block

                if (wpc->open_flags & OPEN_STREAMING)
                    SET_BLOCK_INDEX (wps->wphdr, wps->sample_index = 0);
                else
                    SET_BLOCK_INDEX (wps->wphdr, GET_BLOCK_INDEX (wps->wphdr) - wpc->initial_index);

                memcpy (wps->blockbuff, &wps->wphdr, 32);
                wps->init_done = FALSE;     // we have not yet called unpack_init() for this block

                // if this block has audio, but not the sample index we were expecting, flag an error

                if (wps->wphdr.block_samples && wps->sample_index != GET_BLOCK_INDEX (wps->wphdr))
                    wpc->crc_errors++;

                // if this block has audio, and we're in hybrid lossless mode, read the matching wvc block

                if (wps->wphdr.block_samples && wpc->wvc_flag)
                    read_wvc_block (wpc);

                // if the block does NOT have any audio, call unpack_init() to process non-audio stuff

                if (!wps->wphdr.block_samples) {
                    if (!wps->init_done && !unpack_init (wpc))
                        wpc->crc_errors++;

                    wps->init_done = TRUE;
                }
        }

        // if the current block has no audio, or it's not the first block of a multichannel
        // sequence, or the sample we're on is past the last sample in this block...we need
        // to loop back and read the next block

        if (!wps->wphdr.block_samples || !(wps->wphdr.flags & INITIAL_BLOCK) ||
            wps->sample_index >= GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples)
                continue;

        // There seems to be some missing data, like a block was corrupted or something.
        // If it's not too much data, just fill in with silence here and loop back.

        if (wps->sample_index < GET_BLOCK_INDEX (wps->wphdr)) {
            int32_t zvalue = (wps->wphdr.flags & DSD_FLAG) ? 0x55 : 0;

            samples_to_unpack = (uint32_t) (GET_BLOCK_INDEX (wps->wphdr) - wps->sample_index);

            if (!samples_to_unpack || samples_to_unpack > 262144) {
                strcpy (wpc->error_message, "discontinuity found, aborting file!");
                wps->wphdr.block_samples = 0;
                wps->wphdr.ckSize = 24;
                break;
            }

            if (samples_to_unpack > samples)
                samples_to_unpack = samples;

            wps->sample_index += samples_to_unpack;
            samples_unpacked += samples_to_unpack;
            samples -= samples_to_unpack;

            samples_to_unpack *= (wpc->reduced_channels ? wpc->reduced_channels : num_channels);

            while (samples_to_unpack--)
                *bptr++ = zvalue;

            continue;
        }

        // calculate number of samples to process from this block, then initialize the decoder for
        // this block if we haven't already

        samples_to_unpack = (uint32_t) (GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples - wps->sample_index);

        if (samples_to_unpack > samples)
            samples_to_unpack = samples;

        if (!wps->init_done && !unpack_init (wpc))
            wpc->crc_errors++;

        wps->init_done = TRUE;

        // if this block is not the final block of a multichannel sequence (and we're not truncating
        // to stereo), then enter this conditional block...otherwise we just unpack the samples directly

        if (!wpc->reduced_channels && !(wps->wphdr.flags & FINAL_BLOCK)) {
            int32_t *temp_buffer = malloc (samples_to_unpack * 8), *src, *dst;
            int offset = 0;     // offset to next channel in sequence (0 to num_channels - 1)
            uint32_t samcnt;

            // since we are getting samples from multiple bocks in a multichannel sequence, we must
            // allocate a temporary buffer to unpack to so that we can re-interleave the samples

	    if (!temp_buffer)
		break;

            // loop through all the streams...

            while (1) {

                // if the stream has not been allocated and corresponding block read, do that here...

                if (wpc->current_stream == wpc->num_streams) {
                    wpc->streams = realloc (wpc->streams, (wpc->num_streams + 1) * sizeof (wpc->streams [0]));

                    if (!wpc->streams)
			break;

                    wps = wpc->streams [wpc->num_streams++] = malloc (sizeof (WavpackStream));

                    if (!wps)
			break;

                    CLEAR (*wps);
                    bcount = read_next_header (wpc->reader, wpc->wv_in, &wps->wphdr);

                    if (bcount == (uint32_t) -1) {
                        wpc->streams [0]->wphdr.block_samples = 0;
                        wpc->streams [0]->wphdr.ckSize = 24;
                        file_done = TRUE;
                        break;
                    }

                    wps->blockbuff = malloc (wps->wphdr.ckSize + 8);

                    if (!wps->blockbuff)
		        break;

                    memcpy (wps->blockbuff, &wps->wphdr, 32);

                    if (wpc->reader->read_bytes (wpc->wv_in, wps->blockbuff + 32, wps->wphdr.ckSize - 24) !=
                        wps->wphdr.ckSize - 24) {
                            wpc->streams [0]->wphdr.block_samples = 0;
                            wpc->streams [0]->wphdr.ckSize = 24;
                            file_done = TRUE;
                            break;
                    }

                    // render corrupt blocks harmless
                    if (!WavpackVerifySingleBlock (wps->blockbuff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
                        wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
                        wps->wphdr.block_samples = 0;
                        memcpy (wps->blockbuff, &wps->wphdr, 32);
                    }

                    // potentially adjusting block_index must be done AFTER verifying block

                    if (wpc->open_flags & OPEN_STREAMING)
                        SET_BLOCK_INDEX (wps->wphdr, wps->sample_index = 0);
                    else
                        SET_BLOCK_INDEX (wps->wphdr, GET_BLOCK_INDEX (wps->wphdr) - wpc->initial_index);

                    memcpy (wps->blockbuff, &wps->wphdr, 32);

                    // if this block has audio, and we're in hybrid lossless mode, read the matching wvc block

                    if (wpc->wvc_flag)
                        read_wvc_block (wpc);

                    // initialize the unpacker for this block

                    if (!unpack_init (wpc))
                        wpc->crc_errors++;

                    wps->init_done = TRUE;
                }
                else
                    wps = wpc->streams [wpc->current_stream];

                // unpack the correct number of samples (either mono or stereo) into the temp buffer

#ifdef ENABLE_DSD
                if (wps->wphdr.flags & DSD_FLAG)
                    unpack_dsd_samples (wpc, src = temp_buffer, samples_to_unpack);
                else
#endif
                    unpack_samples (wpc, src = temp_buffer, samples_to_unpack);

                samcnt = samples_to_unpack;
                dst = bptr + offset;

                // if the block is mono, copy the samples from the single channel into the destination
                // using num_channels as the stride

                if (wps->wphdr.flags & MONO_FLAG) {
                    while (samcnt--) {
                        dst [0] = *src++;
                        dst += num_channels;
                    }

                    offset++;
                }

                // if the block is stereo, and we don't have room for two more channels, just copy one
                // and flag an error

                else if (offset == num_channels - 1) {
                    while (samcnt--) {
                        dst [0] = src [0];
                        dst += num_channels;
                        src += 2;
                    }

                    wpc->crc_errors++;
                    offset++;
                }

                // otherwise copy the stereo samples into the destination

                else {
                    while (samcnt--) {
                        dst [0] = *src++;
                        dst [1] = *src++;
                        dst += num_channels;
                    }

                    offset += 2;
                }

                // check several clues that we're done with this set of blocks and exit if we are; else do next stream

                if ((wps->wphdr.flags & FINAL_BLOCK) || wpc->current_stream == wpc->max_streams - 1 || offset == num_channels)
                    break;
                else
                    wpc->current_stream++;
            }

            // if we didn't get all the channels we expected, mute the buffer and flag an error

            if (offset != num_channels) {
                if (wps->wphdr.flags & DSD_FLAG) {
                    int samples_to_zero = samples_to_unpack * num_channels;
                    int32_t *zptr = bptr;

                    while (samples_to_zero--)
                        *zptr++ = 0x55;
                }
                else
                    memset (bptr, 0, samples_to_unpack * num_channels * 4);

                wpc->crc_errors++;
            }

            // go back to the first stream (we're going to leave them all loaded for now because they might have more samples)
            // and free the temp buffer

            wps = wpc->streams [wpc->current_stream = 0];
            free (temp_buffer);
        }
        // catch the error situation where we have only one channel but run into a stereo block
        // (this avoids overwriting the caller's buffer)
        else if (!(wps->wphdr.flags & MONO_FLAG) && (num_channels == 1 || wpc->reduced_channels == 1)) {
            memset (bptr, 0, samples_to_unpack * sizeof (*bptr));
            wps->sample_index += samples_to_unpack;
            wpc->crc_errors++;
        }
#ifdef ENABLE_DSD
        else if (wps->wphdr.flags & DSD_FLAG)
            unpack_dsd_samples (wpc, bptr, samples_to_unpack);
#endif
        else
            unpack_samples (wpc, bptr, samples_to_unpack);

        if (file_done) {
            strcpy (wpc->error_message, "can't read all of last block!");
            break;
        }

        if (wpc->reduced_channels)
            bptr += samples_to_unpack * wpc->reduced_channels;
        else
            bptr += samples_to_unpack * num_channels;

        samples_unpacked += samples_to_unpack;
        samples -= samples_to_unpack;

        // if we just finished a block, check for a calculated crc error
        // (and back up the streams a little if possible in case we passed a header)

        if (wps->sample_index == GET_BLOCK_INDEX (wps->wphdr) + wps->wphdr.block_samples) {
            if (check_crc_error (wpc)) {
                int32_t *zptr = bptr, zvalue = (wps->wphdr.flags & DSD_FLAG) ? 0x55 : 0;
                uint32_t samples_to_zero = wps->wphdr.block_samples;

                if (samples_to_zero > samples_to_unpack)
                    samples_to_zero = samples_to_unpack;

                samples_to_zero *= (wpc->reduced_channels ? wpc->reduced_channels : num_channels);

                while (samples_to_zero--)
                    *--zptr = zvalue;

                if (wps->blockbuff && wpc->reader->can_seek (wpc->wv_in)) {
                    int32_t rseek = ((WavpackHeader *) wps->blockbuff)->ckSize / 3;
                    wpc->reader->set_pos_rel (wpc->wv_in, (rseek > 16384) ? -16384 : -rseek, SEEK_CUR);
                }

                if (wpc->wvc_flag && wps->block2buff && wpc->reader->can_seek (wpc->wvc_in)) {
                    int32_t rseek = ((WavpackHeader *) wps->block2buff)->ckSize / 3;
                    wpc->reader->set_pos_rel (wpc->wvc_in, (rseek > 16384) ? -16384 : -rseek, SEEK_CUR);
                }

                wpc->crc_errors++;
            }
        }

        if (wpc->total_samples != -1 && wps->sample_index == wpc->total_samples)
            break;
    }

#ifdef ENABLE_DSD
    if (wpc->decimation_context)
        decimate_dsd_run (wpc->decimation_context, buffer, samples_unpacked);
#endif

    return samples_unpacked;
}

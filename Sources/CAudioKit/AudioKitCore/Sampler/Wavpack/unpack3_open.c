////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// unpack3_open.c

// This module provides an extension to the open_utils.c module for handling
// WavPack files prior to version 4.0, not including "raw" files. As these
// modes are all obsolete and are no longer written, this code will not be
// fully documented other than the global functions. However, full documenation
// is provided in the version 3.97 source code. Note that this module only
// provides the functionality of opening the files and obtaining information
// from them; the actual audio decoding is located in the unpack3.c module.

#ifdef ENABLE_LEGACY

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"
#include "unpack3.h"

#define ATTEMPT_ERROR_MUTING

// This provides an extension to the WavpackOpenFileRead () function contained
// in the wputils.c module. It is assumed that an 'R' had been read as the
// first character of the file/stream (indicating a non-raw pre version 4.0
// WavPack file) and had been pushed back onto the stream (or simply seeked
// back to).

WavpackContext *open_file3 (WavpackContext *wpc, char *error)
{
    RiffChunkHeader RiffChunkHeader;
    WpChunkHeader WpChunkHeader;
    WavpackHeader3 wphdr;
    WavpackStream3 *wps;
    WaveHeader3 wavhdr;

    CLEAR (wavhdr);
    wpc->stream3 = wps = (WavpackStream3 *) malloc (sizeof (WavpackStream3));
    CLEAR (*wps);

    if (wpc->reader->read_bytes (wpc->wv_in, &RiffChunkHeader, sizeof (RiffChunkHeader)) !=
        sizeof (RiffChunkHeader)) {
            if (error) strcpy (error, "not a valid WavPack file!");
            return WavpackCloseFile (wpc);
    }

    if (!strncmp (RiffChunkHeader.ckID, "RIFF", 4) && !strncmp (RiffChunkHeader.formType, "WAVE", 4)) {

        if (wpc->open_flags & OPEN_WRAPPER) {
            wpc->wrapper_data = malloc (wpc->wrapper_bytes = sizeof (RiffChunkHeader));
            memcpy (wpc->wrapper_data, &RiffChunkHeader, sizeof (RiffChunkHeader));
        }

    // If the first chunk is a wave RIFF header, then read the various chunks
    // until we get to the "data" chunk (and WavPack header should follow). If
    // the first chunk is not a RIFF, then we assume a "raw" WavPack file and
    // the WavPack header must be first.

        while (1) {

            if (wpc->reader->read_bytes (wpc->wv_in, &WpChunkHeader, sizeof (WpChunkHeader)) !=
                sizeof (WpChunkHeader)) {
                    if (error) strcpy (error, "not a valid WavPack file!");
                    return WavpackCloseFile (wpc);
            }
            else {
                if (wpc->open_flags & OPEN_WRAPPER) {
                    wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + sizeof (WpChunkHeader));
                    memcpy (wpc->wrapper_data + wpc->wrapper_bytes, &WpChunkHeader, sizeof (WpChunkHeader));
                    wpc->wrapper_bytes += sizeof (WpChunkHeader);
                }

                WavpackLittleEndianToNative (&WpChunkHeader, ChunkHeaderFormat);

                if (!strncmp (WpChunkHeader.ckID, "fmt ", 4)) {

                    if (WpChunkHeader.ckSize < sizeof (wavhdr) ||
                        wpc->reader->read_bytes (wpc->wv_in, &wavhdr, sizeof (wavhdr)) != sizeof (wavhdr)) {
                            if (error) strcpy (error, "not a valid WavPack file!");
                            return WavpackCloseFile (wpc);
                    }
                    else if (wpc->open_flags & OPEN_WRAPPER) {
                        wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + sizeof (wavhdr));
                        memcpy (wpc->wrapper_data + wpc->wrapper_bytes, &wavhdr, sizeof (wavhdr));
                        wpc->wrapper_bytes += sizeof (wavhdr);
                    }

                    WavpackLittleEndianToNative (&wavhdr, WaveHeader3Format);

                    if (WpChunkHeader.ckSize > sizeof (wavhdr)) {
                        uint32_t bytes_to_skip = (WpChunkHeader.ckSize + 1 - sizeof (wavhdr)) & ~1L;

                        if (bytes_to_skip > 1024 * 1024) {
                            if (error) strcpy (error, "not a valid WavPack file!");
                            return WavpackCloseFile (wpc);
                        }

                        if (wpc->open_flags & OPEN_WRAPPER) {
                            wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + bytes_to_skip);
                            wpc->reader->read_bytes (wpc->wv_in, wpc->wrapper_data + wpc->wrapper_bytes, bytes_to_skip);
                            wpc->wrapper_bytes += bytes_to_skip;
                        }
                        else {
                            unsigned char *temp = malloc (bytes_to_skip);
                            wpc->reader->read_bytes (wpc->wv_in, temp, bytes_to_skip);
                            free (temp);
                        }
                    }
                }
                else if (!strncmp (WpChunkHeader.ckID, "data", 4))
                    break;
                else if ((WpChunkHeader.ckSize + 1) & ~1L) {
                    uint32_t bytes_to_skip = (WpChunkHeader.ckSize + 1) & ~1L;

                    if (bytes_to_skip > 1024 * 1024) {
                        if (error) strcpy (error, "not a valid WavPack file!");
                        return WavpackCloseFile (wpc);
                    }

                    if (wpc->open_flags & OPEN_WRAPPER) {
                        wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + bytes_to_skip);
                        wpc->reader->read_bytes (wpc->wv_in, wpc->wrapper_data + wpc->wrapper_bytes, bytes_to_skip);
                        wpc->wrapper_bytes += bytes_to_skip;
                    }
                    else {
                        unsigned char *temp = malloc (bytes_to_skip);
                        wpc->reader->read_bytes (wpc->wv_in, temp, bytes_to_skip);
                        free (temp);
                    }
                }
            }
        }
    }
    else {
        if (error) strcpy (error, "not a valid WavPack file!");
        return WavpackCloseFile (wpc);
    }

    if (wavhdr.FormatTag != 1 || !wavhdr.NumChannels || wavhdr.NumChannels > 2 ||
        !wavhdr.SampleRate || wavhdr.BitsPerSample < 16 || wavhdr.BitsPerSample > 24 ||
        wavhdr.BlockAlign / wavhdr.NumChannels > 3 || wavhdr.BlockAlign % wavhdr.NumChannels ||
        wavhdr.BlockAlign / wavhdr.NumChannels < (wavhdr.BitsPerSample + 7) / 8) {
            if (error) strcpy (error, "not a valid WavPack file!");
            return WavpackCloseFile (wpc);
    }

    wpc->total_samples = WpChunkHeader.ckSize / wavhdr.NumChannels /
        ((wavhdr.BitsPerSample > 16) ? 3 : 2);

    if (wpc->reader->read_bytes (wpc->wv_in, &wphdr, 10) != 10) {
        if (error) strcpy (error, "not a valid WavPack file!");
        return WavpackCloseFile (wpc);
    }

    if (((char *) &wphdr) [8] == 2 && (wpc->reader->read_bytes (wpc->wv_in, ((char *) &wphdr) + 10, 2) != 2)) {
        if (error) strcpy (error, "not a valid WavPack file!");
        return WavpackCloseFile (wpc);
    }
    else if (((char *) &wphdr) [8] == 3 && (wpc->reader->read_bytes (wpc->wv_in, ((char *) &wphdr) + 10,
        sizeof (wphdr) - 10) != sizeof (wphdr) - 10)) {
            if (error) strcpy (error, "not a valid WavPack file!");
            return WavpackCloseFile (wpc);
    }

    WavpackLittleEndianToNative (&wphdr, WavpackHeader3Format);

    // make sure this is a version we know about

    if (strncmp (wphdr.ckID, "wvpk", 4) || wphdr.version < 1 || wphdr.version > 3) {
        if (error) strcpy (error, "not a valid WavPack file!");
        return WavpackCloseFile (wpc);
    }

    // Because I ran out of flag bits in the WavPack header, an amazingly ugly
    // kludge was forced upon me! This code takes care of preparing the flags
    // field for internal use and checking for unknown formats we can't decode

    if (wphdr.version == 3) {

        if (wphdr.flags & EXTREME_DECORR) {

            if ((wphdr.flags & NOT_STORED_FLAGS) ||
                ((wphdr.bits) &&
                (((wphdr.flags & NEW_HIGH_FLAG) &&
                (wphdr.flags & (FAST_FLAG | HIGH_FLAG))) ||
                (wphdr.flags & CROSS_DECORR)))) {
                    if (error) strcpy (error, "not a valid WavPack file!");
                    return WavpackCloseFile (wpc);
            }

            if (wphdr.flags & CANCEL_EXTREME)
                wphdr.flags &= ~(EXTREME_DECORR | CANCEL_EXTREME);
        }
        else
            wphdr.flags &= ~CROSS_DECORR;
    }

    // check to see if we should look for a "correction" file, and if so try
    // to open it for reading, then set WVC_FLAG accordingly

    if (wpc->wvc_in && wphdr.version == 3 && wphdr.bits && (wphdr.flags & NEW_HIGH_FLAG)) {
        wpc->file2len = wpc->reader->get_length (wpc->wvc_in);
        wphdr.flags |= WVC_FLAG;
        wpc->wvc_flag = TRUE;
    }
    else
        wphdr.flags &= ~WVC_FLAG;

    // check WavPack version to handle special requirements of versions
    // before 3.0 that had smaller headers

    if (wphdr.version < 3) {
        wphdr.total_samples = (int32_t) wpc->total_samples;
        wphdr.flags = wavhdr.NumChannels == 1 ? MONO_FLAG : 0;
        wphdr.shift = 16 - wavhdr.BitsPerSample;

        if (wphdr.version == 1)
            wphdr.bits = 0;
    }

    wpc->config.sample_rate = wavhdr.SampleRate;
    wpc->config.num_channels = wavhdr.NumChannels;
    wpc->config.channel_mask = 5 - wavhdr.NumChannels;

    if (wphdr.flags & MONO_FLAG)
        wpc->config.flags |= CONFIG_MONO_FLAG;

    if (wphdr.flags & EXTREME_DECORR)
        wpc->config.flags |= CONFIG_HIGH_FLAG;

    if (wphdr.bits) {
        if (wphdr.flags & NEW_HIGH_FLAG)
            wpc->config.flags |= CONFIG_HYBRID_FLAG;
        else
            wpc->config.flags |= CONFIG_LOSSY_MODE;
    }
    else if (!(wphdr.flags & HIGH_FLAG))
        wpc->config.flags |= CONFIG_FAST_FLAG;

    wpc->config.bytes_per_sample = (wphdr.flags & BYTES_3) ? 3 : 2;
    wpc->config.bits_per_sample = wavhdr.BitsPerSample;

    memcpy (&wps->wphdr, &wphdr, sizeof (wphdr));
    wps->wvbits.bufsiz = wps->wvcbits.bufsiz = 1024 * 1024;
    return wpc;
}

// return currently decoded sample index

uint32_t get_sample_index3 (WavpackContext *wpc)
{
    WavpackStream3 *wps = (WavpackStream3 *) wpc->stream3;

    return (wps) ? wps->sample_index : (uint32_t) -1;
}

int get_version3 (WavpackContext *wpc)
{
    WavpackStream3 *wps = (WavpackStream3 *) wpc->stream3;

    return (wps) ? wps->wphdr.version : 0;
}

void free_stream3 (WavpackContext *wpc)
{
    WavpackStream3 *wps = (WavpackStream3 *) wpc->stream3;

    if (wps) {
#ifndef NO_SEEKING
        if (wps->unpack_data)
            free (wps->unpack_data);
#endif
        if ((wps->wphdr.flags & WVC_FLAG) && wps->wvcbits.buf)
            free (wps->wvcbits.buf);

        if (wps->wvbits.buf)
            free (wps->wvbits.buf);

        free (wps);
    }
}

#endif  // ENABLE_LEGACY

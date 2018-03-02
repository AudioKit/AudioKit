////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2006 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// wputils.c

// This module provides a high-level interface for decoding WavPack 4.0 audio
// streams and files. WavPack data is read with a stream reading callback. No
// direct seeking is provided for, but it is possible to start decoding
// anywhere in a WavPack stream. In this case, WavPack will be able to provide
// the sample-accurate position when it synchs with the data and begins
// decoding.

#include "wavpack.h"

#include <string.h>

///////////////////////////// local table storage ////////////////////////////

const uint32_t sample_rates [] = { 6000, 8000, 9600, 11025, 12000, 16000, 22050,
    24000, 32000, 44100, 48000, 64000, 88200, 96000, 192000 };

///////////////////////////// executable code ////////////////////////////////

static uint32_t read_next_header (read_stream infile, WavpackHeader *wphdr);
        
// This function reads data from the specified stream in search of a valid
// WavPack 4.0 audio block. If this fails in 1 megabyte (or an invalid or
// unsupported WavPack block is encountered) then an appropriate message is
// copied to "error" and NULL is returned, otherwise a pointer to a
// WavpackContext structure is returned (which is used to call all other
// functions in this module). This can be initiated at the beginning of a
// WavPack file, or anywhere inside a WavPack file. To determine the exact
// position within the file use WavpackGetSampleIndex(). For demonstration
// purposes this uses a single static copy of the WavpackContext structure,
// so obviously it cannot be used for more than one file at a time. Also,
// this function will not handle "correction" files, plays only the first
// two channels of multi-channel files, and is limited in resolution in some
// large integer or floating point files (but always provides at least 24 bits
// of resolution).

static WavpackContext wpc;

WavpackContext *WavpackOpenFileInput (read_stream infile, char *error)
{
    WavpackStream *wps = &wpc.stream;
    uint32_t bcount;

    CLEAR (wpc);
    wpc.infile = infile;
    wpc.total_samples = (uint32_t) -1;
    wpc.norm_offset = 0;
    wpc.open_flags = 0;

    // open the source file for reading and store the size

    while (!wps->wphdr.block_samples) {

        bcount = read_next_header (wpc.infile, &wps->wphdr);

        if (bcount == (uint32_t) -1) {
            strcpy (error, "not compatible with this version of WavPack file!");
            return NULL;
        }

        if (wps->wphdr.block_samples && wps->wphdr.total_samples != (uint32_t) -1)
            wpc.total_samples = wps->wphdr.total_samples;

        if (!unpack_init (&wpc)) {
            strcpy (error, wpc.error_message [0] ? wpc.error_message :
                "not compatible with this version of WavPack file!");

            return NULL;
        }
    }

    wpc.config.flags &= ~0xff;
    wpc.config.flags |= wps->wphdr.flags & 0xff;
    wpc.config.bytes_per_sample = (wps->wphdr.flags & BYTES_STORED) + 1;
    wpc.config.float_norm_exp = wps->float_norm_exp;

    wpc.config.bits_per_sample = (wpc.config.bytes_per_sample * 8) - 
        ((wps->wphdr.flags & SHIFT_MASK) >> SHIFT_LSB);

    if (wpc.config.flags & FLOAT_DATA) {
        wpc.config.bytes_per_sample = 3;
        wpc.config.bits_per_sample = 24;
    }

    if (!wpc.config.sample_rate) {
        if (!wps || !wps->wphdr.block_samples || (wps->wphdr.flags & SRATE_MASK) == SRATE_MASK)
            wpc.config.sample_rate = 44100;
        else
            wpc.config.sample_rate = sample_rates [(wps->wphdr.flags & SRATE_MASK) >> SRATE_LSB];
    }

    if (!wpc.config.num_channels) {
        wpc.config.num_channels = (wps->wphdr.flags & MONO_FLAG) ? 1 : 2;
        wpc.config.channel_mask = 0x5 - wpc.config.num_channels;
    }

    if (!(wps->wphdr.flags & FINAL_BLOCK))
        wpc.reduced_channels = (wps->wphdr.flags & MONO_FLAG) ? 1 : 2;

    return &wpc;
}

// This function obtains general information about an open file and returns
// a mask with the following bit values:

// MODE_LOSSLESS:  file is lossless (pure lossless only)
// MODE_HYBRID:  file is hybrid mode (lossy part only)
// MODE_FLOAT:  audio data is 32-bit ieee floating point (but will provided
//               in 24-bit integers for convenience)
// MODE_HIGH:  file was created in "high" mode (information only)
// MODE_FAST:  file was created in "fast" mode (information only)

int WavpackGetMode (WavpackContext *wpc)
{
    int mode = 0;

    if (wpc) {
        if (wpc->config.flags & CONFIG_HYBRID_FLAG)
            mode |= MODE_HYBRID;
        else if (!(wpc->config.flags & CONFIG_LOSSY_MODE))
            mode |= MODE_LOSSLESS;

        if (wpc->lossy_blocks)
            mode &= ~MODE_LOSSLESS;

        if (wpc->config.flags & CONFIG_FLOAT_DATA)
            mode |= MODE_FLOAT;

        if (wpc->config.flags & CONFIG_HIGH_FLAG)
            mode |= MODE_HIGH;

        if (wpc->config.flags & CONFIG_FAST_FLAG)
            mode |= MODE_FAST;
    }

    return mode;
}

// Unpack the specified number of samples from the current file position.
// Note that "samples" here refers to "complete" samples, which would be
// 2 longs for stereo files. The audio data is returned right-justified in
// 32-bit longs in the endian mode native to the executing processor. So,
// if the original data was 16-bit, then the values returned would be
// +/-32k. Floating point data will be returned as 24-bit integers (and may
// also be clipped). The actual number of samples unpacked is returned,
// which should be equal to the number requested unless the end of fle is
// encountered or an error occurs.

uint32_t WavpackUnpackSamples (WavpackContext *wpc, int32_t *buffer, uint32_t samples)
{
    WavpackStream *wps = &wpc->stream;
    uint32_t bcount, samples_unpacked = 0, samples_to_unpack;
    int num_channels = wpc->config.num_channels;

    while (samples) {
        if (!wps->wphdr.block_samples || !(wps->wphdr.flags & INITIAL_BLOCK) ||
            wps->sample_index >= wps->wphdr.block_index + wps->wphdr.block_samples) {
                bcount = read_next_header (wpc->infile, &wps->wphdr);

                if (bcount == (uint32_t) -1)
                    break;

                if (!wps->wphdr.block_samples || wps->sample_index == wps->wphdr.block_index)
                    if (!unpack_init (wpc))
                        break;
        }

        if (!wps->wphdr.block_samples || !(wps->wphdr.flags & INITIAL_BLOCK) ||
            wps->sample_index >= wps->wphdr.block_index + wps->wphdr.block_samples)
                continue;

        if (wps->sample_index < wps->wphdr.block_index) {
            samples_to_unpack = wps->wphdr.block_index - wps->sample_index;

            if (samples_to_unpack > samples)
                samples_to_unpack = samples;

            wps->sample_index += samples_to_unpack;
            samples_unpacked += samples_to_unpack;
            samples -= samples_to_unpack;

            if (wpc->reduced_channels)
                samples_to_unpack *= wpc->reduced_channels;
            else
                samples_to_unpack *= num_channels;

            while (samples_to_unpack--)
                *buffer++ = 0;

            continue;
        }

        samples_to_unpack = wps->wphdr.block_index + wps->wphdr.block_samples - wps->sample_index;

        if (samples_to_unpack > samples)
            samples_to_unpack = samples;

        unpack_samples (wpc, buffer, samples_to_unpack);

        if (wpc->reduced_channels)
            buffer += samples_to_unpack * wpc->reduced_channels;
        else
            buffer += samples_to_unpack * num_channels;

        samples_unpacked += samples_to_unpack;
        samples -= samples_to_unpack;

        if (wps->sample_index == wps->wphdr.block_index + wps->wphdr.block_samples) {
            if (check_crc_error (wpc))
                wpc->crc_errors++;
        }

        if (wps->sample_index == wpc->total_samples)
            break;
    }

    return samples_unpacked;
}

// Get total number of samples contained in the WavPack file, or -1 if unknown

uint32_t WavpackGetNumSamples (WavpackContext *wpc)
{
    return wpc ? wpc->total_samples : (uint32_t) -1;
}

// Get the current sample index position, or -1 if unknown

uint32_t WavpackGetSampleIndex (WavpackContext *wpc)
{
    if (wpc)
        return wpc->stream.sample_index;

    return (uint32_t) -1;
}

// Get the number of errors encountered so far

int WavpackGetNumErrors (WavpackContext *wpc)
{
    return wpc ? wpc->crc_errors : 0;
}

// return TRUE if any uncorrected lossy blocks were actually written or read

int WavpackLossyBlocks (WavpackContext *wpc)
{
    return wpc ? wpc->lossy_blocks : 0;
}

// Returns the sample rate of the specified WavPack file

uint32_t WavpackGetSampleRate (WavpackContext *wpc)
{
    return wpc ? wpc->config.sample_rate : 44100;
}

// Returns the number of channels of the specified WavPack file. Note that
// this is the actual number of channels contained in the file, but this
// version can only decode the first two.

int WavpackGetNumChannels (WavpackContext *wpc)
{
    return wpc ? wpc->config.num_channels : 2;
}

// Returns the actual number of valid bits per sample contained in the
// original file, which may or may not be a multiple of 8. Floating data
// always has 32 bits, integers may be from 1 to 32 bits each. When this
// value is not a multiple of 8, then the "extra" bits are located in the
// LSBs of the results. That is, values are right justified when unpacked
// into longs, but are left justified in the number of bytes used by the
// original data.

int WavpackGetBitsPerSample (WavpackContext *wpc)
{
    return wpc ? wpc->config.bits_per_sample : 16;
}

// Returns the number of bytes used for each sample (1 to 4) in the original
// file. This is required information for the user of this module because the
// audio data is returned in the LOWER bytes of the long buffer and must be
// left-shifted 8, 16, or 24 bits if normalized longs are required.

int WavpackGetBytesPerSample (WavpackContext *wpc)
{
    return wpc ? wpc->config.bytes_per_sample : 2;
}

// This function will return the actual number of channels decoded from the
// file (which may or may not be less than the actual number of channels, but
// will always be 1 or 2). Normally, this will be the front left and right
// channels of a multi-channel file.

int WavpackGetReducedChannels (WavpackContext *wpc)
{
    if (wpc)
        return wpc->reduced_channels ? wpc->reduced_channels : wpc->config.num_channels;
    else
        return 2;
}

// Read from current file position until a valid 32-byte WavPack 4.0 header is
// found and read into the specified pointer. The number of bytes skipped is
// returned. If no WavPack header is found within 1 meg, then a -1 is returned
// to indicate the error. No additional bytes are read past the header and it
// is returned in the processor's native endian mode. Seeking is not required.

static uint32_t read_next_header (read_stream infile, WavpackHeader *wphdr)
{
    char buffer [sizeof (*wphdr)], *sp = buffer + sizeof (*wphdr), *ep = sp;
    uint32_t bytes_skipped = 0;
    int bleft;

    while (1) {
        if (sp < ep) {
            bleft = (int)(ep - sp);
            memcpy (buffer, sp, bleft);
        }
        else
            bleft = 0;

        if (infile (buffer + bleft, sizeof (*wphdr) - bleft) != (int32_t) sizeof (*wphdr) - bleft)
            return -1;

        sp = buffer;

        if (*sp++ == 'w' && *sp == 'v' && *++sp == 'p' && *++sp == 'k' &&
            !(*++sp & 1) && sp [2] < 16 && !sp [3] && sp [5] == 4 &&
            sp [4] >= (MIN_STREAM_VERS & 0xff) && sp [4] <= (MAX_STREAM_VERS & 0xff)) {
                memcpy (wphdr, buffer, sizeof (*wphdr));
                little_endian_to_native (wphdr, WavpackHeaderFormat);
                return bytes_skipped;
            }

        while (sp < ep && *sp != 'w')
            sp++;

        if ((bytes_skipped += sp - buffer) > 1048576L)
            return -1;
    }
}

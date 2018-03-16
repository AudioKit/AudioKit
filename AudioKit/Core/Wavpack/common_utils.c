////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// common_utils.c

// This module provides a lot of the trivial WavPack API functions and several
// functions that are common to both reading and writing WavPack files (like
// WavpackCloseFile()). Functions here are restricted to those that have few
// external dependancies and this is done so that applications that statically
// link to the WavPack library (like the command-line utilities on Windows)
// do not need to include the entire library image if they only use a subset
// of it. This module will be loaded for ANY WavPack application.

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "wavpack_local.h"

#ifndef LIBWAVPACK_VERSION_STRING
#include "wavpack_version.h"
#endif

///////////////////////////// local table storage ////////////////////////////

const uint32_t sample_rates [] = { 6000, 8000, 9600, 11025, 12000, 16000, 22050,
    24000, 32000, 44100, 48000, 64000, 88200, 96000, 192000 };

///////////////////////////// executable code ////////////////////////////////

// This function obtains general information about an open input file and
// returns a mask with the following bit values:

// MODE_WVC:  a .wvc file has been found and will be used for lossless
// MODE_LOSSLESS:  file is lossless (either pure or hybrid)
// MODE_HYBRID:  file is hybrid mode (either lossy or lossless)
// MODE_FLOAT:  audio data is 32-bit ieee floating point
// MODE_VALID_TAG:  file conatins a valid ID3v1 or APEv2 tag
// MODE_HIGH:  file was created in "high" mode (information only)
// MODE_FAST:  file was created in "fast" mode (information only)
// MODE_EXTRA:  file was created using "extra" mode (information only)
// MODE_APETAG:  file contains a valid APEv2 tag
// MODE_SFX:  file was created as a "self-extracting" executable
// MODE_VERY_HIGH:  file was created in the "very high" mode (or in
//                  the "high" mode prior to 4.4)
// MODE_MD5:  file contains an MD5 checksum
// MODE_XMODE:  level used for extra mode (1-6, 0=unknown)
// MODE_DNS:  dynamic noise shaping

int WavpackGetMode (WavpackContext *wpc)
{
    int mode = 0;

    if (wpc) {
        if (wpc->config.flags & CONFIG_HYBRID_FLAG)
            mode |= MODE_HYBRID;
        else if (!(wpc->config.flags & CONFIG_LOSSY_MODE))
            mode |= MODE_LOSSLESS;

        if (wpc->wvc_flag)
            mode |= (MODE_LOSSLESS | MODE_WVC);

        if (wpc->lossy_blocks)
            mode &= ~MODE_LOSSLESS;

        if (wpc->config.flags & CONFIG_FLOAT_DATA)
            mode |= MODE_FLOAT;

        if (wpc->config.flags & (CONFIG_HIGH_FLAG | CONFIG_VERY_HIGH_FLAG)) {
            mode |= MODE_HIGH;

            if ((wpc->config.flags & CONFIG_VERY_HIGH_FLAG) ||
                (wpc->streams && wpc->streams [0] && wpc->streams [0]->wphdr.version < 0x405))
                    mode |= MODE_VERY_HIGH;
        }

        if (wpc->config.flags & CONFIG_FAST_FLAG)
            mode |= MODE_FAST;

        if (wpc->config.flags & CONFIG_EXTRA_MODE)
            mode |= (MODE_EXTRA | (wpc->config.xmode << 12));

        if (wpc->config.flags & CONFIG_CREATE_EXE)
            mode |= MODE_SFX;

        if (wpc->config.flags & CONFIG_MD5_CHECKSUM)
            mode |= MODE_MD5;

        if ((wpc->config.flags & CONFIG_HYBRID_FLAG) && (wpc->config.flags & CONFIG_DYNAMIC_SHAPING) &&
            wpc->streams && wpc->streams [0] && wpc->streams [0]->wphdr.version >= 0x407)
                mode |= MODE_DNS;

#ifndef NO_TAGS
        if (valid_tag (&wpc->m_tag)) {
            mode |= MODE_VALID_TAG;

            if (valid_tag (&wpc->m_tag) == 'A')
                mode |= MODE_APETAG;
        }
#endif

        mode |= (wpc->config.qmode << 16) & 0xFF0000;
    }

    return mode;
}

// This function obtains information about specific file features that were
// added for version 5.0, specifically qualifications added to support CAF
// and DSD files. Except for indicating the presence of DSD data, these
// bits are meant to simply indicate the format of the data in the original
// source file and do NOT indicate how the library will return the data to
// the appication (which is always the same). This means that in general an
// application that simply wants to play or process the audio data need not
// be concerned about these. If the file is DSD audio, then either of the
// QMDOE_DSD_LSB_FIRST or QMODE_DSD_MSB_FIRST bits will be set (but the
// DSD audio is always returned to the caller MSB first).

// QMODE_BIG_ENDIAN        0x1     // big-endian data format (opposite of WAV format)
// QMODE_SIGNED_BYTES      0x2     // 8-bit audio data is signed (opposite of WAV format)
// QMODE_UNSIGNED_WORDS    0x4     // audio data (other than 8-bit) is unsigned (opposite of WAV format)
// QMODE_REORDERED_CHANS   0x8     // source channels were not Microsoft order, so they were reordered
// QMODE_DSD_LSB_FIRST     0x10    // DSD bytes, LSB first (most Sony .dsf files)
// QMODE_DSD_MSB_FIRST     0x20    // DSD bytes, MSB first (Philips .dff files)
// QMODE_DSD_IN_BLOCKS     0x40    // DSD data is blocked by channels (Sony .dsf only)

int WavpackGetQualifyMode (WavpackContext *wpc)
{
    return wpc->config.qmode & 0xFF;
}

// This function returns a pointer to a string describing the last error
// generated by WavPack.

char *WavpackGetErrorMessage (WavpackContext *wpc)
{
    return wpc->error_message;
}

// Get total number of samples contained in the WavPack file, or -1 if unknown

uint32_t WavpackGetNumSamples (WavpackContext *wpc)
{
    return (uint32_t) WavpackGetNumSamples64 (wpc);
}

int64_t WavpackGetNumSamples64 (WavpackContext *wpc)
{
    return wpc ? wpc->total_samples : -1;
}

// Get the current sample index position, or -1 if unknown

uint32_t WavpackGetSampleIndex (WavpackContext *wpc)
{
    return (uint32_t) WavpackGetSampleIndex64 (wpc);
}

int64_t WavpackGetSampleIndex64 (WavpackContext *wpc)
{
    if (wpc) {
#ifdef ENABLE_LEGACY
        if (wpc->stream3)
            return get_sample_index3 (wpc);
        else if (wpc->streams && wpc->streams [0])
            return wpc->streams [0]->sample_index;
#else
        if (wpc->streams && wpc->streams [0])
            return wpc->streams [0]->sample_index;
#endif
    }

    return -1;
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

// Calculate the progress through the file as a double from 0.0 (for begin)
// to 1.0 (for done). A return value of -1.0 indicates that the progress is
// unknown.

double WavpackGetProgress (WavpackContext *wpc)
{
    if (wpc && wpc->total_samples != -1 && wpc->total_samples != 0)
        return (double) WavpackGetSampleIndex64 (wpc) / wpc->total_samples;
    else
        return -1.0;
}

// Return the total size of the WavPack file(s) in bytes.

uint32_t WavpackGetFileSize (WavpackContext *wpc)
{
    return (uint32_t) (wpc ? wpc->filelen + wpc->file2len : 0);
}

int64_t WavpackGetFileSize64 (WavpackContext *wpc)
{
    return wpc ? wpc->filelen + wpc->file2len : 0;
}

// Calculate the ratio of the specified WavPack file size to the size of the
// original audio data as a double greater than 0.0 and (usually) smaller than
// 1.0. A value greater than 1.0 represents "negative" compression and a
// return value of 0.0 indicates that the ratio cannot be determined.

double WavpackGetRatio (WavpackContext *wpc)
{
    if (wpc && wpc->total_samples != -1 && wpc->filelen) {
        double output_size = (double) wpc->total_samples * wpc->config.num_channels *
            wpc->config.bytes_per_sample;
        double input_size = (double) wpc->filelen + wpc->file2len;

        if (output_size >= 1.0 && input_size >= 1.0)
            return input_size / output_size;
    }

    return 0.0;
}

// Calculate the average bitrate of the WavPack file in bits per second. A
// return of 0.0 indicates that the bitrate cannot be determined. An option is
// provided to use (or not use) any attendant .wvc file.

double WavpackGetAverageBitrate (WavpackContext *wpc, int count_wvc)
{
    if (wpc && wpc->total_samples != -1 && wpc->filelen) {
        double output_time = (double) wpc->total_samples / WavpackGetSampleRate (wpc);
        double input_size = (double) wpc->filelen + (count_wvc ? wpc->file2len : 0);

        if (output_time >= 0.1 && input_size >= 1.0)
            return input_size * 8.0 / output_time;
    }

    return 0.0;
}

// Calculate the bitrate of the current WavPack file block in bits per second.
// This can be used for an "instant" bit display and gets updated from about
// 1 to 4 times per second. A return of 0.0 indicates that the bitrate cannot
// be determined.

double WavpackGetInstantBitrate (WavpackContext *wpc)
{
    if (wpc && wpc->stream3)
        return WavpackGetAverageBitrate (wpc, TRUE);

    if (wpc && wpc->streams && wpc->streams [0] && wpc->streams [0]->wphdr.block_samples) {
        double output_time = (double) wpc->streams [0]->wphdr.block_samples / WavpackGetSampleRate (wpc);
        double input_size = 0;
        int si;

        for (si = 0; si < wpc->num_streams; ++si) {
            if (wpc->streams [si]->blockbuff)
                input_size += ((WavpackHeader *) wpc->streams [si]->blockbuff)->ckSize;

            if (wpc->streams [si]->block2buff)
                input_size += ((WavpackHeader *) wpc->streams [si]->block2buff)->ckSize;
        }

        if (output_time > 0.0 && input_size >= 1.0)
            return input_size * 8.0 / output_time;
    }

    return 0.0;
}

// This function allows retrieving the Core Audio File channel layout, many of which do not
// conform to the Microsoft ordering standard that WavPack requires internally (at least for
// those channels present in the "channel mask"). In addition to the layout tag, this function
// returns the reordering string (if stored in the file) to allow the unpacker to reorder the
// channels back to the specified layout (if it wants to restore the CAF order). The number of
// channels in the layout is determined from the lower nybble of the layout word (and should
// probably match the number of channels in the file), and if a reorder string is requested
// then that much space must be allocated. Note that all the reordering is actually done
// outside of this library, and that if reordering is done then the appropriate qmode bit
// will be set.
//
// Note: Normally this function would not be used by an application unless it specifically
// wanted to restore a non-standard channel order (to check an MD5, for example) or obtain
// the Core Audio channel layout ID. For simple file decoding for playback, the channel_mask
// should provide all the information required unless there are non-Microsoft channels
// involved, in which case WavpackGetChannelIdentities() will provide the identities of
// the other channels (if they are known).

uint32_t WavpackGetChannelLayout (WavpackContext *wpc, unsigned char *reorder)
{
    if ((wpc->channel_layout & 0xff) && wpc->channel_reordering && reorder)
        memcpy (reorder, wpc->channel_reordering, wpc->channel_layout & 0xff);

    return wpc->channel_layout;
}

// This function provides the identities of ALL the channels in the file, including the
// standard Microsoft channels (which come first, in order, and are numbered 1-18) and also
// any non-Microsoft channels (which can be in any order and have values from 33-254). The
// value 0x00 is invalid and 0xFF indicates an "unknown" or "unnassigned" channel. The
// string is NULL terminated so the caller must supply enough space for the number
// of channels indicated by WavpackGetNumChannels(), plus one.
//
// Note that this function returns the actual order of the channels in the Wavpack file
// (i.e., the order returned by WavpackUnpackSamples()). If the file includes a "reordering"
// string because the source file was not in Microsoft order that is NOT taken into account
// here and really only needs to be considered if doing an MD5 verification or if it's
// required to restore the original order/file (like wvunpack does).

void WavpackGetChannelIdentities (WavpackContext *wpc, unsigned char *identities)
{
    int num_channels = wpc->config.num_channels, index = 1;
    uint32_t channel_mask = wpc->config.channel_mask;
    unsigned char *src = wpc->channel_identities;

    while (num_channels--) {
        if (channel_mask) {
            while (!(channel_mask & 1)) {
                channel_mask >>= 1;
                index++;
            }

            *identities++ = index++;
            channel_mask >>= 1;
        }
        else if (src && *src)
            *identities++ = *src++;
        else
            *identities++ = 0xff;
    }

    *identities = 0;
}

// Close the specified WavPack file and release all resources used by it.
// Returns NULL.

WavpackContext *WavpackCloseFile (WavpackContext *wpc)
{
    if (wpc->streams) {
        free_streams (wpc);

        if (wpc->streams [0])
            free (wpc->streams [0]);

        free (wpc->streams);
    }

#ifdef ENABLE_LEGACY
    if (wpc->stream3)
        free_stream3 (wpc);
#endif

    if (wpc->reader && wpc->reader->close && wpc->wv_in)
        wpc->reader->close (wpc->wv_in);

    if (wpc->reader && wpc->reader->close && wpc->wvc_in)
        wpc->reader->close (wpc->wvc_in);

    WavpackFreeWrapper (wpc);

    if (wpc->channel_reordering)
        free (wpc->channel_reordering);

#ifndef NO_TAGS
    free_tag (&wpc->m_tag);
#endif

#ifdef ENABLE_DSD
    if (wpc->decimation_context)
        decimate_dsd_destroy (wpc->decimation_context);
#endif

    free (wpc);

    return NULL;
}

// These routines are used to access (and free) header and trailer data that
// was retrieved from the Wavpack file. The header will be available before
// the samples are decoded and the trailer will be available after all samples
// have been read.

uint32_t WavpackGetWrapperBytes (WavpackContext *wpc)
{
    return wpc ? wpc->wrapper_bytes : 0;
}

unsigned char *WavpackGetWrapperData (WavpackContext *wpc)
{
    return wpc ? wpc->wrapper_data : NULL;
}

void WavpackFreeWrapper (WavpackContext *wpc)
{
    if (wpc && wpc->wrapper_data) {
        free (wpc->wrapper_data);
        wpc->wrapper_data = NULL;
        wpc->wrapper_bytes = 0;
    }
}

// Returns the sample rate of the specified WavPack file

uint32_t WavpackGetSampleRate (WavpackContext *wpc)
{
    return wpc ? (wpc->dsd_multiplier ? wpc->config.sample_rate * wpc->dsd_multiplier : wpc->config.sample_rate) : 44100;
}

// Returns the native sample rate of the specified WavPack file
// (provides the native rate for DSD files rather than the "byte" rate that's used for
//   seeking, duration, etc. and would generally be used just for user facing reports)

uint32_t WavpackGetNativeSampleRate (WavpackContext *wpc)
{
    return wpc ? (wpc->dsd_multiplier ? wpc->config.sample_rate * wpc->dsd_multiplier * 8 : wpc->config.sample_rate) : 44100;
}

// Returns the number of channels of the specified WavPack file. Note that
// this is the actual number of channels contained in the file even if the
// OPEN_2CH_MAX flag was specified when the file was opened.

int WavpackGetNumChannels (WavpackContext *wpc)
{
    return wpc ? wpc->config.num_channels : 2;
}

// Returns the standard Microsoft channel mask for the specified WavPack
// file. A value of zero indicates that there is no speaker assignment
// information.

int WavpackGetChannelMask (WavpackContext *wpc)
{
    return wpc ? wpc->config.channel_mask : 0;
}

// Return the normalization value for floating point data (valid only
// if floating point data is present). A value of 127 indicates that
// the floating point range is +/- 1.0. Higher values indicate a
// larger floating point range.

int WavpackGetFloatNormExp (WavpackContext *wpc)
{
    return wpc->config.float_norm_exp;
}

// Returns the actual number of valid bits per sample contained in the
// original file, which may or may not be a multiple of 8. Floating data
// always has 32 bits, integers may be from 1 to 32 bits each. When this
// value is not a multiple of 8, then the "extra" bits are located in the
// LSBs of the results. That is, values are right justified when unpacked
// into ints, but are left justified in the number of bytes used by the
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

// If the OPEN_2CH_MAX flag is specified when opening the file, this function
// will return the actual number of channels decoded from the file (which may
// or may not be less than the actual number of channels, but will always be
// 1 or 2). Normally, this will be the front left and right channels of a
// multichannel file.

int WavpackGetReducedChannels (WavpackContext *wpc)
{
    if (wpc)
        return wpc->reduced_channels ? wpc->reduced_channels : wpc->config.num_channels;
    else
        return 2;
}

// Free all memory allocated for raw WavPack blocks (for all allocated streams)
// and free all additonal streams. This does not free the default stream ([0])
// which is always kept around.

void free_streams (WavpackContext *wpc)
{
    int si = wpc->num_streams;

    while (si--) {
        if (wpc->streams [si]->blockbuff) {
            free (wpc->streams [si]->blockbuff);
            wpc->streams [si]->blockbuff = NULL;
        }

        if (wpc->streams [si]->block2buff) {
            free (wpc->streams [si]->block2buff);
            wpc->streams [si]->block2buff = NULL;
        }

        if (wpc->streams [si]->sample_buffer) {
            free (wpc->streams [si]->sample_buffer);
            wpc->streams [si]->sample_buffer = NULL;
        }

        if (wpc->streams [si]->dc.shaping_data) {
            free (wpc->streams [si]->dc.shaping_data);
            wpc->streams [si]->dc.shaping_data = NULL;
        }

#ifdef ENABLE_DSD
        if (wpc->streams [si]->dsd.probabilities) {
            free (wpc->streams [si]->dsd.probabilities);
            wpc->streams [si]->dsd.probabilities = NULL;
        }

        if (wpc->streams [si]->dsd.summed_probabilities) {
            free (wpc->streams [si]->dsd.summed_probabilities);
            wpc->streams [si]->dsd.summed_probabilities = NULL;
        }

        if (wpc->streams [si]->dsd.value_lookup) {
            int i;

            for (i = 0; i < wpc->streams [si]->dsd.history_bins; ++i)
                if (wpc->streams [si]->dsd.value_lookup [i])
                    free (wpc->streams [si]->dsd.value_lookup [i]);

            free (wpc->streams [si]->dsd.value_lookup);
            wpc->streams [si]->dsd.value_lookup = NULL;
        }

        if (wpc->streams [si]->dsd.ptable) {
            free (wpc->streams [si]->dsd.ptable);
            wpc->streams [si]->dsd.ptable = NULL;
        }
#endif

        if (si) {
            wpc->num_streams--;
            free (wpc->streams [si]);
            wpc->streams [si] = NULL;
        }
    }

    wpc->current_stream = 0;
}

void WavpackFloatNormalize (int32_t *values, int32_t num_values, int delta_exp)
{
    f32 *fvalues = (f32 *) values;
    int exp;

    if (!delta_exp)
        return;

    while (num_values--) {
        if ((exp = get_exponent (*fvalues)) == 0 || exp + delta_exp <= 0)
            *fvalues = 0;
        else if (exp == 255 || (exp += delta_exp) >= 255) {
            set_exponent (*fvalues, 255);
            set_mantissa (*fvalues, 0);
        }
        else
            set_exponent (*fvalues, exp);

        fvalues++;
    }
}

void WavpackLittleEndianToNative (void *data, char *format)
{
    unsigned char *cp = (unsigned char *) data;
    int64_t temp;

    while (*format) {
        switch (*format) {
            case 'D':
                temp = cp [0] + ((int64_t) cp [1] << 8) + ((int64_t) cp [2] << 16) + ((int64_t) cp [3] << 24) +
                    ((int64_t) cp [4] << 32) + ((int64_t) cp [5] << 40) + ((int64_t) cp [6] << 48) + ((int64_t) cp [7] << 56);
                * (int64_t *) cp = temp;
                cp += 8;
                break;

            case 'L':
                temp = cp [0] + ((int32_t) cp [1] << 8) + ((int32_t) cp [2] << 16) + ((int32_t) cp [3] << 24);
                * (int32_t *) cp = (int32_t) temp;
                cp += 4;
                break;

            case 'S':
                temp = cp [0] + (cp [1] << 8);
                * (int16_t *) cp = (int16_t) temp;
                cp += 2;
                break;

            default:
                if (isdigit (*format))
                    cp += *format - '0';

                break;
        }

        format++;
    }
}

void WavpackNativeToLittleEndian (void *data, char *format)
{
    unsigned char *cp = (unsigned char *) data;
    int64_t temp;

    while (*format) {
        switch (*format) {
            case 'D':
                temp = * (int64_t *) cp;
                *cp++ = (unsigned char) temp;
                *cp++ = (unsigned char) (temp >> 8);
                *cp++ = (unsigned char) (temp >> 16);
                *cp++ = (unsigned char) (temp >> 24);
                *cp++ = (unsigned char) (temp >> 32);
                *cp++ = (unsigned char) (temp >> 40);
                *cp++ = (unsigned char) (temp >> 48);
                *cp++ = (unsigned char) (temp >> 56);
                break;

            case 'L':
                temp = * (int32_t *) cp;
                *cp++ = (unsigned char) temp;
                *cp++ = (unsigned char) (temp >> 8);
                *cp++ = (unsigned char) (temp >> 16);
                *cp++ = (unsigned char) (temp >> 24);
                break;

            case 'S':
                temp = * (int16_t *) cp;
                *cp++ = (unsigned char) temp;
                *cp++ = (unsigned char) (temp >> 8);
                break;

            default:
                if (isdigit (*format))
                    cp += *format - '0';

                break;
        }

        format++;
    }
}

void WavpackBigEndianToNative (void *data, char *format)
{
    unsigned char *cp = (unsigned char *) data;
    int64_t temp;

    while (*format) {
        switch (*format) {
            case 'D':
                temp = cp [7] + ((int64_t) cp [6] << 8) + ((int64_t) cp [5] << 16) + ((int64_t) cp [4] << 24) +
                    ((int64_t) cp [3] << 32) + ((int64_t) cp [2] << 40) + ((int64_t) cp [1] << 48) + ((int64_t) cp [0] << 56);
                * (int64_t *) cp = temp;
                cp += 8;
                break;

            case 'L':
                temp = cp [3] + ((int32_t) cp [2] << 8) + ((int32_t) cp [1] << 16) + ((int32_t) cp [0] << 24);
                * (int32_t *) cp = (int32_t) temp;
                cp += 4;
                break;

            case 'S':
                temp = cp [1] + (cp [0] << 8);
                * (int16_t *) cp = (int16_t) temp;
                cp += 2;
                break;

            default:
                if (isdigit (*format))
                    cp += *format - '0';

                break;
        }

        format++;
    }
}

void WavpackNativeToBigEndian (void *data, char *format)
{
    unsigned char *cp = (unsigned char *) data;
    int64_t temp;

    while (*format) {
        switch (*format) {
            case 'D':
                temp = * (int64_t *) cp;
                *cp++ = (unsigned char) (temp >> 56);
                *cp++ = (unsigned char) (temp >> 48);
                *cp++ = (unsigned char) (temp >> 40);
                *cp++ = (unsigned char) (temp >> 32);
                *cp++ = (unsigned char) (temp >> 24);
                *cp++ = (unsigned char) (temp >> 16);
                *cp++ = (unsigned char) (temp >> 8);
                *cp++ = (unsigned char) temp;
                break;

            case 'L':
                temp = * (int32_t *) cp;
                *cp++ = (unsigned char) (temp >> 24);
                *cp++ = (unsigned char) (temp >> 16);
                *cp++ = (unsigned char) (temp >> 8);
                *cp++ = (unsigned char) temp;
                break;

            case 'S':
                temp = * (int16_t *) cp;
                *cp++ = (unsigned char) (temp >> 8);
                *cp++ = (unsigned char) temp;
                break;

            default:
                if (isdigit (*format))
                    cp += *format - '0';

                break;
        }

        format++;
    }
}

uint32_t WavpackGetLibraryVersion (void)
{
    return (LIBWAVPACK_MAJOR<<16)
          |(LIBWAVPACK_MINOR<<8)
          |(LIBWAVPACK_MICRO<<0);
}

const char *WavpackGetLibraryVersionString (void)
{
    return LIBWAVPACK_VERSION_STRING;
}


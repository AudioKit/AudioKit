////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2006 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// wv_filter.c

// This is the main module for the demonstration WavPack command-line
// decoder filter. It uses the tiny "hardware" version of the decoder and
// accepts WavPack files on stdin and outputs a standard MS wav file to
// stdout. Note that this involves converting the data to little-endian
// (if the executing processor is not), possibly packing the data into
// fewer bytes per sample, and generating an appropriate riff wav header.
// Note that this is NOT the copy of the RIFF header that might be stored
// in the file, and any additional RIFF information and tags are lost.
// See wputils.c for further limitations.

#include "wavpack.h"

#if defined(WIN32)
#include <io.h>
#include <fcntl.h>
#endif

#include <string.h>

// These structures are used to place a wav riff header at the beginning of
// the output.

typedef struct {
    char ckID [4];
    uint32_t ckSize;
    char formType [4];
} RiffChunkHeader;

typedef struct {
    char ckID [4];
    uint32_t ckSize;
} ChunkHeader;

#define ChunkHeaderFormat "4L"

typedef struct {
    ushort FormatTag, NumChannels;
    uint32_t SampleRate, BytesPerSecond;
    ushort BlockAlign, BitsPerSample;
} WaveHeader;

#define WaveHeaderFormat "SSLLSS"

static uchar *format_samples (int bps, uchar *dst, int32_t *src, uint32_t samcnt);
static int32_t temp_buffer [256];

static FILE *infile, *outfile;

static int32_t read_bytes (void *buff, int32_t bcount)
{
    return (int32_t)fread(buff, 1, bcount, infile);
}

int wvunpack (int ifd, int ofd)
{
    ChunkHeader FormatChunkHeader, DataChunkHeader;
    RiffChunkHeader RiffChunkHeader;
    WaveHeader WaveHeader;

    uint32_t total_unpacked_samples = 0, total_samples;
    int num_channels, bps;
    WavpackContext *wpc;
    char error [80];
    int retval = 0;

    infile = fdopen(ifd, "rb");
    outfile = fdopen(ofd, "wb");
    
    wpc = WavpackOpenFileInput (read_bytes, error);

    if (!wpc) {
        // error 1: can't open input file
        retval = 1;
        goto done;
    }

    num_channels = WavpackGetReducedChannels (wpc);
    total_samples = WavpackGetNumSamples (wpc);
    bps = WavpackGetBytesPerSample (wpc);

    strncpy (RiffChunkHeader.ckID, "RIFF", sizeof (RiffChunkHeader.ckID));
    RiffChunkHeader.ckSize = total_samples * num_channels * bps + sizeof (ChunkHeader) * 2 + sizeof (WaveHeader) + 4;
    strncpy (RiffChunkHeader.formType, "WAVE", sizeof (RiffChunkHeader.formType));

    strncpy (FormatChunkHeader.ckID, "fmt ", sizeof (FormatChunkHeader.ckID));
    FormatChunkHeader.ckSize = sizeof (WaveHeader);

    WaveHeader.FormatTag = 1;
    WaveHeader.NumChannels = num_channels;
    WaveHeader.SampleRate = WavpackGetSampleRate (wpc);
    WaveHeader.BlockAlign = num_channels * bps;
    WaveHeader.BytesPerSecond = WaveHeader.SampleRate * WaveHeader.BlockAlign;
    WaveHeader.BitsPerSample = WavpackGetBitsPerSample (wpc);

    strncpy (DataChunkHeader.ckID, "data", sizeof (DataChunkHeader.ckID));
    DataChunkHeader.ckSize = total_samples * num_channels * bps;

    native_to_little_endian (&RiffChunkHeader, ChunkHeaderFormat);
    native_to_little_endian (&FormatChunkHeader, ChunkHeaderFormat);
    native_to_little_endian (&WaveHeader, WaveHeaderFormat);
    native_to_little_endian (&DataChunkHeader, ChunkHeaderFormat);

    if (!fwrite (&RiffChunkHeader, sizeof (RiffChunkHeader), 1, outfile) ||
        !fwrite (&FormatChunkHeader, sizeof (FormatChunkHeader), 1, outfile) ||
        !fwrite (&WaveHeader, sizeof (WaveHeader), 1, outfile) ||
        !fwrite (&DataChunkHeader, sizeof (DataChunkHeader), 1, outfile)) {
            // error 2: can't write .WAV data, disk probably full
            retval = 2;
            goto done;
        }

    while (1) {
        uint32_t samples_unpacked;

        samples_unpacked = WavpackUnpackSamples (wpc, temp_buffer, 256 / num_channels);
        total_unpacked_samples += samples_unpacked;

        if (samples_unpacked) {
            format_samples (bps, (uchar *) temp_buffer, temp_buffer, samples_unpacked *= num_channels);

            if (fwrite (temp_buffer, bps, samples_unpacked, outfile) != samples_unpacked) {
                // error 2: can't write .WAV data, disk probably full
                retval = 2;
                goto done;
            }
        }

        if (!samples_unpacked)
            break;
    }

    fflush (outfile);

    if (WavpackGetNumSamples (wpc) != (uint32_t) -1 &&
        total_unpacked_samples != WavpackGetNumSamples (wpc)) {
            // error 3: incorrect number of samples
            retval = 3;
            goto done;
    }

    if (WavpackGetNumErrors (wpc)) {
        // error 4: crc errors detected
        retval = 4;
        goto done;
    }

done:
    fclose(infile);
    fclose(outfile);
    return retval;
}

int getWvData (int ifd, int* pNumChannels, int* pNumSamples)
{
    WavpackContext *wpc;
    char error [80];

    infile = fdopen(ifd, "rb");
    wpc = WavpackOpenFileInput (read_bytes, error);
    if (!wpc)
    {
        // can't open file
        fclose(infile);
        return -1;
    }
    
    *pNumChannels = WavpackGetReducedChannels (wpc);
    *pNumSamples = WavpackGetNumSamples (wpc);
    fclose(infile);
    return 0;
}

int getWvSamples (int ifd, float* pSampleBuffer)
{
    uint32_t total_unpacked_samples = 0, total_samples;
    int num_channels, bps;
    WavpackContext *wpc;
    char error [80];
    int retval = 0;
    
    infile = fdopen(ifd, "rb");
    
    wpc = WavpackOpenFileInput (read_bytes, error);
    
    if (!wpc) {
        // error 1: can't open input file
        retval = 1;
        goto done;
    }
    
    num_channels = WavpackGetReducedChannels (wpc);
    total_samples = WavpackGetNumSamples (wpc);
    bps = WavpackGetBytesPerSample (wpc);
    
    float fMaxSampleValue = (float)(1<<23);
    while (1) {
        uint32_t samples_unpacked;
        
        samples_unpacked = WavpackUnpackSamples (wpc, temp_buffer, 256 / num_channels);
        total_unpacked_samples += samples_unpacked;
        
        if (samples_unpacked) {
            format_samples (4, (uchar *) temp_buffer, temp_buffer, samples_unpacked *= num_channels);
            for (int i=0; i < samples_unpacked; i++)
                *pSampleBuffer++ = temp_buffer[i] / fMaxSampleValue;
        }
        
        if (!samples_unpacked)
            break;
    }
    
    if (WavpackGetNumSamples (wpc) != (uint32_t) -1 &&
        total_unpacked_samples != WavpackGetNumSamples (wpc)) {
        // error 3: incorrect number of samples
        retval = 3;
        goto done;
    }
    
    if (WavpackGetNumErrors (wpc)) {
        // error 4: crc errors detected
        retval = 4;
        goto done;
    }
    
done:
    fclose(infile);
    fclose(outfile);
    return retval;
}

// Reformat samples from longs in processor's native endian mode to
// little-endian data with (possibly) less than 4 bytes / sample.

static uchar *format_samples (int bps, uchar *dst, int32_t *src, uint32_t samcnt)
{
    int32_t temp;

    switch (bps) {

        case 1:
            while (samcnt--)
                *dst++ = *src++ + 128;

            break;

        case 2:
            while (samcnt--) {
                *dst++ = (uchar)(temp = *src++);
                *dst++ = (uchar)(temp >> 8);
            }

            break;

        case 3:
            while (samcnt--) {
                *dst++ = (uchar)(temp = *src++);
                *dst++ = (uchar)(temp >> 8);
                *dst++ = (uchar)(temp >> 16);
            }

            break;

        case 4:
            while (samcnt--) {
                *dst++ = (uchar)(temp = *src++);
                *dst++ = (uchar)(temp >> 8);
                *dst++ = (uchar)(temp >> 16);
                *dst++ = (uchar)(temp >> 24);
            }

            break;
    }

    return dst;
}

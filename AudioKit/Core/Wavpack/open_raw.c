////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//                Copyright (c) 1998 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// open_raw.c

// This code provides the ability to decode WavPack frames directly from
// memory for use in a streaming application. It can handle full blocks
// or the headerless block data provided by Matroska and the DirectShow
// WavPack splitter. For information about how Matroska stores WavPack,
// see: https://www.matroska.org/technical/specs/codecid/wavpack.html

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

typedef struct {
    unsigned char *sptr, *dptr, *eptr, free_required;
} RawSegment;

typedef struct {
    RawSegment *segments;
    int num_segments, curr_segment;
    unsigned char ungetc_char, ungetc_flag;
} WavpackRawContext;

static int32_t raw_read_bytes (void *id, void *data, int32_t bcount)
{
    WavpackRawContext *rcxt = id;
    unsigned char *outptr = data;

    while (bcount) {
        if (rcxt->ungetc_flag) {
            *outptr++ = rcxt->ungetc_char;
            rcxt->ungetc_flag = 0;
            bcount--;
        }
        else if (rcxt->curr_segment < rcxt->num_segments) {
            RawSegment *segptr = rcxt->segments + rcxt->curr_segment;
            int bytes_to_copy = (int)(segptr->eptr - segptr->dptr);

            if (bytes_to_copy > bcount)
                bytes_to_copy = bcount;

            memcpy (outptr, segptr->dptr, bytes_to_copy);
            outptr += bytes_to_copy;
            bcount -= bytes_to_copy;

            if ((segptr->dptr += bytes_to_copy) == segptr->eptr)
                rcxt->curr_segment++;
        }
        else
            break;
    }

    return (int32_t)(outptr - (unsigned char *) data);
}

static int32_t raw_write_bytes (void *id, void *data, int32_t bcount)
{
    return 0;
}

static int64_t raw_get_pos (void *id)
{
    return 0;
}

static int raw_set_pos_abs (void *id, int64_t pos)
{
    return 0;
}

static int raw_set_pos_rel (void *id, int64_t delta, int mode)
{
    return 0;
}

static int raw_push_back_byte (void *id, int c)
{
    WavpackRawContext *rcxt = id;
    rcxt->ungetc_char = c;
    rcxt->ungetc_flag = 1;
    return c; 
}

static int64_t raw_get_length (void *id)
{
    return 0;
}

static int raw_can_seek (void *id)
{
    return 0;
}

static int raw_close_stream (void *id)
{
    WavpackRawContext *rcxt = id;
    int i;

    if (rcxt) {
        for (i = 0; i < rcxt->num_segments; ++i)
            if (rcxt->segments [i].sptr && rcxt->segments [i].free_required)
                free (rcxt->segments [i].sptr);

        if (rcxt->segments) free (rcxt->segments);
        free (rcxt);
    }

    return 0;
}

static WavpackStreamReader64 raw_reader = {
    raw_read_bytes, raw_write_bytes, raw_get_pos, raw_set_pos_abs, raw_set_pos_rel,
    raw_push_back_byte, raw_get_length, raw_can_seek, NULL, raw_close_stream
};

// This function is similar to WavpackOpenFileInput() except that instead of
// providing a filename to open, the caller provides pointers to buffered
// WavPack frames (both standard and, optionally, correction data). It
// decodes only a single frame. Note that in this context, a "frame" is a
// collection of WavPack blocks that represent all the channels present. In
// the case of mono or [most] stereo streams, this is the same thing, but
// for multichannel streams each frame consists of several WavPack blocks
// (which can contain only 1 or 2 channels).

WavpackContext *WavpackOpenRawDecoder (
    void *main_data, int32_t main_size,
    void *corr_data, int32_t corr_size,
    int16_t version, char *error, int flags, int norm_offset)
{
    WavpackRawContext *raw_wv = NULL, *raw_wvc = NULL;

    // if the WavPack data does not contain headers we assume Matroska-style storage
    // and recreate the missing headers

    if (strncmp (main_data, "wvpk", 4)) {
        uint32_t multiple_blocks = 0, block_size, block_samples = 0, wphdr_flags, crc;
        uint32_t main_bytes = main_size, corr_bytes = corr_size;
        unsigned char *mcp = main_data;
        unsigned char *ccp = corr_data;
        int msi = 0, csi = 0;

        raw_wv = malloc (sizeof (WavpackRawContext));
        memset (raw_wv, 0, sizeof (WavpackRawContext));

        if (corr_data && corr_size) {
            raw_wvc = malloc (sizeof (WavpackRawContext));
            memset (raw_wvc, 0, sizeof (WavpackRawContext));
        }

        while (main_bytes >= 12) {
            WavpackHeader *wphdr = malloc (sizeof (WavpackHeader));

            if (!msi) {
                block_samples = *mcp++;
                block_samples += *mcp++ << 8;
                block_samples += *mcp++ << 16;
                block_samples += *mcp++ << 24;
                main_bytes -= 4;
            }

            wphdr_flags = *mcp++;
            wphdr_flags += *mcp++ << 8;
            wphdr_flags += *mcp++ << 16;
            wphdr_flags += *mcp++ << 24;
            main_bytes -= 4;

            // if the first block does not have the FINAL_BLOCK flag set,
            // then there are multiple blocks

            if (!msi && !(wphdr_flags & FINAL_BLOCK))
                multiple_blocks = 1;

            crc = *mcp++;
            crc += *mcp++ << 8;
            crc += *mcp++ << 16;
            crc += *mcp++ << 24;
            main_bytes -= 4;

            if (multiple_blocks) {
                block_size = *mcp++;
                block_size += *mcp++ << 8;
                block_size += *mcp++ << 16;
                block_size += *mcp++ << 24;
                main_bytes -= 4;
            }
            else
                block_size = main_bytes;

            if (block_size > main_bytes) {
                if (error) strcpy (error, "main block overran available data!");
                raw_close_stream (raw_wv);
                raw_close_stream (raw_wvc);
                return NULL;
            } 

            memset (wphdr, 0, sizeof (WavpackHeader));
            memcpy (wphdr->ckID, "wvpk", 4);
            wphdr->ckSize = sizeof (WavpackHeader) - 8 + block_size;
            SET_TOTAL_SAMPLES (*wphdr, block_samples);
            wphdr->block_samples = block_samples;
            wphdr->version = version;
            wphdr->flags = wphdr_flags;
            wphdr->crc = crc;
            WavpackLittleEndianToNative (wphdr, WavpackHeaderFormat);

            raw_wv->num_segments += 2;
            raw_wv->segments = realloc (raw_wv->segments, sizeof (RawSegment) * raw_wv->num_segments);
            raw_wv->segments [msi].dptr = raw_wv->segments [msi].sptr = (unsigned char *) wphdr;
            raw_wv->segments [msi].eptr = raw_wv->segments [msi].dptr + sizeof (WavpackHeader);
            raw_wv->segments [msi++].free_required = 1;
            raw_wv->segments [msi].dptr = raw_wv->segments [msi].sptr = mcp;
            raw_wv->segments [msi].eptr = raw_wv->segments [msi].dptr + block_size;
            raw_wv->segments [msi++].free_required = 0;
            main_bytes -= block_size;
            mcp += block_size;

            if (corr_data && corr_bytes >= 4) {
                wphdr = malloc (sizeof (WavpackHeader));

                crc = *ccp++;
                crc += *ccp++ << 8;
                crc += *ccp++ << 16;
                crc += *ccp++ << 24;
                corr_bytes -= 4;

                if (multiple_blocks) {
                    block_size = *ccp++;
                    block_size += *ccp++ << 8;
                    block_size += *ccp++ << 16;
                    block_size += *ccp++ << 24;
                    corr_bytes -= 4;
                }
                else
                    block_size = corr_bytes;

                if (block_size > corr_bytes) {
                    if (error) strcpy (error, "correction block overran available data!");
                    raw_close_stream (raw_wv);
                    raw_close_stream (raw_wvc);
                    return NULL;
                } 

                memset (wphdr, 0, sizeof (WavpackHeader));
                memcpy (wphdr->ckID, "wvpk", 4);
                wphdr->ckSize = sizeof (WavpackHeader) - 8 + block_size;
                SET_TOTAL_SAMPLES (*wphdr, block_samples);
                wphdr->block_samples = block_samples;
                wphdr->version = version;
                wphdr->flags = wphdr_flags;
                wphdr->crc = crc;
                WavpackLittleEndianToNative (wphdr, WavpackHeaderFormat);

                raw_wvc->num_segments += 2;
                raw_wvc->segments = realloc (raw_wvc->segments, sizeof (RawSegment) * raw_wvc->num_segments);
                raw_wvc->segments [csi].dptr = raw_wvc->segments [csi].sptr = (unsigned char *) wphdr;
                raw_wvc->segments [csi].eptr = raw_wvc->segments [csi].dptr + sizeof (WavpackHeader);
                raw_wvc->segments [csi++].free_required = 1;
                raw_wvc->segments [csi].dptr = raw_wvc->segments [csi].sptr = ccp;
                raw_wvc->segments [csi].eptr = raw_wvc->segments [csi].dptr + block_size;
                raw_wvc->segments [csi++].free_required = 0;
                corr_bytes -= block_size;
                ccp += block_size;
            }
        }

        if (main_bytes || (corr_data && corr_bytes)) {
            if (error) strcpy (error, "leftover multiblock data!");
            raw_close_stream (raw_wv);
            raw_close_stream (raw_wvc);
            return NULL;
        }
    }
    else {      // the case of WavPack blocks with headers is much easier...
        if (main_data) {
            raw_wv = malloc (sizeof (WavpackRawContext));
            memset (raw_wv, 0, sizeof (WavpackRawContext));
            raw_wv->num_segments = 1;
            raw_wv->segments = malloc (sizeof (RawSegment) * raw_wv->num_segments);
            raw_wv->segments [0].dptr = raw_wv->segments [0].sptr = main_data;
            raw_wv->segments [0].eptr = raw_wv->segments [0].dptr + main_size;
            raw_wv->segments [0].free_required = 0;
        }

        if (corr_data && corr_size) {
            raw_wvc = malloc (sizeof (WavpackRawContext));
            memset (raw_wvc, 0, sizeof (WavpackRawContext));
            raw_wvc->num_segments = 1;
            raw_wvc->segments = malloc (sizeof (RawSegment) * raw_wvc->num_segments);
            raw_wvc->segments [0].dptr = raw_wvc->segments [0].sptr = corr_data;
            raw_wvc->segments [0].eptr = raw_wvc->segments [0].dptr + corr_size;
            raw_wvc->segments [0].free_required = 0;
        }
    }

    return WavpackOpenFileInputEx64 (&raw_reader, raw_wv, raw_wvc, error, flags | OPEN_STREAMING | OPEN_NO_CHECKSUM, norm_offset);
}

// Return the number of samples represented by the current (and in the raw case, only) frame.

uint32_t WavpackGetNumSamplesInFrame (WavpackContext *wpc)
{
    if (wpc && wpc->streams && wpc->streams [0])
        return wpc->streams [0]->wphdr.block_samples;
    else
        return -1;
}


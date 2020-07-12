////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//                Copyright (c) 1998 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// open_utils.c

// This module provides all the code required to open an existing WavPack file
// for reading by using a reader callback mechanism (NOT a filename). This
// includes the code required to find and parse WavPack blocks, process any
// included metadata, and queue up the bitstreams containing the encoded audio
// data. It does not the actual code to unpack audio data and this was done so
// that programs that just want to query WavPack files for information (like,
// for example, taggers) don't need to link in a lot of unnecessary code.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

// This function is identical to WavpackOpenFileInput() except that instead
// of providing a filename to open, the caller provides a pointer to a set of
// reader callbacks and instances of up to two streams. The first of these
// streams is required and contains the regular WavPack data stream; the second
// contains the "correction" file if desired. Unlike the standard open
// function which handles the correction file transparently, in this case it
// is the responsibility of the caller to be aware of correction files.

static int seek_eof_information (WavpackContext *wpc, int64_t *final_index, int get_wrapper);

WavpackContext *WavpackOpenFileInputEx64 (WavpackStreamReader64 *reader, void *wv_id, void *wvc_id, char *error, int flags, int norm_offset)
{
    WavpackContext *wpc = malloc (sizeof (WavpackContext));
    WavpackStream *wps;
    int num_blocks = 0;
    unsigned char first_byte;
    uint32_t bcount;

    if (!wpc) {
        if (error) strcpy (error, "can't allocate memory");
        return NULL;
    }

    CLEAR (*wpc);
    wpc->wv_in = wv_id;
    wpc->wvc_in = wvc_id;
    wpc->reader = reader;
    wpc->total_samples = -1;
    wpc->norm_offset = norm_offset;
    wpc->max_streams = OLD_MAX_STREAMS;     // use this until overwritten with actual number
    wpc->open_flags = flags;

    wpc->filelen = wpc->reader->get_length (wpc->wv_in);

#ifndef NO_TAGS
    if ((flags & (OPEN_TAGS | OPEN_EDIT_TAGS)) && wpc->reader->can_seek (wpc->wv_in)) {
        load_tag (wpc);
        wpc->reader->set_pos_abs (wpc->wv_in, 0);

        if ((flags & OPEN_EDIT_TAGS) && !editable_tag (&wpc->m_tag)) {
            if (error) strcpy (error, "can't edit tags located at the beginning of files!");
            return WavpackCloseFile (wpc);
        }
    }
#endif

    if (wpc->reader->read_bytes (wpc->wv_in, &first_byte, 1) != 1) {
        if (error) strcpy (error, "can't read all of WavPack file!");
        return WavpackCloseFile (wpc);
    }

    wpc->reader->push_back_byte (wpc->wv_in, first_byte);

    if (first_byte == 'R') {
#ifdef ENABLE_LEGACY
        return open_file3 (wpc, error);
#else
        if (error) strcpy (error, "this legacy WavPack file is deprecated, use version 4.80.0 to transcode");
        return WavpackCloseFile (wpc);
#endif
    }

    wpc->streams = malloc ((wpc->num_streams = 1) * sizeof (wpc->streams [0]));
    if (!wpc->streams) {
        if (error) strcpy (error, "can't allocate memory");
        return WavpackCloseFile (wpc);
    }

    wpc->streams [0] = wps = malloc (sizeof (WavpackStream));
    if (!wps) {
        if (error) strcpy (error, "can't allocate memory");
        return WavpackCloseFile (wpc);
    }
    CLEAR (*wps);

    while (!wps->wphdr.block_samples) {

        wpc->filepos = wpc->reader->get_pos (wpc->wv_in);
        bcount = read_next_header (wpc->reader, wpc->wv_in, &wps->wphdr);

        if (bcount == (uint32_t) -1 ||
            (!wps->wphdr.block_samples && num_blocks++ > 16)) {
                if (error) strcpy (error, "not compatible with this version of WavPack file!");
                return WavpackCloseFile (wpc);
        }

        wpc->filepos += bcount;
        wps->blockbuff = malloc (wps->wphdr.ckSize + 8);
        if (!wps->blockbuff) {
            if (error) strcpy (error, "can't allocate memory");
            return WavpackCloseFile (wpc);
        }
        memcpy (wps->blockbuff, &wps->wphdr, 32);

        if (wpc->reader->read_bytes (wpc->wv_in, wps->blockbuff + 32, wps->wphdr.ckSize - 24) != wps->wphdr.ckSize - 24) {
            if (error) strcpy (error, "can't read all of WavPack file!");
            return WavpackCloseFile (wpc);
        }

        // if block does not verify, flag error, free buffer, and continue
        if (!WavpackVerifySingleBlock (wps->blockbuff, !(flags & OPEN_NO_CHECKSUM))) {
            wps->wphdr.block_samples = 0;
            free (wps->blockbuff);
            wps->blockbuff = NULL;
            wpc->crc_errors++;
            continue;
        }

        wps->init_done = FALSE;

        if (wps->wphdr.block_samples) {
            if (flags & OPEN_STREAMING)
                SET_BLOCK_INDEX (wps->wphdr, 0);
            else if (wpc->total_samples == -1) {
                if (GET_BLOCK_INDEX (wps->wphdr) || GET_TOTAL_SAMPLES (wps->wphdr) == -1) {
                    wpc->initial_index = GET_BLOCK_INDEX (wps->wphdr);
                    SET_BLOCK_INDEX (wps->wphdr, 0);

                    if (wpc->reader->can_seek (wpc->wv_in)) {
                        int64_t final_index = -1;

                        seek_eof_information (wpc, &final_index, FALSE);

                        if (final_index != -1)
                            wpc->total_samples = final_index - wpc->initial_index;
                    }
                }
                else
                    wpc->total_samples = GET_TOTAL_SAMPLES (wps->wphdr);
            }
        }
        else if (wpc->total_samples == -1 && !GET_BLOCK_INDEX (wps->wphdr) && GET_TOTAL_SAMPLES (wps->wphdr))
            wpc->total_samples = GET_TOTAL_SAMPLES (wps->wphdr);

        if (wpc->wvc_in && wps->wphdr.block_samples && (wps->wphdr.flags & HYBRID_FLAG)) {
            unsigned char ch;

            if (wpc->reader->read_bytes (wpc->wvc_in, &ch, 1) == 1) {
                wpc->reader->push_back_byte (wpc->wvc_in, ch);
                wpc->file2len = wpc->reader->get_length (wpc->wvc_in);
                wpc->wvc_flag = TRUE;
            }
        }

        if (wpc->wvc_flag && !read_wvc_block (wpc)) {
            if (error) strcpy (error, "not compatible with this version of correction file!");
            return WavpackCloseFile (wpc);
        }

        if (!wps->init_done && !unpack_init (wpc)) {
            if (error) strcpy (error, wpc->error_message [0] ? wpc->error_message :
                "not compatible with this version of WavPack file!");

            return WavpackCloseFile (wpc);
        }

        wps->init_done = TRUE;
    }

    wpc->config.flags &= ~0xff;
    wpc->config.flags |= wps->wphdr.flags & 0xff;

    if (!wpc->config.num_channels) {
        wpc->config.num_channels = (wps->wphdr.flags & MONO_FLAG) ? 1 : 2;
        wpc->config.channel_mask = 0x5 - wpc->config.num_channels;
    }

    if ((flags & OPEN_2CH_MAX) && !(wps->wphdr.flags & FINAL_BLOCK))
        wpc->reduced_channels = (wps->wphdr.flags & MONO_FLAG) ? 1 : 2;

    if (wps->wphdr.flags & DSD_FLAG) {
#ifdef ENABLE_DSD
        if (flags & OPEN_DSD_NATIVE) {
            wpc->config.bytes_per_sample = 1;
            wpc->config.bits_per_sample = 8;
        }
        else if (flags & OPEN_DSD_AS_PCM) {
            wpc->decimation_context = decimate_dsd_init (wpc->reduced_channels ?
                wpc->reduced_channels : wpc->config.num_channels);

            wpc->config.bytes_per_sample = 3;
            wpc->config.bits_per_sample = 24;
        }
        else {
            if (error) strcpy (error, "not configured to handle DSD WavPack files!");
            return WavpackCloseFile (wpc);
        }
#else
        if (error) strcpy (error, "not configured to handle DSD WavPack files!");
        return WavpackCloseFile (wpc);
#endif
    }
    else {
        wpc->config.bytes_per_sample = (wps->wphdr.flags & BYTES_STORED) + 1;
        wpc->config.float_norm_exp = wps->float_norm_exp;

        wpc->config.bits_per_sample = (wpc->config.bytes_per_sample * 8) -
            ((wps->wphdr.flags & SHIFT_MASK) >> SHIFT_LSB);
    }

    if (!wpc->config.sample_rate) {
        if (!wps->wphdr.block_samples || (wps->wphdr.flags & SRATE_MASK) == SRATE_MASK)
            wpc->config.sample_rate = 44100;
        else
            wpc->config.sample_rate = sample_rates [(wps->wphdr.flags & SRATE_MASK) >> SRATE_LSB];
    }

    return wpc;
}

// This function returns the major version number of the WavPack program
// (or library) that created the open file. Currently, this can be 1 to 5.
// Minor versions are not recorded in WavPack files.

int WavpackGetVersion (WavpackContext *wpc)
{
    if (wpc) {
#ifdef ENABLE_LEGACY
        if (wpc->stream3)
            return get_version3 (wpc);
#endif
        return wpc->version_five ? 5 : 4;
    }

    return 0;
}

// Return the file format specified in the call to WavpackSetFileInformation()
// when the file was created. For all files created prior to WavPack 5.0 this
// will 0 (WP_FORMAT_WAV).

unsigned char WavpackGetFileFormat (WavpackContext *wpc)
{
    return wpc->file_format;
}

// Return a string representing the recommended file extension for the open
// WavPack file. For all files created prior to WavPack 5.0 this will be "wav",
// even for raw files with no RIFF into. This string is specified in the
// call to WavpackSetFileInformation() when the file was created.

char *WavpackGetFileExtension (WavpackContext *wpc)
{
    if (wpc && wpc->file_extension [0])
        return wpc->file_extension;
    else
        return "wav";
}

// This function initializes everything required to unpack a WavPack block
// and must be called before unpack_samples() is called to obtain audio data.
// It is assumed that the WavpackHeader has been read into the wps->wphdr
// (in the current WavpackStream) and that the entire block has been read at
// wps->blockbuff. If a correction file is available (wpc->wvc_flag = TRUE)
// then the corresponding correction block must be read into wps->block2buff
// and its WavpackHeader has overwritten the header at wps->wphdr. This is
// where all the metadata blocks are scanned including those that contain
// bitstream data.

static int read_metadata_buff (WavpackMetadata *wpmd, unsigned char *blockbuff, unsigned char **buffptr);
static int process_metadata (WavpackContext *wpc, WavpackMetadata *wpmd);
static void bs_open_read (Bitstream *bs, void *buffer_start, void *buffer_end);

int unpack_init (WavpackContext *wpc)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    unsigned char *blockptr, *block2ptr;
    WavpackMetadata wpmd;

    wps->num_terms = 0;
    wps->mute_error = FALSE;
    wps->crc = wps->crc_x = 0xffffffff;
    wps->dsd.ready = 0;
    CLEAR (wps->wvbits);
    CLEAR (wps->wvcbits);
    CLEAR (wps->wvxbits);
    CLEAR (wps->decorr_passes);
    CLEAR (wps->dc);
    CLEAR (wps->w);

    if (!(wps->wphdr.flags & MONO_FLAG) && wpc->config.num_channels && wps->wphdr.block_samples &&
        (wpc->reduced_channels == 1 || wpc->config.num_channels == 1)) {
            wps->mute_error = TRUE;
            return FALSE;
    }

    if ((wps->wphdr.flags & UNKNOWN_FLAGS) || (wps->wphdr.flags & MONO_DATA) == MONO_DATA) {
        wps->mute_error = TRUE;
        return FALSE;
    }

    blockptr = wps->blockbuff + sizeof (WavpackHeader);

    while (read_metadata_buff (&wpmd, wps->blockbuff, &blockptr))
        if (!process_metadata (wpc, &wpmd)) {
            wps->mute_error = TRUE;
            return FALSE;
        }

    if (wps->wphdr.block_samples && wpc->wvc_flag && wps->block2buff) {
        block2ptr = wps->block2buff + sizeof (WavpackHeader);

        while (read_metadata_buff (&wpmd, wps->block2buff, &block2ptr))
            if (!process_metadata (wpc, &wpmd)) {
                wps->mute_error = TRUE;
                return FALSE;
            }
    }

    if (wps->wphdr.block_samples && ((wps->wphdr.flags & DSD_FLAG) ? !wps->dsd.ready : !bs_is_open (&wps->wvbits))) {
        if (bs_is_open (&wps->wvcbits))
            strcpy (wpc->error_message, "can't unpack correction files alone!");

        wps->mute_error = TRUE;
        return FALSE;
    }

    if (wps->wphdr.block_samples && !bs_is_open (&wps->wvxbits)) {
        if ((wps->wphdr.flags & INT32_DATA) && wps->int32_sent_bits)
            wpc->lossy_blocks = TRUE;

        if ((wps->wphdr.flags & FLOAT_DATA) &&
            wps->float_flags & (FLOAT_EXCEPTIONS | FLOAT_ZEROS_SENT | FLOAT_SHIFT_SENT | FLOAT_SHIFT_SAME))
                wpc->lossy_blocks = TRUE;
    }

    if (wps->wphdr.block_samples)
        wps->sample_index = GET_BLOCK_INDEX (wps->wphdr);

    return TRUE;
}

//////////////////////////////// matadata handlers ///////////////////////////////

// These functions handle specific metadata types and are called directly
// during WavPack block parsing by process_metadata() at the bottom.

// This function initialzes the main bitstream for audio samples, which must
// be in the "wv" file.

static int init_wv_bitstream (WavpackStream *wps, WavpackMetadata *wpmd)
{
    if (!wpmd->byte_length || (wpmd->byte_length & 1))
        return FALSE;

    bs_open_read (&wps->wvbits, wpmd->data, (unsigned char *) wpmd->data + wpmd->byte_length);
    return TRUE;
}

// This function initialzes the "correction" bitstream for audio samples,
// which currently must be in the "wvc" file.

static int init_wvc_bitstream (WavpackStream *wps, WavpackMetadata *wpmd)
{
    if (!wpmd->byte_length || (wpmd->byte_length & 1))
        return FALSE;

    bs_open_read (&wps->wvcbits, wpmd->data, (unsigned char *) wpmd->data + wpmd->byte_length);
    return TRUE;
}

// This function initialzes the "extra" bitstream for audio samples which
// contains the information required to losslessly decompress 32-bit float data
// or integer data that exceeds 24 bits. This bitstream is in the "wv" file
// for pure lossless data or the "wvc" file for hybrid lossless. This data
// would not be used for hybrid lossy mode. There is also a 32-bit CRC stored
// in the first 4 bytes of these blocks.

static int init_wvx_bitstream (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char *cp = wpmd->data;

    if (wpmd->byte_length <= 4 || (wpmd->byte_length & 1))
        return FALSE;

    wps->crc_wvx = *cp++;
    wps->crc_wvx |= (int32_t) *cp++ << 8;
    wps->crc_wvx |= (int32_t) *cp++ << 16;
    wps->crc_wvx |= (int32_t) *cp++ << 24;

    bs_open_read (&wps->wvxbits, cp, (unsigned char *) wpmd->data + wpmd->byte_length);
    return TRUE;
}

// Read the int32 data from the specified metadata into the specified stream.
// This data is used for integer data that has more than 24 bits of magnitude
// or, in some cases, used to eliminate redundant bits from any audio stream.

static int read_int32_info (WavpackStream *wps, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length;
    char *byteptr = wpmd->data;

    if (bytecnt != 4)
        return FALSE;

    wps->int32_sent_bits = *byteptr++;
    wps->int32_zeros = *byteptr++;
    wps->int32_ones = *byteptr++;
    wps->int32_dups = *byteptr;

    return TRUE;
}

static int read_float_info (WavpackStream *wps, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length;
    char *byteptr = wpmd->data;

    if (bytecnt != 4)
        return FALSE;

    wps->float_flags = *byteptr++;
    wps->float_shift = *byteptr++;
    wps->float_max_exp = *byteptr++;
    wps->float_norm_exp = *byteptr;
    return TRUE;
}

// Read multichannel information from metadata. The first byte is the total
// number of channels and the following bytes represent the channel_mask
// as described for Microsoft WAVEFORMATEX.

static int read_channel_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length, shift = 0, mask_bits;
    unsigned char *byteptr = wpmd->data;
    uint32_t mask = 0;

    if (!bytecnt || bytecnt > 7)
        return FALSE;

    if (!wpc->config.num_channels) {

        // if bytecnt is 6 or 7 we are using new configuration with "unlimited" streams

        if (bytecnt >= 6) {
            wpc->config.num_channels = (byteptr [0] | ((byteptr [2] & 0xf) << 8)) + 1;
            wpc->max_streams = (byteptr [1] | ((byteptr [2] & 0xf0) << 4)) + 1;

            if (wpc->config.num_channels < wpc->max_streams)
                return FALSE;
    
            byteptr += 3;
            mask = *byteptr++;
            mask |= (uint32_t) *byteptr++ << 8;
            mask |= (uint32_t) *byteptr++ << 16;

            if (bytecnt == 7)                           // this was introduced in 5.0
                mask |= (uint32_t) *byteptr << 24;
        }
        else {
            wpc->config.num_channels = *byteptr++;

            while (--bytecnt) {
                mask |= (uint32_t) *byteptr++ << shift;
                shift += 8;
            }
        }

        if (wpc->config.num_channels > wpc->max_streams * 2)
            return FALSE;

        wpc->config.channel_mask = mask;

        for (mask_bits = 0; mask; mask >>= 1)
            if ((mask & 1) && ++mask_bits > wpc->config.num_channels)
                return FALSE;
    }

    return TRUE;
}

// Read multichannel identity information from metadata. Data is an array of
// unsigned characters representing any channels in the file that DO NOT
// match one the 18 Microsoft standard channels (and are represented in the
// channel mask). A value of 0 is not allowed and 0xff means an unknown or
// undefined channel identity.

static int read_channel_identities (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    if (!wpc->channel_identities) {
        wpc->channel_identities = malloc (wpmd->byte_length + 1);
        memcpy (wpc->channel_identities, wpmd->data, wpmd->byte_length);
        wpc->channel_identities [wpmd->byte_length] = 0;
    }

    return TRUE;
}

// Read configuration information from metadata.

static int read_config_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length;
    unsigned char *byteptr = wpmd->data;

    if (bytecnt >= 3) {
        wpc->config.flags &= 0xff;
        wpc->config.flags |= (int32_t) *byteptr++ << 8;
        wpc->config.flags |= (int32_t) *byteptr++ << 16;
        wpc->config.flags |= (int32_t) *byteptr++ << 24;
        bytecnt -= 3;

        if (bytecnt && (wpc->config.flags & CONFIG_EXTRA_MODE)) {
            wpc->config.xmode = *byteptr++;
            bytecnt--;
        }

        // we used an extra config byte here for the 5.0.0 alpha, so still
        // honor it now (but this has been replaced with NEW_CONFIG)

        if (bytecnt) {
            wpc->config.qmode = (wpc->config.qmode & ~0xff) | *byteptr;
            wpc->version_five = 1;
        }
    }

    return TRUE;
}

// Read "new" configuration information from metadata.

static int read_new_config_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length;
    unsigned char *byteptr = wpmd->data;

    wpc->version_five = 1;      // just having this block signals version 5.0

    wpc->file_format = wpc->config.qmode = wpc->channel_layout = 0;

    if (wpc->channel_reordering) {
        free (wpc->channel_reordering);
        wpc->channel_reordering = NULL;
    }

    // if there's any data, the first two bytes are file_format and qmode flags

    if (bytecnt >= 2) {
        wpc->file_format = *byteptr++;
        wpc->config.qmode = (wpc->config.qmode & ~0xff) | *byteptr++;
        bytecnt -= 2;

        // another byte indicates a channel layout

        if (bytecnt) {
            int nchans, i;

            wpc->channel_layout = (int32_t) *byteptr++ << 16;
            bytecnt--;

            // another byte means we have a channel count for the layout and maybe a reordering

            if (bytecnt) {
                wpc->channel_layout += nchans = *byteptr++;
                bytecnt--;

                // any more means there's a reordering string

                if (bytecnt) {
                    if (bytecnt > nchans)
                        return FALSE;

                    wpc->channel_reordering = malloc (nchans);

                    // note that redundant reordering info is not stored, so we fill in the rest

                    if (wpc->channel_reordering) {
                        for (i = 0; i < nchans; ++i)
                            if (bytecnt) {
                                wpc->channel_reordering [i] = *byteptr++;

                                if (wpc->channel_reordering [i] >= nchans)  // make sure index is in range
                                    wpc->channel_reordering [i] = 0;

                                bytecnt--;
                            }
                            else
                                wpc->channel_reordering [i] = i;
                    }
                }
            }
            else
                wpc->channel_layout += wpc->config.num_channels;
        }
    }

    return TRUE;
}

// Read non-standard sampling rate from metadata.

static int read_sample_rate (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    int bytecnt = wpmd->byte_length;
    unsigned char *byteptr = wpmd->data;

    if (bytecnt == 3 || bytecnt == 4) {
        wpc->config.sample_rate = (int32_t) *byteptr++;
        wpc->config.sample_rate |= (int32_t) *byteptr++ << 8;
        wpc->config.sample_rate |= (int32_t) *byteptr++ << 16;

        // for sampling rates > 16777215 (non-audio probably, or ...)

        if (bytecnt == 4)
            wpc->config.sample_rate |= (int32_t) (*byteptr & 0x7f) << 24;
    }

    return TRUE;
}

// Read wrapper data from metadata. Currently, this consists of the RIFF
// header and trailer that wav files contain around the audio data but could
// be used for other formats as well. Because WavPack files contain all the
// information required for decoding and playback, this data can probably
// be ignored except when an exact wavefile restoration is needed.

static int read_wrapper_data (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    if ((wpc->open_flags & OPEN_WRAPPER) && wpc->wrapper_bytes < MAX_WRAPPER_BYTES && wpmd->byte_length) {
        wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + wpmd->byte_length);
	if (!wpc->wrapper_data)
	    return FALSE;
        memcpy (wpc->wrapper_data + wpc->wrapper_bytes, wpmd->data, wpmd->byte_length);
        wpc->wrapper_bytes += wpmd->byte_length;
    }

    return TRUE;
}

static int read_metadata_buff (WavpackMetadata *wpmd, unsigned char *blockbuff, unsigned char **buffptr)
{
    WavpackHeader *wphdr = (WavpackHeader *) blockbuff;
    unsigned char *buffend = blockbuff + wphdr->ckSize + 8;

    if (buffend - *buffptr < 2)
        return FALSE;

    wpmd->id = *(*buffptr)++;
    wpmd->byte_length = *(*buffptr)++ << 1;

    if (wpmd->id & ID_LARGE) {
        wpmd->id &= ~ID_LARGE;

        if (buffend - *buffptr < 2)
            return FALSE;

        wpmd->byte_length += *(*buffptr)++ << 9;
        wpmd->byte_length += *(*buffptr)++ << 17;
    }

    if (wpmd->id & ID_ODD_SIZE) {
        if (!wpmd->byte_length)         // odd size and zero length makes no sense
            return FALSE;
        wpmd->id &= ~ID_ODD_SIZE;
        wpmd->byte_length--;
    }

    if (wpmd->byte_length) {
        if (buffend - *buffptr < wpmd->byte_length + (wpmd->byte_length & 1)) {
            wpmd->data = NULL;
            return FALSE;
        }

        wpmd->data = *buffptr;
        (*buffptr) += wpmd->byte_length + (wpmd->byte_length & 1);
    }
    else
        wpmd->data = NULL;

    return TRUE;
}

static int process_metadata (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];

    switch (wpmd->id) {
        case ID_DUMMY:
            return TRUE;

        case ID_DECORR_TERMS:
            return read_decorr_terms (wps, wpmd);

        case ID_DECORR_WEIGHTS:
            return read_decorr_weights (wps, wpmd);

        case ID_DECORR_SAMPLES:
            return read_decorr_samples (wps, wpmd);

        case ID_ENTROPY_VARS:
            return read_entropy_vars (wps, wpmd);

        case ID_HYBRID_PROFILE:
            return read_hybrid_profile (wps, wpmd);

        case ID_SHAPING_WEIGHTS:
            return read_shaping_info (wps, wpmd);

        case ID_FLOAT_INFO:
            return read_float_info (wps, wpmd);

        case ID_INT32_INFO:
            return read_int32_info (wps, wpmd);

        case ID_CHANNEL_INFO:
            return read_channel_info (wpc, wpmd);

        case ID_CHANNEL_IDENTITIES:
            return read_channel_identities (wpc, wpmd);

        case ID_CONFIG_BLOCK:
            return read_config_info (wpc, wpmd);

        case ID_NEW_CONFIG_BLOCK:
            return read_new_config_info (wpc, wpmd);

        case ID_SAMPLE_RATE:
            return read_sample_rate (wpc, wpmd);

        case ID_WV_BITSTREAM:
            return init_wv_bitstream (wps, wpmd);

        case ID_WVC_BITSTREAM:
            return init_wvc_bitstream (wps, wpmd);

        case ID_WVX_BITSTREAM:
            return init_wvx_bitstream (wps, wpmd);

        case ID_DSD_BLOCK:
#ifdef ENABLE_DSD
            return init_dsd_block (wpc, wpmd);
#else
            strcpy (wpc->error_message, "not configured to handle DSD WavPack files!");
            return FALSE;
#endif

        case ID_ALT_HEADER: case ID_ALT_TRAILER:
            if (!(wpc->open_flags & OPEN_ALT_TYPES))
                return TRUE;

        case ID_RIFF_HEADER: case ID_RIFF_TRAILER:
            return read_wrapper_data (wpc, wpmd);

        case ID_ALT_MD5_CHECKSUM:
            if (!(wpc->open_flags & OPEN_ALT_TYPES))
                return TRUE;

        case ID_MD5_CHECKSUM:
            if (wpmd->byte_length == 16) {
                memcpy (wpc->config.md5_checksum, wpmd->data, 16);
                wpc->config.flags |= CONFIG_MD5_CHECKSUM;
                wpc->config.md5_read = 1;
            }

            return TRUE;

        case ID_ALT_EXTENSION:
            if (wpmd->byte_length && wpmd->byte_length < sizeof (wpc->file_extension)) {
                memcpy (wpc->file_extension, wpmd->data, wpmd->byte_length);
                wpc->file_extension [wpmd->byte_length] = 0;
            }

            return TRUE;

        // we don't actually verify the checksum here (it's done right after the
        // block is read), but it's a good indicator of version 5 files

        case ID_BLOCK_CHECKSUM:
            wpc->version_five = 1;
            return TRUE;

        default:
            return (wpmd->id & ID_OPTIONAL_DATA) ? TRUE : FALSE;
    }
}

//////////////////////////////// bitstream management ///////////////////////////////

// Open the specified BitStream and associate with the specified buffer.

static void bs_read (Bitstream *bs);

static void bs_open_read (Bitstream *bs, void *buffer_start, void *buffer_end)
{
    bs->error = bs->sr = bs->bc = 0;
    bs->ptr = (bs->buf = buffer_start) - 1;
    bs->end = buffer_end;
    bs->wrap = bs_read;
}

// This function is only called from the getbit() and getbits() macros when
// the BitStream has been exhausted and more data is required. Sinve these
// bistreams no longer access files, this function simple sets an error and
// resets the buffer.

static void bs_read (Bitstream *bs)
{
    bs->ptr = bs->buf;
    bs->error = 1;
}

// This function is called to close the bitstream. It returns the number of
// full bytes actually read as bits.

uint32_t bs_close_read (Bitstream *bs)
{
    uint32_t bytes_read;

    if (bs->bc < sizeof (*(bs->ptr)) * 8)
        bs->ptr++;

    bytes_read = (uint32_t)(bs->ptr - bs->buf) * sizeof (*(bs->ptr));

    if (!(bytes_read & 1))
        ++bytes_read;

    CLEAR (*bs);
    return bytes_read;
}

// Normally the trailing wrapper will not be available when a WavPack file is first
// opened for reading because it is stored in the final block of the file. This
// function forces a seek to the end of the file to pick up any trailing wrapper
// stored there (then use WavPackGetWrapper**() to obtain). This can obviously only
// be used for seekable files (not pipes) and is not available for pre-4.0 WavPack
// files.

void WavpackSeekTrailingWrapper (WavpackContext *wpc)
{
    if ((wpc->open_flags & OPEN_WRAPPER) &&
        wpc->reader->can_seek (wpc->wv_in) && !wpc->stream3)
            seek_eof_information (wpc, NULL, TRUE);
}

// Get any MD5 checksum stored in the metadata (should be called after reading
// last sample or an extra seek will occur). A return value of FALSE indicates
// that no MD5 checksum was stored.

int WavpackGetMD5Sum (WavpackContext *wpc, unsigned char data [16])
{
    if (wpc->config.flags & CONFIG_MD5_CHECKSUM) {
        if (!wpc->config.md5_read && wpc->reader->can_seek (wpc->wv_in))
            seek_eof_information (wpc, NULL, FALSE);

        if (wpc->config.md5_read) {
            memcpy (data, wpc->config.md5_checksum, 16);
            return TRUE;
        }
    }

    return FALSE;
}

// Read from current file position until a valid 32-byte WavPack 4.0 header is
// found and read into the specified pointer. The number of bytes skipped is
// returned. If no WavPack header is found within 1 meg, then a -1 is returned
// to indicate the error. No additional bytes are read past the header and it
// is returned in the processor's native endian mode. Seeking is not required.

uint32_t read_next_header (WavpackStreamReader64 *reader, void *id, WavpackHeader *wphdr)
{
    unsigned char buffer [sizeof (*wphdr)], *sp = buffer + sizeof (*wphdr), *ep = sp;
    uint32_t bytes_skipped = 0;
    int bleft;

    while (1) {
        if (sp < ep) {
            bleft = (int)(ep - sp);
            memmove (buffer, sp, bleft);
        }
        else
            bleft = 0;

        if (reader->read_bytes (id, buffer + bleft, sizeof (*wphdr) - bleft) != sizeof (*wphdr) - bleft)
            return -1;

        sp = buffer;

        if (*sp++ == 'w' && *sp == 'v' && *++sp == 'p' && *++sp == 'k' &&
            !(*++sp & 1) && sp [2] < 16 && !sp [3] && (sp [2] || sp [1] || *sp >= 24) && sp [5] == 4 &&
            sp [4] >= (MIN_STREAM_VERS & 0xff) && sp [4] <= (MAX_STREAM_VERS & 0xff) && sp [18] < 3 && !sp [19]) {
                memcpy (wphdr, buffer, sizeof (*wphdr));
                WavpackLittleEndianToNative (wphdr, WavpackHeaderFormat);
                return bytes_skipped;
            }

        while (sp < ep && *sp != 'w')
            sp++;

        if ((bytes_skipped += (uint32_t)(sp - buffer)) > 1024 * 1024)
            return -1;
    }
}

// Compare the regular wv file block header to a potential matching wvc
// file block header and return action code based on analysis:
//
//   0 = use wvc block (assuming rest of block is readable)
//   1 = bad match; try to read next wvc block
//  -1 = bad match; ignore wvc file for this block and backup fp (if
//       possible) and try to use this block next time

static int match_wvc_header (WavpackHeader *wv_hdr, WavpackHeader *wvc_hdr)
{
    if (GET_BLOCK_INDEX (*wv_hdr) == GET_BLOCK_INDEX (*wvc_hdr) &&
        wv_hdr->block_samples == wvc_hdr->block_samples) {
            int wvi = 0, wvci = 0;

            if (wv_hdr->flags == wvc_hdr->flags)
                return 0;

            if (wv_hdr->flags & INITIAL_BLOCK)
                wvi -= 1;

            if (wv_hdr->flags & FINAL_BLOCK)
                wvi += 1;

            if (wvc_hdr->flags & INITIAL_BLOCK)
                wvci -= 1;

            if (wvc_hdr->flags & FINAL_BLOCK)
                wvci += 1;

            return (wvci - wvi < 0) ? 1 : -1;
        }

    if (((GET_BLOCK_INDEX (*wvc_hdr) - GET_BLOCK_INDEX (*wv_hdr)) << 24) < 0)
        return 1;
    else
        return -1;
}

// Read the wvc block that matches the regular wv block that has been
// read for the current stream. If an exact match is not found then
// we either keep reading or back up and (possibly) use the block
// later. The skip_wvc flag is set if not matching wvc block is found
// so that we can still decode using only the lossy version (although
// we flag this as an error). A return of FALSE indicates a serious
// error (not just that we missed one wvc block).

int read_wvc_block (WavpackContext *wpc)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int64_t bcount, file2pos;
    WavpackHeader orig_wphdr;
    WavpackHeader wphdr;
    int compare_result;

    while (1) {
        file2pos = wpc->reader->get_pos (wpc->wvc_in);
        bcount = read_next_header (wpc->reader, wpc->wvc_in, &wphdr);

        if (bcount == (uint32_t) -1) {
            wps->wvc_skip = TRUE;
            wpc->crc_errors++;
            return FALSE;
        }

        memcpy (&orig_wphdr, &wphdr, 32);       // save original header for verify step

        if (wpc->open_flags & OPEN_STREAMING)
            SET_BLOCK_INDEX (wphdr, wps->sample_index = 0);
        else
            SET_BLOCK_INDEX (wphdr, GET_BLOCK_INDEX (wphdr) - wpc->initial_index);

        if (wphdr.flags & INITIAL_BLOCK)
            wpc->file2pos = file2pos + bcount;

        compare_result = match_wvc_header (&wps->wphdr, &wphdr);

        if (!compare_result) {
            wps->block2buff = malloc (wphdr.ckSize + 8);
	    if (!wps->block2buff)
	        return FALSE;

            if (wpc->reader->read_bytes (wpc->wvc_in, wps->block2buff + 32, wphdr.ckSize - 24) !=
                wphdr.ckSize - 24) {
                    free (wps->block2buff);
                    wps->block2buff = NULL;
                    wps->wvc_skip = TRUE;
                    wpc->crc_errors++;
                    return FALSE;
            }

            memcpy (wps->block2buff, &orig_wphdr, 32);

            // don't use corrupt blocks
            if (!WavpackVerifySingleBlock (wps->block2buff, !(wpc->open_flags & OPEN_NO_CHECKSUM))) {
                free (wps->block2buff);
                wps->block2buff = NULL;
                wps->wvc_skip = TRUE;
                wpc->crc_errors++;
                return TRUE;
            }

            wps->wvc_skip = FALSE;
            memcpy (wps->block2buff, &wphdr, 32);
            memcpy (&wps->wphdr, &wphdr, 32);
            return TRUE;
        }
        else if (compare_result == -1) {
            wps->wvc_skip = TRUE;
            wpc->reader->set_pos_rel (wpc->wvc_in, -32, SEEK_CUR);
            wpc->crc_errors++;
            return TRUE;
        }
    }
}

// This function is used to seek to end of a file to obtain certain information
// that is stored there at the file creation time because it is not known at
// the start. This includes the MD5 sum and and trailing part of the file
// wrapper, and in some rare cases may include the total number of samples in
// the file (although we usually try to back up and write that at the front of
// the file). Note this function restores the file position to its original
// location (and obviously requires a seekable file). The normal return value
// is TRUE indicating no errors, although this does not actually mean that any
// information was retrieved. An error return of FALSE usually means the file
// terminated unexpectedly. Note that this could be used to get all three
// types of information in one go, but it's not actually used that way now.

static int seek_eof_information (WavpackContext *wpc, int64_t *final_index, int get_wrapper)
{
    int64_t restore_pos, last_pos = -1;
    WavpackStreamReader64 *reader = wpc->reader;
    int alt_types = wpc->open_flags & OPEN_ALT_TYPES;
    uint32_t blocks = 0, audio_blocks = 0;
    void *id = wpc->wv_in;
    WavpackHeader wphdr;

    restore_pos = reader->get_pos (id);    // we restore file position when done

    // start 1MB from the end-of-file, or from the start if the file is not that big

    if (reader->get_length (id) > (int64_t) 1048576)
        reader->set_pos_rel (id, -1048576, SEEK_END);
    else
        reader->set_pos_abs (id, 0);

    // Note that we go backward (without parsing inside blocks) until we find a block
    // with audio (careful to not get stuck in a loop). Only then do we go forward
    // parsing all blocks in their entirety.

    while (1) {
        uint32_t bcount = read_next_header (reader, id, &wphdr);
        int64_t current_pos = reader->get_pos (id);

        // if we just got to the same place as last time, we're stuck and need to give up

        if (current_pos == last_pos) {
            reader->set_pos_abs (id, restore_pos);
            return FALSE;
        }

        last_pos = current_pos;

        // We enter here if we just read 1 MB without seeing any WavPack block headers.
        // Since WavPack blocks are < 1 MB, that means we're in a big APE tag, or we got
        // to the end-of-file.

        if (bcount == (uint32_t) -1) {

            // if we have not seen any blocks at all yet, back up almost 2 MB (or to the
            // beginning of the file) and try again

            if (!blocks) {
                if (current_pos > (int64_t) 2000000)
                    reader->set_pos_rel (id, -2000000, SEEK_CUR);
                else
                    reader->set_pos_abs (id, 0);

                continue;
            }

            // if we have seen WavPack blocks, then this means we've done all we can do here

            reader->set_pos_abs (id, restore_pos);
            return TRUE;
        }

        blocks++;

        // If the block has audio samples, calculate a final index, although this is not
        // final since this may not be the last block with audio. On the other hand, if
        // this block does not have audio, and we haven't seen one with audio, we have
        // to go back some more.

        if (wphdr.block_samples) {
            if (final_index)
                *final_index = GET_BLOCK_INDEX (wphdr) + wphdr.block_samples;

            audio_blocks++;
        }
        else if (!audio_blocks) {
            if (current_pos > (int64_t) 1048576)
                reader->set_pos_rel (id, -1048576, SEEK_CUR);
            else
                reader->set_pos_abs (id, 0);

            continue;
        }

        // at this point we have seen at least one block with audio, so we parse the
        // entire block looking for MD5 metadata or (conditionally) trailing wrappers

        bcount = wphdr.ckSize - sizeof (WavpackHeader) + 8;

        while (bcount >= 2) {
            unsigned char meta_id, c1, c2;
            uint32_t meta_bc, meta_size;

            if (reader->read_bytes (id, &meta_id, 1) != 1 ||
                reader->read_bytes (id, &c1, 1) != 1) {
                    reader->set_pos_abs (id, restore_pos);
                    return FALSE;
            }

            meta_bc = c1 << 1;
            bcount -= 2;

            if (meta_id & ID_LARGE) {
                if (bcount < 2 || reader->read_bytes (id, &c1, 1) != 1 ||
                    reader->read_bytes (id, &c2, 1) != 1) {
                        reader->set_pos_abs (id, restore_pos);
                        return FALSE;
                }

                meta_bc += ((uint32_t) c1 << 9) + ((uint32_t) c2 << 17);
                bcount -= 2;
            }

            meta_size = (meta_id & ID_ODD_SIZE) ? meta_bc - 1 : meta_bc;
            meta_id &= ID_UNIQUE;

            if (get_wrapper && (meta_id == ID_RIFF_TRAILER || (alt_types && meta_id == ID_ALT_TRAILER)) && meta_bc) {
                wpc->wrapper_data = realloc (wpc->wrapper_data, wpc->wrapper_bytes + meta_bc);

                if (!wpc->wrapper_data) {
                    reader->set_pos_abs (id, restore_pos);
                    return FALSE;
                }

                if (reader->read_bytes (id, wpc->wrapper_data + wpc->wrapper_bytes, meta_bc) == meta_bc)
                    wpc->wrapper_bytes += meta_size;
                else {
                    reader->set_pos_abs (id, restore_pos);
                    return FALSE;
                }
            }
            else if (meta_id == ID_MD5_CHECKSUM || (alt_types && meta_id == ID_ALT_MD5_CHECKSUM)) {
                if (meta_bc == 16 && bcount >= 16) {
                    if (reader->read_bytes (id, wpc->config.md5_checksum, 16) == 16)
                        wpc->config.md5_read = TRUE;
                    else {
                        reader->set_pos_abs (id, restore_pos);
                        return FALSE;
                    }
                }
                else
                    reader->set_pos_rel (id, meta_bc, SEEK_CUR);
            }
            else
                reader->set_pos_rel (id, meta_bc, SEEK_CUR);

            bcount -= meta_bc;
        }
    }
}

// Quickly verify the referenced block. It is assumed that the WavPack header has been converted
// to native endian format. If a block checksum is performed, that is done in little-endian
// (file) format. It is also assumed that the caller has made sure that the block length
// indicated in the header is correct (we won't overflow the buffer). If a checksum is present,
// then it is checked, otherwise we just check that all the metadata blocks are formatted
// correctly (without looking at their contents). Returns FALSE for bad block.

int WavpackVerifySingleBlock (unsigned char *buffer, int verify_checksum)
{
    WavpackHeader *wphdr = (WavpackHeader *) buffer;
    uint32_t checksum_passed = 0, bcount, meta_bc;
    unsigned char *dp, meta_id, c1, c2;

    if (strncmp (wphdr->ckID, "wvpk", 4) || wphdr->ckSize + 8 < sizeof (WavpackHeader))
        return FALSE;

    bcount = wphdr->ckSize - sizeof (WavpackHeader) + 8;
    dp = (unsigned char *)(wphdr + 1);

    while (bcount >= 2) {
        meta_id = *dp++;
        c1 = *dp++;

        meta_bc = c1 << 1;
        bcount -= 2;

        if (meta_id & ID_LARGE) {
            if (bcount < 2)
                return FALSE;

            c1 = *dp++;
            c2 = *dp++;
            meta_bc += ((uint32_t) c1 << 9) + ((uint32_t) c2 << 17);
            bcount -= 2;
        }

        if (bcount < meta_bc)
            return FALSE;

        if (verify_checksum && (meta_id & ID_UNIQUE) == ID_BLOCK_CHECKSUM) {
#ifdef BITSTREAM_SHORTS
            uint16_t *csptr = (uint16_t*) buffer;
#else
            unsigned char *csptr = buffer;
#endif
            int wcount = (int)(dp - 2 - buffer) >> 1;
            uint32_t csum = (uint32_t) -1;

            if ((meta_id & ID_ODD_SIZE) || meta_bc < 2 || meta_bc > 4)
                return FALSE;

#ifdef BITSTREAM_SHORTS
            while (wcount--)
                csum = (csum * 3) + *csptr++;
#else
            WavpackNativeToLittleEndian ((WavpackHeader *) buffer, WavpackHeaderFormat);

            while (wcount--) {
                csum = (csum * 3) + csptr [0] + (csptr [1] << 8);
                csptr += 2;
            }

            WavpackLittleEndianToNative ((WavpackHeader *) buffer, WavpackHeaderFormat);
#endif

            if (meta_bc == 4) {
                if (*dp++ != (csum & 0xff) || *dp++ != ((csum >> 8) & 0xff) || *dp++ != ((csum >> 16) & 0xff) || *dp++ != ((csum >> 24) & 0xff))
                    return FALSE;
            }
            else {
                csum ^= csum >> 16;

                if (*dp++ != (csum & 0xff) || *dp++ != ((csum >> 8) & 0xff))
                    return FALSE;
            }

            checksum_passed++;
        }

        bcount -= meta_bc;
        dp += meta_bc;
    }

    return (bcount == 0) && (!verify_checksum || !(wphdr->flags & HAS_CHECKSUM) || checksum_passed);
}

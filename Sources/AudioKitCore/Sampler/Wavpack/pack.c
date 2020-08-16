////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//               MMX optimizations (c) 2006 Joachim Henke                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// pack.c

// This module actually handles the compression of the audio data, except for
// the entropy encoding which is handled by the write_words.c module. For better
// efficiency, the conversion is isolated to tight loops that handle an entire
// buffer.

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "wavpack_local.h"
#include "decorr_tables.h"      // contains data, only include from this module!

///////////////////////////// executable code ////////////////////////////////

// This function initializes everything required to pack WavPack bitstreams
// and must be called BEFORE any other function in this module.

void pack_init (WavpackContext *wpc)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];

    wps->sample_index = 0;
    wps->delta_decay = 2.0;
    CLEAR (wps->decorr_passes);
    CLEAR (wps->dc);

#ifdef SKIP_DECORRELATION
    wpc->config.xmode = 0;
#endif

    /* although we set the term and delta values here for clarity, they're
     * actually hardcoded in the analysis function for speed
     */

    CLEAR (wps->analysis_pass);
    wps->analysis_pass.term = 18;
    wps->analysis_pass.delta = 2;

    if (wpc->config.flags & CONFIG_AUTO_SHAPING) {
        if (wpc->config.flags & CONFIG_OPTIMIZE_WVC)
            wps->dc.shaping_acc [0] = wps->dc.shaping_acc [1] = -(512L << 16);
        else if (wpc->config.sample_rate >= 64000)
            wps->dc.shaping_acc [0] = wps->dc.shaping_acc [1] = 1024L << 16;
        else
            wpc->config.flags |= CONFIG_DYNAMIC_SHAPING;
    }
    else {
        int32_t weight = (int32_t) floor (wpc->config.shaping_weight * 1024.0 + 0.5);

        if (weight <= -1000)
            weight = -1000;

        wps->dc.shaping_acc [0] = wps->dc.shaping_acc [1] = weight << 16;
    }

    if (wpc->config.flags & CONFIG_DYNAMIC_SHAPING)
        wps->dc.shaping_data = malloc (wpc->max_samples * sizeof (*wps->dc.shaping_data));

    if (!wpc->config.xmode)
        wps->num_passes = 0;
    else if (wpc->config.xmode == 1)
        wps->num_passes = 2;
    else if (wpc->config.xmode == 2)
        wps->num_passes = 4;
    else
        wps->num_passes = 9;

    if (wpc->config.flags & CONFIG_VERY_HIGH_FLAG) {
        wps->num_decorrs = NUM_VERY_HIGH_SPECS;
        wps->decorr_specs = very_high_specs;
    }
    else if (wpc->config.flags & CONFIG_HIGH_FLAG) {
        wps->num_decorrs = NUM_HIGH_SPECS;
        wps->decorr_specs = high_specs;
    }
    else if (wpc->config.flags & CONFIG_FAST_FLAG) {
        wps->num_decorrs = NUM_FAST_SPECS;
        wps->decorr_specs = fast_specs;
    }
    else {
        wps->num_decorrs = NUM_DEFAULT_SPECS;
        wps->decorr_specs = default_specs;
    }

    init_words (wps);
}

// Allocate room for and copy the decorrelation terms from the decorr_passes
// array into the specified metadata structure. Both the actual term id and
// the delta are packed into single characters.

static void write_decorr_terms (WavpackStream *wps, WavpackMetadata *wpmd)
{
    int tcount = wps->num_terms;
    struct decorr_pass *dpp;
    char *byteptr;

    byteptr = wpmd->data = malloc (tcount + 1);
    wpmd->id = ID_DECORR_TERMS;

    for (dpp = wps->decorr_passes; tcount--; ++dpp)
        *byteptr++ = ((dpp->term + 5) & 0x1f) | ((dpp->delta << 5) & 0xe0);

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the decorrelation term weights from the
// decorr_passes array into the specified metadata structure. The weights
// range +/-1024, but are rounded and truncated to fit in signed chars for
// metadata storage. Weights are separate for the two channels

static void write_decorr_weights (WavpackStream *wps, WavpackMetadata *wpmd)
{
    struct decorr_pass *dpp = wps->decorr_passes;
    int tcount = wps->num_terms, i;
    char *byteptr;

    byteptr = wpmd->data = malloc ((tcount * 2) + 1);
    wpmd->id = ID_DECORR_WEIGHTS;

    for (i = wps->num_terms - 1; i >= 0; --i)
        if (store_weight (dpp [i].weight_A) ||
            (!(wps->wphdr.flags & MONO_DATA) && store_weight (dpp [i].weight_B)))
                break;

    tcount = i + 1;

    for (i = 0; i < wps->num_terms; ++i) {
        if (i < tcount) {
            dpp [i].weight_A = restore_weight (*byteptr++ = store_weight (dpp [i].weight_A));

            if (!(wps->wphdr.flags & MONO_DATA))
                dpp [i].weight_B = restore_weight (*byteptr++ = store_weight (dpp [i].weight_B));
        }
        else
            dpp [i].weight_A = dpp [i].weight_B = 0;
    }

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the decorrelation samples from the decorr_passes
// array into the specified metadata structure. The samples are signed 32-bit
// values, but are converted to signed log2 values for storage in metadata.
// Values are stored for both channels and are specified from the first term
// with unspecified samples set to zero. The number of samples stored varies
// with the actual term value, so those must obviously be specified before
// these in the metadata list. Any number of terms can have their samples
// specified from no terms to all the terms, however I have found that
// sending more than the first term's samples is a waste. The "wcount"
// variable can be set to the number of terms to have their samples stored.

static void write_decorr_samples (WavpackStream *wps, WavpackMetadata *wpmd)
{
    int tcount = wps->num_terms, wcount = 1, temp;
    struct decorr_pass *dpp;
    unsigned char *byteptr;

    byteptr = wpmd->data = malloc (256);
    wpmd->id = ID_DECORR_SAMPLES;

    for (dpp = wps->decorr_passes; tcount--; ++dpp)
        if (wcount) {
            if (dpp->term > MAX_TERM) {
                dpp->samples_A [0] = wp_exp2s (temp = wp_log2s (dpp->samples_A [0]));
                *byteptr++ = temp;
                *byteptr++ = temp >> 8;
                dpp->samples_A [1] = wp_exp2s (temp = wp_log2s (dpp->samples_A [1]));
                *byteptr++ = temp;
                *byteptr++ = temp >> 8;

                if (!(wps->wphdr.flags & MONO_DATA)) {
                    dpp->samples_B [0] = wp_exp2s (temp = wp_log2s (dpp->samples_B [0]));
                    *byteptr++ = temp;
                    *byteptr++ = temp >> 8;
                    dpp->samples_B [1] = wp_exp2s (temp = wp_log2s (dpp->samples_B [1]));
                    *byteptr++ = temp;
                    *byteptr++ = temp >> 8;
                }
            }
            else if (dpp->term < 0) {
                dpp->samples_A [0] = wp_exp2s (temp = wp_log2s (dpp->samples_A [0]));
                *byteptr++ = temp;
                *byteptr++ = temp >> 8;
                dpp->samples_B [0] = wp_exp2s (temp = wp_log2s (dpp->samples_B [0]));
                *byteptr++ = temp;
                *byteptr++ = temp >> 8;
            }
            else {
                int m = 0, cnt = dpp->term;

                while (cnt--) {
                    dpp->samples_A [m] = wp_exp2s (temp = wp_log2s (dpp->samples_A [m]));
                    *byteptr++ = temp;
                    *byteptr++ = temp >> 8;

                    if (!(wps->wphdr.flags & MONO_DATA)) {
                        dpp->samples_B [m] = wp_exp2s (temp = wp_log2s (dpp->samples_B [m]));
                        *byteptr++ = temp;
                        *byteptr++ = temp >> 8;
                    }

                    m++;
                }
            }

            wcount--;
        }
        else {
            CLEAR (dpp->samples_A);
            CLEAR (dpp->samples_B);
        }

    wpmd->byte_length = (int32_t)(byteptr - (unsigned char *) wpmd->data);
}

// Allocate room for and copy the noise shaping info into the specified
// metadata structure. These would normally be written to the
// "correction" file and are used for lossless reconstruction of
// hybrid data. The "delta" parameter is not yet used in encoding as it
// will be part of the "quality" mode.

static void write_shaping_info (WavpackStream *wps, WavpackMetadata *wpmd)
{
    char *byteptr;
    int temp;

    byteptr = wpmd->data = malloc (12);
    wpmd->id = ID_SHAPING_WEIGHTS;

    wps->dc.error [0] = wp_exp2s (temp = wp_log2s (wps->dc.error [0]));
    *byteptr++ = temp;
    *byteptr++ = temp >> 8;
    wps->dc.shaping_acc [0] = wp_exp2s (temp = wp_log2s (wps->dc.shaping_acc [0]));
    *byteptr++ = temp;
    *byteptr++ = temp >> 8;

    if (!(wps->wphdr.flags & MONO_DATA)) {
        wps->dc.error [1] = wp_exp2s (temp = wp_log2s (wps->dc.error [1]));
        *byteptr++ = temp;
        *byteptr++ = temp >> 8;
        wps->dc.shaping_acc [1] = wp_exp2s (temp = wp_log2s (wps->dc.shaping_acc [1]));
        *byteptr++ = temp;
        *byteptr++ = temp >> 8;
    }

    if (wps->dc.shaping_delta [0] | wps->dc.shaping_delta [1]) {
        wps->dc.shaping_delta [0] = wp_exp2s (temp = wp_log2s (wps->dc.shaping_delta [0]));
        *byteptr++ = temp;
        *byteptr++ = temp >> 8;

        if (!(wps->wphdr.flags & MONO_DATA)) {
            wps->dc.shaping_delta [1] = wp_exp2s (temp = wp_log2s (wps->dc.shaping_delta [1]));
            *byteptr++ = temp;
            *byteptr++ = temp >> 8;
        }
    }

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the int32 data values into the specified
// metadata structure. This data is used for integer data that has more
// than 24 bits of magnitude or, in some cases, it's used to eliminate
// redundant bits from any audio stream.

static void write_int32_info (WavpackStream *wps, WavpackMetadata *wpmd)
{
    char *byteptr;

    byteptr = wpmd->data = malloc (4);
    wpmd->id = ID_INT32_INFO;
    *byteptr++ = wps->int32_sent_bits;
    *byteptr++ = wps->int32_zeros;
    *byteptr++ = wps->int32_ones;
    *byteptr++ = wps->int32_dups;
    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

static void write_float_info (WavpackStream *wps, WavpackMetadata *wpmd)
{
    char *byteptr;

    byteptr = wpmd->data = malloc (4);
    wpmd->id = ID_FLOAT_INFO;
    *byteptr++ = wps->float_flags;
    *byteptr++ = wps->float_shift;
    *byteptr++ = wps->float_max_exp;
    *byteptr++ = wps->float_norm_exp;
    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the multichannel information into the specified
// metadata structure. The first byte is the total number of channels and the
// following bytes represent the channel_mask as described for Microsoft
// WAVEFORMATEX.

static void write_channel_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    uint32_t mask = wpc->config.channel_mask;
    char *byteptr = wpmd->data = malloc (8);

    wpmd->id = ID_CHANNEL_INFO;

    if (wpc->num_streams > OLD_MAX_STREAMS) {       // if > 8 streams, use 6 or 7 bytes (breaks old decoders
        *byteptr++ = wpc->config.num_channels - 1;  // that could only handle 8 streams) and allow (in theory)
        *byteptr++ = wpc->num_streams - 1;          // up to 4096 channels
        *byteptr++ = (((wpc->num_streams - 1) >> 4) & 0xf0) | (((wpc->config.num_channels - 1) >> 8) & 0xf);
        *byteptr++ = mask;
        *byteptr++ = (mask >> 8);
        *byteptr++ = (mask >> 16);

        if (mask & 0xff000000)                      // this will break versions < 5.0, but is RF64-specific
            *byteptr++ = (mask >> 24);
    }
    else {                                          // otherwise use only 1 to 5 bytes
        *byteptr++ = wpc->config.num_channels;

        while (mask) {
            *byteptr++ = mask;
            mask >>= 8;
        }
    }

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the multichannel identities into the specified
// metadata structure. Data is an array of unsigned characters representing
// any channels in the file that DO NOT match one the 18 Microsoft standard
// channels (and are represented in the channel mask). A value of 0 is not
// allowed and 0xff means an unknown or undefined channel identity.

static void write_channel_identities_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    wpmd->byte_length = (int) strlen ((char *) wpc->channel_identities);
    wpmd->data = strdup ((char *) wpc->channel_identities);
    wpmd->id = ID_CHANNEL_IDENTITIES;
}

// Allocate room for and copy the configuration information into the specified
// metadata structure. Currently, we just store the upper 3 bytes of
// config.flags and only in the first block of audio data. Note that this is
// for informational purposes not required for playback or decoding (like
// whether high or fast mode was specified).

static void write_config_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    char *byteptr;

    byteptr = wpmd->data = malloc (8);
    wpmd->id = ID_CONFIG_BLOCK;
    *byteptr++ = (char) (wpc->config.flags >> 8);
    *byteptr++ = (char) (wpc->config.flags >> 16);
    *byteptr++ = (char) (wpc->config.flags >> 24);

    if (wpc->config.flags & CONFIG_EXTRA_MODE)
        *byteptr++ = (char) wpc->config.xmode;

    // for the 5.0.0 alpha, we wrote the qmode flags here, but this
    // has been replaced with the new_config block
    // *byteptr++ = (char) wpc->config.qmode;

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the "new" configuration information into the
// specified metadata structure. This is all the stuff introduced with version
// 5.0 and includes the qmode flags (big-endian, etc.) and CAF extended
// channel layouts (including optional reordering). Even if there is no new
// configuration, we still send the empty metadata block to signal a 5.0 file.

static void write_new_config_info (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    char *byteptr = wpmd->data = malloc (260);

    wpmd->id = ID_NEW_CONFIG_BLOCK;

    if (wpc->file_format || (wpc->config.qmode & 0xff) || wpc->channel_layout) {
        *byteptr++ = (char) wpc->file_format;
        *byteptr++ = (char) wpc->config.qmode;

        if (wpc->channel_layout) {
            int nchans = wpc->channel_layout & 0xff;

            *byteptr++ = (char) ((wpc->channel_layout & 0xff0000) >> 16);

            if (wpc->channel_reordering || nchans != wpc->config.num_channels)
                *byteptr++ = (char) nchans;

            if (wpc->channel_reordering) {
                int i, num_to_send = 0;

                // to save space, don't send redundant reorder string bytes

                for (i = 0; i < nchans; ++i)
                    if (wpc->channel_reordering [i] != i)
                        num_to_send = i + 1;

                if (num_to_send) {
                    memcpy (byteptr, wpc->channel_reordering, num_to_send);
                    byteptr += num_to_send;
                }
            }
        }
    }

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Allocate room for and copy the non-standard sampling rate into the specified
// metadata structure. We normally store the lower 3 bytes of the sampling rate,
// unless 4 bytes are required (introduced in version 5). Note that this would
// only be used when the sampling rate was not included in the table of 15
// "standard" values.

static void write_sample_rate (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    char *byteptr;

    byteptr = wpmd->data = malloc (4);
    wpmd->id = ID_SAMPLE_RATE;
    *byteptr++ = (char) (wpc->config.sample_rate);
    *byteptr++ = (char) (wpc->config.sample_rate >> 8);
    *byteptr++ = (char) (wpc->config.sample_rate >> 16);

    // handle 4-byte sampling rates for scientific applications, etc.

    if (wpc->config.sample_rate & 0x7f000000)
        *byteptr++ = (char) (wpc->config.sample_rate >> 24) & 0x7f;

    wpmd->byte_length = (int32_t)(byteptr - (char *) wpmd->data);
}

// Pack an entire block of samples (either mono or stereo) into a completed
// WavPack block. This function is actually a shell for pack_samples() and
// performs tasks like handling any shift required by the format, preprocessing
// of floating point data or integer data over 24 bits wide, and implementing
// the "extra" mode (via the extra?.c modules). It is assumed that there is
// sufficient space for the completed block at "wps->blockbuff" and that
// "wps->blockend" points to the end of the available space. A return value of
// FALSE indicates an error.

static int scan_int32_data (WavpackStream *wps, int32_t *values, int32_t num_values);
static void scan_int32_quick (WavpackStream *wps, int32_t *values, int32_t num_values);
static void send_int32_data (WavpackStream *wps, int32_t *values, int32_t num_values);
static int scan_redundancy (int32_t *values, int32_t num_values);
static int pack_samples (WavpackContext *wpc, int32_t *buffer);
static void bs_open_write (Bitstream *bs, void *buffer_start, void *buffer_end);
static uint32_t bs_close_write (Bitstream *bs);

int pack_block (WavpackContext *wpc, int32_t *buffer)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags, sflags = wps->wphdr.flags;
    int32_t sample_count = wps->wphdr.block_samples, *orig_data = NULL;
    int dynamic_shaping_done = FALSE;

    // This is done first because this code can potentially change the size of the block about to
    // be encoded. This can happen because the dynamic noise shaping algorithm wants to send a
    // shorter block because the desired noise-shaping profile is changing quickly. It can also
    // be that the --merge-blocks feature wants to create a longer block because it combines areas
    // with equal redundancy. These are not applicable for anything besides the first stream of
    // the file and they are not applicable with float data or >24-bit data.

    if (!wpc->current_stream && !(flags & FLOAT_DATA) && (flags & MAG_MASK) >> MAG_LSB < 24) {
        if ((wpc->config.flags & CONFIG_DYNAMIC_SHAPING) && !wpc->config.block_samples) {
            dynamic_noise_shaping (wpc, buffer, TRUE);
            sample_count = wps->wphdr.block_samples;
            dynamic_shaping_done = TRUE;
        }
        else if (wpc->block_boundary && sample_count >= (int32_t) wpc->block_boundary * 2) {
            int bc = sample_count / wpc->block_boundary, chans = (flags & MONO_DATA) ? 1 : 2;
            int res = scan_redundancy (buffer, wpc->block_boundary * chans), i; 

            for (i = 1; i < bc; ++i)
                if (res != scan_redundancy (buffer + (i * wpc->block_boundary * chans),
                    wpc->block_boundary * chans)) {
                        sample_count = wps->wphdr.block_samples = wpc->block_boundary * i;
                        break;
                    }
        }
    }

    // This code scans stereo data to check whether it can be stored as mono data
    // (i.e., all L/R samples identical). Only available with MAX_STREAM_VERS.

    if (!(flags & MONO_FLAG) && wpc->stream_version == MAX_STREAM_VERS) {
        int32_t lor = 0, diff = 0;
        int32_t *sptr, *dptr, i;

        for (sptr = buffer, i = 0; i < (int32_t) sample_count; sptr += 2, i++) {
            lor |= sptr [0] | sptr [1];
            diff |= sptr [0] - sptr [1];

            if (lor && diff)
                break;
        }

        if (i == sample_count && lor && !diff) {
            flags &= ~(JOINT_STEREO | CROSS_DECORR | HYBRID_BALANCE);
            wps->wphdr.flags = flags |= FALSE_STEREO;
            dptr = buffer;
            sptr = buffer;

            for (i = sample_count; i--; sptr++)
                *dptr++ = *sptr++;

            if (!wps->false_stereo) {
                wps->false_stereo = 1;
                wps->num_terms = 0;
                init_words (wps);
            }
        }
        else if (wps->false_stereo) {
            wps->false_stereo = 0;
            wps->num_terms = 0;
            init_words (wps);
        }
    }

    // This is where we handle any fixed shift which occurs when the integer size does not evenly fit
    // in bytes (like 12-bit or 20-bit) and is the same for the entire file (not based on scanning)

    if (flags & SHIFT_MASK) {
        int shift = (flags & SHIFT_MASK) >> SHIFT_LSB;
        int mag = (flags & MAG_MASK) >> MAG_LSB;
        uint32_t cnt = sample_count;
        int32_t *ptr = buffer;

        if (flags & MONO_DATA)
            while (cnt--)
                *ptr++ >>= shift;
        else
            while (cnt--) {
                *ptr++ >>= shift;
                *ptr++ >>= shift;
            }

        if ((mag -= shift) < 0)
            flags &= ~MAG_MASK;
        else
            flags -= (1 << MAG_LSB) * shift;

        wps->wphdr.flags = flags;
    }

    // The regular WavPack decorrelation and entropy encoding can handle up to 24-bit integer data. If
    // we have float data or integers larger than 24-bit, then we have to potentially do extra processing.
    // For lossy encoding, we can simply convert this data in-place to 24-bit data and encode and sent
    // that, along with some metadata about how to restore the original format (even if the restoration
    // is not exact). However, for lossless operation we must make a copy of the original data that will
    // be used to create a "extension stream" that will allow verbatim restoration of the original data.
    // In the hybrid mode that extension goes in the correction file, otherwise it goes in the mail file.

    if ((flags & FLOAT_DATA) || (flags & MAG_MASK) >> MAG_LSB >= 24) {      // if float data or >24-bit integers...

        // if lossless we have to copy the data to use later...

        if ((!(flags & HYBRID_FLAG) || wpc->wvc_flag) && !(wpc->config.flags & CONFIG_SKIP_WVX)) {
            orig_data = malloc (sizeof (f32) * ((flags & MONO_DATA) ? sample_count : sample_count * 2));
            memcpy (orig_data, buffer, sizeof (f32) * ((flags & MONO_DATA) ? sample_count : sample_count * 2));

            if (flags & FLOAT_DATA) {                                       // if lossless float data come here
                wps->float_norm_exp = wpc->config.float_norm_exp;

                if (!scan_float_data (wps, (f32 *) buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2)) {
                    free (orig_data);
                    orig_data = NULL;
                }
            }
            else {                                                          // otherwise lossless > 24-bit integers
                if (!scan_int32_data (wps, buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2)) {
                    free (orig_data);
                    orig_data = NULL;
                }
            }
        }
        else {                                                              // otherwise, we're lossy, so no copy
            if (flags & FLOAT_DATA) {
                wps->float_norm_exp = wpc->config.float_norm_exp;

                if (scan_float_data (wps, (f32 *) buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2))
                    wpc->lossy_blocks = TRUE;
            }
            else if (scan_int32_data (wps, buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2))
                wpc->lossy_blocks = TRUE;
        }

        // if there's any chance of magnitude change, clear the noise-shaping error term
        // and also reset the entropy encoder (which this does)

        wps->dc.error [0] = wps->dc.error [1] = 0;
        wps->num_terms = 0;
    }
    // if 24-bit integers or less we do a "quick" scan which just scans for redundancy and does NOT set the flag's "magnitude" value
    else {
        scan_int32_quick (wps, buffer, (flags & MONO_DATA) ? sample_count : sample_count * 2);

        if (wps->shift != wps->int32_zeros + wps->int32_ones + wps->int32_dups) {   // detect a change in any redundancy shifting here
            wps->shift = wps->int32_zeros + wps->int32_ones + wps->int32_dups;
            wps->dc.error [0] = wps->dc.error [1] = 0;                              // on a change, clear the noise-shaping error term and
            wps->num_terms = 0;                                                     // also reset the entropy encoder (which this does)
        }
    }

    if ((wpc->config.flags & CONFIG_DYNAMIC_SHAPING) && !dynamic_shaping_done)      // calculate dynamic noise profile
        dynamic_noise_shaping (wpc, buffer, FALSE);

    // In some cases we need to start the decorrelation and entropy encoding from scratch. This
    // could be because we switched from stereo to mono encoding or because the magnitude of
    // the data changed, or just because this is the first block.

    if (!wps->num_passes && !wps->num_terms) {
        wps->num_passes = 1;

        if (flags & MONO_DATA)
            execute_mono (wpc, buffer, 1, 0);
        else
            execute_stereo (wpc, buffer, 1, 0);

        wps->num_passes = 0;
    }

    // actually pack the block here and return on an error (which pretty much can only be a block buffer overrun)

    if (!pack_samples (wpc, buffer)) {
        wps->wphdr.flags = sflags;

        if (orig_data)
            free (orig_data);

        return FALSE;
    }
    else
        wps->wphdr.flags = sflags;

    // potentially move any unused dynamic noise shaping profile data to use next time

    if (wps->dc.shaping_data) {
        if (wps->dc.shaping_samples != sample_count)
            memmove (wps->dc.shaping_data, wps->dc.shaping_data + sample_count,
                (wps->dc.shaping_samples - sample_count) * sizeof (*wps->dc.shaping_data));

        wps->dc.shaping_samples -= sample_count;
    }

    // finally, if we're doing lossless float data or lossless >24-bit integers, this is where we take the
    // original data that we saved earlier and create the "extension" stream containing the information
    // required to refine the "lossy" 24-bit data into the lossless original

    if (orig_data) {
        uint32_t data_count;
        unsigned char *cptr;

        if (wpc->wvc_flag)
            cptr = wps->block2buff + ((WavpackHeader *) wps->block2buff)->ckSize + 8;
        else
            cptr = wps->blockbuff + ((WavpackHeader *) wps->blockbuff)->ckSize + 8;

        bs_open_write (&wps->wvxbits, cptr + 8, wpc->wvc_flag ? wps->block2end : wps->blockend);

        if (flags & FLOAT_DATA)
            send_float_data (wps, (f32*) orig_data, (flags & MONO_DATA) ? sample_count : sample_count * 2);
        else
            send_int32_data (wps, orig_data, (flags & MONO_DATA) ? sample_count : sample_count * 2);

        data_count = bs_close_write (&wps->wvxbits);
        free (orig_data);

        if (data_count) {
            if (data_count != (uint32_t) -1) {
                *cptr++ = ID_WVX_BITSTREAM | ID_LARGE;
                *cptr++ = (data_count += 4) >> 1;
                *cptr++ = data_count >> 9;
                *cptr++ = data_count >> 17;
                *cptr++ = wps->crc_x;
                *cptr++ = wps->crc_x >> 8;
                *cptr++ = wps->crc_x >> 16;
                *cptr = wps->crc_x >> 24;

                if (wpc->wvc_flag)
                    ((WavpackHeader *) wps->block2buff)->ckSize += data_count + 4;
                else
                    ((WavpackHeader *) wps->blockbuff)->ckSize += data_count + 4;
            }
            else
                return FALSE;
        }
    }

    return TRUE;
}

// Quickly scan a buffer of long integer data and determine whether any
// redundancy in the LSBs can be used to reduce the data's magnitude. If yes,
// then the INT32_DATA flag is set and the int32 parameters are set. This
// version is designed to terminate as soon as it figures out that no
// redundancy is available so that it can be used for all files.

static void scan_int32_quick (WavpackStream *wps, int32_t *values, int32_t num_values)
{
    uint32_t magdata = 0, ordata = 0, xordata = 0, anddata = ~0;
    int total_shift = 0;
    int32_t *dp, count;

    wps->int32_sent_bits = wps->int32_zeros = wps->int32_ones = wps->int32_dups = 0;

    for (dp = values, count = num_values; count--; dp++) {
        magdata |= (*dp < 0) ? ~*dp : *dp;
        xordata |= *dp ^ -(*dp & 1);
        anddata &= *dp;
        ordata |= *dp;

        if ((ordata & 1) && !(anddata & 1) && (xordata & 2))
            return;
    }

    wps->wphdr.flags &= ~MAG_MASK;

    while (magdata) {
        wps->wphdr.flags += 1 << MAG_LSB;
        magdata >>= 1;
    }

    if (!(wps->wphdr.flags & MAG_MASK))
        return;

    if (!(ordata & 1))
        while (!(ordata & 1)) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_zeros++;
            total_shift++;
            ordata >>= 1;
        }
    else if (anddata & 1)
        while (anddata & 1) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_ones++;
            total_shift++;
            anddata >>= 1;
        }
    else if (!(xordata & 2))
        while (!(xordata & 2)) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_dups++;
            total_shift++;
            xordata >>= 1;
        }

    if (total_shift) {
        wps->wphdr.flags |= INT32_DATA;

        for (dp = values, count = num_values; count--; dp++)
            *dp >>= total_shift;
    }
}

static int scan_redundancy (int32_t *values, int32_t num_values)
{
    uint32_t ordata = 0, xordata = 0, anddata = ~0;
    int redundant_bits = 0;
    int32_t *dp, count;

    for (dp = values, count = num_values; count--; dp++) {
        xordata |= *dp ^ -(*dp & 1);
        anddata &= *dp;
        ordata |= *dp;

        if ((ordata & 1) && !(anddata & 1) && (xordata & 2))
            return 0;
    }

    if (!ordata || anddata == ~0 || !xordata)
        return 0;

    if (!(ordata & 1))
        while (!(ordata & 1)) {
            redundant_bits++;
            ordata >>= 1;
        }
    else if (anddata & 1)
        while (anddata & 1) {
            redundant_bits = (redundant_bits + 1) | 0x40;
            anddata >>= 1;
        }
    else if (!(xordata & 2))
        while (!(xordata & 2)) {
            redundant_bits = (redundant_bits + 1) | 0x80;
            redundant_bits++;
            xordata >>= 1;
        }

    return redundant_bits;
}

// Scan a buffer of long integer data and determine whether any redundancy in
// the LSBs can be used to reduce the data's magnitude. If yes, then the
// INT32_DATA flag is set and the int32 parameters are set. If bits must still
// be transmitted literally to get down to 24 bits (which is all the integer
// compression code can handle) then we return TRUE to indicate that a wvx
// stream must be created in either lossless mode.

static int scan_int32_data (WavpackStream *wps, int32_t *values, int32_t num_values)
{
    uint32_t magdata = 0, ordata = 0, xordata = 0, anddata = ~0;
    uint32_t crc = 0xffffffff;
    int total_shift = 0;
    int32_t *dp, count;

    wps->int32_sent_bits = wps->int32_zeros = wps->int32_ones = wps->int32_dups = 0;

    for (dp = values, count = num_values; count--; dp++) {
        crc = crc * 9 + (*dp & 0xffff) * 3 + ((*dp >> 16) & 0xffff);
        magdata |= (*dp < 0) ? ~*dp : *dp;
        xordata |= *dp ^ -(*dp & 1);
        anddata &= *dp;
        ordata |= *dp;
    }

    wps->crc_x = crc;
    wps->wphdr.flags &= ~MAG_MASK;

    while (magdata) {
        wps->wphdr.flags += 1 << MAG_LSB;
        magdata >>= 1;
    }

    if (!((wps->wphdr.flags & MAG_MASK) >> MAG_LSB)) {
        wps->wphdr.flags &= ~INT32_DATA;
        return FALSE;
    }

    if (!(ordata & 1))
        while (!(ordata & 1)) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_zeros++;
            total_shift++;
            ordata >>= 1;
        }
    else if (anddata & 1)
        while (anddata & 1) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_ones++;
            total_shift++;
            anddata >>= 1;
        }
    else if (!(xordata & 2))
        while (!(xordata & 2)) {
            wps->wphdr.flags -= 1 << MAG_LSB;
            wps->int32_dups++;
            total_shift++;
            xordata >>= 1;
        }

    if (((wps->wphdr.flags & MAG_MASK) >> MAG_LSB) > 23) {
        wps->int32_sent_bits = (unsigned char)(((wps->wphdr.flags & MAG_MASK) >> MAG_LSB) - 23);
        total_shift += wps->int32_sent_bits;
        wps->wphdr.flags &= ~MAG_MASK;
        wps->wphdr.flags += 23 << MAG_LSB;
    }

    if (total_shift) {
        wps->wphdr.flags |= INT32_DATA;

        for (dp = values, count = num_values; count--; dp++)
            *dp >>= total_shift;
    }

    return wps->int32_sent_bits;
}

// For the specified buffer values and the int32 parameters stored in "wps",
// send the literal bits required to the "wvxbits" bitstream.

static void send_int32_data (WavpackStream *wps, int32_t *values, int32_t num_values)
{
    int sent_bits = wps->int32_sent_bits, pre_shift;
    int32_t mask = (1 << sent_bits) - 1;
    int32_t count, value, *dp;

    pre_shift = wps->int32_zeros + wps->int32_ones + wps->int32_dups;

    if (sent_bits)
        for (dp = values, count = num_values; count--; dp++) {
            value = (*dp >> pre_shift) & mask;
            putbits (value, sent_bits, &wps->wvxbits);
        }
}

void send_general_metadata (WavpackContext *wpc)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    uint32_t flags = wps->wphdr.flags;
    WavpackMetadata wpmd;

    if ((flags & SRATE_MASK) == SRATE_MASK && wpc->config.sample_rate != 44100) {
        write_sample_rate (wpc, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);
    }

    if ((flags & INITIAL_BLOCK) &&
        (wpc->config.num_channels > 2 ||
        wpc->config.channel_mask != 0x5 - wpc->config.num_channels)) {
            write_channel_info (wpc, &wpmd);
            copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
            free_metadata (&wpmd);

            if (wpc->channel_identities) {
                write_channel_identities_info (wpc, &wpmd);
                copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
                free_metadata (&wpmd);
            }
    }

    if ((flags & INITIAL_BLOCK) && !wps->sample_index) {
        write_config_info (wpc, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);
    }

    if (flags & INITIAL_BLOCK) {
        write_new_config_info (wpc, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);
    }
}

// Pack an entire block of samples (either mono or stereo) into a completed
// WavPack block. It is assumed that there is sufficient space for the
// completed block at "wps->blockbuff" and that "wps->blockend" points to the
// end of the available space. A return value of FALSE indicates an error.
// Any unsent metadata is transmitted first, then required metadata for this
// block is sent, and finally the compressed integer data is sent. If a "wpx"
// stream is required for floating point data or large integer data, then this
// must be handled outside this function. To find out how much data was written
// the caller must look at the ckSize field of the written WavpackHeader, NOT
// the one in the WavpackStream.

#ifdef OPT_ASM_X86
    #define DECORR_STEREO_PASS(a,b,c) do {              \
        if (pack_cpu_has_feature_x86 (CPU_FEATURE_MMX)) \
            pack_decorr_stereo_pass_x86 (a, b, c);      \
        else decorr_stereo_pass (a, b, c); } while (0)
    #define DECORR_MONO_BUFFER pack_decorr_mono_buffer_x86
    #define SCAN_MAX_MAGNITUDE(a,b)                     \
        (pack_cpu_has_feature_x86 (CPU_FEATURE_MMX) ?   \
            scan_max_magnitude_x86 (a, b) :             \
            scan_max_magnitude (a, b))
#elif defined(OPT_ASM_X64) && (defined (_WIN64) || defined(__CYGWIN__) || defined(__MINGW64__))
    #define DECORR_STEREO_PASS pack_decorr_stereo_pass_x64win
    #define DECORR_MONO_BUFFER pack_decorr_mono_buffer_x64win
    #define SCAN_MAX_MAGNITUDE scan_max_magnitude_x64win
#elif defined(OPT_ASM_X64)
    #define DECORR_STEREO_PASS pack_decorr_stereo_pass_x64
    #define DECORR_MONO_BUFFER pack_decorr_mono_buffer_x64
    #define SCAN_MAX_MAGNITUDE scan_max_magnitude_x64
#else
    #define DECORR_STEREO_PASS decorr_stereo_pass
    #define DECORR_MONO_BUFFER decorr_mono_buffer
    #define SCAN_MAX_MAGNITUDE scan_max_magnitude
#endif

uint32_t DECORR_MONO_BUFFER (int32_t *buffer, struct decorr_pass *decorr_passes, int32_t num_terms, int32_t sample_count);

#ifdef OPT_ASM_X86
void decorr_stereo_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count);
void pack_decorr_stereo_pass_x86 (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count);
uint32_t scan_max_magnitude (int32_t *values, int32_t num_values);
uint32_t scan_max_magnitude_x86 (int32_t *values, int32_t num_values);
#else
void DECORR_STEREO_PASS (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count);
uint32_t SCAN_MAX_MAGNITUDE (int32_t *values, int32_t num_values);
#endif

// This macro controls the "repack" function where a block of samples will be repacked with
// fewer terms if a single residual exceeds the specified magnitude threshold.

#define REPACK_SAFE_NUM_TERMS 5                 // 5 terms is always okay (and we truncate to this)

static int pack_samples (WavpackContext *wpc, int32_t *buffer)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream], saved_stream;
    uint32_t flags = wps->wphdr.flags, repack_possible, data_count, crc, crc2, i;
    uint32_t sample_count = wps->wphdr.block_samples, repack_mask;
    int32_t *bptr, *saved_buffer = NULL;
    struct decorr_pass *dpp;
    WavpackMetadata wpmd;

    crc = crc2 = 0xffffffff;

    if (!(flags & HYBRID_FLAG) && (flags & MONO_DATA)) {
        int32_t *eptr = buffer + sample_count;

        for (bptr = buffer; bptr < eptr;)
            crc += (crc << 1) + *bptr++;

        if (wps->num_passes)
            execute_mono (wpc, buffer, !wps->num_terms, 1);
    }
    else if (!(flags & HYBRID_FLAG) && !(flags & MONO_DATA)) {
        int32_t *eptr = buffer + (sample_count * 2);

        for (bptr = buffer; bptr < eptr; bptr += 2)
            crc += (crc << 3) + (bptr [0] << 1) + bptr [0] + bptr [1];

        if (wps->num_passes) {
            execute_stereo (wpc, buffer, !wps->num_terms, 1);
            flags = wps->wphdr.flags;
        }
    }
    else if ((flags & HYBRID_FLAG) && (flags & MONO_DATA)) {
        if (wps->num_passes)
            execute_mono (wpc, buffer, !wps->num_terms, 0);
    }
    else if ((flags & HYBRID_FLAG) && !(flags & MONO_DATA)) {
        if (wps->num_passes) {
            execute_stereo (wpc, buffer, !wps->num_terms, 0);
            flags = wps->wphdr.flags;
        }
    }

    wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
    memcpy (wps->blockbuff, &wps->wphdr, sizeof (WavpackHeader));

    if (wpc->metacount) {
        WavpackMetadata *wpmdp = wpc->metadata;

        while (wpc->metacount) {
            copy_metadata (wpmdp, wps->blockbuff, wps->blockend);
            wpc->metabytes -= wpmdp->byte_length;
            free_metadata (wpmdp++);
            wpc->metacount--;
        }

        free (wpc->metadata);
        wpc->metadata = NULL;
    }

    if (!sample_count)
        return TRUE;

    memcpy (&wps->wphdr, wps->blockbuff, sizeof (WavpackHeader));
    repack_possible = !wps->num_passes && wps->num_terms > REPACK_SAFE_NUM_TERMS;
    repack_mask = (flags & MAG_MASK) >> MAG_LSB >= 16 ? 0xF0000000 : 0xFFF00000;
    saved_stream = *wps;

    if (repack_possible && !(flags & HYBRID_FLAG)) {
        saved_buffer = malloc (sample_count * sizeof (int32_t) * (flags & MONO_DATA ? 1 : 2));
        memcpy (saved_buffer, buffer, sample_count * sizeof (int32_t) * (flags & MONO_DATA ? 1 : 2));
    }

    // This code is written as a loop, but in the overwhelming majority of cases it executes only once.
    // If one of the higher modes is being used and a residual exceeds a certain threshold, then the
    // block will be repacked using fewer decorrelation terms. Note that this has only been triggered
    // by pathological audio samples designed to trigger it...in practice this might never happen. Note
    // that this only applies to the "high" and "very high" modes and only when packing directly
    // (i.e. without the "extra" modes that will have already checked magnitude).

    do {
        short *shaping_array = wps->dc.shaping_array;
        int tcount, lossy = FALSE, m = 0;
        double noise_acc = 0.0, noise;
        uint32_t max_magnitude = 0;

        write_decorr_terms (wps, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);

        write_decorr_weights (wps, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);

        write_decorr_samples (wps, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);

        write_entropy_vars (wps, &wpmd);
        copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
        free_metadata (&wpmd);

        if (flags & HYBRID_FLAG) {
            write_hybrid_profile (wps, &wpmd);
            copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
            free_metadata (&wpmd);
        }

        if (flags & FLOAT_DATA) {
            write_float_info (wps, &wpmd);
            copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
            free_metadata (&wpmd);
        }

        if (flags & INT32_DATA) {
            write_int32_info (wps, &wpmd);
            copy_metadata (&wpmd, wps->blockbuff, wps->blockend);
            free_metadata (&wpmd);
        }

        send_general_metadata (wpc);
        bs_open_write (&wps->wvbits, wps->blockbuff + ((WavpackHeader *) wps->blockbuff)->ckSize + 12, wps->blockend);

        if (wpc->wvc_flag) {
            wps->wphdr.ckSize = sizeof (WavpackHeader) - 8;
            memcpy (wps->block2buff, &wps->wphdr, sizeof (WavpackHeader));

            if (flags & HYBRID_SHAPE) {
                write_shaping_info (wps, &wpmd);
                copy_metadata (&wpmd, wps->block2buff, wps->block2end);
                free_metadata (&wpmd);
            }

            bs_open_write (&wps->wvcbits, wps->block2buff + ((WavpackHeader *) wps->block2buff)->ckSize + 12, wps->block2end);
        }

        /////////////////////// handle lossless mono mode /////////////////////////

        if (!(flags & HYBRID_FLAG) && (flags & MONO_DATA)) {
            if (!wps->num_passes) {
                max_magnitude = DECORR_MONO_BUFFER (buffer, wps->decorr_passes, wps->num_terms, sample_count);
                m = sample_count & (MAX_TERM - 1);
            }

            send_words_lossless (wps, buffer, sample_count);
        }

        //////////////////// handle the lossless stereo mode //////////////////////

        else if (!(flags & HYBRID_FLAG) && !(flags & MONO_DATA)) {
            if (!wps->num_passes) {
                if (flags & JOINT_STEREO) {
                    int32_t *eptr = buffer + (sample_count * 2);

                    for (bptr = buffer; bptr < eptr; bptr += 2)
                        bptr [1] += ((bptr [0] -= bptr [1]) >> 1);
                }

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount-- ; dpp++)
                    DECORR_STEREO_PASS (dpp, buffer, sample_count);

                m = sample_count & (MAX_TERM - 1);

                if (repack_possible)
                    max_magnitude = SCAN_MAX_MAGNITUDE (buffer, sample_count * 2);
            }

            send_words_lossless (wps, buffer, sample_count);
        }

        /////////////////// handle the lossy/hybrid mono mode /////////////////////

        else if ((flags & HYBRID_FLAG) && (flags & MONO_DATA))
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t code, temp;
                int shaping_weight;

                crc2 += (crc2 << 1) + (code = *bptr++);

                if (flags & HYBRID_SHAPE) {
                    if (shaping_array)
                        shaping_weight = *shaping_array++;
                    else
                        shaping_weight = (wps->dc.shaping_acc [0] += wps->dc.shaping_delta [0]) >> 16;

                    temp = -apply_weight (shaping_weight, wps->dc.error [0]);

                    if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                        if (temp == wps->dc.error [0])
                            temp = (temp < 0) ? temp + 1 : temp - 1;

                        wps->dc.error [0] = -code;
                        code += temp;
                    }
                    else
                        wps->dc.error [0] = -(code += temp);
                }

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount-- ; dpp++)
                    if (dpp->term > MAX_TERM) {
                        if (dpp->term & 1)
                            dpp->samples_A [2] = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                        else
                            dpp->samples_A [2] = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

                        code -= (dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [2]));
                    }
                    else
                        code -= (dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [m]));

                max_magnitude |= (code < 0 ? ~code : code);
                code = send_word (wps, code, 0);

                while (--dpp >= wps->decorr_passes) {
                    if (dpp->term > MAX_TERM) {
                        update_weight (dpp->weight_A, dpp->delta, dpp->samples_A [2], code);
                        dpp->samples_A [1] = dpp->samples_A [0];
                        dpp->samples_A [0] = (code += dpp->aweight_A);
                    }
                    else {
                        int32_t sam = dpp->samples_A [m];

                        update_weight (dpp->weight_A, dpp->delta, sam, code);
                        dpp->samples_A [(m + dpp->term) & (MAX_TERM - 1)] = (code += dpp->aweight_A);
                    }
                }

                wps->dc.error [0] += code;
                m = (m + 1) & (MAX_TERM - 1);

                if ((crc += (crc << 1) + code) != crc2)
                    lossy = TRUE;

                if (wpc->config.flags & CONFIG_CALC_NOISE) {
                    noise = code - bptr [-1];

                    noise_acc += noise *= noise;
                    wps->dc.noise_ave = (wps->dc.noise_ave * 0.99) + (noise * 0.01);

                    if (wps->dc.noise_ave > wps->dc.noise_max)
                        wps->dc.noise_max = wps->dc.noise_ave;
                }
            }

        /////////////////// handle the lossy/hybrid stereo mode ///////////////////

        else if ((flags & HYBRID_FLAG) && !(flags & MONO_DATA))
            for (bptr = buffer, i = 0; i < sample_count; ++i) {
                int32_t left, right, temp;
                int shaping_weight;

                left = *bptr++;
                crc2 += (crc2 << 3) + (left << 1) + left + (right = *bptr++);

                if (flags & HYBRID_SHAPE) {
                    if (shaping_array)
                        shaping_weight = *shaping_array++;
                    else
                        shaping_weight = (wps->dc.shaping_acc [0] += wps->dc.shaping_delta [0]) >> 16;

                    temp = -apply_weight (shaping_weight, wps->dc.error [0]);

                    if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                        if (temp == wps->dc.error [0])
                            temp = (temp < 0) ? temp + 1 : temp - 1;

                        wps->dc.error [0] = -left;
                        left += temp;
                    }
                    else
                        wps->dc.error [0] = -(left += temp);

                    if (!shaping_array)
                        shaping_weight = (wps->dc.shaping_acc [1] += wps->dc.shaping_delta [1]) >> 16;

                    temp = -apply_weight (shaping_weight, wps->dc.error [1]);

                    if ((flags & NEW_SHAPING) && shaping_weight < 0 && temp) {
                        if (temp == wps->dc.error [1])
                            temp = (temp < 0) ? temp + 1 : temp - 1;

                        wps->dc.error [1] = -right;
                        right += temp;
                    }
                    else
                        wps->dc.error [1] = -(right += temp);
                }

                if (flags & JOINT_STEREO)
                    right += ((left -= right) >> 1);

                for (tcount = wps->num_terms, dpp = wps->decorr_passes; tcount-- ; dpp++)
                    if (dpp->term > MAX_TERM) {
                        if (dpp->term & 1) {
                            dpp->samples_A [2] = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                            dpp->samples_B [2] = 2 * dpp->samples_B [0] - dpp->samples_B [1];
                        }
                        else {
                            dpp->samples_A [2] = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;
                            dpp->samples_B [2] = (3 * dpp->samples_B [0] - dpp->samples_B [1]) >> 1;
                        }

                        left -= (dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [2]));
                        right -= (dpp->aweight_B = apply_weight (dpp->weight_B, dpp->samples_B [2]));
                    }
                    else if (dpp->term > 0) {
                        left -= (dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [m]));
                        right -= (dpp->aweight_B = apply_weight (dpp->weight_B, dpp->samples_B [m]));
                    }
                    else {
                        if (dpp->term == -1)
                            dpp->samples_B [0] = left;
                        else if (dpp->term == -2)
                            dpp->samples_A [0] = right;

                        left -= (dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [0]));
                        right -= (dpp->aweight_B = apply_weight (dpp->weight_B, dpp->samples_B [0]));
                    }

                max_magnitude |= (left < 0 ? ~left : left) | (right < 0 ? ~right : right);
                left = send_word (wps, left, 0);
                right = send_word (wps, right, 1);

                while (--dpp >= wps->decorr_passes)
                    if (dpp->term > MAX_TERM) {
                        update_weight (dpp->weight_A, dpp->delta, dpp->samples_A [2], left);
                        update_weight (dpp->weight_B, dpp->delta, dpp->samples_B [2], right);

                        dpp->samples_A [1] = dpp->samples_A [0];
                        dpp->samples_B [1] = dpp->samples_B [0];

                        dpp->samples_A [0] = (left += dpp->aweight_A);
                        dpp->samples_B [0] = (right += dpp->aweight_B);
                    }
                    else if (dpp->term > 0) {
                        int k = (m + dpp->term) & (MAX_TERM - 1);

                        update_weight (dpp->weight_A, dpp->delta, dpp->samples_A [m], left);
                        dpp->samples_A [k] = (left += dpp->aweight_A);

                        update_weight (dpp->weight_B, dpp->delta, dpp->samples_B [m], right);
                        dpp->samples_B [k] = (right += dpp->aweight_B);
                    }
                    else {
                        if (dpp->term == -1) {
                            dpp->samples_B [0] = left + dpp->aweight_A;
                            dpp->aweight_B = apply_weight (dpp->weight_B, dpp->samples_B [0]);
                        }
                        else if (dpp->term == -2) {
                            dpp->samples_A [0] = right + dpp->aweight_B;
                            dpp->aweight_A = apply_weight (dpp->weight_A, dpp->samples_A [0]);
                        }

                        update_weight_clip (dpp->weight_A, dpp->delta, dpp->samples_A [0], left);
                        update_weight_clip (dpp->weight_B, dpp->delta, dpp->samples_B [0], right);
                        dpp->samples_B [0] = (left += dpp->aweight_A);
                        dpp->samples_A [0] = (right += dpp->aweight_B);
                    }

                if (flags & JOINT_STEREO)
                    left += (right -= (left >> 1));

                wps->dc.error [0] += left;
                wps->dc.error [1] += right;
                m = (m + 1) & (MAX_TERM - 1);

                if ((crc += (crc << 3) + (left << 1) + left + right) != crc2)
                    lossy = TRUE;

                if (wpc->config.flags & CONFIG_CALC_NOISE) {
                    noise = (double)(left - bptr [-2]) * (left - bptr [-2]);
                    noise += (double)(right - bptr [-1]) * (right - bptr [-1]);

                    noise_acc += noise /= 2.0;
                    wps->dc.noise_ave = (wps->dc.noise_ave * 0.99) + (noise * 0.01);

                    if (wps->dc.noise_ave > wps->dc.noise_max)
                        wps->dc.noise_max = wps->dc.noise_ave;
                }
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

        if (wpc->config.flags & CONFIG_CALC_NOISE)
            wps->dc.noise_sum += noise_acc;

        flush_word (wps);
        data_count = bs_close_write (&wps->wvbits);

        if (data_count) {
            if (data_count != (uint32_t) -1) {
                unsigned char *cptr = wps->blockbuff + ((WavpackHeader *) wps->blockbuff)->ckSize + 8;

                *cptr++ = ID_WV_BITSTREAM | ID_LARGE;
                *cptr++ = data_count >> 1;
                *cptr++ = data_count >> 9;
                *cptr++ = data_count >> 17;
                ((WavpackHeader *) wps->blockbuff)->ckSize += data_count + 4;
            }
            else
                return FALSE;
        }

        ((WavpackHeader *) wps->blockbuff)->crc = crc;

        if (wpc->wvc_flag) {
            data_count = bs_close_write (&wps->wvcbits);

            if (data_count && lossy) {
                if (data_count != (uint32_t) -1) {
                    unsigned char *cptr = wps->block2buff + ((WavpackHeader *) wps->block2buff)->ckSize + 8;

                    *cptr++ = ID_WVC_BITSTREAM | ID_LARGE;
                    *cptr++ = data_count >> 1;
                    *cptr++ = data_count >> 9;
                    *cptr++ = data_count >> 17;
                    ((WavpackHeader *) wps->block2buff)->ckSize += data_count + 4;
                }
                else
                    return FALSE;
            }

            ((WavpackHeader *) wps->block2buff)->crc = crc2;
        }
        else if (lossy)
            wpc->lossy_blocks = TRUE;

        // we're done with the entire block, so now we check if our threshold for a "repack" was hit

        if (repack_possible && wps->num_terms > REPACK_SAFE_NUM_TERMS && (max_magnitude & repack_mask)) {
            *wps = saved_stream;
            wps->num_terms = REPACK_SAFE_NUM_TERMS;
            memcpy (wps->blockbuff, &wps->wphdr, sizeof (WavpackHeader));

            if (saved_buffer)
                memcpy (buffer, saved_buffer, sample_count * sizeof (int32_t) * (flags & MONO_DATA ? 1 : 2));

            if (flags & HYBRID_FLAG)
                crc = crc2 = 0xffffffff;
        }
        else {
            // if we actually did repack the block with fewer terms, we detect that here
            // and clean up so that we return to the original term count...otherwise we just
            // free the saved_buffer (if allocated) and break out of the loop
            if (wps->num_terms != saved_stream.num_terms) {
                int ti;

                for (ti = wps->num_terms; ti < saved_stream.num_terms; ++ti) {
                    wps->decorr_passes [ti].weight_A = wps->decorr_passes [ti].weight_B = 0;
                    CLEAR (wps->decorr_passes [ti].samples_A);
                    CLEAR (wps->decorr_passes [ti].samples_B);
                }

                wps->num_terms = saved_stream.num_terms;
            }

            if (saved_buffer)
                free (saved_buffer);

            break;
        }

    } while (1);

    wps->sample_index += sample_count;
    return TRUE;
}

#if !defined(OPT_ASM_X64)

// This is the "C" version of the stereo decorrelation pass function. There
// are assembly optimized versions of this that can be used if available.
// It performs a single pass of stereo decorrelation, in place, as specified
// by the decorr_pass structure. Note that this function does NOT return the
// dpp->samples_X[] values in the "normalized" positions for terms 1-8, so if
// the number of samples is not a multiple of MAX_TERM, these must be moved if
// they are to be used somewhere else.

void decorr_stereo_pass (struct decorr_pass *dpp, int32_t *buffer, int32_t sample_count)
{
    int32_t *bptr, *eptr = buffer + (sample_count * 2);
    int m, k;

    switch (dpp->term) {
        case 17:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam, tmp;

                sam = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                dpp->samples_A [1] = dpp->samples_A [0];
                bptr [0] = tmp = (dpp->samples_A [0] = bptr [0]) - apply_weight (dpp->weight_A, sam);
                update_weight (dpp->weight_A, dpp->delta, sam, tmp);

                sam = 2 * dpp->samples_B [0] - dpp->samples_B [1];
                dpp->samples_B [1] = dpp->samples_B [0];
                bptr [1] = tmp = (dpp->samples_B [0] = bptr [1]) - apply_weight (dpp->weight_B, sam);
                update_weight (dpp->weight_B, dpp->delta, sam, tmp);
            }

            break;

        case 18:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam, tmp;

                sam = dpp->samples_A [0] + ((dpp->samples_A [0] - dpp->samples_A [1]) >> 1);
                dpp->samples_A [1] = dpp->samples_A [0];
                bptr [0] = tmp = (dpp->samples_A [0] = bptr [0]) - apply_weight (dpp->weight_A, sam);
                update_weight (dpp->weight_A, dpp->delta, sam, tmp);

                sam = dpp->samples_B [0] + ((dpp->samples_B [0] - dpp->samples_B [1]) >> 1);
                dpp->samples_B [1] = dpp->samples_B [0];
                bptr [1] = tmp = (dpp->samples_B [0] = bptr [1]) - apply_weight (dpp->weight_B, sam);
                update_weight (dpp->weight_B, dpp->delta, sam, tmp);
            }

            break;

        default:
            for (m = 0, k = dpp->term & (MAX_TERM - 1), bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam, tmp;

                sam = dpp->samples_A [m];
                bptr [0] = tmp = (dpp->samples_A [k] = bptr [0]) - apply_weight (dpp->weight_A, sam);
                update_weight (dpp->weight_A, dpp->delta, sam, tmp);

                sam = dpp->samples_B [m];
                bptr [1] = tmp = (dpp->samples_B [k] = bptr [1]) - apply_weight (dpp->weight_B, sam);
                update_weight (dpp->weight_B, dpp->delta, sam, tmp);

                m = (m + 1) & (MAX_TERM - 1);
                k = (k + 1) & (MAX_TERM - 1);
            }

            break;

        case -1:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam_A, sam_B, tmp;

                sam_A = dpp->samples_A [0];
                bptr [0] = tmp = (sam_B = bptr [0]) - apply_weight (dpp->weight_A, sam_A);
                update_weight_clip (dpp->weight_A, dpp->delta, sam_A, tmp);

                bptr [1] = tmp = (dpp->samples_A [0] = bptr [1]) - apply_weight (dpp->weight_B, sam_B);
                update_weight_clip (dpp->weight_B, dpp->delta, sam_B, tmp);
            }

            break;

        case -2:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam_A, sam_B, tmp;

                sam_B = dpp->samples_B [0];
                bptr [1] = tmp = (sam_A = bptr [1]) - apply_weight (dpp->weight_B, sam_B);
                update_weight_clip (dpp->weight_B, dpp->delta, sam_B, tmp);

                bptr [0] = tmp = (dpp->samples_B [0] = bptr [0]) - apply_weight (dpp->weight_A, sam_A);
                update_weight_clip (dpp->weight_A, dpp->delta, sam_A, tmp);
            }

            break;

        case -3:
            for (bptr = buffer; bptr < eptr; bptr += 2) {
                int32_t sam_A, sam_B, tmp;

                sam_A = dpp->samples_A [0];
                sam_B = dpp->samples_B [0];

                dpp->samples_A [0] = tmp = bptr [1];
                bptr [1] = tmp -= apply_weight (dpp->weight_B, sam_B);
                update_weight_clip (dpp->weight_B, dpp->delta, sam_B, tmp);

                dpp->samples_B [0] = tmp = bptr [0];
                bptr [0] = tmp -= apply_weight (dpp->weight_A, sam_A);
                update_weight_clip (dpp->weight_A, dpp->delta, sam_A, tmp);
            }

            break;
    }
}

// This is the "C" version of the magnitude scanning function. There are
// assembly optimized versions of this that can be used if available. This
// function scans a buffer of signed 32-bit ints and returns the magnitude
// of the largest sample, with a power-of-two resolution. It might be more
// useful to return the actual maximum absolute value (and this function
// could do that without breaking anything), but that implementation would
// likely be slower. Instead, this simply returns the "or" of all the
// values "xor"d with their own sign.

uint32_t scan_max_magnitude (int32_t *values, int32_t num_values)
{
    uint32_t magnitude = 0;

    while (num_values--)
        magnitude |= (*values < 0) ? ~*values++ : *values++;

    return magnitude;
}

#endif

#if !defined(OPT_ASM_X86) && !defined(OPT_ASM_X64)

// This is the "C" version of the mono decorrelation pass function. There
// are assembly optimized versions of this that are be used if available.
// It decorrelates a buffer of mono samples, in place, as specified by the array
// of decorr_pass structures. Note that this function does NOT return the
// dpp->samples_X[] values in the "normalized" positions for terms 1-8, so if
// the number of samples is not a multiple of MAX_TERM, these must be moved if
// they are to be used somewhere else. The magnitude of the output samples is
// accumulated and returned (see scan_max_magnitude() for more details).

uint32_t decorr_mono_buffer (int32_t *buffer, struct decorr_pass *decorr_passes, int32_t num_terms, int32_t sample_count)
{
    uint32_t max_magnitude = 0;
    struct decorr_pass *dpp;
    int tcount, i;

    for (i = 0; i < sample_count; ++i) {
        int32_t code = *buffer;

        for (tcount = num_terms, dpp = decorr_passes; tcount--; dpp++) {
            int32_t sam;

            if (dpp->term > MAX_TERM) {
                if (dpp->term & 1)
                    sam = 2 * dpp->samples_A [0] - dpp->samples_A [1];
                else
                    sam = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

                dpp->samples_A [1] = dpp->samples_A [0];
                dpp->samples_A [0] = code;
            }
            else {
                sam = dpp->samples_A [i & (MAX_TERM - 1)];
                dpp->samples_A [(i + dpp->term) & (MAX_TERM - 1)] = code;
            }

            code -= apply_weight (dpp->weight_A, sam);
            update_weight (dpp->weight_A, dpp->delta, sam, code);
        }

        *buffer++ = code;
        max_magnitude |= (code < 0) ? ~code : code;
    }

    return max_magnitude;
}

#endif

//////////////////////////////////////////////////////////////////////////////
// This function returns the accumulated RMS noise as a double if the       //
// CALC_NOISE bit was set in the WavPack header. The peak noise can also be //
// returned if desired. See wavpack.c for the calculations required to      //
// convert this into decibels of noise below full scale.                    //
//////////////////////////////////////////////////////////////////////////////

double WavpackGetEncodedNoise (WavpackContext *wpc, double *peak)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];

    if (peak)
        *peak = wps->dc.noise_max;

    return wps->dc.noise_sum;
}

// Open the specified BitStream using the specified buffer pointers. It is
// assumed that enough buffer space has been allocated for all data that will
// be written, otherwise an error will be generated.

static void bs_write (Bitstream *bs);

static void bs_open_write (Bitstream *bs, void *buffer_start, void *buffer_end)
{
    bs->error = bs->sr = bs->bc = 0;
    bs->ptr = bs->buf = buffer_start;
    bs->end = buffer_end;
    bs->wrap = bs_write;
}

// This function is only called from the putbit() and putbits() macros when
// the buffer is full, which is now flagged as an error.

static void bs_write (Bitstream *bs)
{
    bs->ptr = bs->buf;
    bs->error = 1;
}

// This function forces a flushing write of the specified BitStream, and
// returns the total number of bytes written into the buffer.

static uint32_t bs_close_write (Bitstream *bs)
{
    uint32_t bytes_written;

    if (bs->error)
        return (uint32_t) -1;

    while (1) {
        while (bs->bc)
            putbit_1 (bs);

        bytes_written = (uint32_t)(bs->ptr - bs->buf) * sizeof (*(bs->ptr));

        if (bytes_written & 1) {
            putbit_1 (bs);
        }
        else
            break;
    };

    CLEAR (*bs);
    return bytes_written;
}

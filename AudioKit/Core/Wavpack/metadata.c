////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2006 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// metadata.c

// This module handles the metadata structure introduced in WavPack 4.0

#include "wavpack.h"

int read_metadata_buff (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    uchar tchar;

    if (!wpc->infile (&wpmd->id, 1) || !wpc->infile (&tchar, 1))
        return FALSE;

    wpmd->byte_length = tchar << 1;

    if (wpmd->id & ID_LARGE) {
        wpmd->id &= ~ID_LARGE;

        if (!wpc->infile (&tchar, 1))
            return FALSE;

        wpmd->byte_length += (int32_t) tchar << 9; 

        if (!wpc->infile (&tchar, 1))
            return FALSE;

        wpmd->byte_length += (int32_t) tchar << 17;
    }

    if (wpmd->id & ID_ODD_SIZE) {
        wpmd->id &= ~ID_ODD_SIZE;
        wpmd->byte_length--;
    }

    if (wpmd->byte_length && wpmd->byte_length <= sizeof (wpc->read_buffer)) {
        uint32_t bytes_to_read = wpmd->byte_length + (wpmd->byte_length & 1);

        if (wpc->infile (wpc->read_buffer, bytes_to_read) != (int32_t) bytes_to_read) {
            wpmd->data = NULL;
            return FALSE;
        }

        wpmd->data = wpc->read_buffer;
    }
    else
        wpmd->data = NULL;

    return TRUE;
}

int process_metadata (WavpackContext *wpc, WavpackMetadata *wpmd)
{
    WavpackStream *wps = &wpc->stream;

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

        case ID_FLOAT_INFO:
            return read_float_info (wps, wpmd);

        case ID_INT32_INFO:
            return read_int32_info (wps, wpmd);

        case ID_CHANNEL_INFO:
            return read_channel_info (wpc, wpmd);

        case ID_CONFIG_BLOCK:
            return read_config_info (wpc, wpmd);

        case ID_WV_BITSTREAM:
            return init_wv_bitstream (wpc, wpmd);

        case ID_SHAPING_WEIGHTS:
        case ID_WVC_BITSTREAM:
        case ID_WVX_BITSTREAM:
            return TRUE;

        default:
            if (wpmd->byte_length && !wpmd->data) {
                uint32_t bytes_to_skip = wpmd->byte_length + (wpmd->byte_length & 1);

                while (bytes_to_skip--)
                    if (wpc->infile (wpc->read_buffer, 1) != 1)
                        return FALSE;
            }

            return (wpmd->id & ID_OPTIONAL_DATA) ? TRUE : FALSE;
    }
}

////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2006 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// float.c

#include "wavpack.h"

int read_float_info (WavpackStream *wps, WavpackMetadata *wpmd)
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

void float_values (WavpackStream *wps, int32_t *values, int32_t num_values)
{
    int shift = wps->float_max_exp - wps->float_norm_exp + wps->float_shift;

    if (shift > 32)
        shift = 32;
    else if (shift < -32)
        shift = -32;

    while (num_values--) {
        if (shift > 0)
            *values <<= shift;
        else if (shift < 0)
            *values >>= -shift;

        if (*values > 8388607L)
            *values = 8388607L;
        else if (*values < -8388608L)
            *values = -8388608L;

        values++;
    }
}

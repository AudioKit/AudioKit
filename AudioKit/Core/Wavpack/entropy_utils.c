////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// entropy_utils.c

// This module contains the functions that process metadata blocks that are
// specific to the entropy decoder; these would be called any time a WavPack
// block was parsed. Additionally, it contains tables and functions that are
// common to both entropy coding and decoding. These are in a module separate
// from the actual entropy encoder (write_words.c) and decoder (read_words.c)
// so that if applications that just do a subset of the full WavPack reading
// and writing can link with a subset of the library.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

///////////////////////////// local table storage ////////////////////////////

const uint32_t bitset [] = {
    1L << 0, 1L << 1, 1L << 2, 1L << 3,
    1L << 4, 1L << 5, 1L << 6, 1L << 7,
    1L << 8, 1L << 9, 1L << 10, 1L << 11,
    1L << 12, 1L << 13, 1L << 14, 1L << 15,
    1L << 16, 1L << 17, 1L << 18, 1L << 19,
    1L << 20, 1L << 21, 1L << 22, 1L << 23,
    1L << 24, 1L << 25, 1L << 26, 1L << 27,
    1L << 28, 1L << 29, 1L << 30, 1L << 31
};

const uint32_t bitmask [] = {
    (1L << 0) - 1, (1L << 1) - 1, (1L << 2) - 1, (1L << 3) - 1,
    (1L << 4) - 1, (1L << 5) - 1, (1L << 6) - 1, (1L << 7) - 1,
    (1L << 8) - 1, (1L << 9) - 1, (1L << 10) - 1, (1L << 11) - 1,
    (1L << 12) - 1, (1L << 13) - 1, (1L << 14) - 1, (1L << 15) - 1,
    (1L << 16) - 1, (1L << 17) - 1, (1L << 18) - 1, (1L << 19) - 1,
    (1L << 20) - 1, (1L << 21) - 1, (1L << 22) - 1, (1L << 23) - 1,
    (1L << 24) - 1, (1L << 25) - 1, (1L << 26) - 1, (1L << 27) - 1,
    (1L << 28) - 1, (1L << 29) - 1, (1L << 30) - 1, 0x7fffffff
};

const char nbits_table [] = {
    0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,     // 0 - 15
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,     // 16 - 31
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,     // 32 - 47
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,     // 48 - 63
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,     // 64 - 79
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,     // 80 - 95
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,     // 96 - 111
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,     // 112 - 127
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 128 - 143
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 144 - 159
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 160 - 175
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 176 - 191
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 192 - 207
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 208 - 223
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,     // 224 - 239
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8      // 240 - 255
};

static const unsigned char log2_table [] = {
    0x00, 0x01, 0x03, 0x04, 0x06, 0x07, 0x09, 0x0a, 0x0b, 0x0d, 0x0e, 0x10, 0x11, 0x12, 0x14, 0x15,
    0x16, 0x18, 0x19, 0x1a, 0x1c, 0x1d, 0x1e, 0x20, 0x21, 0x22, 0x24, 0x25, 0x26, 0x28, 0x29, 0x2a,
    0x2c, 0x2d, 0x2e, 0x2f, 0x31, 0x32, 0x33, 0x34, 0x36, 0x37, 0x38, 0x39, 0x3b, 0x3c, 0x3d, 0x3e,
    0x3f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4d, 0x4e, 0x4f, 0x50, 0x51,
    0x52, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63,
    0x64, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x74, 0x75,
    0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85,
    0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95,
    0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4,
    0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1, 0xb2, 0xb2,
    0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, 0xc0, 0xc0,
    0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcb, 0xcc, 0xcd, 0xce,
    0xcf, 0xd0, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd8, 0xd9, 0xda, 0xdb,
    0xdc, 0xdc, 0xdd, 0xde, 0xdf, 0xe0, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe4, 0xe5, 0xe6, 0xe7, 0xe7,
    0xe8, 0xe9, 0xea, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xee, 0xef, 0xf0, 0xf1, 0xf1, 0xf2, 0xf3, 0xf4,
    0xf4, 0xf5, 0xf6, 0xf7, 0xf7, 0xf8, 0xf9, 0xf9, 0xfa, 0xfb, 0xfc, 0xfc, 0xfd, 0xfe, 0xff, 0xff
};

static const unsigned char exp2_table [] = {
    0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05, 0x06, 0x06, 0x07, 0x08, 0x08, 0x09, 0x0a, 0x0b,
    0x0b, 0x0c, 0x0d, 0x0e, 0x0e, 0x0f, 0x10, 0x10, 0x11, 0x12, 0x13, 0x13, 0x14, 0x15, 0x16, 0x16,
    0x17, 0x18, 0x19, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1d, 0x1e, 0x1f, 0x20, 0x20, 0x21, 0x22, 0x23,
    0x24, 0x24, 0x25, 0x26, 0x27, 0x28, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2c, 0x2d, 0x2e, 0x2f, 0x30,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3a, 0x3b, 0x3c, 0x3d,
    0x3e, 0x3f, 0x40, 0x41, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x48, 0x49, 0x4a, 0x4b,
    0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a,
    0x5b, 0x5c, 0x5d, 0x5e, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
    0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
    0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87, 0x88, 0x89, 0x8a,
    0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b,
    0x9c, 0x9d, 0x9f, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad,
    0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbc, 0xbd, 0xbe, 0xbf, 0xc0,
    0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc8, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf, 0xd0, 0xd2, 0xd3, 0xd4,
    0xd6, 0xd7, 0xd8, 0xd9, 0xdb, 0xdc, 0xdd, 0xde, 0xe0, 0xe1, 0xe2, 0xe4, 0xe5, 0xe6, 0xe8, 0xe9,
    0xea, 0xec, 0xed, 0xee, 0xf0, 0xf1, 0xf2, 0xf4, 0xf5, 0xf6, 0xf8, 0xf9, 0xfa, 0xfc, 0xfd, 0xff
};

///////////////////////////// executable code ////////////////////////////////

// Read the median log2 values from the specifed metadata structure, convert
// them back to 32-bit unsigned values and store them. If length is not
// exactly correct then we flag and return an error.

int read_entropy_vars (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char *byteptr = wpmd->data;

    if (wpmd->byte_length != ((wps->wphdr.flags & MONO_DATA) ? 6 : 12))
        return FALSE;

    wps->w.c [0].median [0] = wp_exp2s (byteptr [0] + (byteptr [1] << 8));
    wps->w.c [0].median [1] = wp_exp2s (byteptr [2] + (byteptr [3] << 8));
    wps->w.c [0].median [2] = wp_exp2s (byteptr [4] + (byteptr [5] << 8));

    if (!(wps->wphdr.flags & MONO_DATA)) {
        wps->w.c [1].median [0] = wp_exp2s (byteptr [6] + (byteptr [7] << 8));
        wps->w.c [1].median [1] = wp_exp2s (byteptr [8] + (byteptr [9] << 8));
        wps->w.c [1].median [2] = wp_exp2s (byteptr [10] + (byteptr [11] << 8));
    }

    return TRUE;
}

// Read the hybrid related values from the specifed metadata structure, convert
// them back to their internal formats and store them. The extended profile
// stuff is not implemented yet, so return an error if we get more data than
// we know what to do with.

int read_hybrid_profile (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char *byteptr = wpmd->data;
    unsigned char *endptr = byteptr + wpmd->byte_length;

    if (wps->wphdr.flags & HYBRID_BITRATE) {
        if (byteptr + (wps->wphdr.flags & MONO_DATA ? 2 : 4) > endptr)
            return FALSE;

        wps->w.c [0].slow_level = wp_exp2s (byteptr [0] + (byteptr [1] << 8));
        byteptr += 2;

        if (!(wps->wphdr.flags & MONO_DATA)) {
            wps->w.c [1].slow_level = wp_exp2s (byteptr [0] + (byteptr [1] << 8));
            byteptr += 2;
        }
    }

    if (byteptr + (wps->wphdr.flags & MONO_DATA ? 2 : 4) > endptr)
        return FALSE;

    wps->w.bitrate_acc [0] = (int32_t)(byteptr [0] + (byteptr [1] << 8)) << 16;
    byteptr += 2;

    if (!(wps->wphdr.flags & MONO_DATA)) {
        wps->w.bitrate_acc [1] = (int32_t)(byteptr [0] + (byteptr [1] << 8)) << 16;
        byteptr += 2;
    }

    if (byteptr < endptr) {
        if (byteptr + (wps->wphdr.flags & MONO_DATA ? 2 : 4) > endptr)
            return FALSE;

        wps->w.bitrate_delta [0] = wp_exp2s ((int16_t)(byteptr [0] + (byteptr [1] << 8)));
        byteptr += 2;

        if (!(wps->wphdr.flags & MONO_DATA)) {
            wps->w.bitrate_delta [1] = wp_exp2s ((int16_t)(byteptr [0] + (byteptr [1] << 8)));
            byteptr += 2;
        }

        if (byteptr < endptr)
            return FALSE;
    }
    else
        wps->w.bitrate_delta [0] = wps->w.bitrate_delta [1] = 0;

    return TRUE;
}

// This function is called during both encoding and decoding of hybrid data to
// update the "error_limit" variable which determines the maximum sample error
// allowed in the main bitstream. In the HYBRID_BITRATE mode (which is the only
// currently implemented) this is calculated from the slow_level values and the
// bitrate accumulators. Note that the bitrate accumulators can be changing.

void update_error_limit (WavpackStream *wps)
{
    int bitrate_0 = (wps->w.bitrate_acc [0] += wps->w.bitrate_delta [0]) >> 16;

    if (wps->wphdr.flags & MONO_DATA) {
        if (wps->wphdr.flags & HYBRID_BITRATE) {
            int slow_log_0 = (wps->w.c [0].slow_level + SLO) >> SLS;

            if (slow_log_0 - bitrate_0 > -0x100)
                wps->w.c [0].error_limit = wp_exp2s (slow_log_0 - bitrate_0 + 0x100);
            else
                wps->w.c [0].error_limit = 0;
        }
        else
            wps->w.c [0].error_limit = wp_exp2s (bitrate_0);
    }
    else {
        int bitrate_1 = (wps->w.bitrate_acc [1] += wps->w.bitrate_delta [1]) >> 16;

        if (wps->wphdr.flags & HYBRID_BITRATE) {
            int slow_log_0 = (wps->w.c [0].slow_level + SLO) >> SLS;
            int slow_log_1 = (wps->w.c [1].slow_level + SLO) >> SLS;

            if (wps->wphdr.flags & HYBRID_BALANCE) {
                int balance = (slow_log_1 - slow_log_0 + bitrate_1 + 1) >> 1;

                if (balance > bitrate_0) {
                    bitrate_1 = bitrate_0 * 2;
                    bitrate_0 = 0;
                }
                else if (-balance > bitrate_0) {
                    bitrate_0 = bitrate_0 * 2;
                    bitrate_1 = 0;
                }
                else {
                    bitrate_1 = bitrate_0 + balance;
                    bitrate_0 = bitrate_0 - balance;
                }
            }

            if (slow_log_0 - bitrate_0 > -0x100)
                wps->w.c [0].error_limit = wp_exp2s (slow_log_0 - bitrate_0 + 0x100);
            else
                wps->w.c [0].error_limit = 0;

            if (slow_log_1 - bitrate_1 > -0x100)
                wps->w.c [1].error_limit = wp_exp2s (slow_log_1 - bitrate_1 + 0x100);
            else
                wps->w.c [1].error_limit = 0;
        }
        else {
            wps->w.c [0].error_limit = wp_exp2s (bitrate_0);
            wps->w.c [1].error_limit = wp_exp2s (bitrate_1);
        }
    }
}

// The concept of a base 2 logarithm is used in many parts of WavPack. It is
// a way of sufficiently accurately representing 32-bit signed and unsigned
// values storing only 16 bits (actually fewer). It is also used in the hybrid
// mode for quickly comparing the relative magnitude of large values (i.e.
// division) and providing smooth exponentials using only addition.

// These are not strict logarithms in that they become linear around zero and
// can therefore represent both zero and negative values. They have 8 bits
// of precision and in "roundtrip" conversions the total error never exceeds 1
// part in 225 except for the cases of +/-115 and +/-195 (which error by 1).


// This function returns the log2 for the specified 32-bit unsigned value.
// The maximum value allowed is about 0xff800000 and returns 8447.

int FASTCALL wp_log2 (uint32_t avalue)
{
    int dbits;

    if ((avalue += avalue >> 9) < (1 << 8)) {
        dbits = nbits_table [avalue];
        return (dbits << 8) + log2_table [(avalue << (9 - dbits)) & 0xff];
    }
    else {
        if (avalue < (1L << 16))
            dbits = nbits_table [avalue >> 8] + 8;
        else if (avalue < (1L << 24))
            dbits = nbits_table [avalue >> 16] + 16;
        else
            dbits = nbits_table [avalue >> 24] + 24;

        return (dbits << 8) + log2_table [(avalue >> (dbits - 9)) & 0xff];
    }
}

// This function scans a buffer of longs and accumulates the total log2 value
// of all the samples. This is useful for determining maximum compression
// because the bitstream storage required for entropy coding is proportional
// to the base 2 log of the samples. On some platforms there is an assembly
// version of this.

#if !defined(OPT_ASM_X86) && !defined(OPT_ASM_X64)

uint32_t log2buffer (int32_t *samples, uint32_t num_samples, int limit)
{
    uint32_t result = 0, avalue;
    int dbits;

    while (num_samples--) {
        avalue = abs (*samples++);

        if ((avalue += avalue >> 9) < (1 << 8)) {
            dbits = nbits_table [avalue];
            result += (dbits << 8) + log2_table [(avalue << (9 - dbits)) & 0xff];
        }
        else {
            if (avalue < (1L << 16))
                dbits = nbits_table [avalue >> 8] + 8;
            else if (avalue < (1L << 24))
                dbits = nbits_table [avalue >> 16] + 16;
            else
                dbits = nbits_table [avalue >> 24] + 24;

            result += dbits = (dbits << 8) + log2_table [(avalue >> (dbits - 9)) & 0xff];

            if (limit && dbits >= limit)
                return (uint32_t) -1;
        }
    }

    return result;
}

#endif

// This function returns the log2 for the specified 32-bit signed value.
// All input values are valid and the return values are in the range of
// +/- 8192.

int wp_log2s (int32_t value)
{
    return (value < 0) ? -wp_log2 (-value) : wp_log2 (value);
}

// This function returns the original integer represented by the supplied
// logarithm (at least within the provided accuracy). The log is signed,
// but since a full 32-bit value is returned this can be used for unsigned
// conversions as well (i.e. the input range is -8192 to +8447).

int32_t wp_exp2s (int log)
{
    uint32_t value;

    if (log < 0)
        return -wp_exp2s (-log);

    value = exp2_table [log & 0xff] | 0x100;

    if ((log >>= 8) <= 9)
        return value >> (9 - log);
    else
        return value << (log - 9);
}

// These two functions convert internal weights (which are normally +/-1024)
// to and from an 8-bit signed character version for storage in metadata. The
// weights are clipped here in the case that they are outside that range.

signed char store_weight (int weight)
{
    if (weight > 1024)
        weight = 1024;
    else if (weight < -1024)
        weight = -1024;

    if (weight > 0)
        weight -= (weight + 64) >> 7;

    return (weight + 4) >> 3;
}

int restore_weight (signed char weight)
{
    int result;

    if ((result = (int) weight << 3) > 0)
        result += (result + 64) >> 7;

    return result;
}

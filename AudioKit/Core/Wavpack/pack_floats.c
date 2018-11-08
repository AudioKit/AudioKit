////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// pack_floats.c

// This module deals with the compression of floating-point data. Note that no
// floating point math is involved here...the values are only processed with
// the macros that directly access the mantissa, exponent, and sign fields.
// That's why we use the f32 type instead of the built-in float type.

#include <stdlib.h>

#include "wavpack_local.h"

//#define DISPLAY_DIAGNOSTICS

// Scan the provided buffer of floating-point values and (1) convert the
// significant portion of the data to integers for compression using the
// regular WavPack algorithms (which only operate on integers) and (2)
// determine whether the data requires a second stream for lossless
// storage (which will usually be the case except when the floating-point
// data was originally integer data). The converted integers are returned
// "in-place" and a return value of TRUE indicates that a second stream
// is required.

int scan_float_data (WavpackStream *wps, f32 *values, int32_t num_values)
{
    int32_t shifted_ones = 0, shifted_zeros = 0, shifted_both = 0;
    int32_t false_zeros = 0, neg_zeros = 0;
#ifdef DISPLAY_DIAGNOSTICS
    int32_t true_zeros = 0, denormals = 0, exceptions = 0;
#endif
    uint32_t ordata = 0, crc = 0xffffffff;
    int32_t count, value, shift_count;
    int max_mag = 0, max_exp = 0;
    f32 *dp;

    wps->float_shift = wps->float_flags = 0;

    // First loop goes through all the data and (1) calculates the CRC and (2) finds the
    // max magnitude that does not have an exponent of 255 (reserved for +/-inf and NaN).
    for (dp = values, count = num_values; count--; dp++) {
        crc = crc * 27 + get_mantissa (*dp) * 9 + get_exponent (*dp) * 3 + get_sign (*dp);

        if (get_exponent (*dp) < 255 && get_magnitude (*dp) > max_mag)
            max_mag = get_magnitude (*dp);
    }

    wps->crc_x = crc;

    // round up the magnitude so that when we convert the floating-point values to integers,
    // they will be (at most) just over 24-bits signed precision
    if (get_exponent (max_mag))
        max_exp = get_exponent (max_mag + 0x7F0000);

    for (dp = values, count = num_values; count--; dp++) {
        // Exponent of 255 is reserved for +/-inf (mantissa = 0) or NaN (mantissa != 0).
        // we use a value one greater than 24-bits unsigned for this.
        if (get_exponent (*dp) == 255) {
#ifdef DISPLAY_DIAGNOSTICS
            exceptions++;
#endif
            wps->float_flags |= FLOAT_EXCEPTIONS;
            value = 0x1000000;
            shift_count = 0;
        }
        // This is the regular case. We generate a 24-bit unsigned value with the implied
        // '1' MSB set and calculate a shift that will make it line up with the biggest
        // samples in this block (although that shift would obviously shift out real data).
        else if (get_exponent (*dp)) {
            shift_count = max_exp - get_exponent (*dp);
            value = 0x800000 + get_mantissa (*dp);
        }
        // Zero exponent means either +/- zero (mantissa = 0) or denormals (mantissa != 0).
        // shift_count is set so that denormals (without an implied '1') will line up with
        // regular values (with their implied '1' added at bit 23). Trust me. We don't care
        // about the shift with zero.
        else {
            shift_count = max_exp ? max_exp - 1 : 0;
            value = get_mantissa (*dp);

#ifdef DISPLAY_DIAGNOSTICS
            if (get_mantissa (*dp))
                denormals++;
#endif
        }

        if (shift_count < 25)
            value >>= shift_count;      // perform the shift if there could be anything left
        else
            value = 0;                  // else just zero the value

        // If we are going to encode an integer zero, then this might be a "false zero" which
        // means that there are significant bits but they're completely shifted out, or a
        // "negative zero" which is simply a floating point value that we have to encode
        // (and converting it to a positive zero would be an error).
        if (!value) {
            if (get_exponent (*dp) || get_mantissa (*dp))
                ++false_zeros;
            else if (get_sign (*dp))
                ++neg_zeros;
#ifdef DISPLAY_DIAGNOSTICS
            else
                ++true_zeros;
#endif
        }
        // If we are going to shift something (but not everything) out of our integer before
        // encoding, then we generate a mask corresponding to the bits that will be shifted
        // out and increment the counter for the 3 possible cases of (1) all zeros, (2) all
        // ones, and (3) a mix of ones and zeros.
        else if (shift_count) {
            int32_t mask = (1 << shift_count) - 1;

            if (!(get_mantissa (*dp) & mask))
                shifted_zeros++;
            else if ((get_mantissa (*dp) & mask) == mask)
                shifted_ones++;
            else
                shifted_both++;
        }

        // "or" all the integer values together, and store the final integer with applied sign

        ordata |= value;
        * (int32_t *) dp = (get_sign (*dp)) ? -value : value;
    }

    wps->float_max_exp = max_exp;   // on decode, we use this to calculate actual exponent

    // Now, based on our various counts, we determine the scheme required to encode the bits
    // shifted out. Usually these will simply have to be sent literally, but in some rare cases
    // we can get away with always assuming ones shifted out, or assuming all the bits shifted
    // out in each value are the same (which means we only have to send a single bit).
    if (shifted_both)
        wps->float_flags |= FLOAT_SHIFT_SENT;
    else if (shifted_ones && !shifted_zeros)
        wps->float_flags |= FLOAT_SHIFT_ONES;
    else if (shifted_ones && shifted_zeros)
        wps->float_flags |= FLOAT_SHIFT_SAME;
    // Another case is that we only shift out zeros (or maybe nothing), and in that case we
    // check to see if our data actually has less than 24 or 25 bits of resolution, which means
    // that we reduce can the magnitude of the integers we are encoding (which saves all those
    // bits). The number of bits of reduced resolution is stored in float_shift.
    else if (ordata && !(ordata & 1)) {
        while (!(ordata & 1)) {
            wps->float_shift++;
            ordata >>= 1;
        }

        // here we shift out all those zeros in the integer data we will encode
        for (dp = values, count = num_values; count--; dp++)
            * (int32_t *) dp >>= wps->float_shift;
    }

    // Here we calculate the actual magnitude used by our integer data, although this is just
    // used for informational purposes during encode/decode to possibly use faster math.

    wps->wphdr.flags &= ~MAG_MASK;

    while (ordata) {
        wps->wphdr.flags += 1 << MAG_LSB;
        ordata >>= 1;
    }

    // Finally, we have to set some flags that guide how we encode various types of "zeros".
    // If none of these are set (which is the most common situation), then every integer
    // zero in the decoded data will simply become a floating-point zero.

    if (false_zeros || neg_zeros)
        wps->float_flags |= FLOAT_ZEROS_SENT;

    if (neg_zeros)
        wps->float_flags |= FLOAT_NEG_ZEROS;

#ifdef DISPLAY_DIAGNOSTICS
    {
        int32_t *ip, min = 0x7fffffff, max = 0x80000000;
        for (ip = (int32_t *) values, count = num_values; count--; ip++) {
            if (*ip < min) min = *ip;
            if (*ip > max) max = *ip;
        }

        fprintf (stderr, "integer range = %d to %d\n", min, max);
    }

    fprintf (stderr, "samples = %d, max exp = %d, pre-shift = %d, denormals = %d, exceptions = %d, max_mag = %x\n",
        num_values, max_exp, wps->float_shift, denormals, exceptions, max_mag);
    fprintf (stderr, "shifted ones/zeros/both = %d/%d/%d, true/neg/false zeros = %d/%d/%d\n",
        shifted_ones, shifted_zeros, shifted_both, true_zeros, neg_zeros, false_zeros);
#endif

    return wps->float_flags & (FLOAT_EXCEPTIONS | FLOAT_ZEROS_SENT | FLOAT_SHIFT_SENT | FLOAT_SHIFT_SAME);
}

// Given a buffer of float data, convert the data to integers (which is what the WavPack compression
// algorithms require) and write the other data required for lossless compression (which includes
// significant bits shifted out of the integers, plus information about +/- zeros and exceptions
// like NaN and +/- infinities) into the wvxbits stream (which is assumed to be opened). Note that
// for this work correctly, scan_float_data() must have been called on the original data to set
// the appropiate flags in float_flags and max_exp.

void send_float_data (WavpackStream *wps, f32 *values, int32_t num_values)
{
    int max_exp = wps->float_max_exp;
    int32_t count, value, shift_count;
    f32 *dp;

    for (dp = values, count = num_values; count--; dp++) {
        if (get_exponent (*dp) == 255) {
            if (get_mantissa (*dp)) {
                putbit_1 (&wps->wvxbits);
                putbits (get_mantissa (*dp), 23, &wps->wvxbits);
            }
            else {
                putbit_0 (&wps->wvxbits);
            }

            value = 0x1000000;
            shift_count = 0;
        }
        else if (get_exponent (*dp)) {
            shift_count = max_exp - get_exponent (*dp);
            value = 0x800000 + get_mantissa (*dp);
        }
        else {
            shift_count = max_exp ? max_exp - 1 : 0;
            value = get_mantissa (*dp);
        }

        if (shift_count < 25)
            value >>= shift_count;
        else
            value = 0;

        if (!value) {
            if (wps->float_flags & FLOAT_ZEROS_SENT) {
                if (get_exponent (*dp) || get_mantissa (*dp)) {
                    putbit_1 (&wps->wvxbits);
                    putbits (get_mantissa (*dp), 23, &wps->wvxbits);

                    if (max_exp >= 25) {
                        putbits (get_exponent (*dp), 8, &wps->wvxbits);
                    }

                    putbit (get_sign (*dp), &wps->wvxbits);
                }
                else {
                    putbit_0 (&wps->wvxbits);

                    if (wps->float_flags & FLOAT_NEG_ZEROS)
                        putbit (get_sign (*dp), &wps->wvxbits);
                }
            }
        }
        else if (shift_count) {
            if (wps->float_flags & FLOAT_SHIFT_SENT) {
                int32_t data = get_mantissa (*dp) & ((1 << shift_count) - 1);
                putbits (data, shift_count, &wps->wvxbits);
            }
            else if (wps->float_flags & FLOAT_SHIFT_SAME) {
                putbit (get_mantissa (*dp) & 1, &wps->wvxbits);
            }
        }
    }
}

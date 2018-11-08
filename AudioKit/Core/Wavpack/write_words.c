////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// write_words.c

// This module provides entropy word encoding functions using
// a variation on the Rice method.  This was introduced in version 3.93
// because it allows splitting the data into a "lossy" stream and a
// "correction" stream in a very efficient manner and is therefore ideal
// for the "hybrid" mode.  For 4.0, the efficiency of this method was
// significantly improved by moving away from the normal Rice restriction of
// using powers of two for the modulus divisions and now the method can be
// used for both hybrid and pure lossless encoding.

// Samples are divided by median probabilities at 5/7 (71.43%), 10/49 (20.41%),
// and 20/343 (5.83%). Each zone has 3.5 times fewer samples than the
// previous. Using standard Rice coding on this data would result in 1.4
// bits per sample average (not counting sign bit). However, there is a
// very simple encoding that is over 99% efficient with this data and
// results in about 1.22 bits per sample.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

///////////////////////////// executable code ////////////////////////////////

// Initialize entropy encoder for the specified stream. In lossless mode there
// are no parameters to select; in hybrid mode the bitrate mode and value need
// be initialized.

static void word_set_bitrate (WavpackStream *wps);

void init_words (WavpackStream *wps)
{
    CLEAR (wps->w);

    if (wps->wphdr.flags & HYBRID_FLAG)
        word_set_bitrate (wps);
}

// Set up parameters for hybrid mode based on header flags and "bits" field.
// This is currently only set up for the HYBRID_BITRATE mode in which the
// allowed error varies with the residual level (from "slow_level"). The
// simpler mode (which is not used yet) has the error level directly
// controlled from the metadata.

static void word_set_bitrate (WavpackStream *wps)
{
    int bitrate_0, bitrate_1;

    if (wps->wphdr.flags & HYBRID_BITRATE) {
        if (wps->wphdr.flags & FALSE_STEREO)
            bitrate_0 = (wps->bits * 2 - 512) < 568 ? 0 : (wps->bits * 2 - 512) - 568;
        else
            bitrate_0 = wps->bits < 568 ? 0 : wps->bits - 568;

        if (!(wps->wphdr.flags & MONO_DATA)) {

            if (wps->wphdr.flags & HYBRID_BALANCE)
                bitrate_1 = (wps->wphdr.flags & JOINT_STEREO) ? 256 : 0;
            else {
                bitrate_1 = bitrate_0;

                if (wps->wphdr.flags & JOINT_STEREO) {
                    if (bitrate_0 < 128) {
                        bitrate_1 += bitrate_0;
                        bitrate_0 = 0;
                    }
                    else {
                        bitrate_0 -= 128;
                        bitrate_1 += 128;
                    }
                }
            }
        }
        else
            bitrate_1 = 0;
    }
    else
        bitrate_0 = bitrate_1 = 0;

    wps->w.bitrate_acc [0] = (int32_t) bitrate_0 << 16;
    wps->w.bitrate_acc [1] = (int32_t) bitrate_1 << 16;
}

// Allocates the correct space in the metadata structure and writes the
// current median values to it. Values are converted from 32-bit unsigned
// to our internal 16-bit wp_log2 values, and read_entropy_vars () is called
// to read the values back because we must compensate for the loss through
// the log function.

void write_entropy_vars (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char *byteptr;
    int temp;

    byteptr = wpmd->data = malloc (12);
    wpmd->id = ID_ENTROPY_VARS;

    *byteptr++ = temp = wp_log2 (wps->w.c [0].median [0]);
    *byteptr++ = temp >> 8;
    *byteptr++ = temp = wp_log2 (wps->w.c [0].median [1]);
    *byteptr++ = temp >> 8;
    *byteptr++ = temp = wp_log2 (wps->w.c [0].median [2]);
    *byteptr++ = temp >> 8;

    if (!(wps->wphdr.flags & MONO_DATA)) {
        *byteptr++ = temp = wp_log2 (wps->w.c [1].median [0]);
        *byteptr++ = temp >> 8;
        *byteptr++ = temp = wp_log2 (wps->w.c [1].median [1]);
        *byteptr++ = temp >> 8;
        *byteptr++ = temp = wp_log2 (wps->w.c [1].median [2]);
        *byteptr++ = temp >> 8;
    }

    wpmd->byte_length = (int32_t)(byteptr - (unsigned char *) wpmd->data);
    read_entropy_vars (wps, wpmd);
}

// Allocates enough space in the metadata structure and writes the current
// high word of the bitrate accumulator and the slow_level values to it. The
// slow_level values are converted from 32-bit unsigned to our internal 16-bit
// wp_log2 values. Afterward, read_entropy_vars () is called to read the values
// back because we must compensate for the loss through the log function and
// the truncation of the bitrate.

void write_hybrid_profile (WavpackStream *wps, WavpackMetadata *wpmd)
{
    unsigned char *byteptr;
    int temp;

    word_set_bitrate (wps);
    byteptr = wpmd->data = malloc (512);
    wpmd->id = ID_HYBRID_PROFILE;

    if (wps->wphdr.flags & HYBRID_BITRATE) {
        *byteptr++ = temp = wp_log2s (wps->w.c [0].slow_level);
        *byteptr++ = temp >> 8;

        if (!(wps->wphdr.flags & MONO_DATA)) {
            *byteptr++ = temp = wp_log2s (wps->w.c [1].slow_level);
            *byteptr++ = temp >> 8;
        }
    }

    *byteptr++ = temp = wps->w.bitrate_acc [0] >> 16;
    *byteptr++ = temp >> 8;

    if (!(wps->wphdr.flags & MONO_DATA)) {
        *byteptr++ = temp = wps->w.bitrate_acc [1] >> 16;
        *byteptr++ = temp >> 8;
    }

    if (wps->w.bitrate_delta [0] | wps->w.bitrate_delta [1]) {
        *byteptr++ = temp = wp_log2s (wps->w.bitrate_delta [0]);
        *byteptr++ = temp >> 8;

        if (!(wps->wphdr.flags & MONO_DATA)) {
            *byteptr++ = temp = wp_log2s (wps->w.bitrate_delta [1]);
            *byteptr++ = temp >> 8;
        }
    }

    wpmd->byte_length = (int32_t)(byteptr - (unsigned char *) wpmd->data);
    read_hybrid_profile (wps, wpmd);
}

// This function writes the specified word to the open bitstream "wvbits" and,
// if the bitstream "wvcbits" is open, writes any correction data there. This
// function will work for either lossless or hybrid but because a version
// optimized for lossless exits below, it would normally be used for the hybrid
// mode only. The return value is the actual value stored to the stream (even
// if a correction file is being created) and is used as feedback to the
// predictor.

int32_t FASTCALL send_word (WavpackStream *wps, int32_t value, int chan)
{
    struct entropy_data *c = wps->w.c + chan;
    uint32_t ones_count, low, mid, high;
    int sign = (value < 0) ? 1 : 0;

    if (wps->w.c [0].median [0] < 2 && !wps->w.holding_zero && wps->w.c [1].median [0] < 2) {
        if (wps->w.zeros_acc) {
            if (value)
                flush_word (wps);
            else {
                c->slow_level -= (c->slow_level + SLO) >> SLS;
                wps->w.zeros_acc++;
                return 0;
            }
        }
        else if (value)
            putbit_0 (&wps->wvbits);
        else {
            c->slow_level -= (c->slow_level + SLO) >> SLS;
            CLEAR (wps->w.c [0].median);
            CLEAR (wps->w.c [1].median);
            wps->w.zeros_acc = 1;
            return 0;
        }
    }

    if (sign)
        value = ~value;

    if ((wps->wphdr.flags & HYBRID_FLAG) && !chan)
        update_error_limit (wps);

    if (value < (int32_t) GET_MED (0)) {
        ones_count = low = 0;
        high = GET_MED (0) - 1;
        DEC_MED0 ();
    }
    else {
        low = GET_MED (0);
        INC_MED0 ();

        if (value - low < GET_MED (1)) {
            ones_count = 1;
            high = low + GET_MED (1) - 1;
            DEC_MED1 ();
        }
        else {
            low += GET_MED (1);
            INC_MED1 ();

            if (value - low < GET_MED (2)) {
                ones_count = 2;
                high = low + GET_MED (2) - 1;
                DEC_MED2 ();
            }
            else {
                ones_count = 2 + (value - low) / GET_MED (2);
                low += (ones_count - 2) * GET_MED (2);
                high = low + GET_MED (2) - 1;
                INC_MED2 ();
            }
        }
    }

    mid = (high + low + 1) >> 1;

    if (wps->w.holding_zero) {
        if (ones_count)
            wps->w.holding_one++;

        flush_word (wps);

        if (ones_count) {
            wps->w.holding_zero = 1;
            ones_count--;
        }
        else
            wps->w.holding_zero = 0;
    }
    else
        wps->w.holding_zero = 1;

    wps->w.holding_one = ones_count * 2;

    if (!c->error_limit) {
        if (high != low) {
            uint32_t maxcode = high - low, code = value - low;
            int bitcount = count_bits (maxcode);
            uint32_t extras = bitset [bitcount] - maxcode - 1;

            if (code < extras) {
                wps->w.pend_data |= code << wps->w.pend_count;
                wps->w.pend_count += bitcount - 1;
            }
            else {
                wps->w.pend_data |= ((code + extras) >> 1) << wps->w.pend_count;
                wps->w.pend_count += bitcount - 1;
                wps->w.pend_data |= ((code + extras) & 1) << wps->w.pend_count++;
            }
        }

        mid = value;
    }
    else
        while (high - low > c->error_limit)
            if (value < (int32_t) mid) {
                mid = ((high = mid - 1) + low + 1) >> 1;
                wps->w.pend_count++;
            }
            else {
                mid = (high + (low = mid) + 1) >> 1;
                wps->w.pend_data |= bitset [wps->w.pend_count++];
            }

    wps->w.pend_data |= ((int32_t) sign << wps->w.pend_count++);

    if (!wps->w.holding_zero)
        flush_word (wps);

    if (bs_is_open (&wps->wvcbits) && c->error_limit) {
        uint32_t code = value - low, maxcode = high - low;
        int bitcount = count_bits (maxcode);
        uint32_t extras = bitset [bitcount] - maxcode - 1;

        if (bitcount) {
            if (code < extras)
                putbits (code, bitcount - 1, &wps->wvcbits);
            else {
                putbits ((code + extras) >> 1, bitcount - 1, &wps->wvcbits);
                putbit ((code + extras) & 1, &wps->wvcbits);
            }
        }
    }

    if (wps->wphdr.flags & HYBRID_BITRATE) {
        c->slow_level -= (c->slow_level + SLO) >> SLS;
        c->slow_level += wp_log2 (mid);
    }

    return sign ? ~mid : mid;
}

// This function is an optimized version of send_word() that only handles
// lossless (error_limit == 0) and sends an entire buffer of either mono or
// stereo data rather than a single sample. Unlike the generalized
// send_word(), it does not return values because it always encodes
// the exact value passed.

void send_words_lossless (WavpackStream *wps, int32_t *buffer, int32_t nsamples)
{
    struct entropy_data *c = wps->w.c;
    int32_t value, csamples;

    if (!(wps->wphdr.flags & MONO_DATA))
        nsamples *= 2;

    for (csamples = 0; csamples < nsamples; ++csamples) {
        int sign = ((value = *buffer++) < 0) ? 1 : 0;
        uint32_t ones_count, low, high;

        if (!(wps->wphdr.flags & MONO_DATA))
            c = wps->w.c + (csamples & 1);

        if (wps->w.c [0].median [0] < 2 && !wps->w.holding_zero && wps->w.c [1].median [0] < 2) {
            if (wps->w.zeros_acc) {
                if (value)
                    flush_word (wps);
                else {
                    wps->w.zeros_acc++;
                    continue;
                }
            }
            else if (value)
                putbit_0 (&wps->wvbits);
            else {
                CLEAR (wps->w.c [0].median);
                CLEAR (wps->w.c [1].median);
                wps->w.zeros_acc = 1;
                continue;
            }
        }

        if (sign)
            value = ~value;

        if (value < (int32_t) GET_MED (0)) {
            ones_count = low = 0;
            high = GET_MED (0) - 1;
            DEC_MED0 ();
        }
        else {
            low = GET_MED (0);
            INC_MED0 ();

            if (value - low < GET_MED (1)) {
                ones_count = 1;
                high = low + GET_MED (1) - 1;
                DEC_MED1 ();
            }
            else {
                low += GET_MED (1);
                INC_MED1 ();

                if (value - low < GET_MED (2)) {
                    ones_count = 2;
                    high = low + GET_MED (2) - 1;
                    DEC_MED2 ();
                }
                else {
                    ones_count = 2 + (value - low) / GET_MED (2);
                    low += (ones_count - 2) * GET_MED (2);
                    high = low + GET_MED (2) - 1;
                    INC_MED2 ();
                }
            }
        }

        if (wps->w.holding_zero) {
            if (ones_count)
                wps->w.holding_one++;

            flush_word (wps);

            if (ones_count) {
                wps->w.holding_zero = 1;
                ones_count--;
            }
            else
                wps->w.holding_zero = 0;
        }
        else
            wps->w.holding_zero = 1;

        wps->w.holding_one = ones_count * 2;

        if (high != low) {
            uint32_t maxcode = high - low, code = value - low;
            int bitcount = count_bits (maxcode);
            uint32_t extras = bitset [bitcount] - maxcode - 1;

            if (code < extras) {
                wps->w.pend_data |= code << wps->w.pend_count;
                wps->w.pend_count += bitcount - 1;
            }
            else {
                wps->w.pend_data |= ((code + extras) >> 1) << wps->w.pend_count;
                wps->w.pend_count += bitcount - 1;
                wps->w.pend_data |= ((code + extras) & 1) << wps->w.pend_count++;
            }
        }

        wps->w.pend_data |= ((int32_t) sign << wps->w.pend_count++);

        if (!wps->w.holding_zero)
            flush_word (wps);
    }
}

// Used by send_word() and send_word_lossless() to actually send most the
// accumulated data onto the bitstream. This is also called directly from
// clients when all words have been sent.

void flush_word (WavpackStream *wps)
{
    if (wps->w.zeros_acc) {
        int cbits = count_bits (wps->w.zeros_acc);

        while (cbits--)
            putbit_1 (&wps->wvbits);

        putbit_0 (&wps->wvbits);

        while (wps->w.zeros_acc > 1) {
            putbit (wps->w.zeros_acc & 1, &wps->wvbits);
            wps->w.zeros_acc >>= 1;
        }

        wps->w.zeros_acc = 0;
    }

    if (wps->w.holding_one) {
#ifdef LIMIT_ONES
        if (wps->w.holding_one >= LIMIT_ONES) {
            int cbits;

            putbits ((1L << LIMIT_ONES) - 1, LIMIT_ONES + 1, &wps->wvbits);
            wps->w.holding_one -= LIMIT_ONES;
            cbits = count_bits (wps->w.holding_one);

            while (cbits--)
                putbit_1 (&wps->wvbits);

            putbit_0 (&wps->wvbits);

            while (wps->w.holding_one > 1) {
                putbit (wps->w.holding_one & 1, &wps->wvbits);
                wps->w.holding_one >>= 1;
            }

            wps->w.holding_zero = 0;
        }
        else
            putbits (bitmask [wps->w.holding_one], wps->w.holding_one, &wps->wvbits);

        wps->w.holding_one = 0;
#else
        do {
            putbit_1 (&wps->wvbits);
        } while (--wps->w.holding_one);
#endif
    }

    if (wps->w.holding_zero) {
        putbit_0 (&wps->wvbits);
        wps->w.holding_zero = 0;
    }

    if (wps->w.pend_count) {
        putbits (wps->w.pend_data, wps->w.pend_count, &wps->wvbits);
        wps->w.pend_data = wps->w.pend_count = 0;
    }
}

// This function is similar to send_word() except that no data is actually
// written to any stream, but it does return the value that would have been
// sent to a hybrid stream. It is used to determine beforehand how much noise
// will be added to samples.

int32_t nosend_word (WavpackStream *wps, int32_t value, int chan)
{
    struct entropy_data *c = wps->w.c + chan;
    uint32_t ones_count, low, mid, high;
    int sign = (value < 0) ? 1 : 0;

    if (sign)
        value = ~value;

    if ((wps->wphdr.flags & HYBRID_FLAG) && !chan)
        update_error_limit (wps);

    if (value < (int32_t) GET_MED (0)) {
        low = 0;
        high = GET_MED (0) - 1;
        DEC_MED0 ();
    }
    else {
        low = GET_MED (0);
        INC_MED0 ();

        if (value - low < GET_MED (1)) {
            high = low + GET_MED (1) - 1;
            DEC_MED1 ();
        }
        else {
            low += GET_MED (1);
            INC_MED1 ();

            if (value - low < GET_MED (2)) {
                high = low + GET_MED (2) - 1;
                DEC_MED2 ();
            }
            else {
                ones_count = 2 + (value - low) / GET_MED (2);
                low += (ones_count - 2) * GET_MED (2);
                high = low + GET_MED (2) - 1;
                INC_MED2 ();
            }
        }
    }

    mid = (high + low + 1) >> 1;

    if (!c->error_limit)
        mid = value;
    else
        while (high - low > c->error_limit)
            if (value < (int32_t) mid)
                mid = ((high = mid - 1) + low + 1) >> 1;
            else
                mid = (high + (low = mid) + 1) >> 1;

    c->slow_level -= (c->slow_level + SLO) >> SLS;
    c->slow_level += wp_log2 (mid);

    return sign ? ~mid : mid;
}

// This function is used to scan some number of samples to set the variables
// "slow_level" and the "median" array. In pure symetrical encoding mode this
// would not be needed because these values would simply be continued from the
// previous block. However, in the -X modes and the 32-bit modes we cannot do
// this because parameters may change between blocks and the variables might
// not apply. This function can work in mono or stereo and can scan a block
// in either direction.

void scan_word (WavpackStream *wps, int32_t *samples, uint32_t num_samples, int dir)
{
    uint32_t flags = wps->wphdr.flags, value, low;
    struct entropy_data *c = wps->w.c;
    int chan;

    init_words (wps);

    if (flags & MONO_DATA) {
        if (dir < 0) {
            samples += (num_samples - 1);
            dir = -1;
        }
        else
            dir = 1;
    }
    else {
        if (dir < 0) {
            samples += (num_samples - 1) * 2;
            dir = -2;
        }
        else
            dir = 2;
    }

    while (num_samples--) {

        value = (uint32_t)(labs (samples [chan = 0]));

        if (flags & HYBRID_BITRATE) {
            wps->w.c [0].slow_level -= (wps->w.c [0].slow_level + SLO) >> SLS;
            wps->w.c [0].slow_level += wp_log2 (value);
        }

        if (value < GET_MED (0)) {
            DEC_MED0 ();
        }
        else {
            low = GET_MED (0);
            INC_MED0 ();

            if (value - low < GET_MED (1)) {
                DEC_MED1 ();
            }
            else {
                low += GET_MED (1);
                INC_MED1 ();

                if (value - low < GET_MED (2)) {
                    DEC_MED2 ();
                }
                else {
                    INC_MED2 ();
                }
            }
        }

        if (!(flags & MONO_DATA)) {
            value = (uint32_t)(labs (samples [chan = 1]));
            c++;

            if (wps->wphdr.flags & HYBRID_BITRATE) {
                wps->w.c [1].slow_level -= (wps->w.c [1].slow_level + SLO) >> SLS;
                wps->w.c [1].slow_level += wp_log2 (value);
            }

            if (value < GET_MED (0)) {
                DEC_MED0 ();
            }
            else {
                low = GET_MED (0);
                INC_MED0 ();

                if (value - low < GET_MED (1)) {
                    DEC_MED1 ();
                }
                else {
                    low += GET_MED (1);
                    INC_MED1 ();

                    if (value - low < GET_MED (2)) {
                        DEC_MED2 ();
                    }
                    else {
                        INC_MED2 ();
                    }
                }
            }

            c--;
        }

        samples += dir;
    }
}


////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// read_words.c

// This module provides entropy word decoding functions using
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

#if defined (HAVE___BUILTIN_CTZ) || defined (_WIN64)
#define USE_CTZ_OPTIMIZATION    // use ctz intrinsic (or Windows equivalent) to count trailing ones
#else
#define USE_NEXT8_OPTIMIZATION  // optimization using a table to count trailing ones
#endif

#define USE_BITMASK_TABLES      // use tables instead of shifting for certain masking operations

///////////////////////////// local table storage ////////////////////////////

#ifdef USE_NEXT8_OPTIMIZATION
static const char ones_count_table [] = {
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,5,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,6,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,5,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,7,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,5,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,6,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,5,
    0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,8
};
#endif

///////////////////////////// executable code ////////////////////////////////

static uint32_t __inline read_code (Bitstream *bs, uint32_t maxcode);

// Read the next word from the bitstream "wvbits" and return the value. This
// function can be used for hybrid or lossless streams, but since an
// optimized version is available for lossless this function would normally
// be used for hybrid only. If a hybrid lossless stream is being read then
// the "correction" offset is written at the specified pointer. A return value
// of WORD_EOF indicates that the end of the bitstream was reached (all 1s) or
// some other error occurred.

int32_t FASTCALL get_word (WavpackStream *wps, int chan, int32_t *correction)
{
    register struct entropy_data *c = wps->w.c + chan;
    uint32_t ones_count, low, mid, high;
    int32_t value;
    int sign;

    if (!wps->wvbits.ptr)
        return WORD_EOF;

    if (correction)
        *correction = 0;

    if (!(wps->w.c [0].median [0] & ~1) && !wps->w.holding_zero && !wps->w.holding_one && !(wps->w.c [1].median [0] & ~1)) {
        uint32_t mask;
        int cbits;

        if (wps->w.zeros_acc) {
            if (--wps->w.zeros_acc) {
                c->slow_level -= (c->slow_level + SLO) >> SLS;
                return 0;
            }
        }
        else {
            for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

            if (cbits == 33)
                return WORD_EOF;

            if (cbits < 2)
                wps->w.zeros_acc = cbits;
            else {
                for (mask = 1, wps->w.zeros_acc = 0; --cbits; mask <<= 1)
                    if (getbit (&wps->wvbits))
                        wps->w.zeros_acc |= mask;

                wps->w.zeros_acc |= mask;
            }

            if (wps->w.zeros_acc) {
                c->slow_level -= (c->slow_level + SLO) >> SLS;
                CLEAR (wps->w.c [0].median);
                CLEAR (wps->w.c [1].median);
                return 0;
            }
        }
    }

    if (wps->w.holding_zero)
        ones_count = wps->w.holding_zero = 0;
    else {
#ifdef USE_CTZ_OPTIMIZATION
        while (wps->wvbits.bc < LIMIT_ONES) {
            if (++(wps->wvbits.ptr) == wps->wvbits.end)
                wps->wvbits.wrap (&wps->wvbits);

            wps->wvbits.sr |= *(wps->wvbits.ptr) << wps->wvbits.bc;
            wps->wvbits.bc += sizeof (*(wps->wvbits.ptr)) * 8;
        }

#ifdef _WIN32
        _BitScanForward (&ones_count, ~wps->wvbits.sr);
#else
        ones_count = __builtin_ctz (~wps->wvbits.sr);
#endif

        if (ones_count >= LIMIT_ONES) {
            wps->wvbits.bc -= ones_count;
            wps->wvbits.sr >>= ones_count;

            for (; ones_count < (LIMIT_ONES + 1) && getbit (&wps->wvbits); ++ones_count);

            if (ones_count == (LIMIT_ONES + 1))
                return WORD_EOF;

            if (ones_count == LIMIT_ONES) {
                uint32_t mask;
                int cbits;

                for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

                if (cbits == 33)
                    return WORD_EOF;

                if (cbits < 2)
                    ones_count = cbits;
                else {
                    for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                        if (getbit (&wps->wvbits))
                            ones_count |= mask;

                    ones_count |= mask;
                }

                ones_count += LIMIT_ONES;
            }
        }
        else {
            wps->wvbits.bc -= ones_count + 1;
            wps->wvbits.sr >>= ones_count + 1;
        }
#elif defined (USE_NEXT8_OPTIMIZATION)
        int next8;

        if (wps->wvbits.bc < 8) {
            if (++(wps->wvbits.ptr) == wps->wvbits.end)
                wps->wvbits.wrap (&wps->wvbits);

            next8 = (wps->wvbits.sr |= *(wps->wvbits.ptr) << wps->wvbits.bc) & 0xff;
            wps->wvbits.bc += sizeof (*(wps->wvbits.ptr)) * 8;
        }
        else
            next8 = wps->wvbits.sr & 0xff;

        if (next8 == 0xff) {
            wps->wvbits.bc -= 8;
            wps->wvbits.sr >>= 8;

            for (ones_count = 8; ones_count < (LIMIT_ONES + 1) && getbit (&wps->wvbits); ++ones_count);

            if (ones_count == (LIMIT_ONES + 1))
                return WORD_EOF;

            if (ones_count == LIMIT_ONES) {
                uint32_t mask;
                int cbits;

                for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

                if (cbits == 33)
                    return WORD_EOF;

                if (cbits < 2)
                    ones_count = cbits;
                else {
                    for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                        if (getbit (&wps->wvbits))
                            ones_count |= mask;

                    ones_count |= mask;
                }

                ones_count += LIMIT_ONES;
            }
        }
        else {
            wps->wvbits.bc -= (ones_count = ones_count_table [next8]) + 1;
            wps->wvbits.sr >>= ones_count + 1;
        }
#else
        for (ones_count = 0; ones_count < (LIMIT_ONES + 1) && getbit (&wps->wvbits); ++ones_count);

        if (ones_count >= LIMIT_ONES) {
            uint32_t mask;
            int cbits;

            if (ones_count == (LIMIT_ONES + 1))
                return WORD_EOF;

            for (cbits = 0; cbits < 33 && getbit (&wps->wvbits); ++cbits);

            if (cbits == 33)
                return WORD_EOF;

            if (cbits < 2)
                ones_count = cbits;
            else {
                for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                    if (getbit (&wps->wvbits))
                        ones_count |= mask;

                ones_count |= mask;
            }

            ones_count += LIMIT_ONES;
        }
#endif

        if (wps->w.holding_one) {
            wps->w.holding_one = ones_count & 1;
            ones_count = (ones_count >> 1) + 1;
        }
        else {
            wps->w.holding_one = ones_count & 1;
            ones_count >>= 1;
        }

        wps->w.holding_zero = ~wps->w.holding_one & 1;
    }

    if ((wps->wphdr.flags & HYBRID_FLAG) && !chan)
        update_error_limit (wps);

    if (ones_count == 0) {
        low = 0;
        high = GET_MED (0) - 1;
        DEC_MED0 ();
    }
    else {
        low = GET_MED (0);
        INC_MED0 ();

        if (ones_count == 1) {
            high = low + GET_MED (1) - 1;
            DEC_MED1 ();
        }
        else {
            low += GET_MED (1);
            INC_MED1 ();

            if (ones_count == 2) {
                high = low + GET_MED (2) - 1;
                DEC_MED2 ();
            }
            else {
                low += (ones_count - 2) * GET_MED (2);
                high = low + GET_MED (2) - 1;
                INC_MED2 ();
            }
        }
    }

    low &= 0x7fffffff;
    high &= 0x7fffffff;

    if (low > high)         // make sure high and low make sense
        high = low;

    mid = (high + low + 1) >> 1;

    if (!c->error_limit)
        mid = read_code (&wps->wvbits, high - low) + low;
    else while (high - low > c->error_limit) {
        if (getbit (&wps->wvbits))
            mid = (high + (low = mid) + 1) >> 1;
        else
            mid = ((high = mid - 1) + low + 1) >> 1;
    }

    sign = getbit (&wps->wvbits);

    if (bs_is_open (&wps->wvcbits) && c->error_limit) {
        value = read_code (&wps->wvcbits, high - low) + low;

        if (correction)
            *correction = sign ? (mid - value) : (value - mid);
    }

    if (wps->wphdr.flags & HYBRID_BITRATE) {
        c->slow_level -= (c->slow_level + SLO) >> SLS;
        c->slow_level += wp_log2 (mid);
    }

    return sign ? ~mid : mid;
}

// This is an optimized version of get_word() that is used for lossless only
// (error_limit == 0). Also, rather than obtaining a single sample, it can be
// used to obtain an entire buffer of either mono or stereo samples.

int32_t get_words_lossless (WavpackStream *wps, int32_t *buffer, int32_t nsamples)
{
    struct entropy_data *c = wps->w.c;
    uint32_t ones_count, low, high;
    Bitstream *bs = &wps->wvbits;
    int32_t csamples;
#ifdef USE_NEXT8_OPTIMIZATION
    int32_t next8;
#endif

    if (nsamples && !bs->ptr) {
        memset (buffer, 0, (wps->wphdr.flags & MONO_DATA) ? nsamples * 4 : nsamples * 8);
        return nsamples;
    }

    if (!(wps->wphdr.flags & MONO_DATA))
        nsamples *= 2;

    for (csamples = 0; csamples < nsamples; ++csamples) {
        if (!(wps->wphdr.flags & MONO_DATA))
            c = wps->w.c + (csamples & 1);

        if (wps->w.holding_zero) {
            wps->w.holding_zero = 0;
            low = read_code (bs, GET_MED (0) - 1);
            DEC_MED0 ();
            buffer [csamples] = (getbit (bs)) ? ~low : low;

            if (++csamples == nsamples)
                break;

            if (!(wps->wphdr.flags & MONO_DATA))
                c = wps->w.c + (csamples & 1);
        }

        if (wps->w.c [0].median [0] < 2 && !wps->w.holding_one && wps->w.c [1].median [0] < 2) {
            uint32_t mask;
            int cbits;

            if (wps->w.zeros_acc) {
                if (--wps->w.zeros_acc) {
                    buffer [csamples] = 0;
                    continue;
                }
            }
            else {
                for (cbits = 0; cbits < 33 && getbit (bs); ++cbits);

                if (cbits == 33)
                    break;

                if (cbits < 2)
                    wps->w.zeros_acc = cbits;
                else {
                    for (mask = 1, wps->w.zeros_acc = 0; --cbits; mask <<= 1)
                        if (getbit (bs))
                            wps->w.zeros_acc |= mask;

                    wps->w.zeros_acc |= mask;
                }

                if (wps->w.zeros_acc) {
                    CLEAR (wps->w.c [0].median);
                    CLEAR (wps->w.c [1].median);
                    buffer [csamples] = 0;
                    continue;
                }
            }
        }

#ifdef USE_CTZ_OPTIMIZATION
        while (bs->bc < LIMIT_ONES) {
            if (++(bs->ptr) == bs->end)
                bs->wrap (bs);

            bs->sr |= *(bs->ptr) << bs->bc;
            bs->bc += sizeof (*(bs->ptr)) * 8;
        }

#ifdef _WIN32
        _BitScanForward (&ones_count, ~wps->wvbits.sr);
#else
        ones_count = __builtin_ctz (~wps->wvbits.sr);
#endif

        if (ones_count >= LIMIT_ONES) {
            bs->bc -= ones_count;
            bs->sr >>= ones_count;

            for (; ones_count < (LIMIT_ONES + 1) && getbit (bs); ++ones_count);

            if (ones_count == (LIMIT_ONES + 1))
                break;

            if (ones_count == LIMIT_ONES) {
                uint32_t mask;
                int cbits;

                for (cbits = 0; cbits < 33 && getbit (bs); ++cbits);

                if (cbits == 33)
                    break;

                if (cbits < 2)
                    ones_count = cbits;
                else {
                    for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                        if (getbit (bs))
                            ones_count |= mask;

                    ones_count |= mask;
                }

                ones_count += LIMIT_ONES;
            }
        }
        else {
            bs->bc -= ones_count + 1;
            bs->sr >>= ones_count + 1;
        }
#elif defined (USE_NEXT8_OPTIMIZATION)
        if (bs->bc < 8) {
            if (++(bs->ptr) == bs->end)
                bs->wrap (bs);

            next8 = (bs->sr |= *(bs->ptr) << bs->bc) & 0xff;
            bs->bc += sizeof (*(bs->ptr)) * 8;
        }
        else
            next8 = bs->sr & 0xff;

        if (next8 == 0xff) {
            bs->bc -= 8;
            bs->sr >>= 8;

            for (ones_count = 8; ones_count < (LIMIT_ONES + 1) && getbit (bs); ++ones_count);

            if (ones_count == (LIMIT_ONES + 1))
                break;

            if (ones_count == LIMIT_ONES) {
                uint32_t mask;
                int cbits;

                for (cbits = 0; cbits < 33 && getbit (bs); ++cbits);

                if (cbits == 33)
                    break;

                if (cbits < 2)
                    ones_count = cbits;
                else {
                    for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                        if (getbit (bs))
                            ones_count |= mask;

                    ones_count |= mask;
                }

                ones_count += LIMIT_ONES;
            }
        }
        else {
            bs->bc -= (ones_count = ones_count_table [next8]) + 1;
            bs->sr >>= ones_count + 1;
        }
#else
        for (ones_count = 0; ones_count < (LIMIT_ONES + 1) && getbit (bs); ++ones_count);

        if (ones_count >= LIMIT_ONES) {
            uint32_t mask;
            int cbits;

            if (ones_count == (LIMIT_ONES + 1))
                break;

            for (cbits = 0; cbits < 33 && getbit (bs); ++cbits);

            if (cbits == 33)
                break;

            if (cbits < 2)
                ones_count = cbits;
            else {
                for (mask = 1, ones_count = 0; --cbits; mask <<= 1)
                    if (getbit (bs))
                        ones_count |= mask;

                ones_count |= mask;
            }

            ones_count += LIMIT_ONES;
        }
#endif

        low = wps->w.holding_one;
        wps->w.holding_one = ones_count & 1;
        wps->w.holding_zero = ~ones_count & 1;
        ones_count = (ones_count >> 1) + low;

        if (ones_count == 0) {
            low = 0;
            high = GET_MED (0) - 1;
            DEC_MED0 ();
        }
        else {
            low = GET_MED (0);
            INC_MED0 ();

            if (ones_count == 1) {
                high = low + GET_MED (1) - 1;
                DEC_MED1 ();
            }
            else {
                low += GET_MED (1);
                INC_MED1 ();

                if (ones_count == 2) {
                    high = low + GET_MED (2) - 1;
                    DEC_MED2 ();
                }
                else {
                    low += (ones_count - 2) * GET_MED (2);
                    high = low + GET_MED (2) - 1;
                    INC_MED2 ();
                }
            }
        }

        low += read_code (bs, high - low);
        buffer [csamples] = (getbit (bs)) ? ~low : low;
    }

    return (wps->wphdr.flags & MONO_DATA) ? csamples : (csamples / 2);
}

// Read a single unsigned value from the specified bitstream with a value
// from 0 to maxcode. If there are exactly a power of two number of possible
// codes then this will read a fixed number of bits; otherwise it reads the
// minimum number of bits and then determines whether another bit is needed
// to define the code.

static uint32_t __inline read_code (Bitstream *bs, uint32_t maxcode)
{
    unsigned long local_sr;
    uint32_t extras, code;
    int bitcount;

    if (maxcode < 2)
        return maxcode ? getbit (bs) : 0;

    bitcount = count_bits (maxcode);
#ifdef USE_BITMASK_TABLES
    extras = bitset [bitcount] - maxcode - 1;
#else
    extras = (1 << bitcount) - maxcode - 1;
#endif

    local_sr = bs->sr;

    while (bs->bc < bitcount) {
        if (++(bs->ptr) == bs->end)
            bs->wrap (bs);

        local_sr |= (long)*(bs->ptr) << bs->bc;
        bs->bc += sizeof (*(bs->ptr)) * 8;
    }

#ifdef USE_BITMASK_TABLES
    if ((code = local_sr & bitmask [bitcount - 1]) >= extras)
#else
    if ((code = local_sr & ((1 << (bitcount - 1)) - 1)) >= extras)
#endif
        code = (code << 1) - extras + ((local_sr >> (bitcount - 1)) & 1);
    else
        bitcount--;

    if (sizeof (local_sr) < 8 && bs->bc > sizeof (local_sr) * 8) {
        bs->bc -= bitcount;
        bs->sr = *(bs->ptr) >> (sizeof (*(bs->ptr)) * 8 - bs->bc);
    }
    else {
        bs->bc -= bitcount;
        bs->sr = (uint32_t)(local_sr >> bitcount);
    }

    return code;
}

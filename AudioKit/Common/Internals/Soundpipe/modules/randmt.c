/*
   A C-program for MT19937, with initialisation improved 2002/1/26.
   Coded by Takuji Nishimura and Makoto Matsumoto.

   Before using, initialise the state by using csoundSeedRandMT().

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote
        products derived from this software without specific prior written
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.
   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
   ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
   IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.

   Any feedback is very welcome.
   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
*/

#include "soundpipe.h"
#define N           (624)
#define M           (397)
#define MATRIX_A    0x9908B0DFU     /* constant vector a */
#define UPPER_MASK  0x80000000U     /* most significant w-r bits */
#define LOWER_MASK  0x7FFFFFFFU     /* least significant r bits */

static void MT_update_state(uint32_t *mt)
{
    /* mag01[x] = x * MATRIX_A  for x=0,1 */
    const uint32_t  mag01[2] = { (uint32_t) 0, (uint32_t) MATRIX_A };
    int       i;
    uint32_t  y;

    for (i = 0; i < (N - M); i++) {
      y = (mt[i] & UPPER_MASK) | (mt[i + 1] & LOWER_MASK);
      mt[i] = mt[i + M] ^ (y >> 1) ^ mag01[y & (uint32_t) 1];
    }
    for ( ; i < (N - 1); i++) {
      y = (mt[i] & UPPER_MASK) | (mt[i + 1] & LOWER_MASK);
      mt[i] = mt[i + (M - N)] ^ (y >> 1) ^ mag01[y & (uint32_t) 1];
    }
    y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
    mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & (uint32_t) 1];
}

/* generates a random number on [0,0xffffffff]-interval */

uint32_t sp_randmt_compute(sp_randmt *p)
{
    int       i = p->mti;
    uint32_t  y;

    if (i >= N) {                   /* generate N words at one time */
      MT_update_state(&(p->mt[0]));
      i = 0;
    }
    y = p->mt[i];
    p->mti = i + 1;
    /* Tempering */
    y ^= (y >> 11);
    y ^= (y << 7) & (uint32_t) 0x9D2C5680U;
    y ^= (y << 15) & (uint32_t) 0xEFC60000U;
    y ^= (y >> 18);

    return y;
}

void sp_randmt_seed(sp_randmt *p,
    const uint32_t *initKey, uint32_t keyLength)
{
    int       i, j, k;
    uint32_t  x;

    /* if array is NULL, use length parameter as simple 32 bit seed */
    x = (initKey == NULL ? keyLength : (uint32_t) 19650218);
    p->mt[0] = x;
    for (i = 1; i < N; i++) {
      /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
      /* In the previous versions, MSBs of the seed affect   */
      /* only MSBs of the array mt[].                        */
      /* 2002/01/09 modified by Makoto Matsumoto             */
      x = ((uint32_t) 1812433253 * (x ^ (x >> 30)) + (uint32_t) i);
      p->mt[i] = x;
    }
    p->mti = N;
    if (initKey == NULL)
      return;
    i = 0; j = 0;
    k = (N > (int) keyLength ? N : (int) keyLength);
    for ( ; k; k--) {
      x = p->mt[i++];
      p->mt[i] = (p->mt[i] ^ ((x ^ (x >> 30)) * (uint32_t) 1664525))
                 + initKey[j] + (uint32_t) j;   /* non linear */
      if (i == (N - 1)) {
        p->mt[0] = p->mt[N - 1];
        i = 0;
      }
      if (++j >= (int) keyLength)
        j = 0;
    }
    for (k = (N - 1); k; k--) {
      x = p->mt[i++];
      p->mt[i] = (p->mt[i] ^ ((x ^ (x >> 30)) * (uint32_t) 1566083941))
                 - (uint32_t) i;                /* non linear */
      if (i == (N - 1)) {
        p->mt[0] = p->mt[N - 1];
        i = 0;
      }
    }
    /* MSB is 1; assuring non-zero initial array */
    p->mt[0] = (uint32_t) 0x80000000U;
}


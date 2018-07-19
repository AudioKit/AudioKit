/* THIS IS A GENERATED FILE. DO NOT EDIT BY HAND */
/*
    FFT library
    based on public domain code by John Green <green_jt@vsdec.npt.nuwc.navy.mil>
    original version is available at
      http://hyperarchive.lcs.mit.edu/
            /HyperArchive/Archive/dev/src/ffts-for-risc-2-c.hqx
    ported to Csound by Istvan Varga, 2005
*/

#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define POW2(m) ((uint32_t) 1 << (m))       /* integer power of 2 for m<32 */

/* fft's with M bigger than this bust primary cache */
#define MCACHE  (11 - (sizeof(SPFLOAT) / 8))

/* some math constants to 40 decimal places */
#define MYPI      3.141592653589793238462643383279502884197   /* pi         */
#define MYROOT2   1.414213562373095048801688724209698078569   /* sqrt(2)    */
#define MYCOSPID8 0.9238795325112867561281831893967882868224  /* cos(pi/8)  */
#define MYSINPID8 0.3826834323650897717284599840303988667613  /* sin(pi/8)  */

/*****************************************************
* routines to initialize tables used by fft routines *
*****************************************************/

static void fftCosInit(int M, SPFLOAT *Utbl)
{
    /* Compute Utbl, the cosine table for ffts  */
    /* of size (pow(2,M)/4 +1)                  */
    /* INPUTS                                   */
    /*   M = log2 of fft size                   */
    /* OUTPUTS                                  */
    /*   *Utbl = cosine table                   */
    unsigned int fftN = POW2(M);
    unsigned int i1;

    Utbl[0] = 1.0;
    for (i1 = 1; i1 < fftN/4; i1++)
      Utbl[i1] = cos((2.0 * M_PI * (SPFLOAT)i1) / (SPFLOAT)fftN);
    Utbl[fftN/4] = 0.0;
}

void fftBRInit(int M, int16_t *BRLow)
{
    /* Compute BRLow, the bit reversed table for ffts */
    /* of size pow(2,M/2 -1)                          */
    /* INPUTS                                         */
    /*   M = log2 of fft size                         */
    /* OUTPUTS                                        */
    /*   *BRLow = bit reversed counter table          */
    int Mroot_1 = M / 2 - 1;
    int Nroot_1 = POW2(Mroot_1);
    int i1;
    int bitsum;
    int bitmask;
    int bit;

    for (i1 = 0; i1 < Nroot_1; i1++) {
      bitsum = 0;
      bitmask = 1;
      for (bit = 1; bit <= Mroot_1; bitmask <<= 1, bit++)
        if (i1 & bitmask)
          bitsum = bitsum + (Nroot_1 >> bit);
      BRLow[i1] = bitsum;
    }
}

/*****************
* parts of ffts1 *
*****************/

static void bitrevR2(SPFLOAT *ioptr, int M, int16_t *BRLow)
{
    /*** bit reverse and first radix 2 stage of forward or inverse fft ***/
    SPFLOAT f0r;
    SPFLOAT f0i;
    SPFLOAT f1r;
    SPFLOAT f1i;
    SPFLOAT f2r;
    SPFLOAT f2i;
    SPFLOAT f3r;
    SPFLOAT f3i;
    SPFLOAT f4r;
    SPFLOAT f4i;
    SPFLOAT f5r;
    SPFLOAT f5i;
    SPFLOAT f6r;
    SPFLOAT f6i;
    SPFLOAT f7r;
    SPFLOAT f7i;
    SPFLOAT t0r;
    SPFLOAT t0i;
    SPFLOAT t1r;
    SPFLOAT t1i;
    SPFLOAT *p0r;
    SPFLOAT *p1r;
    SPFLOAT *IOP;
    SPFLOAT *iolimit;
    int Colstart;
    int iCol;
    unsigned int posA;
    unsigned int posAi;
    unsigned int posB;
    unsigned int posBi;

    const unsigned int Nrems2 = POW2((M + 3) / 2);
    const unsigned int Nroot_1_ColInc = POW2(M) - Nrems2;
    const unsigned int Nroot_1 = POW2(M / 2 - 1) - 1;
    const unsigned int ColstartShift = (M + 1) / 2 + 1;

    posA = POW2(M);               /* 1/2 of POW2(M) complexes */
    posAi = posA + 1;
    posB = posA + 2;
    posBi = posB + 1;

    iolimit = ioptr + Nrems2;
    for (; ioptr < iolimit; ioptr += POW2(M / 2 + 1)) {
      for (Colstart = Nroot_1; Colstart >= 0; Colstart--) {
        iCol = Nroot_1;
        p0r = ioptr + Nroot_1_ColInc + BRLow[Colstart] * 4;
        IOP = ioptr + (Colstart << ColstartShift);
        p1r = IOP + BRLow[iCol] * 4;
        f0r = *(p0r);
        f0i = *(p0r + 1);
        f1r = *(p0r + posA);
        f1i = *(p0r + posAi);
        for (; iCol > Colstart;) {
          f2r = *(p0r + 2);
          f2i = *(p0r + (2 + 1));
          f3r = *(p0r + posB);
          f3i = *(p0r + posBi);
          f4r = *(p1r);
          f4i = *(p1r + 1);
          f5r = *(p1r + posA);
          f5i = *(p1r + posAi);
          f6r = *(p1r + 2);
          f6i = *(p1r + (2 + 1));
          f7r = *(p1r + posB);
          f7i = *(p1r + posBi);

          t0r = f0r + f1r;
          t0i = f0i + f1i;
          f1r = f0r - f1r;
          f1i = f0i - f1i;
          t1r = f2r + f3r;
          t1i = f2i + f3i;
          f3r = f2r - f3r;
          f3i = f2i - f3i;
          f0r = f4r + f5r;
          f0i = f4i + f5i;
          f5r = f4r - f5r;
          f5i = f4i - f5i;
          f2r = f6r + f7r;
          f2i = f6i + f7i;
          f7r = f6r - f7r;
          f7i = f6i - f7i;

          *(p1r) = t0r;
          *(p1r + 1) = t0i;
          *(p1r + 2) = f1r;
          *(p1r + (2 + 1)) = f1i;
          *(p1r + posA) = t1r;
          *(p1r + posAi) = t1i;
          *(p1r + posB) = f3r;
          *(p1r + posBi) = f3i;
          *(p0r) = f0r;
          *(p0r + 1) = f0i;
          *(p0r + 2) = f5r;
          *(p0r + (2 + 1)) = f5i;
          *(p0r + posA) = f2r;
          *(p0r + posAi) = f2i;
          *(p0r + posB) = f7r;
          *(p0r + posBi) = f7i;

          p0r -= Nrems2;
          f0r = *(p0r);
          f0i = *(p0r + 1);
          f1r = *(p0r + posA);
          f1i = *(p0r + posAi);
          iCol -= 1;
          p1r = IOP + BRLow[iCol] * 4;
        }
        f2r = *(p0r + 2);
        f2i = *(p0r + (2 + 1));
        f3r = *(p0r + posB);
        f3i = *(p0r + posBi);

        t0r = f0r + f1r;
        t0i = f0i + f1i;
        f1r = f0r - f1r;
        f1i = f0i - f1i;
        t1r = f2r + f3r;
        t1i = f2i + f3i;
        f3r = f2r - f3r;
        f3i = f2i - f3i;

        *(p0r) = t0r;
        *(p0r + 1) = t0i;
        *(p0r + 2) = f1r;
        *(p0r + (2 + 1)) = f1i;
        *(p0r + posA) = t1r;
        *(p0r + posAi) = t1i;
        *(p0r + posB) = f3r;
        *(p0r + posBi) = f3i;
      }
    }
}

static void fft2pt(SPFLOAT *ioptr)
{
    /***   RADIX 2 fft      ***/
    SPFLOAT f0r, f0i, f1r, f1i;
    SPFLOAT t0r, t0i;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[2];
    f1i = ioptr[3];

    /* Butterflys           */
    /*
       f0   -       -       t0
       f1   -  1 -  f1
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f0i - f1i;

    /* store result */
    ioptr[0] = t0r;
    ioptr[1] = t0i;
    ioptr[2] = f1r;
    ioptr[3] = f1i;
}

static void fft4pt(SPFLOAT *ioptr)
{
    /***   RADIX 4 fft      ***/
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT t0r, t0i, t1r, t1i;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[4];
    f1i = ioptr[5];
    f2r = ioptr[2];
    f2i = ioptr[3];
    f3r = ioptr[6];
    f3i = ioptr[7];

    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0
       f1   -  1 -  f1      -       -       f1
       f2   -       -       f2      -  1 -  f2
       f3   -  1 -  t1      - -i -  f3
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f0i - f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = t0i - f2i;

    f3r = f1r - t1i;
    f3i = f1i + t1r;
    f1r = f1r + t1i;
    f1i = f1i - t1r;

    /* store result */
    ioptr[0] = f0r;
    ioptr[1] = f0i;
    ioptr[2] = f1r;
    ioptr[3] = f1i;
    ioptr[4] = f2r;
    ioptr[5] = f2i;
    ioptr[6] = f3r;
    ioptr[7] = f3i;
}

static void fft8pt(SPFLOAT *ioptr)
{
    /***   RADIX 8 fft      ***/
    SPFLOAT w0r = (SPFLOAT)(1.0 / MYROOT2);    /* cos(pi/4)   */
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[8];
    f1i = ioptr[9];
    f2r = ioptr[4];
    f2i = ioptr[5];
    f3r = ioptr[12];
    f3i = ioptr[13];
    f4r = ioptr[2];
    f4i = ioptr[3];
    f5r = ioptr[10];
    f5i = ioptr[11];
    f6r = ioptr[6];
    f6i = ioptr[7];
    f7r = ioptr[14];
    f7i = ioptr[15];
    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0      -       -       f0
       f1   -  1 -  f1      -       -       f1      -       -       f1
       f2   -       -       f2      -  1 -  f2      -       -       f2
       f3   -  1 -  t1      - -i -  f3      -       -       f3
       f4   -       -       t0      -       -       f4      -  1 -  t0
       f5   -  1 -  f5      -       -       f5      - w3 -  f4
       f6   -       -       f6      -  1 -  f6      - -i -  t1
       f7   -  1 -  t1      - -i -  f7      - iw3-  f6
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f0i - f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = t0i - f2i;

    f3r = f1r - t1i;
    f3i = f1i + t1r;
    f1r = f1r + t1i;
    f1i = f1i - t1r;

    t0r = f4r + f5r;
    t0i = f4i + f5i;
    f5r = f4r - f5r;
    f5i = f4i - f5i;

    t1r = f6r - f7r;
    t1i = f6i - f7i;
    f6r = f6r + f7r;
    f6i = f6i + f7i;

    f4r = t0r + f6r;
    f4i = t0i + f6i;
    f6r = t0r - f6r;
    f6i = t0i - f6i;

    f7r = f5r - t1i;
    f7i = f5i + t1r;
    f5r = f5r + t1i;
    f5i = f5i - t1r;

    t0r = f0r - f4r;
    t0i = f0i - f4i;
    f0r = f0r + f4r;
    f0i = f0i + f4i;

    t1r = f2r - f6i;
    t1i = f2i + f6r;
    f2r = f2r + f6i;
    f2i = f2i - f6r;

    f4r = f1r - f5r * w0r - f5i * w0r;
    f4i = f1i + f5r * w0r - f5i * w0r;
    f1r = f1r * Two - f4r;
    f1i = f1i * Two - f4i;

    f6r = f3r + f7r * w0r - f7i * w0r;
    f6i = f3i + f7r * w0r + f7i * w0r;
    f3r = f3r * Two - f6r;
    f3i = f3i * Two - f6i;

    /* store result */
    ioptr[0] = f0r;
    ioptr[1] = f0i;
    ioptr[2] = f1r;
    ioptr[3] = f1i;
    ioptr[4] = f2r;
    ioptr[5] = f2i;
    ioptr[6] = f3r;
    ioptr[7] = f3i;
    ioptr[8] = t0r;
    ioptr[9] = t0i;
    ioptr[10] = f4r;
    ioptr[11] = f4i;
    ioptr[12] = t1r;
    ioptr[13] = t1i;
    ioptr[14] = f6r;
    ioptr[15] = f6i;
}

static void bfR2(SPFLOAT *ioptr, int M, int NDiffU)
{
    /*** 2nd radix 2 stage ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int NSameU;
    unsigned int SameUCnt;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;

    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 4;
    pos = 2;
    posi = pos + 1;
    NSameU = POW2(M) / 4 / NDiffU;        /* 4 Us at a time */
    pstrt = ioptr;
    p0r = pstrt;
    p1r = pstrt + pinc;
    p2r = p1r + pinc;
    p3r = p2r + pinc;

    /* Butterflys           */
    /*
       f0   -       -       f4
       f1   -  1 -  f5
       f2   -       -       f6
       f3   -  1 -  f7
     */
    /* Butterflys           */
    /*
       f0   -       -       f4
       f1   -  1 -  f5
       f2   -       -       f6
       f3   -  1 -  f7
     */

    for (SameUCnt = NSameU; SameUCnt > 0; SameUCnt--) {

      f0r = *p0r;
      f1r = *p1r;
      f0i = *(p0r + 1);
      f1i = *(p1r + 1);
      f2r = *p2r;
      f3r = *p3r;
      f2i = *(p2r + 1);
      f3i = *(p3r + 1);

      f4r = f0r + f1r;
      f4i = f0i + f1i;
      f5r = f0r - f1r;
      f5i = f0i - f1i;

      f6r = f2r + f3r;
      f6i = f2i + f3i;
      f7r = f2r - f3r;
      f7i = f2i - f3i;

      *p0r = f4r;
      *(p0r + 1) = f4i;
      *p1r = f5r;
      *(p1r + 1) = f5i;
      *p2r = f6r;
      *(p2r + 1) = f6i;
      *p3r = f7r;
      *(p3r + 1) = f7i;

      f0r = *(p0r + pos);
      f1i = *(p1r + posi);
      f0i = *(p0r + posi);
      f1r = *(p1r + pos);
      f2r = *(p2r + pos);
      f3i = *(p3r + posi);
      f2i = *(p2r + posi);
      f3r = *(p3r + pos);

      f4r = f0r + f1i;
      f4i = f0i - f1r;
      f5r = f0r - f1i;
      f5i = f0i + f1r;

      f6r = f2r + f3i;
      f6i = f2i - f3r;
      f7r = f2r - f3i;
      f7i = f2i + f3r;

      *(p0r + pos) = f4r;
      *(p0r + posi) = f4i;
      *(p1r + pos) = f5r;
      *(p1r + posi) = f5i;
      *(p2r + pos) = f6r;
      *(p2r + posi) = f6i;
      *(p3r + pos) = f7r;
      *(p3r + posi) = f7i;

      p0r += pnext;
      p1r += pnext;
      p2r += pnext;
      p3r += pnext;
    }
}

static void bfR4(SPFLOAT *ioptr, int M, int NDiffU)
{
    /*** 1 radix 4 stage ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int pnexti;
    unsigned int NSameU;
    unsigned int SameUCnt;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;

    SPFLOAT w1r = 1.0 / MYROOT2;    /* cos(pi/4)   */
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t1r, t1i;
    const SPFLOAT Two = 2.0;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 4;
    pnexti = pnext + 1;
    pos = 2;
    posi = pos + 1;
    NSameU = POW2(M) / 4 / NDiffU;        /* 4 pts per butterfly */
    pstrt = ioptr;
    p0r = pstrt;
    p1r = pstrt + pinc;
    p2r = p1r + pinc;
    p3r = p2r + pinc;

    /* Butterflys           */
    /*
       f0   -       -       f0      -       -       f4
       f1   -  1 -  f5      -       -       f5
       f2   -       -       f6      -  1 -  f6
       f3   -  1 -  f3      - -i -  f7
     */
    /* Butterflys           */
    /*
       f0   -       -       f4      -       -       f4
       f1   - -i -  t1      -       -       f5
       f2   -       -       f2      - w1 -  f6
       f3   - -i -  f7      - iw1-  f7
     */

    f0r = *p0r;
    f1r = *p1r;
    f2r = *p2r;
    f3r = *p3r;
    f0i = *(p0r + 1);
    f1i = *(p1r + 1);
    f2i = *(p2r + 1);
    f3i = *(p3r + 1);

    f5r = f0r - f1r;
    f5i = f0i - f1i;
    f0r = f0r + f1r;
    f0i = f0i + f1i;

    f6r = f2r + f3r;
    f6i = f2i + f3i;
    f3r = f2r - f3r;
    f3i = f2i - f3i;

    for (SameUCnt = NSameU - 1; SameUCnt > 0; SameUCnt--) {

      f7r = f5r - f3i;
      f7i = f5i + f3r;
      f5r = f5r + f3i;
      f5i = f5i - f3r;

      f4r = f0r + f6r;
      f4i = f0i + f6i;
      f6r = f0r - f6r;
      f6i = f0i - f6i;

      f2r = *(p2r + pos);
      f2i = *(p2r + posi);
      f1r = *(p1r + pos);
      f1i = *(p1r + posi);
      f3i = *(p3r + posi);
      f0r = *(p0r + pos);
      f3r = *(p3r + pos);
      f0i = *(p0r + posi);

      *p3r = f7r;
      *p0r = f4r;
      *(p3r + 1) = f7i;
      *(p0r + 1) = f4i;
      *p1r = f5r;
      *p2r = f6r;
      *(p1r + 1) = f5i;
      *(p2r + 1) = f6i;

      f7r = f2r - f3i;
      f7i = f2i + f3r;
      f2r = f2r + f3i;
      f2i = f2i - f3r;

      f4r = f0r + f1i;
      f4i = f0i - f1r;
      t1r = f0r - f1i;
      t1i = f0i + f1r;

      f5r = t1r - f7r * w1r + f7i * w1r;
      f5i = t1i - f7r * w1r - f7i * w1r;
      f7r = t1r * Two - f5r;
      f7i = t1i * Two - f5i;

      f6r = f4r - f2r * w1r - f2i * w1r;
      f6i = f4i + f2r * w1r - f2i * w1r;
      f4r = f4r * Two - f6r;
      f4i = f4i * Two - f6i;

      f3r = *(p3r + pnext);
      f0r = *(p0r + pnext);
      f3i = *(p3r + pnexti);
      f0i = *(p0r + pnexti);
      f2r = *(p2r + pnext);
      f2i = *(p2r + pnexti);
      f1r = *(p1r + pnext);
      f1i = *(p1r + pnexti);

      *(p2r + pos) = f6r;
      *(p1r + pos) = f5r;
      *(p2r + posi) = f6i;
      *(p1r + posi) = f5i;
      *(p3r + pos) = f7r;
      *(p0r + pos) = f4r;
      *(p3r + posi) = f7i;
      *(p0r + posi) = f4i;

      f6r = f2r + f3r;
      f6i = f2i + f3i;
      f3r = f2r - f3r;
      f3i = f2i - f3i;

      f5r = f0r - f1r;
      f5i = f0i - f1i;
      f0r = f0r + f1r;
      f0i = f0i + f1i;

      p3r += pnext;
      p0r += pnext;
      p1r += pnext;
      p2r += pnext;
    }
    f7r = f5r - f3i;
    f7i = f5i + f3r;
    f5r = f5r + f3i;
    f5i = f5i - f3r;

    f4r = f0r + f6r;
    f4i = f0i + f6i;
    f6r = f0r - f6r;
    f6i = f0i - f6i;

    f2r = *(p2r + pos);
    f2i = *(p2r + posi);
    f1r = *(p1r + pos);
    f1i = *(p1r + posi);
    f3i = *(p3r + posi);
    f0r = *(p0r + pos);
    f3r = *(p3r + pos);
    f0i = *(p0r + posi);

    *p3r = f7r;
    *p0r = f4r;
    *(p3r + 1) = f7i;
    *(p0r + 1) = f4i;
    *p1r = f5r;
    *p2r = f6r;
    *(p1r + 1) = f5i;
    *(p2r + 1) = f6i;

    f7r = f2r - f3i;
    f7i = f2i + f3r;
    f2r = f2r + f3i;
    f2i = f2i - f3r;

    f4r = f0r + f1i;
    f4i = f0i - f1r;
    t1r = f0r - f1i;
    t1i = f0i + f1r;

    f5r = t1r - f7r * w1r + f7i * w1r;
    f5i = t1i - f7r * w1r - f7i * w1r;
    f7r = t1r * Two - f5r;
    f7i = t1i * Two - f5i;

    f6r = f4r - f2r * w1r - f2i * w1r;
    f6i = f4i + f2r * w1r - f2i * w1r;
    f4r = f4r * Two - f6r;
    f4i = f4i * Two - f6i;

    *(p2r + pos) = f6r;
    *(p1r + pos) = f5r;
    *(p2r + posi) = f6i;
    *(p1r + posi) = f5i;
    *(p3r + pos) = f7r;
    *(p0r + pos) = f4r;
    *(p3r + posi) = f7i;
    *(p0r + posi) = f4i;
}

static void bfstages(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int Ustride,
                     int NDiffU, int StageCnt)
{
    /***   RADIX 8 Stages   ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int NSameU;
    int          Uinc;
    int          Uinc2;
    int          Uinc4;
    unsigned int DiffUCnt;
    unsigned int SameUCnt;
    unsigned int U2toU3;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;
    SPFLOAT *u0r, *u0i, *u1r, *u1i, *u2r, *u2i;

    SPFLOAT w0r, w0i, w1r, w1i, w2r, w2i, w3r, w3i;
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 8;
    pos = pinc * 4;
    posi = pos + 1;
    NSameU = POW2(M) / 8 / NDiffU;        /* 8 pts per butterfly */
    Uinc = (int) NSameU * Ustride;
    Uinc2 = Uinc * 2;
    Uinc4 = Uinc * 4;
    U2toU3 = (POW2(M) / 8) * Ustride;
    for (; StageCnt > 0; StageCnt--) {

      u0r = &Utbl[0];
      u0i = &Utbl[POW2(M - 2) * Ustride];
      u1r = u0r;
      u1i = u0i;
      u2r = u0r;
      u2i = u0i;

      w0r = *u0r;
      w0i = *u0i;
      w1r = *u1r;
      w1i = *u1i;
      w2r = *u2r;
      w2i = *u2i;
      w3r = *(u2r + U2toU3);
      w3i = *(u2i - U2toU3);

      pstrt = ioptr;

      p0r = pstrt;
      p1r = pstrt + pinc;
      p2r = p1r + pinc;
      p3r = p2r + pinc;

      /* Butterflys           */
      /*
         f0   -       -       t0      -       -       f0      -       -       f0
         f1   - w0-   f1      -       -       f1      -       -       f1
         f2   -       -       f2      - w1-   f2      -       -       f4
         f3   - w0-   t1      - iw1-  f3      -       -       f5

         f4   -       -       t0      -       -       f4      - w2-   t0
         f5   - w0-   f5      -       -       f5      - w3-   t1
         f6   -       -       f6      - w1-   f6      - iw2-  f6
         f7   - w0-   t1      - iw1-  f7      - iw3-  f7
       */

      for (DiffUCnt = NDiffU; DiffUCnt > 0; DiffUCnt--) {
        f0r = *p0r;
        f0i = *(p0r + 1);
        f1r = *p1r;
        f1i = *(p1r + 1);
        for (SameUCnt = NSameU - 1; SameUCnt > 0; SameUCnt--) {
          f2r = *p2r;
          f2i = *(p2r + 1);
          f3r = *p3r;
          f3i = *(p3r + 1);

          t0r = f0r + f1r * w0r + f1i * w0i;
          t0i = f0i - f1r * w0i + f1i * w0r;
          f1r = f0r * Two - t0r;
          f1i = f0i * Two - t0i;

          f4r = *(p0r + pos);
          f4i = *(p0r + posi);
          f5r = *(p1r + pos);
          f5i = *(p1r + posi);

          f6r = *(p2r + pos);
          f6i = *(p2r + posi);
          f7r = *(p3r + pos);
          f7i = *(p3r + posi);

          t1r = f2r - f3r * w0r - f3i * w0i;
          t1i = f2i + f3r * w0i - f3i * w0r;
          f2r = f2r * Two - t1r;
          f2i = f2i * Two - t1i;

          f0r = t0r + f2r * w1r + f2i * w1i;
          f0i = t0i - f2r * w1i + f2i * w1r;
          f2r = t0r * Two - f0r;
          f2i = t0i * Two - f0i;

          f3r = f1r + t1r * w1i - t1i * w1r;
          f3i = f1i + t1r * w1r + t1i * w1i;
          f1r = f1r * Two - f3r;
          f1i = f1i * Two - f3i;

          t0r = f4r + f5r * w0r + f5i * w0i;
          t0i = f4i - f5r * w0i + f5i * w0r;
          f5r = f4r * Two - t0r;
          f5i = f4i * Two - t0i;

          t1r = f6r - f7r * w0r - f7i * w0i;
          t1i = f6i + f7r * w0i - f7i * w0r;
          f6r = f6r * Two - t1r;
          f6i = f6i * Two - t1i;

          f4r = t0r + f6r * w1r + f6i * w1i;
          f4i = t0i - f6r * w1i + f6i * w1r;
          f6r = t0r * Two - f4r;
          f6i = t0i * Two - f4i;

          f7r = f5r + t1r * w1i - t1i * w1r;
          f7i = f5i + t1r * w1r + t1i * w1i;
          f5r = f5r * Two - f7r;
          f5i = f5i * Two - f7i;

          t0r = f0r - f4r * w2r - f4i * w2i;
          t0i = f0i + f4r * w2i - f4i * w2r;
          f0r = f0r * Two - t0r;
          f0i = f0i * Two - t0i;

          t1r = f1r - f5r * w3r - f5i * w3i;
          t1i = f1i + f5r * w3i - f5i * w3r;
          f1r = f1r * Two - t1r;
          f1i = f1i * Two - t1i;

          *(p0r + pos) = t0r;
          *(p1r + pos) = t1r;
          *(p0r + posi) = t0i;
          *(p1r + posi) = t1i;
          *p0r = f0r;
          *p1r = f1r;
          *(p0r + 1) = f0i;
          *(p1r + 1) = f1i;

          p0r += pnext;
          f0r = *p0r;
          f0i = *(p0r + 1);

          p1r += pnext;

          f1r = *p1r;
          f1i = *(p1r + 1);

          f4r = f2r - f6r * w2i + f6i * w2r;
          f4i = f2i - f6r * w2r - f6i * w2i;
          f6r = f2r * Two - f4r;
          f6i = f2i * Two - f4i;

          f5r = f3r - f7r * w3i + f7i * w3r;
          f5i = f3i - f7r * w3r - f7i * w3i;
          f7r = f3r * Two - f5r;
          f7i = f3i * Two - f5i;

          *p2r = f4r;
          *p3r = f5r;
          *(p2r + 1) = f4i;
          *(p3r + 1) = f5i;
          *(p2r + pos) = f6r;
          *(p3r + pos) = f7r;
          *(p2r + posi) = f6i;
          *(p3r + posi) = f7i;

          p2r += pnext;
          p3r += pnext;
        }

        f2r = *p2r;
        f2i = *(p2r + 1);
        f3r = *p3r;
        f3i = *(p3r + 1);

        t0r = f0r + f1r * w0r + f1i * w0i;
        t0i = f0i - f1r * w0i + f1i * w0r;
        f1r = f0r * Two - t0r;
        f1i = f0i * Two - t0i;

        f4r = *(p0r + pos);
        f4i = *(p0r + posi);
        f5r = *(p1r + pos);
        f5i = *(p1r + posi);

        f6r = *(p2r + pos);
        f6i = *(p2r + posi);
        f7r = *(p3r + pos);
        f7i = *(p3r + posi);

        t1r = f2r - f3r * w0r - f3i * w0i;
        t1i = f2i + f3r * w0i - f3i * w0r;
        f2r = f2r * Two - t1r;
        f2i = f2i * Two - t1i;

        f0r = t0r + f2r * w1r + f2i * w1i;
        f0i = t0i - f2r * w1i + f2i * w1r;
        f2r = t0r * Two - f0r;
        f2i = t0i * Two - f0i;

        f3r = f1r + t1r * w1i - t1i * w1r;
        f3i = f1i + t1r * w1r + t1i * w1i;
        f1r = f1r * Two - f3r;
        f1i = f1i * Two - f3i;

        if ((int) DiffUCnt == NDiffU / 2)
          Uinc4 = -Uinc4;

        u0r += Uinc4;
        u0i -= Uinc4;
        u1r += Uinc2;
        u1i -= Uinc2;
        u2r += Uinc;
        u2i -= Uinc;

        pstrt += 2;

        t0r = f4r + f5r * w0r + f5i * w0i;
        t0i = f4i - f5r * w0i + f5i * w0r;
        f5r = f4r * Two - t0r;
        f5i = f4i * Two - t0i;

        t1r = f6r - f7r * w0r - f7i * w0i;
        t1i = f6i + f7r * w0i - f7i * w0r;
        f6r = f6r * Two - t1r;
        f6i = f6i * Two - t1i;

        f4r = t0r + f6r * w1r + f6i * w1i;
        f4i = t0i - f6r * w1i + f6i * w1r;
        f6r = t0r * Two - f4r;
        f6i = t0i * Two - f4i;

        f7r = f5r + t1r * w1i - t1i * w1r;
        f7i = f5i + t1r * w1r + t1i * w1i;
        f5r = f5r * Two - f7r;
        f5i = f5i * Two - f7i;

        w0r = *u0r;
        w0i = *u0i;
        w1r = *u1r;
        w1i = *u1i;

        if ((int) DiffUCnt <= NDiffU / 2)
          w0r = -w0r;

        t0r = f0r - f4r * w2r - f4i * w2i;
        t0i = f0i + f4r * w2i - f4i * w2r;
        f0r = f0r * Two - t0r;
        f0i = f0i * Two - t0i;

        f4r = f2r - f6r * w2i + f6i * w2r;
        f4i = f2i - f6r * w2r - f6i * w2i;
        f6r = f2r * Two - f4r;
        f6i = f2i * Two - f4i;

        *(p0r + pos) = t0r;
        *p2r = f4r;
        *(p0r + posi) = t0i;
        *(p2r + 1) = f4i;
        w2r = *u2r;
        w2i = *u2i;
        *p0r = f0r;
        *(p2r + pos) = f6r;
        *(p0r + 1) = f0i;
        *(p2r + posi) = f6i;

        p0r = pstrt;
        p2r = pstrt + pinc + pinc;

        t1r = f1r - f5r * w3r - f5i * w3i;
        t1i = f1i + f5r * w3i - f5i * w3r;
        f1r = f1r * Two - t1r;
        f1i = f1i * Two - t1i;

        f5r = f3r - f7r * w3i + f7i * w3r;
        f5i = f3i - f7r * w3r - f7i * w3i;
        f7r = f3r * Two - f5r;
        f7i = f3i * Two - f5i;

        *(p1r + pos) = t1r;
        *p3r = f5r;
        *(p1r + posi) = t1i;
        *(p3r + 1) = f5i;
        w3r = *(u2r + U2toU3);
        w3i = *(u2i - U2toU3);
        *p1r = f1r;
        *(p3r + pos) = f7r;
        *(p1r + 1) = f1i;
        *(p3r + posi) = f7i;

        p1r = pstrt + pinc;
        p3r = p2r + pinc;
      }
      NSameU /= 8;
      Uinc /= 8;
      Uinc2 /= 8;
      Uinc4 = Uinc * 4;
      NDiffU *= 8;
      pinc *= 8;
      pnext *= 8;
      pos *= 8;
      posi = pos + 1;
    }
}

static void fftrecurs(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int Ustride, int NDiffU,
                      int StageCnt)
{
    /* recursive bfstages calls to maximize on chip cache efficiency */
    int i1;

    if (M <= (int) MCACHE)              /* fits on chip ? */
      bfstages(ioptr, M, Utbl, Ustride, NDiffU, StageCnt); /* RADIX 8 Stages */
    else {
      for (i1 = 0; i1 < 8; i1++) {
        fftrecurs(&ioptr[i1 * POW2(M - 3) * 2], M - 3, Utbl, 8 * Ustride,
                  NDiffU, StageCnt - 1);  /*  RADIX 8 Stages      */
      }
      bfstages(ioptr, M, Utbl, Ustride, POW2(M - 3), 1);  /*  RADIX 8 Stage */
    }
}

static void ffts1(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int16_t *BRLow)
{
    /* Compute in-place complex fft on the rows of the input array  */
    /* INPUTS                                                       */
    /*   *ioptr = input data array                                  */
    /*   M = log2 of fft size (ex M=10 for 1024 point fft)          */
    /*   *Utbl = cosine table                                       */
    /*   *BRLow = bit reversed counter table                        */
    /* OUTPUTS                                                      */
    /*   *ioptr = output data array                                 */

    int StageCnt;
    int NDiffU;

    switch (M) {
    case 0:
      break;
    case 1:
      fft2pt(ioptr);            /* a 2 pt fft */
      break;
    case 2:
      fft4pt(ioptr);            /* a 4 pt fft */
      break;
    case 3:
      fft8pt(ioptr);            /* an 8 pt fft */
      break;
    default:
      bitrevR2(ioptr, M, BRLow);  /* bit reverse and first radix 2 stage */
      StageCnt = (M - 1) / 3;     /* number of radix 8 stages           */
      NDiffU = 2;                 /* one radix 2 stage already complete */
      if ((M - 1 - (StageCnt * 3)) == 1) {
        bfR2(ioptr, M, NDiffU); /* 1 radix 2 stage */
        NDiffU *= 2;
      }
      if ((M - 1 - (StageCnt * 3)) == 2) {
        bfR4(ioptr, M, NDiffU); /* 1 radix 4 stage */
        NDiffU *= 4;
      }
      if (M <= (int) MCACHE)
        bfstages(ioptr, M, Utbl, 1, NDiffU, StageCnt);  /* RADIX 8 Stages */
      else
        fftrecurs(ioptr, M, Utbl, 1, NDiffU, StageCnt); /* RADIX 8 Stages */
    }
}

/******************
* parts of iffts1 *
******************/

static void scbitrevR2(SPFLOAT *ioptr, int M, int16_t *BRLow, SPFLOAT scale)
{
    /*** scaled bit reverse and first radix 2 stage forward or inverse fft ***/
    SPFLOAT f0r;
    SPFLOAT f0i;
    SPFLOAT f1r;
    SPFLOAT f1i;
    SPFLOAT f2r;
    SPFLOAT f2i;
    SPFLOAT f3r;
    SPFLOAT f3i;
    SPFLOAT f4r;
    SPFLOAT f4i;
    SPFLOAT f5r;
    SPFLOAT f5i;
    SPFLOAT f6r;
    SPFLOAT f6i;
    SPFLOAT f7r;
    SPFLOAT f7i;
    SPFLOAT t0r;
    SPFLOAT t0i;
    SPFLOAT t1r;
    SPFLOAT t1i;
    SPFLOAT *p0r;
    SPFLOAT *p1r;
    SPFLOAT *IOP;
    SPFLOAT *iolimit;
    int Colstart;
    int iCol;
    unsigned int posA;
    unsigned int posAi;
    unsigned int posB;
    unsigned int posBi;

    const unsigned int Nrems2 = POW2((M + 3) / 2);
    const unsigned int Nroot_1_ColInc = POW2(M) - Nrems2;
    const unsigned int Nroot_1 = POW2(M / 2 - 1) - 1;
    const unsigned int ColstartShift = (M + 1) / 2 + 1;

    posA = POW2(M);               /* 1/2 of POW2(M) complexes */
    posAi = posA + 1;
    posB = posA + 2;
    posBi = posB + 1;

    iolimit = ioptr + Nrems2;
    for (; ioptr < iolimit; ioptr += POW2(M / 2 + 1)) {
      for (Colstart = Nroot_1; Colstart >= 0; Colstart--) {
        iCol = Nroot_1;
        p0r = ioptr + Nroot_1_ColInc + BRLow[Colstart] * 4;
        IOP = ioptr + (Colstart << ColstartShift);
        p1r = IOP + BRLow[iCol] * 4;
        f0r = *(p0r);
        f0i = *(p0r + 1);
        f1r = *(p0r + posA);
        f1i = *(p0r + posAi);
        for (; iCol > Colstart;) {
          f2r = *(p0r + 2);
          f2i = *(p0r + (2 + 1));
          f3r = *(p0r + posB);
          f3i = *(p0r + posBi);
          f4r = *(p1r);
          f4i = *(p1r + 1);
          f5r = *(p1r + posA);
          f5i = *(p1r + posAi);
          f6r = *(p1r + 2);
          f6i = *(p1r + (2 + 1));
          f7r = *(p1r + posB);
          f7i = *(p1r + posBi);

          t0r = f0r + f1r;
          t0i = f0i + f1i;
          f1r = f0r - f1r;
          f1i = f0i - f1i;
          t1r = f2r + f3r;
          t1i = f2i + f3i;
          f3r = f2r - f3r;
          f3i = f2i - f3i;
          f0r = f4r + f5r;
          f0i = f4i + f5i;
          f5r = f4r - f5r;
          f5i = f4i - f5i;
          f2r = f6r + f7r;
          f2i = f6i + f7i;
          f7r = f6r - f7r;
          f7i = f6i - f7i;

          *(p1r) = scale * t0r;
          *(p1r + 1) = scale * t0i;
          *(p1r + 2) = scale * f1r;
          *(p1r + (2 + 1)) = scale * f1i;
          *(p1r + posA) = scale * t1r;
          *(p1r + posAi) = scale * t1i;
          *(p1r + posB) = scale * f3r;
          *(p1r + posBi) = scale * f3i;
          *(p0r) = scale * f0r;
          *(p0r + 1) = scale * f0i;
          *(p0r + 2) = scale * f5r;
          *(p0r + (2 + 1)) = scale * f5i;
          *(p0r + posA) = scale * f2r;
          *(p0r + posAi) = scale * f2i;
          *(p0r + posB) = scale * f7r;
          *(p0r + posBi) = scale * f7i;

          p0r -= Nrems2;
          f0r = *(p0r);
          f0i = *(p0r + 1);
          f1r = *(p0r + posA);
          f1i = *(p0r + posAi);
          iCol -= 1;
          p1r = IOP + BRLow[iCol] * 4;
        }
        f2r = *(p0r + 2);
        f2i = *(p0r + (2 + 1));
        f3r = *(p0r + posB);
        f3i = *(p0r + posBi);

        t0r = f0r + f1r;
        t0i = f0i + f1i;
        f1r = f0r - f1r;
        f1i = f0i - f1i;
        t1r = f2r + f3r;
        t1i = f2i + f3i;
        f3r = f2r - f3r;
        f3i = f2i - f3i;

        *(p0r) = scale * t0r;
        *(p0r + 1) = scale * t0i;
        *(p0r + 2) = scale * f1r;
        *(p0r + (2 + 1)) = scale * f1i;
        *(p0r + posA) = scale * t1r;
        *(p0r + posAi) = scale * t1i;
        *(p0r + posB) = scale * f3r;
        *(p0r + posBi) = scale * f3i;
      }
    }
}

//static void ifft2pt(SPFLOAT *ioptr, SPFLOAT scale)
//{
//    /***   RADIX 2 ifft     ***/
//    SPFLOAT f0r, f0i, f1r, f1i;
//    SPFLOAT t0r, t0i;
//
//    /* bit reversed load */
//    f0r = ioptr[0];
//    f0i = ioptr[1];
//    f1r = ioptr[2];
//    f1i = ioptr[3];
//
//    /* Butterflys           */
//    /*
//       f0   -       -       t0
//       f1   -  1 -  f1
//     */
//
//    t0r = f0r + f1r;
//    t0i = f0i + f1i;
//    f1r = f0r - f1r;
//    f1i = f0i - f1i;
//
//    /* store result */
//    ioptr[0] = scale * t0r;
//    ioptr[1] = scale * t0i;
//    ioptr[2] = scale * f1r;
//    ioptr[3] = scale * f1i;
//}
//
//static void ifft4pt(SPFLOAT *ioptr, SPFLOAT scale)
//{
//    /***   RADIX 4 ifft     ***/
//    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
//    SPFLOAT t0r, t0i, t1r, t1i;
//
//    /* bit reversed load */
//    f0r = ioptr[0];
//    f0i = ioptr[1];
//    f1r = ioptr[4];
//    f1i = ioptr[5];
//    f2r = ioptr[2];
//    f2i = ioptr[3];
//    f3r = ioptr[6];
//    f3i = ioptr[7];
//
//    /* Butterflys           */
//    /*
//       f0   -       -       t0      -       -       f0
//       f1   -  1 -  f1      -       -       f1
//       f2   -       -       f2      -  1 -  f2
//       f3   -  1 -  t1      -  i -  f3
//     */
//
//    t0r = f0r + f1r;
//    t0i = f0i + f1i;
//    f1r = f0r - f1r;
//    f1i = f0i - f1i;
//
//    t1r = f2r - f3r;
//    t1i = f2i - f3i;
//    f2r = f2r + f3r;
//    f2i = f2i + f3i;
//
//    f0r = t0r + f2r;
//    f0i = t0i + f2i;
//    f2r = t0r - f2r;
//    f2i = t0i - f2i;
//
//    f3r = f1r + t1i;
//    f3i = f1i - t1r;
//    f1r = f1r - t1i;
//    f1i = f1i + t1r;
//
//    /* store result */
//    ioptr[0] = scale * f0r;
//    ioptr[1] = scale * f0i;
//    ioptr[2] = scale * f1r;
//    ioptr[3] = scale * f1i;
//    ioptr[4] = scale * f2r;
//    ioptr[5] = scale * f2i;
//    ioptr[6] = scale * f3r;
//    ioptr[7] = scale * f3i;
//}
//
//static void ifft8pt(SPFLOAT *ioptr, SPFLOAT scale)
//{
//    /***   RADIX 8 ifft     ***/
//    SPFLOAT w0r = 1.0 / MYROOT2;    /* cos(pi/4)   */
//    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
//    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
//    SPFLOAT t0r, t0i, t1r, t1i;
//    const SPFLOAT Two = 2.0;
//
//    /* bit reversed load */
//    f0r = ioptr[0];
//    f0i = ioptr[1];
//    f1r = ioptr[8];
//    f1i = ioptr[9];
//    f2r = ioptr[4];
//    f2i = ioptr[5];
//    f3r = ioptr[12];
//    f3i = ioptr[13];
//    f4r = ioptr[2];
//    f4i = ioptr[3];
//    f5r = ioptr[10];
//    f5i = ioptr[11];
//    f6r = ioptr[6];
//    f6i = ioptr[7];
//    f7r = ioptr[14];
//    f7i = ioptr[15];
//
//    /* Butterflys           */
//    /*
//       f0   -       -       t0      -       -       f0      -       -       f0
//       f1   -  1 -  f1      -       -       f1      -       -       f1
//       f2   -       -       f2      -  1 -  f2      -       -       f2
//       f3   -  1 -  t1      -  i -  f3      -       -       f3
//       f4   -       -       t0      -       -       f4      -  1 -  t0
//       f5   -  1 -  f5      -       -       f5      - w3 -  f4
//       f6   -       -       f6      -  1 -  f6      -  i -  t1
//       f7   -  1 -  t1      -  i -  f7      - iw3-  f6
//     */
//
//    t0r = f0r + f1r;
//    t0i = f0i + f1i;
//    f1r = f0r - f1r;
//    f1i = f0i - f1i;
//
//    t1r = f2r - f3r;
//    t1i = f2i - f3i;
//    f2r = f2r + f3r;
//    f2i = f2i + f3i;
//
//    f0r = t0r + f2r;
//    f0i = t0i + f2i;
//    f2r = t0r - f2r;
//    f2i = t0i - f2i;
//
//    f3r = f1r + t1i;
//    f3i = f1i - t1r;
//    f1r = f1r - t1i;
//    f1i = f1i + t1r;
//
//    t0r = f4r + f5r;
//    t0i = f4i + f5i;
//    f5r = f4r - f5r;
//    f5i = f4i - f5i;
//
//    t1r = f6r - f7r;
//    t1i = f6i - f7i;
//    f6r = f6r + f7r;
//    f6i = f6i + f7i;
//
//    f4r = t0r + f6r;
//    f4i = t0i + f6i;
//    f6r = t0r - f6r;
//    f6i = t0i - f6i;
//
//    f7r = f5r + t1i;
//    f7i = f5i - t1r;
//    f5r = f5r - t1i;
//    f5i = f5i + t1r;
//
//    t0r = f0r - f4r;
//    t0i = f0i - f4i;
//    f0r = f0r + f4r;
//    f0i = f0i + f4i;
//
//    t1r = f2r + f6i;
//    t1i = f2i - f6r;
//    f2r = f2r - f6i;
//    f2i = f2i + f6r;
//
//    f4r = f1r - f5r * w0r + f5i * w0r;
//    f4i = f1i - f5r * w0r - f5i * w0r;
//    f1r = f1r * Two - f4r;
//    f1i = f1i * Two - f4i;
//
//    f6r = f3r + f7r * w0r + f7i * w0r;
//    f6i = f3i - f7r * w0r + f7i * w0r;
//    f3r = f3r * Two - f6r;
//    f3i = f3i * Two - f6i;
//
//    /* store result */
//    ioptr[0] = scale * f0r;
//    ioptr[1] = scale * f0i;
//    ioptr[2] = scale * f1r;
//    ioptr[3] = scale * f1i;
//    ioptr[4] = scale * f2r;
//    ioptr[5] = scale * f2i;
//    ioptr[6] = scale * f3r;
//    ioptr[7] = scale * f3i;
//    ioptr[8] = scale * t0r;
//    ioptr[9] = scale * t0i;
//    ioptr[10] = scale * f4r;
//    ioptr[11] = scale * f4i;
//    ioptr[12] = scale * t1r;
//    ioptr[13] = scale * t1i;
//    ioptr[14] = scale * f6r;
//    ioptr[15] = scale * f6i;
//}

static void ibfR2(SPFLOAT *ioptr, int M, int NDiffU)
{
    /*** 2nd radix 2 stage ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int NSameU;
    unsigned int SameUCnt;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;

    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 4;
    pos = 2;
    posi = pos + 1;
    NSameU = POW2(M) / 4 / NDiffU;        /* 4 Us at a time */
    pstrt = ioptr;
    p0r = pstrt;
    p1r = pstrt + pinc;
    p2r = p1r + pinc;
    p3r = p2r + pinc;

    /* Butterflys           */
    /*
       f0   -       -       f4
       f1   -  1 -  f5
       f2   -       -       f6
       f3   -  1 -  f7
     */
    /* Butterflys           */
    /*
       f0   -       -       f4
       f1   -  1 -  f5
       f2   -       -       f6
       f3   -  1 -  f7
     */

    for (SameUCnt = NSameU; SameUCnt > 0; SameUCnt--) {

      f0r = *p0r;
      f1r = *p1r;
      f0i = *(p0r + 1);
      f1i = *(p1r + 1);
      f2r = *p2r;
      f3r = *p3r;
      f2i = *(p2r + 1);
      f3i = *(p3r + 1);

      f4r = f0r + f1r;
      f4i = f0i + f1i;
      f5r = f0r - f1r;
      f5i = f0i - f1i;

      f6r = f2r + f3r;
      f6i = f2i + f3i;
      f7r = f2r - f3r;
      f7i = f2i - f3i;

      *p0r = f4r;
      *(p0r + 1) = f4i;
      *p1r = f5r;
      *(p1r + 1) = f5i;
      *p2r = f6r;
      *(p2r + 1) = f6i;
      *p3r = f7r;
      *(p3r + 1) = f7i;

      f0r = *(p0r + pos);
      f1i = *(p1r + posi);
      f0i = *(p0r + posi);
      f1r = *(p1r + pos);
      f2r = *(p2r + pos);
      f3i = *(p3r + posi);
      f2i = *(p2r + posi);
      f3r = *(p3r + pos);

      f4r = f0r - f1i;
      f4i = f0i + f1r;
      f5r = f0r + f1i;
      f5i = f0i - f1r;

      f6r = f2r - f3i;
      f6i = f2i + f3r;
      f7r = f2r + f3i;
      f7i = f2i - f3r;

      *(p0r + pos) = f4r;
      *(p0r + posi) = f4i;
      *(p1r + pos) = f5r;
      *(p1r + posi) = f5i;
      *(p2r + pos) = f6r;
      *(p2r + posi) = f6i;
      *(p3r + pos) = f7r;
      *(p3r + posi) = f7i;

      p0r += pnext;
      p1r += pnext;
      p2r += pnext;
      p3r += pnext;
    }
}

static void ibfR4(SPFLOAT *ioptr, int M, int NDiffU)
{
    /*** 1 radix 4 stage ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int pnexti;
    unsigned int NSameU;
    unsigned int SameUCnt;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;

    SPFLOAT w1r = 1.0 / MYROOT2;    /* cos(pi/4)   */
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t1r, t1i;
    const SPFLOAT Two = 2.0;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 4;
    pnexti = pnext + 1;
    pos = 2;
    posi = pos + 1;
    NSameU = POW2(M) / 4 / NDiffU;        /* 4 pts per butterfly */
    pstrt = ioptr;
    p0r = pstrt;
    p1r = pstrt + pinc;
    p2r = p1r + pinc;
    p3r = p2r + pinc;

    /* Butterflys           */
    /*
       f0   -       -       f0      -       -       f4
       f1   -  1 -  f5      -       -       f5
       f2   -       -       f6      -  1 -  f6
       f3   -  1 -  f3      - -i -  f7
     */
    /* Butterflys           */
    /*
       f0   -       -       f4      -       -       f4
       f1   - -i -  t1      -       -       f5
       f2   -       -       f2      - w1 -  f6
       f3   - -i -  f7      - iw1-  f7
     */

    f0r = *p0r;
    f1r = *p1r;
    f2r = *p2r;
    f3r = *p3r;
    f0i = *(p0r + 1);
    f1i = *(p1r + 1);
    f2i = *(p2r + 1);
    f3i = *(p3r + 1);

    f5r = f0r - f1r;
    f5i = f0i - f1i;
    f0r = f0r + f1r;
    f0i = f0i + f1i;

    f6r = f2r + f3r;
    f6i = f2i + f3i;
    f3r = f2r - f3r;
    f3i = f2i - f3i;

    for (SameUCnt = NSameU - 1; SameUCnt > 0; SameUCnt--) {

      f7r = f5r + f3i;
      f7i = f5i - f3r;
      f5r = f5r - f3i;
      f5i = f5i + f3r;

      f4r = f0r + f6r;
      f4i = f0i + f6i;
      f6r = f0r - f6r;
      f6i = f0i - f6i;

      f2r = *(p2r + pos);
      f2i = *(p2r + posi);
      f1r = *(p1r + pos);
      f1i = *(p1r + posi);
      f3i = *(p3r + posi);
      f0r = *(p0r + pos);
      f3r = *(p3r + pos);
      f0i = *(p0r + posi);

      *p3r = f7r;
      *p0r = f4r;
      *(p3r + 1) = f7i;
      *(p0r + 1) = f4i;
      *p1r = f5r;
      *p2r = f6r;
      *(p1r + 1) = f5i;
      *(p2r + 1) = f6i;

      f7r = f2r + f3i;
      f7i = f2i - f3r;
      f2r = f2r - f3i;
      f2i = f2i + f3r;

      f4r = f0r - f1i;
      f4i = f0i + f1r;
      t1r = f0r + f1i;
      t1i = f0i - f1r;

      f5r = t1r - f7r * w1r - f7i * w1r;
      f5i = t1i + f7r * w1r - f7i * w1r;
      f7r = t1r * Two - f5r;
      f7i = t1i * Two - f5i;

      f6r = f4r - f2r * w1r + f2i * w1r;
      f6i = f4i - f2r * w1r - f2i * w1r;
      f4r = f4r * Two - f6r;
      f4i = f4i * Two - f6i;

      f3r = *(p3r + pnext);
      f0r = *(p0r + pnext);
      f3i = *(p3r + pnexti);
      f0i = *(p0r + pnexti);
      f2r = *(p2r + pnext);
      f2i = *(p2r + pnexti);
      f1r = *(p1r + pnext);
      f1i = *(p1r + pnexti);

      *(p2r + pos) = f6r;
      *(p1r + pos) = f5r;
      *(p2r + posi) = f6i;
      *(p1r + posi) = f5i;
      *(p3r + pos) = f7r;
      *(p0r + pos) = f4r;
      *(p3r + posi) = f7i;
      *(p0r + posi) = f4i;

      f6r = f2r + f3r;
      f6i = f2i + f3i;
      f3r = f2r - f3r;
      f3i = f2i - f3i;

      f5r = f0r - f1r;
      f5i = f0i - f1i;
      f0r = f0r + f1r;
      f0i = f0i + f1i;

      p3r += pnext;
      p0r += pnext;
      p1r += pnext;
      p2r += pnext;
    }
    f7r = f5r + f3i;
    f7i = f5i - f3r;
    f5r = f5r - f3i;
    f5i = f5i + f3r;

    f4r = f0r + f6r;
    f4i = f0i + f6i;
    f6r = f0r - f6r;
    f6i = f0i - f6i;

    f2r = *(p2r + pos);
    f2i = *(p2r + posi);
    f1r = *(p1r + pos);
    f1i = *(p1r + posi);
    f3i = *(p3r + posi);
    f0r = *(p0r + pos);
    f3r = *(p3r + pos);
    f0i = *(p0r + posi);

    *p3r = f7r;
    *p0r = f4r;
    *(p3r + 1) = f7i;
    *(p0r + 1) = f4i;
    *p1r = f5r;
    *p2r = f6r;
    *(p1r + 1) = f5i;
    *(p2r + 1) = f6i;

    f7r = f2r + f3i;
    f7i = f2i - f3r;
    f2r = f2r - f3i;
    f2i = f2i + f3r;

    f4r = f0r - f1i;
    f4i = f0i + f1r;
    t1r = f0r + f1i;
    t1i = f0i - f1r;

    f5r = t1r - f7r * w1r - f7i * w1r;
    f5i = t1i + f7r * w1r - f7i * w1r;
    f7r = t1r * Two - f5r;
    f7i = t1i * Two - f5i;

    f6r = f4r - f2r * w1r + f2i * w1r;
    f6i = f4i - f2r * w1r - f2i * w1r;
    f4r = f4r * Two - f6r;
    f4i = f4i * Two - f6i;

    *(p2r + pos) = f6r;
    *(p1r + pos) = f5r;
    *(p2r + posi) = f6i;
    *(p1r + posi) = f5i;
    *(p3r + pos) = f7r;
    *(p0r + pos) = f4r;
    *(p3r + posi) = f7i;
    *(p0r + posi) = f4i;
}

static void ibfstages(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int Ustride,
                      int NDiffU, int StageCnt)
{
    /***   RADIX 8 Stages   ***/
    unsigned int pos;
    unsigned int posi;
    unsigned int pinc;
    unsigned int pnext;
    unsigned int NSameU;
    int          Uinc;
    int          Uinc2;
    int          Uinc4;
    unsigned int DiffUCnt;
    unsigned int SameUCnt;
    unsigned int U2toU3;

    SPFLOAT *pstrt;
    SPFLOAT *p0r, *p1r, *p2r, *p3r;
    SPFLOAT *u0r, *u0i, *u1r, *u1i, *u2r, *u2i;

    SPFLOAT w0r, w0i, w1r, w1i, w2r, w2i, w3r, w3i;
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    pinc = NDiffU * 2;            /* 2 floats per complex */
    pnext = pinc * 8;
    pos = pinc * 4;
    posi = pos + 1;
    NSameU = POW2(M) / 8 / NDiffU;        /* 8 pts per butterfly */
    Uinc = (int) NSameU * Ustride;
    Uinc2 = Uinc * 2;
    Uinc4 = Uinc * 4;
    U2toU3 = (POW2(M) / 8) * Ustride;
    for (; StageCnt > 0; StageCnt--) {

      u0r = &Utbl[0];
      u0i = &Utbl[POW2(M - 2) * Ustride];
      u1r = u0r;
      u1i = u0i;
      u2r = u0r;
      u2i = u0i;

      w0r = *u0r;
      w0i = *u0i;
      w1r = *u1r;
      w1i = *u1i;
      w2r = *u2r;
      w2i = *u2i;
      w3r = *(u2r + U2toU3);
      w3i = *(u2i - U2toU3);

      pstrt = ioptr;

      p0r = pstrt;
      p1r = pstrt + pinc;
      p2r = p1r + pinc;
      p3r = p2r + pinc;

      /* Butterflys           */
      /*
         f0   -       -       t0      -       -       f0      -       -       f0
         f1   - w0-   f1      -       -       f1      -       -       f1
         f2   -       -       f2      - w1-   f2      -       -       f4
         f3   - w0-   t1      - iw1-  f3      -       -       f5

         f4   -       -       t0      -       -       f4      - w2-   t0
         f5   - w0-   f5      -       -       f5      - w3-   t1
         f6   -       -       f6      - w1-   f6      - iw2-  f6
         f7   - w0-   t1      - iw1-  f7      - iw3-  f7
       */

      for (DiffUCnt = NDiffU; DiffUCnt > 0; DiffUCnt--) {
        f0r = *p0r;
        f0i = *(p0r + 1);
        f1r = *p1r;
        f1i = *(p1r + 1);
        for (SameUCnt = NSameU - 1; SameUCnt > 0; SameUCnt--) {
          f2r = *p2r;
          f2i = *(p2r + 1);
          f3r = *p3r;
          f3i = *(p3r + 1);

          t0r = f0r + f1r * w0r - f1i * w0i;
          t0i = f0i + f1r * w0i + f1i * w0r;
          f1r = f0r * Two - t0r;
          f1i = f0i * Two - t0i;

          f4r = *(p0r + pos);
          f4i = *(p0r + posi);
          f5r = *(p1r + pos);
          f5i = *(p1r + posi);

          f6r = *(p2r + pos);
          f6i = *(p2r + posi);
          f7r = *(p3r + pos);
          f7i = *(p3r + posi);

          t1r = f2r - f3r * w0r + f3i * w0i;
          t1i = f2i - f3r * w0i - f3i * w0r;
          f2r = f2r * Two - t1r;
          f2i = f2i * Two - t1i;

          f0r = t0r + f2r * w1r - f2i * w1i;
          f0i = t0i + f2r * w1i + f2i * w1r;
          f2r = t0r * Two - f0r;
          f2i = t0i * Two - f0i;

          f3r = f1r + t1r * w1i + t1i * w1r;
          f3i = f1i - t1r * w1r + t1i * w1i;
          f1r = f1r * Two - f3r;
          f1i = f1i * Two - f3i;

          t0r = f4r + f5r * w0r - f5i * w0i;
          t0i = f4i + f5r * w0i + f5i * w0r;
          f5r = f4r * Two - t0r;
          f5i = f4i * Two - t0i;

          t1r = f6r - f7r * w0r + f7i * w0i;
          t1i = f6i - f7r * w0i - f7i * w0r;
          f6r = f6r * Two - t1r;
          f6i = f6i * Two - t1i;

          f4r = t0r + f6r * w1r - f6i * w1i;
          f4i = t0i + f6r * w1i + f6i * w1r;
          f6r = t0r * Two - f4r;
          f6i = t0i * Two - f4i;

          f7r = f5r + t1r * w1i + t1i * w1r;
          f7i = f5i - t1r * w1r + t1i * w1i;
          f5r = f5r * Two - f7r;
          f5i = f5i * Two - f7i;

          t0r = f0r - f4r * w2r + f4i * w2i;
          t0i = f0i - f4r * w2i - f4i * w2r;
          f0r = f0r * Two - t0r;
          f0i = f0i * Two - t0i;

          t1r = f1r - f5r * w3r + f5i * w3i;
          t1i = f1i - f5r * w3i - f5i * w3r;
          f1r = f1r * Two - t1r;
          f1i = f1i * Two - t1i;

          *(p0r + pos) = t0r;
          *(p0r + posi) = t0i;
          *p0r = f0r;
          *(p0r + 1) = f0i;

          p0r += pnext;
          f0r = *p0r;
          f0i = *(p0r + 1);

          *(p1r + pos) = t1r;
          *(p1r + posi) = t1i;
          *p1r = f1r;
          *(p1r + 1) = f1i;

          p1r += pnext;

          f1r = *p1r;
          f1i = *(p1r + 1);

          f4r = f2r - f6r * w2i - f6i * w2r;
          f4i = f2i + f6r * w2r - f6i * w2i;
          f6r = f2r * Two - f4r;
          f6i = f2i * Two - f4i;

          f5r = f3r - f7r * w3i - f7i * w3r;
          f5i = f3i + f7r * w3r - f7i * w3i;
          f7r = f3r * Two - f5r;
          f7i = f3i * Two - f5i;

          *p2r = f4r;
          *(p2r + 1) = f4i;
          *(p2r + pos) = f6r;
          *(p2r + posi) = f6i;

          p2r += pnext;

          *p3r = f5r;
          *(p3r + 1) = f5i;
          *(p3r + pos) = f7r;
          *(p3r + posi) = f7i;

          p3r += pnext;
        }

        f2r = *p2r;
        f2i = *(p2r + 1);
        f3r = *p3r;
        f3i = *(p3r + 1);

        t0r = f0r + f1r * w0r - f1i * w0i;
        t0i = f0i + f1r * w0i + f1i * w0r;
        f1r = f0r * Two - t0r;
        f1i = f0i * Two - t0i;

        f4r = *(p0r + pos);
        f4i = *(p0r + posi);
        f5r = *(p1r + pos);
        f5i = *(p1r + posi);

        f6r = *(p2r + pos);
        f6i = *(p2r + posi);
        f7r = *(p3r + pos);
        f7i = *(p3r + posi);

        t1r = f2r - f3r * w0r + f3i * w0i;
        t1i = f2i - f3r * w0i - f3i * w0r;
        f2r = f2r * Two - t1r;
        f2i = f2i * Two - t1i;

        f0r = t0r + f2r * w1r - f2i * w1i;
        f0i = t0i + f2r * w1i + f2i * w1r;
        f2r = t0r * Two - f0r;
        f2i = t0i * Two - f0i;

        f3r = f1r + t1r * w1i + t1i * w1r;
        f3i = f1i - t1r * w1r + t1i * w1i;
        f1r = f1r * Two - f3r;
        f1i = f1i * Two - f3i;

        if ((int) DiffUCnt == NDiffU / 2)
          Uinc4 = -Uinc4;

        u0r += Uinc4;
        u0i -= Uinc4;
        u1r += Uinc2;
        u1i -= Uinc2;
        u2r += Uinc;
        u2i -= Uinc;

        pstrt += 2;

        t0r = f4r + f5r * w0r - f5i * w0i;
        t0i = f4i + f5r * w0i + f5i * w0r;
        f5r = f4r * Two - t0r;
        f5i = f4i * Two - t0i;

        t1r = f6r - f7r * w0r + f7i * w0i;
        t1i = f6i - f7r * w0i - f7i * w0r;
        f6r = f6r * Two - t1r;
        f6i = f6i * Two - t1i;

        f4r = t0r + f6r * w1r - f6i * w1i;
        f4i = t0i + f6r * w1i + f6i * w1r;
        f6r = t0r * Two - f4r;
        f6i = t0i * Two - f4i;

        f7r = f5r + t1r * w1i + t1i * w1r;
        f7i = f5i - t1r * w1r + t1i * w1i;
        f5r = f5r * Two - f7r;
        f5i = f5i * Two - f7i;

        w0r = *u0r;
        w0i = *u0i;
        w1r = *u1r;
        w1i = *u1i;

        if ((int) DiffUCnt <= NDiffU / 2)
          w0r = -w0r;

        t0r = f0r - f4r * w2r + f4i * w2i;
        t0i = f0i - f4r * w2i - f4i * w2r;
        f0r = f0r * Two - t0r;
        f0i = f0i * Two - t0i;

        f4r = f2r - f6r * w2i - f6i * w2r;
        f4i = f2i + f6r * w2r - f6i * w2i;
        f6r = f2r * Two - f4r;
        f6i = f2i * Two - f4i;

        *(p0r + pos) = t0r;
        *p2r = f4r;
        *(p0r + posi) = t0i;
        *(p2r + 1) = f4i;
        w2r = *u2r;
        w2i = *u2i;
        *p0r = f0r;
        *(p2r + pos) = f6r;
        *(p0r + 1) = f0i;
        *(p2r + posi) = f6i;

        p0r = pstrt;
        p2r = pstrt + pinc + pinc;

        t1r = f1r - f5r * w3r + f5i * w3i;
        t1i = f1i - f5r * w3i - f5i * w3r;
        f1r = f1r * Two - t1r;
        f1i = f1i * Two - t1i;

        f5r = f3r - f7r * w3i - f7i * w3r;
        f5i = f3i + f7r * w3r - f7i * w3i;
        f7r = f3r * Two - f5r;
        f7i = f3i * Two - f5i;

        *(p1r + pos) = t1r;
        *p3r = f5r;
        *(p1r + posi) = t1i;
        *(p3r + 1) = f5i;
        w3r = *(u2r + U2toU3);
        w3i = *(u2i - U2toU3);
        *p1r = f1r;
        *(p3r + pos) = f7r;
        *(p1r + 1) = f1i;
        *(p3r + posi) = f7i;

        p1r = pstrt + pinc;
        p3r = p2r + pinc;
      }
      NSameU /= 8;
      Uinc /= 8;
      Uinc2 /= 8;
      Uinc4 = Uinc * 4;
      NDiffU *= 8;
      pinc *= 8;
      pnext *= 8;
      pos *= 8;
      posi = pos + 1;
    }
}

static void ifftrecurs(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int Ustride,
                       int NDiffU, int StageCnt)
{
    /* recursive bfstages calls to maximize on chip cache efficiency */
    int i1;

    if (M <= (int) MCACHE)
      ibfstages(ioptr, M, Utbl, Ustride, NDiffU, StageCnt); /* RADIX 8 Stages */
    else {
      for (i1 = 0; i1 < 8; i1++) {
        ifftrecurs(&ioptr[i1 * POW2(M - 3) * 2], M - 3, Utbl, 8 * Ustride,
                   NDiffU, StageCnt - 1);           /*  RADIX 8 Stages       */
      }
      ibfstages(ioptr, M, Utbl, Ustride, POW2(M - 3), 1);   /* RADIX 8 Stage */
    }
}

//static void iffts1(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int16_t *BRLow)
//{
//    /* Compute in-place inverse complex fft on the rows of the input array  */
//    /* INPUTS                                                               */
//    /*   *ioptr = input data array                                          */
//    /*   M = log2 of fft size                                               */
//    /*   *Utbl = cosine table                                               */
//    /*   *BRLow = bit reversed counter table                                */
//    /* OUTPUTS                                                              */
//    /*   *ioptr = output data array                                         */
//
//    int StageCnt;
//    int NDiffU;
//    const SPFLOAT scale = 1.0 / POW2(M);
//
//    switch (M) {
//    case 0:
//      break;
//    case 1:
//      ifft2pt(ioptr, scale);    /* a 2 pt fft */
//      break;
//    case 2:
//      ifft4pt(ioptr, scale);    /* a 4 pt fft */
//      break;
//    case 3:
//      ifft8pt(ioptr, scale);    /* an 8 pt fft */
//      break;
//    default:
//      /* bit reverse and first radix 2 stage */
//      scbitrevR2(ioptr, M, BRLow, scale);
//      StageCnt = (M - 1) / 3;   /* number of radix 8 stages */
//      NDiffU = 2;               /* one radix 2 stage already complete */
//      if ((M - 1 - (StageCnt * 3)) == 1) {
//        ibfR2(ioptr, M, NDiffU);        /* 1 radix 2 stage */
//        NDiffU *= 2;
//      }
//      if ((M - 1 - (StageCnt * 3)) == 2) {
//        ibfR4(ioptr, M, NDiffU);        /* 1 radix 4 stage */
//        NDiffU *= 4;
//      }
//      if (M <= (int) MCACHE)
//        ibfstages(ioptr, M, Utbl, 1, NDiffU, StageCnt);  /* RADIX 8 Stages */
//      else
//        ifftrecurs(ioptr, M, Utbl, 1, NDiffU, StageCnt); /* RADIX 8 Stages */
//    }
//}

/******************
* parts of rffts1 *
******************/

static void rfft1pt(SPFLOAT *ioptr)
{
    /***   RADIX 2 rfft     ***/
    SPFLOAT f0r, f0i;
    SPFLOAT t0r, t0i;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];

    /* finish rfft */
    t0r = f0r + f0i;
    t0i = f0r - f0i;

    /* store result */
    ioptr[0] = t0r;
    ioptr[1] = t0i;
}

static void rfft2pt(SPFLOAT *ioptr)
{
    /***   RADIX 4 rfft     ***/
    SPFLOAT f0r, f0i, f1r, f1i;
    SPFLOAT t0r, t0i;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[2];
    f1i = ioptr[3];

    /* Butterflys           */
    /*
       f0   -       -       t0
       f1   -  1 -  f1
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f1i - f0i;
    /* finish rfft */
    f0r = t0r + t0i;
    f0i = t0r - t0i;

    /* store result */
    ioptr[0] = f0r;
    ioptr[1] = f0i;
    ioptr[2] = f1r;
    ioptr[3] = f1i;
}

static void rfft4pt(SPFLOAT *ioptr)
{
    /***   RADIX 8 rfft     ***/
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT t0r, t0i, t1r, t1i;
    SPFLOAT w0r = 1.0 / MYROOT2;    /* cos(pi/4)   */
    const SPFLOAT Two = 2.0;
    const SPFLOAT scale = 0.5;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[4];
    f1i = ioptr[5];
    f2r = ioptr[2];
    f2i = ioptr[3];
    f3r = ioptr[6];
    f3i = ioptr[7];

    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0
       f1   -  1 -  f1      -       -       f1
       f2   -       -       f2      -  1 -  f2
       f3   -  1 -  t1      - -i -  f3
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f0i - f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = f2i - t0i;              /* neg for rfft */

    f3r = f1r - t1i;
    f3i = f1i + t1r;
    f1r = f1r + t1i;
    f1i = f1i - t1r;

    /* finish rfft */
    t0r = f0r + f0i;              /* compute Re(x[0]) */
    t0i = f0r - f0i;              /* compute Re(x[N/2]) */

    t1r = f1r + f3r;
    t1i = f1i - f3i;
    f0r = f1i + f3i;
    f0i = f3r - f1r;

    f1r = t1r + w0r * f0r + w0r * f0i;
    f1i = t1i - w0r * f0r + w0r * f0i;
    f3r = Two * t1r - f1r;
    f3i = f1i - Two * t1i;

    /* store result */
    ioptr[4] = f2r;
    ioptr[5] = f2i;
    ioptr[0] = t0r;
    ioptr[1] = t0i;

    ioptr[2] = scale * f1r;
    ioptr[3] = scale * f1i;
    ioptr[6] = scale * f3r;
    ioptr[7] = scale * f3i;
}

static void rfft8pt(SPFLOAT *ioptr)
{
    /***   RADIX 16 rfft    ***/
    SPFLOAT w0r = 1.0 / MYROOT2;    /* cos(pi/4)   */
    SPFLOAT w1r = MYCOSPID8;        /* cos(pi/8)     */
    SPFLOAT w1i = MYSINPID8;        /* sin(pi/8)     */
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;
    const SPFLOAT scale = 0.5;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];
    f1r = ioptr[8];
    f1i = ioptr[9];
    f2r = ioptr[4];
    f2i = ioptr[5];
    f3r = ioptr[12];
    f3i = ioptr[13];
    f4r = ioptr[2];
    f4i = ioptr[3];
    f5r = ioptr[10];
    f5i = ioptr[11];
    f6r = ioptr[6];
    f6i = ioptr[7];
    f7r = ioptr[14];
    f7i = ioptr[15];
    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0      -       -       f0
       f1   -  1 -  f1      -       -       f1      -       -       f1
       f2   -       -       f2      -  1 -  f2      -       -       f2
       f3   -  1 -  t1      - -i -  f3      -       -       f3
       f4   -       -       t0      -       -       f4      -  1 -  t0
       f5   -  1 -  f5      -       -       f5      - w3 -  f4
       f6   -       -       f6      -  1 -  f6      - -i -  t1
       f7   -  1 -  t1      - -i -  f7      - iw3-  f6
     */

    t0r = f0r + f1r;
    t0i = f0i + f1i;
    f1r = f0r - f1r;
    f1i = f0i - f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = t0i - f2i;

    f3r = f1r - t1i;
    f3i = f1i + t1r;
    f1r = f1r + t1i;
    f1i = f1i - t1r;

    t0r = f4r + f5r;
    t0i = f4i + f5i;
    f5r = f4r - f5r;
    f5i = f4i - f5i;

    t1r = f6r - f7r;
    t1i = f6i - f7i;
    f6r = f6r + f7r;
    f6i = f6i + f7i;

    f4r = t0r + f6r;
    f4i = t0i + f6i;
    f6r = t0r - f6r;
    f6i = t0i - f6i;

    f7r = f5r - t1i;
    f7i = f5i + t1r;
    f5r = f5r + t1i;
    f5i = f5i - t1r;

    t0r = f0r - f4r;
    t0i = f4i - f0i;              /* neg for rfft */
    f0r = f0r + f4r;
    f0i = f0i + f4i;

    t1r = f2r - f6i;
    t1i = f2i + f6r;
    f2r = f2r + f6i;
    f2i = f2i - f6r;

    f4r = f1r - f5r * w0r - f5i * w0r;
    f4i = f1i + f5r * w0r - f5i * w0r;
    f1r = f1r * Two - f4r;
    f1i = f1i * Two - f4i;

    f6r = f3r + f7r * w0r - f7i * w0r;
    f6i = f3i + f7r * w0r + f7i * w0r;
    f3r = f3r * Two - f6r;
    f3i = f3i * Two - f6i;

    /* finish rfft */
    f5r = f0r + f0i;              /* compute Re(x[0]) */
    f5i = f0r - f0i;              /* compute Re(x[N/2]) */

    f0r = f2r + t1r;
    f0i = f2i - t1i;
    f7r = f2i + t1i;
    f7i = t1r - f2r;

    f2r = f0r + w0r * f7r + w0r * f7i;
    f2i = f0i - w0r * f7r + w0r * f7i;
    t1r = Two * f0r - f2r;
    t1i = f2i - Two * f0i;

    f0r = f1r + f6r;
    f0i = f1i - f6i;
    f7r = f1i + f6i;
    f7i = f6r - f1r;

    f1r = f0r + w1r * f7r + w1i * f7i;
    f1i = f0i - w1i * f7r + w1r * f7i;
    f6r = Two * f0r - f1r;
    f6i = f1i - Two * f0i;

    f0r = f3r + f4r;
    f0i = f3i - f4i;
    f7r = f3i + f4i;
    f7i = f4r - f3r;

    f3r = f0r + w1i * f7r + w1r * f7i;
    f3i = f0i - w1r * f7r + w1i * f7i;
    f4r = Two * f0r - f3r;
    f4i = f3i - Two * f0i;

    /* store result */
    ioptr[8] = t0r;
    ioptr[9] = t0i;
    ioptr[0] = f5r;
    ioptr[1] = f5i;

    ioptr[4] = scale * f2r;
    ioptr[5] = scale * f2i;
    ioptr[12] = scale * t1r;
    ioptr[13] = scale * t1i;

    ioptr[2] = scale * f1r;
    ioptr[3] = scale * f1i;
    ioptr[6] = scale * f3r;
    ioptr[7] = scale * f3i;
    ioptr[10] = scale * f4r;
    ioptr[11] = scale * f4i;
    ioptr[14] = scale * f6r;
    ioptr[15] = scale * f6i;
}

static void frstage(SPFLOAT *ioptr, int M, SPFLOAT *Utbl)
{
    /*      Finish RFFT             */

    unsigned int pos;
    unsigned int posi;
    unsigned int diffUcnt;

    SPFLOAT *p0r, *p1r;
    SPFLOAT *u0r, *u0i;

    SPFLOAT w0r, w0i;
    SPFLOAT f0r, f0i, f1r, f1i, f4r, f4i, f5r, f5i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    pos = POW2(M - 1);
    posi = pos + 1;

    p0r = ioptr;
    p1r = ioptr + pos / 2;

    u0r = Utbl + POW2(M - 3);

    w0r = *u0r;
    f0r = *(p0r);
    f0i = *(p0r + 1);
    f4r = *(p0r + pos);
    f4i = *(p0r + posi);
    f1r = *(p1r);
    f1i = *(p1r + 1);
    f5r = *(p1r + pos);
    f5i = *(p1r + posi);

    t0r = Two * f0r + Two * f0i;  /* compute Re(x[0]) */
    t0i = Two * f0r - Two * f0i;  /* compute Re(x[N/2]) */
    t1r = f4r + f4r;
    t1i = -f4i - f4i;

    f0r = f1r + f5r;
    f0i = f1i - f5i;
    f4r = f1i + f5i;
    f4i = f5r - f1r;

    f1r = f0r + w0r * f4r + w0r * f4i;
    f1i = f0i - w0r * f4r + w0r * f4i;
    f5r = Two * f0r - f1r;
    f5i = f1i - Two * f0i;

    *(p0r) = t0r;
    *(p0r + 1) = t0i;
    *(p0r + pos) = t1r;
    *(p0r + posi) = t1i;
    *(p1r) = f1r;
    *(p1r + 1) = f1i;
    *(p1r + pos) = f5r;
    *(p1r + posi) = f5i;

    u0r = Utbl + 1;
    u0i = Utbl + (POW2(M - 2) - 1);

    w0r = *u0r;
    w0i = *u0i;

    p0r = (ioptr + 2);
    p1r = (ioptr + (POW2(M - 2) - 1) * 2);

    /* Butterflys */
    /*
       f0   -       t0      -       -       f0
       f5   -       t1      - w0    -       f5

       f1   -       t0      -       -       f1
       f4   -       t1      -iw0 -  f4
     */

    for (diffUcnt = POW2(M - 3) - 1; diffUcnt > 0; diffUcnt--) {

      f0r = *(p0r);
      f0i = *(p0r + 1);
      f5r = *(p1r + pos);
      f5i = *(p1r + posi);
      f1r = *(p1r);
      f1i = *(p1r + 1);
      f4r = *(p0r + pos);
      f4i = *(p0r + posi);

      t0r = f0r + f5r;
      t0i = f0i - f5i;
      t1r = f0i + f5i;
      t1i = f5r - f0r;

      f0r = t0r + w0r * t1r + w0i * t1i;
      f0i = t0i - w0i * t1r + w0r * t1i;
      f5r = Two * t0r - f0r;
      f5i = f0i - Two * t0i;

      t0r = f1r + f4r;
      t0i = f1i - f4i;
      t1r = f1i + f4i;
      t1i = f4r - f1r;

      f1r = t0r + w0i * t1r + w0r * t1i;
      f1i = t0i - w0r * t1r + w0i * t1i;
      f4r = Two * t0r - f1r;
      f4i = f1i - Two * t0i;

      *(p0r) = f0r;
      *(p0r + 1) = f0i;
      *(p1r + pos) = f5r;
      *(p1r + posi) = f5i;

      w0r = *++u0r;
      w0i = *--u0i;

      *(p1r) = f1r;
      *(p1r + 1) = f1i;
      *(p0r + pos) = f4r;
      *(p0r + posi) = f4i;

      p0r += 2;
      p1r -= 2;
    }
}

static void rffts1(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int16_t *BRLow)
{
    /* Compute in-place real fft on the rows of the input array           */
    /* The result is the complex spectra of the positive frequencies      */
    /* except the location for the first complex number contains the real */
    /* values for DC and Nyquest                                          */
    /* INPUTS                                                             */
    /*   *ioptr = real input data array                                   */
    /*   M = log2 of fft size                                             */
    /*   *Utbl = cosine table                                             */
    /*   *BRLow = bit reversed counter table                              */
    /* OUTPUTS                                                            */
    /*   *ioptr = output data array   in the following order              */
    /*     Re(x[0]), Re(x[N/2]), Re(x[1]), Im(x[1]), Re(x[2]), Im(x[2]),  */
    /*     ... Re(x[N/2-1]), Im(x[N/2-1]).                                */

    SPFLOAT scale;
    int StageCnt;
    int NDiffU;

    M = M - 1;
    switch (M) {
    case -1:
      break;
    case 0:
      rfft1pt(ioptr);           /* a 2 pt fft */
      break;
    case 1:
      rfft2pt(ioptr);           /* a 4 pt fft */
      break;
    case 2:
      rfft4pt(ioptr);           /* an 8 pt fft */
      break;
    case 3:
      rfft8pt(ioptr);           /* a 16 pt fft */
      break;
    default:
      scale = 0.5;
      /* bit reverse and first radix 2 stage */
      scbitrevR2(ioptr, M, BRLow, scale);
      StageCnt = (M - 1) / 3;   /* number of radix 8 stages           */
      NDiffU = 2;               /* one radix 2 stage already complete */
      if ((M - 1 - (StageCnt * 3)) == 1) {
        bfR2(ioptr, M, NDiffU); /* 1 radix 2 stage */
        NDiffU *= 2;
      }
      if ((M - 1 - (StageCnt * 3)) == 2) {
        bfR4(ioptr, M, NDiffU); /* 1 radix 4 stage */
        NDiffU *= 4;
      }
      if (M <= (int) MCACHE)
        bfstages(ioptr, M, Utbl, 2, NDiffU, StageCnt);  /* RADIX 8 Stages */
      else
        fftrecurs(ioptr, M, Utbl, 2, NDiffU, StageCnt); /* RADIX 8 Stages */
      frstage(ioptr, M + 1, Utbl);
    }
}

/*******************
* parts of riffts1 *
*******************/

static void rifft1pt(SPFLOAT *ioptr, SPFLOAT scale)
{
    /***   RADIX 2 rifft    ***/
    SPFLOAT f0r, f0i;
    SPFLOAT t0r, t0i;

    /* bit reversed load */
    f0r = ioptr[0];
    f0i = ioptr[1];

    /* finish rfft */
    t0r = f0r + f0i;
    t0i = f0r - f0i;

    /* store result */
    ioptr[0] = scale * t0r;
    ioptr[1] = scale * t0i;
}

static void rifft2pt(SPFLOAT *ioptr, SPFLOAT scale)
{
    /***   RADIX 4 rifft    ***/
    SPFLOAT f0r, f0i, f1r, f1i;
    SPFLOAT t0r, t0i;
    const SPFLOAT Two = 2.0;

    /* bit reversed load */
    t0r = ioptr[0];
    t0i = ioptr[1];
    f1r = Two * ioptr[2];
    f1i = Two * ioptr[3];

    /* start rifft */
    f0r = t0r + t0i;
    f0i = t0r - t0i;
    /* Butterflys           */
    /*
       f0   -       -       t0
       f1   -  1 -  f1
     */

    t0r = f0r + f1r;
    t0i = f0i - f1i;
    f1r = f0r - f1r;
    f1i = f0i + f1i;

    /* store result */
    ioptr[0] = scale * t0r;
    ioptr[1] = scale * t0i;
    ioptr[2] = scale * f1r;
    ioptr[3] = scale * f1i;
}

static void rifft4pt(SPFLOAT *ioptr, SPFLOAT scale)
{
    /***   RADIX 8 rifft    ***/
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT t0r, t0i, t1r, t1i;
    SPFLOAT w0r = 1.0 / MYROOT2;    /* cos(pi/4)   */
    const SPFLOAT Two = 2.0;

    /* bit reversed load */
    t0r = ioptr[0];
    t0i = ioptr[1];
    f2r = ioptr[2];
    f2i = ioptr[3];
    f1r = Two * ioptr[4];
    f1i = Two * ioptr[5];
    f3r = ioptr[6];
    f3i = ioptr[7];

    /* start rfft */
    f0r = t0r + t0i;              /* compute Re(x[0]) */
    f0i = t0r - t0i;              /* compute Re(x[N/2]) */

    t1r = f2r + f3r;
    t1i = f2i - f3i;
    t0r = f2r - f3r;
    t0i = f2i + f3i;

    f2r = t1r - w0r * t0r - w0r * t0i;
    f2i = t1i + w0r * t0r - w0r * t0i;
    f3r = Two * t1r - f2r;
    f3i = f2i - Two * t1i;

    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0
       f1   -  1 -  f1      -       -       f1
       f2   -       -       f2      -  1 -  f2
       f3   -  1 -  t1      -  i -  f3
     */

    t0r = f0r + f1r;
    t0i = f0i - f1i;
    f1r = f0r - f1r;
    f1i = f0i + f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = t0i - f2i;

    f3r = f1r + t1i;
    f3i = f1i - t1r;
    f1r = f1r - t1i;
    f1i = f1i + t1r;

    /* store result */
    ioptr[0] = scale * f0r;
    ioptr[1] = scale * f0i;
    ioptr[2] = scale * f1r;
    ioptr[3] = scale * f1i;
    ioptr[4] = scale * f2r;
    ioptr[5] = scale * f2i;
    ioptr[6] = scale * f3r;
    ioptr[7] = scale * f3i;
}

static void rifft8pt(SPFLOAT *ioptr, SPFLOAT scale)
{
    /***   RADIX 16 rifft   ***/
    SPFLOAT w0r = (SPFLOAT) (1.0 / MYROOT2);    /* cos(pi/4)    */
    SPFLOAT w1r = MYCOSPID8;                  /* cos(pi/8)    */
    SPFLOAT w1i = MYSINPID8;                  /* sin(pi/8)    */
    SPFLOAT f0r, f0i, f1r, f1i, f2r, f2i, f3r, f3i;
    SPFLOAT f4r, f4i, f5r, f5i, f6r, f6i, f7r, f7i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    /* bit reversed load */
    t0r = ioptr[0];
    t0i = ioptr[1];
    f4r = ioptr[2];
    f4i = ioptr[3];
    f2r = ioptr[4];
    f2i = ioptr[5];
    f6r = ioptr[6];
    f6i = ioptr[7];
    f1r = Two * ioptr[8];
    f1i = Two * ioptr[9];
    f5r = ioptr[10];
    f5i = ioptr[11];
    f3r = ioptr[12];
    f3i = ioptr[13];
    f7r = ioptr[14];
    f7i = ioptr[15];

    /* start rfft */
    f0r = t0r + t0i;              /* compute Re(x[0]) */
    f0i = t0r - t0i;              /* compute Re(x[N/2]) */

    t0r = f2r + f3r;
    t0i = f2i - f3i;
    t1r = f2r - f3r;
    t1i = f2i + f3i;

    f2r = t0r - w0r * t1r - w0r * t1i;
    f2i = t0i + w0r * t1r - w0r * t1i;
    f3r = Two * t0r - f2r;
    f3i = f2i - Two * t0i;

    t0r = f4r + f7r;
    t0i = f4i - f7i;
    t1r = f4r - f7r;
    t1i = f4i + f7i;

    f4r = t0r - w1i * t1r - w1r * t1i;
    f4i = t0i + w1r * t1r - w1i * t1i;
    f7r = Two * t0r - f4r;
    f7i = f4i - Two * t0i;

    t0r = f6r + f5r;
    t0i = f6i - f5i;
    t1r = f6r - f5r;
    t1i = f6i + f5i;

    f6r = t0r - w1r * t1r - w1i * t1i;
    f6i = t0i + w1i * t1r - w1r * t1i;
    f5r = Two * t0r - f6r;
    f5i = f6i - Two * t0i;

    /* Butterflys           */
    /*
       f0   -       -       t0      -       -       f0      -       -       f0
       f1*  -  1 -  f1      -       -       f1      -       -       f1
       f2   -       -       f2      -  1 -  f2      -       -       f2
       f3   -  1 -  t1      -  i -  f3      -       -       f3
       f4   -       -       t0      -       -       f4      -  1 -  t0
       f5   -  1 -  f5      -       -       f5      - w3 -  f4
       f6   -       -       f6      -  1 -  f6      -  i -  t1
       f7   -  1 -  t1      -  i -  f7      - iw3-  f6
     */

    t0r = f0r + f1r;
    t0i = f0i - f1i;
    f1r = f0r - f1r;
    f1i = f0i + f1i;

    t1r = f2r - f3r;
    t1i = f2i - f3i;
    f2r = f2r + f3r;
    f2i = f2i + f3i;

    f0r = t0r + f2r;
    f0i = t0i + f2i;
    f2r = t0r - f2r;
    f2i = t0i - f2i;

    f3r = f1r + t1i;
    f3i = f1i - t1r;
    f1r = f1r - t1i;
    f1i = f1i + t1r;

    t0r = f4r + f5r;
    t0i = f4i + f5i;
    f5r = f4r - f5r;
    f5i = f4i - f5i;

    t1r = f6r - f7r;
    t1i = f6i - f7i;
    f6r = f6r + f7r;
    f6i = f6i + f7i;

    f4r = t0r + f6r;
    f4i = t0i + f6i;
    f6r = t0r - f6r;
    f6i = t0i - f6i;

    f7r = f5r + t1i;
    f7i = f5i - t1r;
    f5r = f5r - t1i;
    f5i = f5i + t1r;

    t0r = f0r - f4r;
    t0i = f0i - f4i;
    f0r = f0r + f4r;
    f0i = f0i + f4i;

    t1r = f2r + f6i;
    t1i = f2i - f6r;
    f2r = f2r - f6i;
    f2i = f2i + f6r;

    f4r = f1r - f5r * w0r + f5i * w0r;
    f4i = f1i - f5r * w0r - f5i * w0r;
    f1r = f1r * Two - f4r;
    f1i = f1i * Two - f4i;

    f6r = f3r + f7r * w0r + f7i * w0r;
    f6i = f3i - f7r * w0r + f7i * w0r;
    f3r = f3r * Two - f6r;
    f3i = f3i * Two - f6i;

    /* store result */
    ioptr[0] = scale * f0r;
    ioptr[1] = scale * f0i;
    ioptr[2] = scale * f1r;
    ioptr[3] = scale * f1i;
    ioptr[4] = scale * f2r;
    ioptr[5] = scale * f2i;
    ioptr[6] = scale * f3r;
    ioptr[7] = scale * f3i;
    ioptr[8] = scale * t0r;
    ioptr[9] = scale * t0i;
    ioptr[10] = scale * f4r;
    ioptr[11] = scale * f4i;
    ioptr[12] = scale * t1r;
    ioptr[13] = scale * t1i;
    ioptr[14] = scale * f6r;
    ioptr[15] = scale * f6i;
}

static void ifrstage(SPFLOAT *ioptr, int M, SPFLOAT *Utbl)
{
    /*      Start RIFFT             */

    unsigned int pos;
    unsigned int posi;
    unsigned int diffUcnt;

    SPFLOAT *p0r, *p1r;
    SPFLOAT *u0r, *u0i;

    SPFLOAT w0r, w0i;
    SPFLOAT f0r, f0i, f1r, f1i, f4r, f4i, f5r, f5i;
    SPFLOAT t0r, t0i, t1r, t1i;
    const SPFLOAT Two = 2.0;

    pos = POW2(M - 1);
    posi = pos + 1;

    p0r = ioptr;
    p1r = ioptr + pos / 2;

    u0r = Utbl + POW2(M - 3);

    w0r = *u0r;
    f0r = *(p0r);
    f0i = *(p0r + 1);
    f4r = *(p0r + pos);
    f4i = *(p0r + posi);
    f1r = *(p1r);
    f1i = *(p1r + 1);
    f5r = *(p1r + pos);
    f5i = *(p1r + posi);

    t0r = f0r + f0i;
    t0i = f0r - f0i;
    t1r = f4r + f4r;
    t1i = -f4i - f4i;

    f0r = f1r + f5r;
    f0i = f1i - f5i;
    f4r = f1r - f5r;
    f4i = f1i + f5i;

    f1r = f0r - w0r * f4r - w0r * f4i;
    f1i = f0i + w0r * f4r - w0r * f4i;
    f5r = Two * f0r - f1r;
    f5i = f1i - Two * f0i;

    *(p0r) = t0r;
    *(p0r + 1) = t0i;
    *(p0r + pos) = t1r;
    *(p0r + posi) = t1i;
    *(p1r) = f1r;
    *(p1r + 1) = f1i;
    *(p1r + pos) = f5r;
    *(p1r + posi) = f5i;

    u0r = Utbl + 1;
    u0i = Utbl + (POW2(M - 2) - 1);

    w0r = *u0r;
    w0i = *u0i;

    p0r = (ioptr + 2);
    p1r = (ioptr + (POW2(M - 2) - 1) * 2);

    /* Butterflys */
    /*
       f0   -        t0             -       f0
       f1   -     t1     -w0-   f1

       f2   -        t0             -       f2
       f3   -     t1           -iw0-  f3
     */

    for (diffUcnt = POW2(M - 3) - 1; diffUcnt > 0; diffUcnt--) {

      f0r = *(p0r);
      f0i = *(p0r + 1);
      f5r = *(p1r + pos);
      f5i = *(p1r + posi);
      f1r = *(p1r);
      f1i = *(p1r + 1);
      f4r = *(p0r + pos);
      f4i = *(p0r + posi);

      t0r = f0r + f5r;
      t0i = f0i - f5i;
      t1r = f0r - f5r;
      t1i = f0i + f5i;

      f0r = t0r - w0i * t1r - w0r * t1i;
      f0i = t0i + w0r * t1r - w0i * t1i;
      f5r = Two * t0r - f0r;
      f5i = f0i - Two * t0i;

      t0r = f1r + f4r;
      t0i = f1i - f4i;
      t1r = f1r - f4r;
      t1i = f1i + f4i;

      f1r = t0r - w0r * t1r - w0i * t1i;
      f1i = t0i + w0i * t1r - w0r * t1i;
      f4r = Two * t0r - f1r;
      f4i = f1i - Two * t0i;

      *(p0r) = f0r;
      *(p0r + 1) = f0i;
      *(p1r + pos) = f5r;
      *(p1r + posi) = f5i;

      w0r = *++u0r;
      w0i = *--u0i;

      *(p1r) = f1r;
      *(p1r + 1) = f1i;
      *(p0r + pos) = f4r;
      *(p0r + posi) = f4i;

      p0r += 2;
      p1r -= 2;
    }
}

static void riffts1(SPFLOAT *ioptr, int M, SPFLOAT *Utbl, int16_t *BRLow)
{
    /* Compute in-place real ifft on the rows of the input array    */
    /* data order as from rffts1                                    */
    /* INPUTS                                                       */
    /*   *ioptr = input data array in the following order           */
    /*   M = log2 of fft size                                       */
    /*   Re(x[0]), Re(x[N/2]), Re(x[1]), Im(x[1]),                  */
    /*   Re(x[2]), Im(x[2]), ... Re(x[N/2-1]), Im(x[N/2-1]).        */
    /*   *Utbl = cosine table                                       */
    /*   *BRLow = bit reversed counter table                        */
    /* OUTPUTS                                                      */
    /*   *ioptr = real output data array                            */

    SPFLOAT scale;
    int StageCnt;
    int NDiffU;

    scale = (SPFLOAT)(1.0 / (double)((int)POW2(M)));
    M = M - 1;
    switch (M) {
    case -1:
      break;
    case 0:
      rifft1pt(ioptr, scale);   /* a 2 pt fft */
      break;
    case 1:
      rifft2pt(ioptr, scale);   /* a 4 pt fft */
      break;
    case 2:
      rifft4pt(ioptr, scale);   /* an 8 pt fft */
      break;
    case 3:
      rifft8pt(ioptr, scale);   /* a 16 pt fft */
      break;
    default:
      ifrstage(ioptr, M + 1, Utbl);
      /* bit reverse and first radix 2 stage */
      scbitrevR2(ioptr, M, BRLow, scale);
      StageCnt = (M - 1) / 3;   /* number of radix 8 stages           */
      NDiffU = 2;               /* one radix 2 stage already complete */
      if ((M - 1 - (StageCnt * 3)) == 1) {
        ibfR2(ioptr, M, NDiffU);        /* 1 radix 2 stage */
        NDiffU *= 2;
      }
      if ((M - 1 - (StageCnt * 3)) == 2) {
        ibfR4(ioptr, M, NDiffU);        /* 1 radix 4 stage */
        NDiffU *= 4;
      }
      if (M <= (int) MCACHE)
        ibfstages(ioptr, M, Utbl, 2, NDiffU, StageCnt); /*  RADIX 8 Stages */
      else
        ifftrecurs(ioptr, M, Utbl, 2, NDiffU, StageCnt); /* RADIX 8 Stages */
    }
}
//static void fftInit(sp_fft *fft, int M)
void sp_fft_init(sp_fft *fft, int M)
{
    SPFLOAT *utbl;
    int16_t *BRLow;
    int16_t *BRLowCpx;
//    int i;

    /* init cos table */
    utbl = (SPFLOAT*) malloc((POW2(M) / 4 + 1) * sizeof(SPFLOAT));
    fftCosInit(M, utbl);

    BRLowCpx =
      (int16_t*) malloc(POW2(M / 2 - 1) * sizeof(int16_t));
    fftBRInit(M, BRLowCpx);

    /* init bit reversed table for real FFT */
     BRLow =
      (int16_t*) malloc(POW2((M - 1) / 2 - 1) * sizeof(int16_t));
    fftBRInit(M - 1, BRLow);

    fft->BRLow = BRLow;
    fft->BRLowCpx = BRLowCpx;
    fft->utbl = utbl;
}

void sp_fftr(sp_fft *fft, SPFLOAT *buf, int FFTsize)
{
//    SPFLOAT *Utbl;
//    int16_t *BRLow;
    int   M = log2(FFTsize);
    rffts1(buf, M, fft->utbl, fft->BRLow);
}

void sp_fft_cpx(sp_fft *fft, SPFLOAT *buf, int FFTsize)
{
//    SPFLOAT *Utbl;
//    int16_t *BRLow;
    int   M = log2(FFTsize);
    ffts1(buf, M, fft->utbl, fft->BRLowCpx);
}



void sp_ifftr(sp_fft *fft, SPFLOAT *buf, int FFTsize)
{
//    SPFLOAT *Utbl;
//    int16_t *BRLow;
    int   M = log2(FFTsize);
    riffts1(buf, M, fft->utbl, fft->BRLow);
}

void sp_fft_destroy(sp_fft *fft)
{
    free(fft->utbl);
    free(fft->BRLow);
    free(fft->BRLowCpx);
}

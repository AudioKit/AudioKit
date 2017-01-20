/*
 * conv
 * 
 * This code has been extracted from the Csound opcode "ftconv".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Istvan Varga
 * Year: 2005
 * Location: Opcodes/ftconv.c
 *
 */

#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "soundpipe.h"

static void multiply_fft_buffers(SPFLOAT *outBuf, SPFLOAT *ringBuf,
                                 SPFLOAT *IR_Data, int partSize, int nPartitions,
                                 int ringBuf_startPos)
{
    SPFLOAT   re, im, re1, re2, im1, im2;
    SPFLOAT   *rbPtr, *irPtr, *outBufPtr, *outBufEndPm2, *rbEndP;

    /* note: partSize must be at least 2 samples */
    partSize <<= 1;
    outBufEndPm2 = (SPFLOAT*) outBuf + (int) (partSize - 2);
    rbEndP = (SPFLOAT*) ringBuf + (int) (partSize * nPartitions);
    rbPtr = &(ringBuf[ringBuf_startPos]);
    irPtr = IR_Data;
    outBufPtr = outBuf;
    memset(outBuf, 0, sizeof(SPFLOAT)*(partSize));
    do {
      /* wrap ring buffer position */
      if (rbPtr >= rbEndP)
        rbPtr = ringBuf;
      outBufPtr = outBuf;
      *(outBufPtr++) += *(rbPtr++) * *(irPtr++);    /* convolve DC */
      *(outBufPtr++) += *(rbPtr++) * *(irPtr++);    /* convolve Nyquist */
      re1 = *(rbPtr++);
      im1 = *(rbPtr++);
      re2 = *(irPtr++);
      im2 = *(irPtr++);
      re = re1 * re2 - im1 * im2;
      im = re1 * im2 + re2 * im1;
      while (outBufPtr < outBufEndPm2) {
        /* complex multiply */
        re1 = rbPtr[0];
        im1 = rbPtr[1];
        re2 = irPtr[0];
        im2 = irPtr[1];
        outBufPtr[0] += re;
        outBufPtr[1] += im;
        re = re1 * re2 - im1 * im2;
        im = re1 * im2 + re2 * im1;
        re1 = rbPtr[2];
        im1 = rbPtr[3];
        re2 = irPtr[2];
        im2 = irPtr[3];
        outBufPtr[2] += re;
        outBufPtr[3] += im;
        re = re1 * re2 - im1 * im2;
        im = re1 * im2 + re2 * im1;
        outBufPtr += 4;
        rbPtr += 4;
        irPtr += 4;
      }
      outBufPtr[0] += re;
      outBufPtr[1] += im;
    } while (--nPartitions);
}

static int buf_bytes_alloc(int nChannels, int partSize, int nPartitions)
{
    int nSmps;

    nSmps = (partSize << 1);                                /* tmpBuf     */
    nSmps += ((partSize << 1) * nPartitions);               /* ringBuf    */
    nSmps += ((partSize << 1) * nChannels * nPartitions);   /* IR_Data    */
    nSmps += ((partSize << 1) * nChannels);                 /* outBuffers */

    return ((int) sizeof(SPFLOAT) * nSmps);
}

static void set_buf_pointers(sp_conv *p,
                             int nChannels, int partSize, int nPartitions)
{
    SPFLOAT *ptr;
    int   i;

    ptr = (SPFLOAT *) (p->auxData.ptr);
    p->tmpBuf = ptr;
    ptr += (partSize << 1);
    p->ringBuf = ptr;
    ptr += ((partSize << 1) * nPartitions);
    for (i = 0; i < nChannels; i++) {
      p->IR_Data[i] = ptr;
      ptr += ((partSize << 1) * nPartitions);
    }
    for (i = 0; i < nChannels; i++) {
      p->outBuffers[i] = ptr;
      ptr += (partSize << 1);
    }
}

int sp_conv_create(sp_conv **p)
{
    *p = malloc(sizeof(sp_conv));
    return SP_OK;
}

int sp_conv_destroy(sp_conv **p)
{
    sp_conv *pp = *p;
    sp_auxdata_free(&pp->auxData);
    sp_fft_destroy(&pp->fft);
    free(*p);
    return SP_OK;
}

int sp_conv_init(sp_data *sp, sp_conv *p, sp_ftbl *ft, SPFLOAT iPartLen)
{
    int     i, j, k, n, nBytes, skipSamples;
    SPFLOAT FFTscale;

    p->iTotLen = ft->size;
    p->iSkipSamples = 0;
    p->iPartLen = iPartLen;

    p->nChannels = 1;
    /* partition length */
    p->partSize = (int)lrintf(p->iPartLen);
    if (p->partSize < 4 || (p->partSize & (p->partSize - 1)) != 0) {
        fprintf(stderr, "conv: invalid partition size.\n");
        return SP_NOT_OK;  
    }

    sp_fft_init(&p->fft, (int)log2(p->partSize << 1));
    n = (int) ft->size / p->nChannels;
    skipSamples = (int)lrintf(p->iSkipSamples);
    n -= skipSamples;

    if (lrintf(p->iTotLen) > 0 && n > lrintf(p->iTotLen)) {
        n = (int)lrintf(p->iTotLen);
    }

    if (n <= 0) {
        fprintf(stderr, "uh oh.\n");
        return SP_NOT_OK;
    }

    p->nPartitions = (n + (p->partSize - 1)) / p->partSize;
    /* calculate the amount of aux space to allocate (in bytes) */
    nBytes = buf_bytes_alloc(p->nChannels, p->partSize, p->nPartitions);
    sp_auxdata_alloc(&p->auxData, nBytes);
    /* if skipping samples: check for possible truncation of IR */
    /* initialise buffer pointers */
    set_buf_pointers(p, p->nChannels, p->partSize, p->nPartitions);
    /* clear ring buffer to zero */
    n = (p->partSize << 1) * p->nPartitions;
    memset(p->ringBuf, 0, n*sizeof(SPFLOAT));
    p->cnt = 0;
    p->rbCnt = 0;
    FFTscale = 1.0;
    for (j = 0; j < p->nChannels; j++) {
        /* table read position */
        i = (skipSamples * p->nChannels) + j; 
        /* IR write position */
        n = (p->partSize << 1) * (p->nPartitions - 1); 
        do { 
            for (k = 0; k < p->partSize; k++) {
                if (i >= 0 && i < (int) ft->size) {
                    p->IR_Data[j][n + k] = ft->tbl[i] * FFTscale;
                } else {
                    p->IR_Data[j][n + k] = 0.0;
                } 
                i += p->nChannels;
            }
        /* pad second half of IR to zero */
            for (k = p->partSize; k < (p->partSize << 1); k++) {
                p->IR_Data[j][n + k] = 0.0;
            }
            /* calculate FFT */
            sp_fftr(&p->fft, &(p->IR_Data[j][n]), (p->partSize << 1));
            n -= (p->partSize << 1);
        } while (n >= 0);
    }
    /* clear output buffers to zero */
    for (j = 0; j < p->nChannels; j++) {
        for (i = 0; i < (p->partSize << 1); i++)
        p->outBuffers[j][i] = 0.0;
    }
    p->initDone = 1;

    return SP_OK;
}

int sp_conv_compute(sp_data *sp, sp_conv *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT *x, *rBuf;
    int i, n, nSamples, rBufPos;

    nSamples = p->partSize;
    rBuf = &(p->ringBuf[p->rbCnt * (nSamples << 1)]);
    /* store input signal in buffer */
    rBuf[p->cnt] = *in;
    /* copy output signals from buffer */
    *out = p->outBuffers[0][p->cnt]; 

    /* is input buffer full ? */
    if (++p->cnt < nSamples) {
        return SP_OK;                   
    }
    /* reset buffer position */
    p->cnt = 0;
    /* calculate FFT of input */
    for (i = nSamples; i < (nSamples << 1); i++) {
        /* Zero padding */
        rBuf[i] = 0.0;
    }
    sp_fftr(&p->fft, rBuf, (nSamples << 1));
    /* update ring buffer position */
    p->rbCnt++;

    if (p->rbCnt >= p->nPartitions){ 
        p->rbCnt = 0; 
    }

    rBufPos = p->rbCnt * (nSamples << 1);
    rBuf = &(p->ringBuf[rBufPos]);
    /* PB: will only loop once since nChannels == 1*/
    for (n = 0; n < p->nChannels; n++) {
        /* multiply complex arrays */
        multiply_fft_buffers(p->tmpBuf, p->ringBuf, p->IR_Data[n],
                     nSamples, p->nPartitions, rBufPos);
        /* inverse FFT */
        sp_ifftr(&p->fft, p->tmpBuf, (nSamples << 1));
        /* copy to output buffer, overlap with "tail" of previous block */
        x = &(p->outBuffers[n][0]);
        for (i = 0; i < nSamples; i++) {
            x[i] = p->tmpBuf[i] + x[i + nSamples];
            x[i + nSamples] = p->tmpBuf[i + nSamples];
        }
    }
    return SP_OK;
}

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	/* pi */
#endif

#define tpd360  0.0174532925199433

int sp_ftbl_create(sp_data *sp, sp_ftbl **ft, size_t size)
{
    *ft = malloc(sizeof(sp_ftbl));
    sp_ftbl *ftp = *ft;
    ftp->size = size;
    ftp->tbl = malloc(sizeof(SPFLOAT) * (size + 1));
    memset(ftp->tbl, 0, sizeof(SPFLOAT) * (size + 1));
    ftp->sicvt = 1.0 * SP_FT_MAXLEN / sp->sr;
    ftp->lobits = log2(SP_FT_MAXLEN / size);
    ftp->lomask = (2^ftp->lobits) - 1;
    ftp->lodiv = 1.0 / pow(2, ftp->lobits);
    return SP_OK;
}

int sp_ftbl_destroy(sp_ftbl **ft)
{
    sp_ftbl *ftp = *ft;
    free(ftp->tbl);
    free(*ft);
    return SP_OK;
}

int sp_gen_vals(sp_data *sp, sp_ftbl *ft, const char *string)
{
    char *str1 = NULL, *token = NULL, *t;
    char *saveptr1 = NULL;
    int j;
    char *d;
    d = malloc(sizeof(char) + 1);
    d[0] = ' ';
    d[1] = 0;
    t = malloc(sizeof(char) * (strlen(string) + 1));
    strcpy(t, string);
    for (j = 0, str1 = t; ; j++, str1 = NULL) {
        token = strtok_r(str1, d, &saveptr1);
        if (token == NULL)
            break;
        if(ft->size < j + 1){
            ft->tbl = realloc(ft->tbl, sizeof(SPFLOAT) * (ft->size + 2));
            ft->size++;
        }
        ft->tbl[j] = atof(token);
    }

    free(t);
    free(d);
    return SP_OK;
}

int sp_gen_sine(sp_data *sp, sp_ftbl *ft)
{
    unsigned long i;
    SPFLOAT step = 2 * M_PI / ft->size;
    for(i = 0; i < ft->size; i++){
        ft->tbl[i] = sin(i * step);
    }
    return SP_OK;
}

#ifndef NO_LIBSNDFILE
/*TODO: add error checking, make tests */
//int sp_gen_file(sp_data *sp, sp_ftbl *ft, const char *filename)
//{
//    SF_INFO info;
//    info.format = 0;
//    SNDFILE *snd = sf_open(filename, SFM_READ, &info);
//    sf_readf_float(snd, ft->tbl, ft->size);
//    sf_close(snd);
//    return SP_OK;
//}
//
//int sp_ftbl_loadfile(sp_data *sp, sp_ftbl **ft, const char *filename)
//{
//    *ft = malloc(sizeof(sp_ftbl));
//    sp_ftbl *ftp = *ft;
//    SF_INFO info;
//    info.format = 0;
//    SNDFILE *snd = sf_open(filename, SFM_READ, &info);
//    size_t size = info.frames * info.channels;
//    ftp->size = size;
//    ftp->tbl = malloc(sizeof(SPFLOAT) * (size + 1));
//    sf_readf_float(snd, ftp->tbl, ftp->size);
//    sf_close(snd);
//    return SP_OK;
//}
#endif

/* port of GEN10 from Csound */
int sp_gen_sinesum(sp_data *sp, sp_ftbl *ft, const char *argstring)
{
    sp_ftbl *args;
    sp_ftbl_create(sp, &args, 1);
    sp_gen_vals(sp, args, argstring);

    int32_t phs;
    SPFLOAT amp;
    int32_t flen = (int32_t)ft->size;
    SPFLOAT tpdlen = 2.0 * M_PI / (SPFLOAT) flen;

    int32_t i, n;

    for(i = (int32_t)args->size; i > 0; i--){
        amp = args->tbl[args->size - i];
        if(amp != 0) {
            for(phs = 0, n = 0; n < ft->size; n++){
                ft->tbl[n] += sin(phs * tpdlen) * amp;
                phs += i;
                phs %= flen;
            }
        }
    }
    sp_ftbl_destroy(&args);
    return SP_OK;
}

int sp_gen_line(sp_data *sp, sp_ftbl *ft, const char *argstring)
{
    uint16_t i, n = 0, seglen;
    SPFLOAT incr, amp = 0;
    SPFLOAT x1, x2, y1, y2;
    sp_ftbl *args;
    sp_ftbl_create(sp, &args, 1);
    sp_gen_vals(sp, args, argstring);

    if((args->size % 2) == 1 || args->size == 1) {
        fprintf(stderr, "Error: not enough arguments for gen_line.\n");
        sp_ftbl_destroy(&args);
        return SP_NOT_OK;
    } else if(args->size == 2) {
        for(i = 0; i < ft->size; i++) {
            ft->tbl[i] = args->tbl[1];
        }
        return SP_OK;
    }

    x1 = args->tbl[0];
    y1 = args->tbl[1];
    for(i = 2; i < args->size; i += 2) {
        x2 = args->tbl[i];
        y2 = args->tbl[i + 1];

        if(x2 < x1) {
            fprintf(stderr, "Error: x coordiates must be sequential!\n");
            break;
        }

        seglen = (x2 - x1);
        incr = (SPFLOAT)(y2 - y1) / (seglen - 1);
        amp = y1;

        while(seglen != 0){
            if(n < ft->size) {
                ft->tbl[n] = amp;
                amp += incr;
                seglen--;
                n++;
            } else {
                break;
            }
        }
        y1 = y2;
        x1 = x2;
    }

    sp_ftbl_destroy(&args);
    return SP_OK;
}

int sp_gen_xline(sp_data *sp, sp_ftbl *ft, const char *argstring)
{
    uint16_t i, n = 0, seglen;
    SPFLOAT mult, amp = 0;
    SPFLOAT x1, x2, y1, y2;
    sp_ftbl *args;
    sp_ftbl_create(sp, &args, 1);
    sp_gen_vals(sp, args, argstring);

    if((args->size % 2) == 1 || args->size == 1) {
        fprintf(stderr, "Error: not enough arguments for gen_line.\n");
        sp_ftbl_destroy(&args);
        return SP_NOT_OK;
    } else if(args->size == 2) {
        for(i = 0; i < ft->size; i++) {
            ft->tbl[i] = args->tbl[1];
        }
        return SP_OK;
    }

    x1 = args->tbl[0];
    y1 = args->tbl[1];
    for(i = 2; i < args->size; i += 2) {
        x2 = args->tbl[i];
        y2 = args->tbl[i + 1];

        if(x2 < x1) {
            fprintf(stderr, "Error: x coordiates must be sequential!\n");
            break;
        }

        if(y1 == 0) {
            y1 = 0.000001;
        }

        if(y2 == 0) {
            y2 = 0.000001;
        }

        seglen = (uint32_t)(x2 - x1);
        mult = (y2 / y1);
        mult = pow(mult, (SPFLOAT)1.0 / seglen);
        amp = y1;

        while(seglen != 0){
            if(n < ft->size) {
                ft->tbl[n] = amp;
                amp *= mult;
                seglen--;
                n++;
            } else {
                break;
            }
        }
        y1 = y2;
        x1 = x2;
    }

    sp_ftbl_destroy(&args);
    return SP_OK;

}


static SPFLOAT gaussrand(sp_randmt *p, SPFLOAT scale)
{
    int64_t r1 = -((int64_t)0xFFFFFFFFU * 6);
    int n = 12;
    SPFLOAT x;

    do {
      r1 += (int64_t)sp_randmt_compute(p);
    } while (--n);

    x = (SPFLOAT)r1;
    return (SPFLOAT)(x * ((SPFLOAT)scale * (1.0 / (3.83 * 4294967295.03125))));
}

int sp_gen_gauss(sp_data *sp, sp_ftbl *ft, SPFLOAT scale, uint32_t seed)
{
    int n;

    sp_randmt rand;

    sp_randmt_seed(&rand, NULL, seed);

    for(n = 0; n < ft->size; n++) {
        ft->tbl[n] = gaussrand(&rand, scale);
    }

    return SP_OK;
}

int sp_gen_sinecomp(sp_data *sp, sp_ftbl *ft, const char *argstring)
{
    SPFLOAT phs, inc, amp, dc, tpdlen = 2 * M_PI/ (SPFLOAT) ft->size;
    int i, n;
    
    sp_ftbl *args;
    sp_ftbl_create(sp, &args, 1);
    sp_gen_vals(sp, args, argstring);

    for(n = 0; n < args->size; n += 4) {
        inc = args->tbl[n] * tpdlen;
        amp = args->tbl[n + 1];
        phs = args->tbl[n + 2] * tpd360;
        dc = args->tbl[n + 3];

        for (i = 0; i <ft->size ; i++) {
            ft->tbl[i] += (SPFLOAT) (sin(phs) * amp + dc);
            if ((phs += inc) >= 2 * M_PI) phs -= 2 * M_PI;
        }
    }

    sp_ftbl_destroy(&args);
    return SP_OK;
}

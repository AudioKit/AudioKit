#include <stdlib.h>
#include "soundpipe.h"

int sp_progress_create(sp_progress **p)
{
    *p = malloc(sizeof(sp_progress));
    return SP_OK;
}

int sp_progress_destroy(sp_progress **p)
{
    free(*p);
    return SP_OK;
}

int sp_progress_init(sp_data *sp, sp_progress *p)
{
    p->nbars = 40;
    p->skip = 1000;
    p->counter = 0;
    p->len = (uint32_t) sp->len;
    return SP_OK;
}

int sp_progress_compute(sp_data *sp, sp_progress *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->counter == 0 || sp->pos == p->len - 1) {
        int n;
        SPFLOAT slope = 1.0 / p->nbars;
        if(sp->pos == 0) fprintf(stderr, "\e[?25l");
        SPFLOAT percent = ((SPFLOAT)sp->pos / p->len);
        fprintf(stderr, "[");
        for(n = 0; n < p->nbars; n++) {
            if(n * slope <= percent) {
                fprintf(stderr, "#");
            }else {
                fprintf(stderr, " ");
            }
        }
        fprintf(stderr, "] %.2f%%\t\r", 100 * percent);

    }
    if(sp->pos == p->len - 1) fprintf(stderr, "\n\e[?25h");
    fflush(stderr);
    p->counter++;
    p->counter %= p->skip;
    return SP_OK;
}

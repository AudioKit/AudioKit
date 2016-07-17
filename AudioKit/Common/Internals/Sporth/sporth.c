#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

typedef struct {
    plumber_data pd;
} UserData;

static void process(sp_data *sp, void *udata){
    UserData *ud = udata;
    plumber_data *pd = &ud->pd;
    plumber_compute(pd, PLUMBER_COMPUTE);
    SPFLOAT out = 0;
    int chan;
    for (chan = 0; chan < pd->nchan; chan++) {
        out = sporth_stack_pop_float(&pd->sporth.stack);
        sp->out[chan] = out;
    }
}

int main(int argc, char *argv[])
{
    UserData ud;
    plumber_init(&ud.pd);
    sporth_run(&ud.pd, argc, argv, &ud, process);
    return 0;
}

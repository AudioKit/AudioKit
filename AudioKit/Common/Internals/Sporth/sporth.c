#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

typedef struct {
    plumber_data pd;
} UserData;

static void process(sp_data *sp, void *udata){
    UserData *ud = udata;
    plumber_data *pd = &ud->pd;
    SPFLOAT out = 0;
    int chan;

    if(pd->recompile) {
        fprintf(stderr, "Recompiling!\n");
        plumber_recompile_string(&ud->pd, pd->str);
        pd->recompile = 0;
        free(pd->str);
    }
    
    plumber_compute(pd, PLUMBER_COMPUTE);

    for (chan = 0; chan < pd->nchan; chan++) {
        out = sporth_stack_pop_float(&pd->sporth.stack);
        sp->out[chan] = out;
    }

    if(pd->showprog) {
        sp_progress_compute(sp, pd->prog, NULL, NULL);
    }
}

int main(int argc, char *argv[])
{
    UserData ud;
    plumber_init(&ud.pd);
    sporth_run(&ud.pd, argc, argv, &ud, process);
    return 0;
}

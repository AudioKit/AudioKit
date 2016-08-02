#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_gen_sporth(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    plumber_data my_pd;

    uint32_t size;
    sp_data *sp;
    sp_ftbl *ft;
    char *ftname;
    char *filename;
    uint32_t n;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_SPORTH, NULL);

            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
                fprintf(stderr, "Init: not enough arguments for gen_sine\n");
                return PLUMBER_NOTOK;
            }
            filename = sporth_stack_pop_string(stack);
            size = (uint32_t) sporth_stack_pop_float(stack);
            ftname = sporth_stack_pop_string(stack);
            sp_ftbl_create(pd->sp, &ft, size);
            plumber_ftmap_add(pd, ftname, ft);
#ifdef DEBUG_MODE
            fprintf(stderr, "gen_sporth: compiling file %s to table of size %d\n", 
                    filename, size);
#endif
            plumber_register(&my_pd);
            plumber_init(&my_pd);
            sp_create(&sp);
            sp->sr = pd->sp->sr;
            my_pd.sp = sp;
            my_pd.sp->len = size;
            if(plumber_open_file(&my_pd, filename) == PLUMBER_OK) {
                if(plumber_parse(&my_pd) == PLUMBER_OK) {
                    plumber_compute(&my_pd, PLUMBER_INIT);
                    for(n = 0; n < ft->size; n++) {
                        plumber_compute(&my_pd, PLUMBER_COMPUTE);
                        ft->tbl[n] = sporth_stack_pop_float(&my_pd.sporth.stack);
                    }
                }
                plumber_close_file(&my_pd);
            } 
            plumber_clean(&my_pd);
            sp_destroy(&sp);
            break;

        case PLUMBER_INIT:
            filename = sporth_stack_pop_string(stack);
            size = sporth_stack_pop_float(stack);
            ftname = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

typedef struct {
    sp_gbuzz *gbuzz;
    sp_ftbl *ft;
} sporth_gbuzz_d;

int sporth_gbuzz(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT nharm;
    SPFLOAT lharm;
    SPFLOAT mul;
    sporth_gbuzz_d *gbuzz;

    switch(pd->mode) {
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "gbuzz: Creating\n");
#endif
            gbuzz = malloc(sizeof(sporth_gbuzz_d));
            sp_ftbl_create(pd->sp, &gbuzz->ft, 8192);
            sp_gbuzz_create(&gbuzz->gbuzz);
            plumber_add_ugen(pd, SPORTH_GBUZZ, gbuzz);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for gbuzz\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mul = sporth_stack_pop_float(stack);
            lharm = sporth_stack_pop_float(stack);
            nharm = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "gbuzz: Initialising\n");
#endif
            mul = sporth_stack_pop_float(stack);
            lharm = sporth_stack_pop_float(stack);
            nharm = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            gbuzz = pd->last->ud;
            sp_gen_sine(pd->sp, gbuzz->ft);
            sp_gbuzz_init(pd->sp, gbuzz->gbuzz, gbuzz->ft, 0.25);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            mul = sporth_stack_pop_float(stack);
            lharm = sporth_stack_pop_float(stack);
            nharm = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            gbuzz = pd->last->ud;

            gbuzz->gbuzz->freq = freq;
            gbuzz->gbuzz->amp = amp;
            gbuzz->gbuzz->nharm = nharm;
            gbuzz->gbuzz->lharm = lharm;
            gbuzz->gbuzz->mul = mul;
            SPFLOAT dumb = 0;
            sp_gbuzz_compute(pd->sp, gbuzz->gbuzz, &dumb, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            gbuzz = pd->last->ud;
            sp_gbuzz_destroy(&gbuzz->gbuzz);
            sp_ftbl_destroy(&gbuzz->ft);
            free(gbuzz);
            break;
        default:
            fprintf(stderr, "gbuzz: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

#include <stdlib.h>
#include "plumber.h"

typedef struct {
    sp_vdelay *vdelay;
    SPFLOAT prev;
} sporth_vdelay_d;

int sporth_vdelay(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT maxdel;
    SPFLOAT feedback;
    SPFLOAT del;
    sporth_vdelay_d *vd;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "vdelay: Creating\n");
#endif
            vd = malloc(sizeof(sporth_vdelay_d));
            sp_vdelay_create(&vd->vdelay);
            plumber_add_ugen(pd, SPORTH_VDELAY, vd);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for vdelay\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            maxdel = sporth_stack_pop_float(stack);
            del = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            vd->prev = 0;
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "vdelay: Initialising\n");
#endif

            maxdel = sporth_stack_pop_float(stack);
            del = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            vd = pd->last->ud;
            vd->prev = 0;
            sp_vdelay_init(pd->sp, vd->vdelay, maxdel);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            vd = pd->last->ud;
            maxdel = sporth_stack_pop_float(stack);
            del = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            in += vd->prev * feedback;
            vd->vdelay->del = del;
            sp_vdelay_compute(pd->sp, vd->vdelay, &in, &out);
            sporth_stack_push_float(stack, out);
            vd->prev = out;
            break;
        case PLUMBER_DESTROY:
            vd= pd->last->ud;
            sp_vdelay_destroy(&vd->vdelay);
            free(vd);
            break;
        default:
            fprintf(stderr, "vdelay: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

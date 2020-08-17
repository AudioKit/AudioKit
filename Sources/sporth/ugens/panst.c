#include "plumber.h"

int sporth_panst(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in_left;
    SPFLOAT in_right;
    SPFLOAT out_left;
    SPFLOAT out_right;
    SPFLOAT pan;
    sp_panst *panst;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "panst: Creating\n");
#endif

            sp_panst_create(&panst);
            plumber_add_ugen(pd, SPORTH_PAN, panst);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for panst\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            pan = sporth_stack_pop_float(stack);
            in_right = sporth_stack_pop_float(stack);
            in_left = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "panst: Initialising\n");
#endif
            pan = sporth_stack_pop_float(stack);
            in_right = sporth_stack_pop_float(stack);
            in_left = sporth_stack_pop_float(stack);
            panst = pd->last->ud;
            sp_panst_init(pd->sp, panst);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            pan = sporth_stack_pop_float(stack);
            in_right = sporth_stack_pop_float(stack);
            in_left = sporth_stack_pop_float(stack);
            panst = pd->last->ud;
            panst->pan = pan;
            sp_panst_compute(pd->sp, panst, &in_left, &out_left, &out_left, &out_right);
            sporth_stack_push_float(stack, out_left);
            sporth_stack_push_float(stack, out_right);
            break;
        case PLUMBER_DESTROY:
            panst = pd->last->ud;
            sp_panst_destroy(&panst);
            break;
        default:
            plumber_print(pd, "panst: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}


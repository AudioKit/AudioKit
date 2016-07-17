#include "plumber.h"

int sporth_count(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT count;
    SPFLOAT mode;
    sp_count *cnt;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "count: Creating\n");
#endif

            sp_count_create(&cnt);
            plumber_add_ugen(pd, SPORTH_COUNT, cnt);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for count\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mode = sporth_stack_pop_float(stack);
            count = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "count: Initialising\n");
#endif
            mode = sporth_stack_pop_float(stack);
            count = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            cnt = pd->last->ud;
            sp_count_init(pd->sp, cnt);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            mode = sporth_stack_pop_float(stack);
            count = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            cnt = pd->last->ud;
            cnt->count = count;
            cnt->mode = mode;
            sp_count_compute(pd->sp, cnt, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            cnt = pd->last->ud;
            sp_count_destroy(&cnt);
            break;
        default:
            fprintf(stderr, "count: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

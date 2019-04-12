#include "plumber.h"

int sporth_tone(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT hp;
    sp_tone *tone;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tone: Creating\n");
#endif
            sp_tone_create(&tone);
            plumber_add_ugen(pd, SPORTH_TONE, tone);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tone\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tone: Initialising\n");
#endif
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            tone = pd->last->ud;
            sp_tone_init(pd->sp, tone);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            tone = pd->last->ud;
            tone->hp = hp;
            sp_tone_compute(pd->sp, tone, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tone = pd->last->ud;
            sp_tone_destroy(&tone);
            break;
        default:
            plumber_print(pd, "tone: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

#include "plumber.h"

int sporth_phaser(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input1;
    SPFLOAT input2;
    SPFLOAT out_left;
    SPFLOAT out_right;
    SPFLOAT MaxNotch1Freq;
    SPFLOAT MinNotch1Freq;
    SPFLOAT Notch_width;
    SPFLOAT NotchFreq;
    SPFLOAT VibratoMode;
    SPFLOAT depth;
    SPFLOAT feedback_gain;
    SPFLOAT invert;
    SPFLOAT level;
    SPFLOAT lfobpm;
    sp_phaser *phaser;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "phaser: Creating\n");
#endif

            sp_phaser_create(&phaser);
            plumber_add_ugen(pd, SPORTH_PHASER, phaser);
            if(sporth_check_args(stack, "ffffffffffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for phaser\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            lfobpm = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            invert = sporth_stack_pop_float(stack);
            feedback_gain = sporth_stack_pop_float(stack);
            depth = sporth_stack_pop_float(stack);
            VibratoMode = sporth_stack_pop_float(stack);
            NotchFreq = sporth_stack_pop_float(stack);
            Notch_width = sporth_stack_pop_float(stack);
            MinNotch1Freq = sporth_stack_pop_float(stack);
            MaxNotch1Freq = sporth_stack_pop_float(stack);
            input1 = sporth_stack_pop_float(stack);
            input2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "phaser: Initialising\n");
#endif

            lfobpm = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            invert = sporth_stack_pop_float(stack);
            feedback_gain = sporth_stack_pop_float(stack);
            depth = sporth_stack_pop_float(stack);
            VibratoMode = sporth_stack_pop_float(stack);
            NotchFreq = sporth_stack_pop_float(stack);
            Notch_width = sporth_stack_pop_float(stack);
            MinNotch1Freq = sporth_stack_pop_float(stack);
            MaxNotch1Freq = sporth_stack_pop_float(stack);
            input1 = sporth_stack_pop_float(stack);
            input2 = sporth_stack_pop_float(stack);
            phaser = pd->last->ud;
            sp_phaser_init(pd->sp, phaser);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            lfobpm = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            invert = sporth_stack_pop_float(stack);
            feedback_gain = sporth_stack_pop_float(stack);
            depth = sporth_stack_pop_float(stack);
            VibratoMode = sporth_stack_pop_float(stack);
            NotchFreq = sporth_stack_pop_float(stack);
            Notch_width = sporth_stack_pop_float(stack);
            MinNotch1Freq = sporth_stack_pop_float(stack);
            MaxNotch1Freq = sporth_stack_pop_float(stack);
            input1 = sporth_stack_pop_float(stack);
            input2 = sporth_stack_pop_float(stack);
            phaser = pd->last->ud;
            *phaser->MaxNotch1Freq = MaxNotch1Freq;
            *phaser->MinNotch1Freq = MinNotch1Freq;
            *phaser->Notch_width = Notch_width;
            *phaser->NotchFreq = NotchFreq;
            *phaser->VibratoMode = VibratoMode;
            *phaser->depth = depth;
            *phaser->feedback_gain = feedback_gain;
            *phaser->invert = invert;
            *phaser->level = level;
            *phaser->lfobpm = lfobpm;
            sp_phaser_compute(pd->sp, phaser, &input1, &input2, &out_left, &out_right);
            sporth_stack_push_float(stack, out_left);
            sporth_stack_push_float(stack, out_right);
            break;
        case PLUMBER_DESTROY:
            phaser = pd->last->ud;
            sp_phaser_destroy(&phaser);
            break;
        default:
            plumber_print(pd, "phaser: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

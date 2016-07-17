#include "plumber.h"

int sporth_zitarev(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input_1;
    SPFLOAT input_2;
    SPFLOAT out_1;
    SPFLOAT out_2;
    SPFLOAT in_delay;
    SPFLOAT lf_x;
    SPFLOAT rt60_low;
    SPFLOAT rt60_mid;
    SPFLOAT hf_damping;
    SPFLOAT eq1_freq;
    SPFLOAT eq1_level;
    SPFLOAT eq2_freq;
    SPFLOAT eq2_level;
    SPFLOAT mix;
    SPFLOAT level;
    sp_zitarev *zitarev;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "zitarev: Creating\n");
#endif

            sp_zitarev_create(&zitarev);
            plumber_add_ugen(pd, SPORTH_ZITAREV, zitarev);
            if(sporth_check_args(stack, "fffffffffffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for zitarev\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            level = sporth_stack_pop_float(stack);
            mix = sporth_stack_pop_float(stack);
            eq2_level = sporth_stack_pop_float(stack);
            eq2_freq = sporth_stack_pop_float(stack);
            eq1_level = sporth_stack_pop_float(stack);
            eq1_freq = sporth_stack_pop_float(stack);
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            lf_x = sporth_stack_pop_float(stack);
            in_delay = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "zitarev: Initialising\n");
#endif
            level = sporth_stack_pop_float(stack);
            mix = sporth_stack_pop_float(stack);
            eq2_level = sporth_stack_pop_float(stack);
            eq2_freq = sporth_stack_pop_float(stack);
            eq1_level = sporth_stack_pop_float(stack);
            eq1_freq = sporth_stack_pop_float(stack);
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            lf_x = sporth_stack_pop_float(stack);
            in_delay = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            zitarev = pd->last->ud;
            sp_zitarev_init(pd->sp, zitarev);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            level = sporth_stack_pop_float(stack);
            mix = sporth_stack_pop_float(stack);
            eq2_level = sporth_stack_pop_float(stack);
            eq2_freq = sporth_stack_pop_float(stack);
            eq1_level = sporth_stack_pop_float(stack);
            eq1_freq = sporth_stack_pop_float(stack);
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            lf_x = sporth_stack_pop_float(stack);
            in_delay = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            zitarev = pd->last->ud;
            *zitarev->in_delay = in_delay;
            *zitarev->lf_x = lf_x;
            *zitarev->rt60_low = rt60_low;
            *zitarev->rt60_mid = rt60_mid;
            *zitarev->hf_damping = hf_damping;
            *zitarev->eq1_freq = eq1_freq;
            *zitarev->eq1_level = eq1_level;
            *zitarev->eq2_freq = eq2_freq;
            *zitarev->eq2_level = eq2_level;
            *zitarev->mix = mix;
            *zitarev->level = level;
            sp_zitarev_compute(pd->sp, zitarev, &input_1, &input_2, &out_1, &out_2);
            sporth_stack_push_float(stack, out_1);
            sporth_stack_push_float(stack, out_2);
            break;
        case PLUMBER_DESTROY:
            zitarev = pd->last->ud;
            sp_zitarev_destroy(&zitarev);
            break;
        default:
            fprintf(stderr, "zitarev: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_zrev(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input_1;
    SPFLOAT input_2;
    SPFLOAT out_1;
    SPFLOAT out_2;
    SPFLOAT rt60_low;
    SPFLOAT rt60_mid;
    SPFLOAT hf_damping;
    sp_zitarev *zitarev;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "zrev: Creating\n");
#endif

            sp_zitarev_create(&zitarev);
            plumber_add_ugen(pd, SPORTH_ZREV, zitarev);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for zitarev\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "zrev: Initialising\n");
#endif

            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for zitarev\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            zitarev = pd->last->ud;
            sp_zitarev_init(pd->sp, zitarev);
            *zitarev->level = 0;
            *zitarev->mix = 1;
            *zitarev->in_delay = 10;
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            hf_damping = sporth_stack_pop_float(stack);
            rt60_mid = sporth_stack_pop_float(stack);
            rt60_low = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            zitarev = pd->last->ud;
            *zitarev->rt60_low = rt60_low;
            *zitarev->rt60_mid = rt60_mid;
            *zitarev->hf_damping = hf_damping;
            sp_zitarev_compute(pd->sp, zitarev, &input_1, &input_2, &out_1, &out_2);
            sporth_stack_push_float(stack, out_1);
            sporth_stack_push_float(stack, out_2);
            break;
        case PLUMBER_DESTROY:
            zitarev = pd->last->ud;
            sp_zitarev_destroy(&zitarev);
            break;
        default:
            fprintf(stderr, "zrev: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

#include "plumber.h"

int sporth_brown(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sp_brown *brown;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "brown: Creating\n");
#endif

            sp_brown_create(&brown);
            plumber_add_ugen(pd, SPORTH_BROWN, brown);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "brown: Initialising\n");
#endif

            brown = pd->last->ud;
            sp_brown_init(pd->sp, brown);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            brown = pd->last->ud;
            sp_brown_compute(pd->sp, brown, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            brown = pd->last->ud;
            sp_brown_destroy(&brown);
            break;
        default:
            plumber_print(pd, "brown: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

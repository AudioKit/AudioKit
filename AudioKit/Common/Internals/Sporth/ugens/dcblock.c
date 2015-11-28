#include "plumber.h"

int sporth_dcblock(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT out;
    SPFLOAT in;
    sp_dcblock *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "Creating module dcblk\n");
#endif
            sp_dcblock_create(&data);
            plumber_add_module(pd, SPORTH_DCBLK, sizeof(sp_dcblock), data);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for dcblk\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            in = sporth_stack_pop_float(stack);
            sp_dcblock_init(pd->sp, data);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for dcblk\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            data = pd->last->ud;
            in = sporth_stack_pop_float(stack);
            sp_dcblock_compute(pd->sp, data, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_dcblock_destroy(&data);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_NOTOK;
}

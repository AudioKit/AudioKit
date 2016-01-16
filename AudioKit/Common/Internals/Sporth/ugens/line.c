#include <stdlib.h>
#include "plumber.h"

typedef struct {
    SPFLOAT ia, idur, ib;
    SPFLOAT val, incr;
} sporth_line_d;

int sporth_line(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT ia = 0;
    SPFLOAT idur = 0;
    SPFLOAT ib = 0;
    SPFLOAT out = 0;
    sp_line *line;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "line: Creating\n");
#endif
            sp_line_create(&line);
            plumber_add_ugen(pd, SPORTH_LINE, line);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for line\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ib = sporth_stack_pop_float(stack);
            idur = sporth_stack_pop_float(stack);
            ia = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "line: Initialising\n");
#endif

            line = pd->last->ud;
            ib = sporth_stack_pop_float(stack);
            idur = sporth_stack_pop_float(stack);
            ia = sporth_stack_pop_float(stack);
            sp_line_init(pd->sp, line, ia, idur, ib);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            line = pd->last->ud;
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sp_line_compute(pd->sp, line, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            line = pd->last->ud;
            sp_line_destroy(&line);
            break;
        default:
            fprintf(stderr, "line: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

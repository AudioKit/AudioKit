#include <stdlib.h>
#include "plumber.h"

typedef struct {
    SPFLOAT ia, idur, ib;
    SPFLOAT val, incr; 
} sporth_line_d;

static void line_init(plumber_data *pd, sporth_line_d *line)
{
    SPFLOAT onedsr = 1.0 / pd->sp->sr;
    line->incr = (SPFLOAT)((line->ib - line->ia) / (line->idur)) * onedsr;
    line->val = line->ia;
}

SPFLOAT line_compute(sporth_line_d *line) 
{
    SPFLOAT val = line->val;
    line->val += line->incr;
    return val;
}

int sporth_line(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    
    sporth_line_d *line;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "line: Creating\n");
#endif
            line = malloc(sizeof(sporth_line_d));
            plumber_add_module(pd, SPORTH_LINE, sizeof(sporth_line_d), line);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "line: Initialising\n");
#endif

            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for line\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            line = pd->last->ud;
            line->ib = sporth_stack_pop_float(stack);
            line->idur = sporth_stack_pop_float(stack);
            line->ia = sporth_stack_pop_float(stack);
            line_init(pd, line);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            line = pd->last->ud;
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, line_compute(line));
            break;
        case PLUMBER_DESTROY:
            line = pd->last->ud;
            free(line);
            break;
        default:
            fprintf(stderr, "line: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

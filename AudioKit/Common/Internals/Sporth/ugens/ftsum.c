
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

typedef struct {
    sp_ftbl *ft;
} sporth_ftsum_d;

int sporth_ftsum(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    uint32_t start, end, tmp, i;
    char *ftname;
    sporth_ftsum_d *ftsum;
    SPFLOAT out = 0;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "ftsum: creating... \n");
#endif
            ftsum = malloc(sizeof(sporth_ftsum_d));
            plumber_add_ugen(pd, SPORTH_FTSUM, ftsum);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                stack->error++;
                plumber_print(pd,"Invalid arguments for ftsum.\n");
                return PLUMBER_NOTOK;
            }

            ftname = sporth_stack_pop_string(stack);
            end = (uint32_t) sporth_stack_pop_float(stack);
            start = (uint32_t) sporth_stack_pop_float(stack);

            if(plumber_ftmap_search(pd, ftname, &ftsum->ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
            ftname = sporth_stack_pop_string(stack);
            end = (uint32_t) sporth_stack_pop_float(stack);
            start = (uint32_t) sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_COMPUTE:
            ftsum = pd->last->ud;
            end = (uint32_t) sporth_stack_pop_float(stack);
            start = (uint32_t) sporth_stack_pop_float(stack);
            if(end < start) {
                tmp = end;
                end = start;
                start = tmp;
            } else if(end > ftsum->ft->size) {
                end = (uint32_t)ftsum->ft->size;
            }
            out = 0;
            for(i = start; i <= end; i++) {
                out += ftsum->ft->tbl[i];
            }
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            ftsum = pd->last->ud;
            free(ftsum);
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

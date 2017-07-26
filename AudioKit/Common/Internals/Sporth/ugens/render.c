#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

typedef struct {
    plumbing pipes;
    plumber_ftentry ft[256];
} sporth_render_d;


int sporth_render(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sporth_render_d *rend;
    FILE *tmp, *fp;
    plumber_ftentry *old_ftmap;
    const char *filename;
    int rc = PLUMBER_OK;

    switch(pd->mode){
        case PLUMBER_CREATE:
            rend = malloc(sizeof(sporth_render_d));
            plumber_add_ugen(pd, SPORTH_RENDER, rend);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd, "Not enough arguments for render.\n");
                return PLUMBER_NOTOK;
            }

            filename = sporth_stack_pop_string(stack);
            fp = fopen(filename, "r");
            if(fp == NULL) {
                plumber_print(pd, 
                        "There was an issue opening the file \"%s\"\n",
                        filename);
                return PLUMBER_NOTOK;
            }
            tmp = pd->fp;
            old_ftmap = pd->ftmap;
            pd->fp = fp;
            pd->ftmap = rend->ft;
            plumber_ftmap_init(pd);
            plumbing_init(&rend->pipes);
            rc = plumbing_parse(pd, &rend->pipes);
            fclose(fp);
            pd->fp = tmp;
            pd->ftmap = old_ftmap;
            return rc;

        case PLUMBER_INIT:
            rend = pd->last->ud;
            old_ftmap = pd->ftmap;
            pd->ftmap = rend->ft;
            filename = sporth_stack_pop_string(stack);
            plumbing_compute(pd, &rend->pipes, PLUMBER_INIT);
            pd->ftmap = old_ftmap;
            break;

        case PLUMBER_COMPUTE:
            rend = pd->last->ud;
            old_ftmap = pd->ftmap;
            pd->ftmap = rend->ft;
            plumbing_compute(pd, &rend->pipes, PLUMBER_COMPUTE);
            pd->ftmap = old_ftmap;
            break;

        case PLUMBER_DESTROY:
            rend = pd->last->ud;
            old_ftmap = pd->ftmap;
            pd->ftmap = rend->ft;
            plumbing_compute(pd, &rend->pipes, PLUMBER_DESTROY);
            plumbing_destroy(&rend->pipes);
            plumber_ftmap_destroy(pd);
            pd->ftmap = old_ftmap;
            free(rend);
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

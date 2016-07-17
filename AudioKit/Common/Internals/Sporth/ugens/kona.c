#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "plumber.h"

#ifdef BUILD_KONA
#include "kona.h"
#endif

int sporth_kona(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

#ifdef BUILD_KONA
    int n; 
    sp_ftbl *ft;
    char *str;
    char *ftname;
#endif

    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "Kona: create mode\n");
#endif
            plumber_add_ugen(pd, SPORTH_KONA, NULL);

#ifdef BUILD_KONA
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                fprintf(stderr, "Kona: not enough arguments.\n");
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            ftname = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            fprintf(stderr, "Evaluating Kona string '%s'\n", str);
#endif
            srand(time(NULL));
            ksk("", 0);
            K ints = ksk(str, 0);
            I *tbl = KI(ints);
            sp_ftbl_create(pd->sp, &ft, ints->n);
            for(n = 0; n < ft->size; n++) {
                ft->tbl[n] = (SPFLOAT)tbl[n];
            }
            plumber_ftmap_add(pd, ftname, ft);
            free(ftname);
            free(str);
#endif
            break;

        case PLUMBER_INIT:

#ifdef BUILD_KONA
            ftname = sporth_stack_pop_string(stack);
            str = sporth_stack_pop_string(stack);
            free(str);
            free(ftname);
#endif
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

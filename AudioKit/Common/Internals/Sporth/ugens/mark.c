
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_markleft(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MARKLEFT, NULL);
        default:
           break;
    }
    return PLUMBER_OK;
}
int sporth_markright(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MARKRIGHT, NULL);
        default:
           break;
    }
    return PLUMBER_OK;
}

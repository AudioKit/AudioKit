#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "h/sporth.h"

#define LENGTH(x) ((int)(sizeof(x) / sizeof *(x)))

int sporth_register_func(sporth_data *sporth, sporth_func *flist)
{
    sporth->flist = flist;
    uint32_t i = 0;
    while(sporth->flist[i].name != NULL) {
#ifdef DEBUG_MODE
       fprintf(stderr,"Registering function \"%s\" at position %d\n", 
               sporth->flist[i].name, i + SPORTH_FOFFSET);
#endif
        sporth_htable_add(&sporth->dict, sporth->flist[i].name, i);
        i++;
    }
    sporth->nfunc = i;
    return SPORTH_OK;
}

int sporth_exec(sporth_data *sporth, const char *keyword)
{
    uint32_t id;
    if(sporth_search(&sporth->dict, keyword, &id) != SPORTH_OK) {
       fprintf(stderr,"Could not find function called '%s'.\n", keyword);
        return SPORTH_NOTOK;
    }
#ifdef DEBUG_MODE
   fprintf(stderr,"Executing function \"%s\" (id %d)\n", keyword, id);
#endif
   return sporth->flist[id].func(&sporth->stack, sporth->flist[id].ud);
}


int sporth_check_args(sporth_stack *stack, const char *args)
{
    if(stack->error > 0) return SPORTH_NOTOK;

    int len = (int) strlen(args);
    int i;
    if(len > stack->pos) {
       fprintf(stderr,"Expected %d arguments on the stack, but there are only %d!\n",
                len, stack->pos);
        stack->error++;
        return SPORTH_NOTOK;
    }
    int pos = stack->pos - len;
    for(i = 0; i < len; i++) {
        switch(args[i]) {
            case 'f':
                if(stack->stack[pos].type != SPORTH_FLOAT) {
                   fprintf(stderr,"Argument %d was expecting a float\n", i);
                    stack->error++;
                    return SPORTH_NOTOK;
                }
                break;
            case 's':
                if(stack->stack[pos].type != SPORTH_STRING) {
                   fprintf(stderr,"Argument %d was expecting a string, got value %g instead\n",
                            i, stack->stack[pos].fval);
                    stack->error++;
                    return SPORTH_NOTOK;
                }
                break;
            case 'n':
                break;
        }
        pos++;
    }

    return SPORTH_OK;
}

int sporth_init(sporth_data *sporth)
{
    sporth_stack_init(&sporth->stack);
    sporth_htable_init(&sporth->dict);
    return SPORTH_OK;
}

int sporth_destroy(sporth_data *sporth)
{
    sporth_htable_destroy(&sporth->dict);
    return SPORTH_OK;
}


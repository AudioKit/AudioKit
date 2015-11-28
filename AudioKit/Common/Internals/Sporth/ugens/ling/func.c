#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "sporth.h"
#include "ling.h"

#define LENGTH(x) ((int)(sizeof(x) / sizeof *(x)))

int ling_register_func(ling_data *ld, ling_func *flist)
{
    
    ld->flist = flist;
    uint32_t i = 0;
    while(ld->flist[i].name != NULL) {
#ifdef DEBUG_MODE
       fprintf(stderr,"Registering function \"%s\" at position %d\n", ld->flist[i].name, i);
#endif
        sporth_htable_add(&ld->dict, ld->flist[i].name, i);
        i++;
    }
    ld->nfunc = i;
    return LING_OK;
}

int ling_exec(ling_data *ld, const char *keyword)
{
    uint32_t id;
    if(sporth_search(&ld->dict, keyword, &id) != SPORTH_OK) {
       fprintf(stderr,"Could not find function called '%s'.\n", keyword);
        return LING_NOTOK;
    }
#ifdef DEBUG_MODE
   fprintf(stderr,"Executing function \"%s\"\n", keyword);
#endif
    ld->flist[id].func(&ld->stack, ld->flist[id].ud);
    return LING_OK;
}


int ling_check_args(ling_stack *stack, const char *args)
{
    //if(stack->error > 0) return LING_NOTOK;

    //int len = strlen(args);
    //int i;
    //if(len > stack->pos) {
    //   fprintf(stderr,"Expected %d arguments on the stack, but there are only %d!\n",
    //            len, stack->pos);
    //    stack->error++;
    //    return LING_NOTOK;
    //}
    //int pos = stack->pos - len;
    //for(i = 0; i < len; i++) {
    //    switch(args[i]) {
    //        case 'f':
    //            if(stack->stack[pos].type != LING_FLOAT) {
    //               fprintf(stderr,"Argument %d was expecting a float\n", i);
    //                stack->error++;
    //                return LING_NOTOK;
    //            }
    //            break;
    //    }
    //    pos++;
    //}

    return LING_OK;
}

int ling_init(ling_data *ld)
{
    ling_stack_init(&ld->stack);
    ld->t = 0;
    sporth_htable_init(&ld->dict);
    ling_seq_init(&ld->seq);
    return LING_OK;
}

int ling_destroy(ling_data *ld)
{
    sporth_htable_destroy(&ld->dict);
    ling_seq_destroy(&ld->seq);
    free(ld->flist);
    return LING_OK;
}


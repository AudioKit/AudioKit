#include <stdlib.h>
#include "string.h"
#include "plumber.h"
#include "ling.h"

typedef struct {
    ling_data ling;
    uint32_t val;
    uint32_t mode;
    char bin[32];
    uint32_t pos;
    uint32_t N;
} sp_ling;

static void num_to_bin(uint32_t val, char *out, int size) 
{
    uint32_t n;
    for(n = 1; n <= size; n++) {
        out[n - 1] = (val & (1 << (n - 1))) >> (n - 1);
    }
}

int sporth_ling(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT tick = 0; 
    sp_ling *ling; 
    ling_func *fl = NULL; 
    char *str;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "ling: Creating\n");
#endif
            ling = malloc(sizeof(sp_ling));
            plumber_add_module(pd, SPORTH_LING, sizeof(sp_ling), ling);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "ling: Initialising\n");
#endif

            if(sporth_check_args(stack, "fffs") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for ling\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ling = pd->last->ud;

            str = sporth_stack_pop_string(stack);
            ling->mode = sporth_stack_pop_float(stack);
            ling->N = (uint32_t) sporth_stack_pop_float(stack);
            tick = sporth_stack_pop_float(stack);
            ling_init(&ling->ling);
            fl = ling_create_flist(&ling->ling);
            ling_register_func(&ling->ling, fl);
            ling->val = 0;
            ling->pos = 0;
            sporth_stack_push_float(stack, 0);
#ifdef DEBUG_MODE
            printf("ling: the string is %s\n", str);
#endif
            ling_parse_line(&ling->ling, str);
            free(str);
            break;
        case PLUMBER_COMPUTE:
            ling = pd->last->ud;
            ling->mode = sporth_stack_pop_float(stack);
            ling->N = (uint32_t) sporth_stack_pop_float(stack);
            tick = sporth_stack_pop_float(stack);
            switch(ling->mode) {
                case 0:
                    if(tick != 0) {
                        ling_seq_run(&ling->ling);
                        ling->val = ling_stack_pop(&ling->ling.stack);
                        ling->ling.t++;
                    } 
                    break;
                case 1:
                    if(tick != 0 ) {
                        if(ling->N <= 0 || ling->N > 32) ling->N = 1;
                        if(ling->pos == 0) {
                            ling_seq_run(&ling->ling);
                            ling->val = ling_stack_pop(&ling->ling.stack);
                            ling->ling.t++;
                            num_to_bin(ling->val, ling->bin, ling->N);
                        }
                        ling->val = ling->bin[ling->pos];
                        ling->pos++;
                        ling->pos %= ling->N;
                    } else {
                        //fprintf(stderr, "we are here...\n");
                        ling->val = 0;
                    }
                    break;
                default: 
                    break;
            }
            sporth_stack_push_float(stack, (SPFLOAT)ling->val);
            break;
        case PLUMBER_DESTROY:
            ling = pd->last->ud;
            ling_destroy(&ling->ling);
            free(ling);
            break;
        default:
            fprintf(stderr, "ling: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}


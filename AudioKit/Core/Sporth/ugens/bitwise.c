#include <stdio.h>

#include "plumber.h"

int sporth_and(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_AND, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 & v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 & v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 & v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_or(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_OR, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 | v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 | v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 | v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_leftshift(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_LEFTSHIFT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 << v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 << v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 << v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_rightshift(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_RIGHTSHIFT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 >> v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 >> v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 >> v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_xor(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_XOR, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 ^ v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 ^ v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 ^ v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_mod(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MOD, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 % v2);
            break;
        case PLUMBER_INIT:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 % v2);
            break;
        case PLUMBER_COMPUTE:
            v2 = sporth_stack_pop_float(stack);
            v1 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 % v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

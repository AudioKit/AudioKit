#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "plumber.h"

int sporth_mix(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT val = 0;
    SPFLOAT sum = 0;
    int n;
    int count;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MIX, NULL);
            count = stack->pos;
            if(count > 1) {
                for(n = 1; n <= count; n++){
                    val = sporth_stack_pop_float(stack);
                }
                sporth_stack_push_float(stack, val);
            }
            break;
        case PLUMBER_INIT:
            count = stack->pos;
            if(count > 1) {
                for(n = 1; n <= count; n++){
                    val = sporth_stack_pop_float(stack);
                }
                sporth_stack_push_float(stack, val);
            }
            break;
        case PLUMBER_COMPUTE:
            count = stack->pos;
            if(count > 1) {
                for(n = 1; n <= count; n++){
                    val = sporth_stack_pop_float(stack);
                    sum += val;
                }
                sporth_stack_push_float(stack, sum);
            }

            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_drop(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_DROP, NULL);
            sporth_stack_pop_float(stack);
            break;
        case PLUMBER_INIT:
            sporth_stack_pop_float(stack);
            break;
        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_rot(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT v1, v2, v3;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_ROT, NULL);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                stack->error++;
                return SPORTH_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            v3 = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            v3 = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, v2);
            sporth_stack_push_float(stack, v1);
            sporth_stack_push_float(stack, v3);

            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            v3 = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, v2);
            sporth_stack_push_float(stack, v1);
            sporth_stack_push_float(stack, v3);

            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_dup(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT val = 0;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_DUP, NULL);
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_COMPUTE:
            if(stack->pos == 0) {
               fprintf(stderr,"Nothing to duplicate\n");
            } else {

                val = sporth_stack_pop_float(stack);
                sporth_stack_push_float(stack, val);
                sporth_stack_push_float(stack, val);
            }
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_swap(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SWAP, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1);
            sporth_stack_push_float(stack, v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_constant(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    float val;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_CONSTANT, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_COMPUTE:
            if(pd->sp->pos == 0) {
                val = sporth_stack_pop_float(stack);
            } else {
                val = sporth_stack_pop_float(stack);
                sporth_stack_pop_float(stack);
            }
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

typedef struct {
    sp_osc *osc;
    sp_ftbl *ft;
} sporth_sine_d;

int sporth_sine(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT amp, freq;
    SPFLOAT out;
    sporth_sine_d *data;
    plumber_pipe *pipe;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
           fprintf(stderr,"creating sine function... \n");
#endif
            data = malloc(sizeof(sporth_sine_d));
            sp_osc_create(&data->osc);
            sp_ftbl_create(pd->sp, &data->ft, 4096);
            plumber_add_ugen(pd, SPORTH_SINE, data);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr, "returning error SPORTH_NOTOK\n");
                return PLUMBER_NOTOK;
            }

            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            sp_gen_sine(pd->sp, data->ft);
            sp_osc_init(pd->sp, data->osc, data->ft, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                return SPORTH_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->osc->freq = freq;
            data->osc->amp = amp;
            sp_osc_compute(pd->sp, data->osc, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            fprintf(stderr, "Destroying sine\n");
#endif
            pipe = pd->last;
            data = pipe->ud;
            sp_ftbl_destroy(&data->ft);
            sp_osc_destroy(&data->osc);
            free(data);
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_add(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_ADD, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 + v2);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v1 + v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_mul(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MUL, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v1 * v2);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v1 * v2);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v1 * v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_sub(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SUB, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v2 - v1);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v2 - v1);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, v2 - v1);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_divide(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_DIV, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 / v1);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 / v1);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_max(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MAX, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 > v1 ? v2 : v1);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 > v1 ? v2 : v1);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)  v2 > v1 ? v2 : v1);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_min(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MIN, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 > v1 ? v1 : v2);
            break;
        case PLUMBER_INIT:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT) v2 > v1 ? v1 : v2);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)  v2 > v1 ? v1 : v2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_abs(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_ABS, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)fabsf(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)fabsf(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)fabsf(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_floor(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_FLOOR, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)floorf(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)floorf(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)floorf(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_frac(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_FRAC, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)(val - floorf(val)));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)(val - floorf(val)));
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)(val - floorf(val)));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_log(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_LOG, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)logf(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)logf(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_log10(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_LOG10, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log10f(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log10f(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log10f(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}


int sporth_round(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_ROUND, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)roundf(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)roundf(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)roundf(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_mtof(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT nn;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_MTOF, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            nn = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, sp_midi2cps(nn));
            break;
        case PLUMBER_INIT:
            nn = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, sp_midi2cps(nn));
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                return PLUMBER_NOTOK;
            }
            nn = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, sp_midi2cps(nn));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_eq(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "eq: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_EQ, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr, "Not enough args for eq\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "eq: Initializing\n");
#endif
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (v2 == v1 ? 1 : 0));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"eq: unknown mode!");
          stack->error++;
          return PLUMBER_NOTOK;
          break;
    }
    return PLUMBER_OK;
}

int sporth_lt(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "lt: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_LT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr, "Not enough args for lt\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "lt: Initializing\n");
#endif
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (v2 < v1 ? 1 : 0));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"lt: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_gt(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "gt: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_GT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr, "Not enough args for gt\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "gt: Initializing\n");
#endif
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (v2 > v1 ? 1 : 0));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"gt: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_ne(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "ne: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_NE, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr, "Not enough args for ne\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "ne: Initializing\n");
#endif
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (v2 != v1 ? 1 : 0));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"ne: unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_branch(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT v1, v2, cond;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "branch: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_BRANCH, NULL);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr, "Not enough args for branch\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            cond = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "branch: Initializing\n");
#endif
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            cond = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            cond = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (cond != 0 ? v2 : v1));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr,"branch: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int sporth_pos(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "pos: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_POS, NULL);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "pos: Initializing\n");
#endif
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            sporth_stack_push_float(stack, (SPFLOAT) pd->sp->pos / pd->sp->sr);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          fprintf(stderr,"pos: unknown mode!");
           stack->error++;
           return PLUMBER_NOTOK;
           break;
    }
    return PLUMBER_OK;
}

int sporth_dur(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT *dur;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "dur: Creating\n");
#endif
            dur = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_DUR, dur);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "dur: Initializing\n");
#endif
            dur = pd->last->ud;
            *dur = (SPFLOAT) pd->sp->len / pd->sp->sr;
            sporth_stack_push_float(stack, *dur);
            break;
        case PLUMBER_COMPUTE:
            dur = pd->last->ud;
            sporth_stack_push_float(stack, *dur);
            break;
        case PLUMBER_DESTROY:
            dur = pd->last->ud;
            free(dur);
            break;
        default:
            fprintf(stderr,"pos: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

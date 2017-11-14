#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "plumber.h"


#define FLT_EPSILON 1.1920928955078125e-07F
#define EPS FLT_EPSILON

#define FORCE_EVAL(x) do {                \
        volatile float __x;               \
        __x = (x);                        \
} while(0)


static const SPFLOAT toint = 1/EPS;

/*
 * this roundf fuction is needed when compiling with -ansi flag
 * the code for this is from the musl libc library
 */
static SPFLOAT sproundf(SPFLOAT x)
{
	union {SPFLOAT f; uint32_t i;} u = {x};
	int e = u.i >> 23 & 0xff;
	SPFLOAT y;

	if (e >= 0x7f+23)
		return x;
	if (u.i >> 31)
		x = -x;
	if (e < 0x7f-1) {
        /* TODO: I don't understand this */
		/* FORCE_EVAL(x + toint); */
		return 0*u.f;
	}
	y = x + toint - toint - x;
	if (y > 0.5f)
		y = y + x - 1;
	else if (y <= -0.5f)
		y = y + x + 1;
	else
		y = y + x;
	if (u.i >> 31)
		y = -y;
	return y;
}

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
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
            if(stack->error) {
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, val);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          plumber_print(pd,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_dup2(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT val1 = 0;
    SPFLOAT val2 = 0;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_DUP2, NULL);
            val1 = sporth_stack_pop_float(stack);
            val2 = sporth_stack_pop_float(stack);
            if(stack->error) {
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            break;
        case PLUMBER_INIT:
            val1 = sporth_stack_pop_float(stack);
            val2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            break;
        case PLUMBER_COMPUTE:
            val1 = sporth_stack_pop_float(stack);
            val2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            sporth_stack_push_float(stack, val1);
            sporth_stack_push_float(stack, val2);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
          plumber_print(pd,"Error: Unknown mode!");
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
            plumber_print(pd,"Error: Unknown mode!");
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
           plumber_print(pd,"creating sine function... \n");
#endif
            data = malloc(sizeof(sporth_sine_d));
            sp_osc_create(&data->osc);
            sp_ftbl_create(pd->sp, &data->ft, 8192);
            plumber_add_ugen(pd, SPORTH_SINE, data);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd, "returning error SPORTH_NOTOK\n");
                return PLUMBER_NOTOK;
            }

            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
           plumber_print(pd,"Initializing sine function... \n");
#endif
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
            plumber_print(pd, "Destroying sine\n");
#endif
            pipe = pd->last;
            data = pipe->ud;
            sp_ftbl_destroy(&data->ft);
            sp_osc_destroy(&data->osc);
            free(data);
            break;
        default:
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
            plumber_print(pd,"Error: Unknown mode!");
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
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)fabs(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)fabs(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)fabs(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)floor(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)floor(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)floor(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)(val - floor(val)));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)(val - floor(val)));
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)(val - floor(val)));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)log(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)log10(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log10(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)log10(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
            sporth_stack_push_float(stack, (SPFLOAT)sproundf(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)sproundf(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)sproundf(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"Error: Unknown mode!");
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
          plumber_print(pd,"Error: Unknown mode!");
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
            plumber_print(pd, "eq: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_EQ, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for eq\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "eq: Initializing\n");
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
          plumber_print(pd,"eq: unknown mode!");
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
            plumber_print(pd, "lt: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_LT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for lt\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "lt: Initializing\n");
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
            plumber_print(pd,"lt: unknown mode!");
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
            plumber_print(pd, "gt: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_GT, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for gt\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "gt: Initializing\n");
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
            plumber_print(pd,"gt: unknown mode!");
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
            plumber_print(pd, "ne: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_NE, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for ne\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            v1 = sporth_stack_pop_float(stack);
            v2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "ne: Initializing\n");
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
          plumber_print(pd,"ne: unknown mode!");
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
            plumber_print(pd, "branch: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_BRANCH, NULL);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for branch\n");
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
            plumber_print(pd, "branch: Initializing\n");
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
            sporth_stack_push_float(stack, (cond != 0 ? v1 : v2));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"branch: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int sporth_pos(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    uint32_t *pos;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "pos: Creating\n");
#endif
            pos = malloc(sizeof(uint32_t));
            plumber_add_ugen(pd, SPORTH_POS, pos);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "pos: Initializing\n");
#endif
            pos = pd->last->ud;
            *pos = 0;
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            pos = pd->last->ud;
            sporth_stack_push_float(stack, (SPFLOAT) *pos / pd->sp->sr);
            *pos = *pos + 1;
            break;
        case PLUMBER_DESTROY:
            pos = pd->last->ud;
            free(pos);
            break;
        default:
          plumber_print(pd,"pos: unknown mode!");
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
            plumber_print(pd, "dur: Creating\n");
#endif
            dur = malloc(sizeof(SPFLOAT));
            *dur = (SPFLOAT) pd->sp->len / pd->sp->sr;
            plumber_add_ugen(pd, SPORTH_DUR, dur);
            sporth_stack_push_float(stack, *dur);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "dur: Initializing\n");
#endif
            dur = pd->last->ud;
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
            plumber_print(pd,"pos: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_durs(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT *dur;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "dur: Creating\n");
#endif
            dur = malloc(sizeof(SPFLOAT));
            *dur = (SPFLOAT) pd->sp->len;
            plumber_add_ugen(pd, SPORTH_DURS, dur);
            sporth_stack_push_float(stack, *dur);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "dur: Initializing\n");
#endif
            dur = pd->last->ud;
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
            plumber_print(pd,"pos: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_setdurs(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    uint32_t dur = 0;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "setdurs: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_SETDURS, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd, "Not enough args for setdurs\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            dur = (uint32_t) sporth_stack_pop_float(stack);
            pd->sp->len = dur;
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
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_ampdb(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT *ampdb;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "ampdb: Creating\n");
#endif
            ampdb = malloc(sizeof(SPFLOAT));
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd, "ampdb: not enough args\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            plumber_add_ugen(pd, SPORTH_AMPDB, ampdb);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "ampdb: Initializing\n");
#endif
            ampdb = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            *ampdb = (SPFLOAT) log(10) / 20;
            sporth_stack_push_float(stack, exp(*ampdb * val));
            break;
        case PLUMBER_COMPUTE:
            ampdb = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, exp(*ampdb * val));
            break;
        case PLUMBER_DESTROY:
            ampdb = pd->last->ud;
            free(ampdb);
            break;
        default:
            plumber_print(pd,"ampdb: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_sr(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT *sr;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "sr: Creating\n");
#endif
            sr = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_SR, sr);
            *sr = pd->sp->sr;
            sporth_stack_push_float(stack, *sr);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "sr: Initializing\n");
#endif
            sr = pd->last->ud;
            sporth_stack_push_float(stack, *sr);
            break;
        case PLUMBER_COMPUTE:
            sr = pd->last->ud;
            sporth_stack_push_float(stack, *sr);
            break;
        case PLUMBER_DESTROY:
            sr = pd->last->ud;
            free(sr);
            break;
        default:
            plumber_print(pd,"sr: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_limit(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT min, max, in, out;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "limit: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_LIMIT, NULL);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd, "limit: not enough args\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            out = (in > max ? max : in);
            out = (out < min ? min : out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "limit: Initializing\n");
#endif
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            out = (in > max ? max : in);
            out = (out < min ? min : out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_COMPUTE:
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            out = (in > max ? max : in);
            out = (out < min ? min : out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd,"limit: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

typedef struct {
    SPFLOAT pval;
    SPFLOAT out;
} inv_d;

int sporth_inv(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    inv_d *inv;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "inv: Creating\n");
#endif
            inv = malloc(sizeof(inv_d));
            plumber_add_ugen(pd, SPORTH_INV, inv);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd, "inv: not enough args\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            inv->out  = (1.0 / val);
            inv->pval = val;
            sporth_stack_push_float(stack, inv->out);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            plumber_print(pd, "inv: Initializing\n");
#endif
            inv = (inv_d *)pd->last->ud;
            val = sporth_stack_pop_float(stack);

            if(val != inv->pval) {
                inv->out = (1.0 / val);
                inv->pval = val;
            }

            sporth_stack_push_float(stack, inv->out);
            break;
        case PLUMBER_COMPUTE:
            inv = (inv_d *)pd->last->ud;
            val = sporth_stack_pop_float(stack);

            if(val != inv->pval) {
                inv->out = (1.0 / val);
                inv->pval = val;
            }
            sporth_stack_push_float(stack, inv->out);
            break;
        case PLUMBER_DESTROY:
            inv = (inv_d *)pd->last->ud;
            free(inv);
            break;
        default:
            plumber_print(pd,"inv: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_sqrt(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SQRT, NULL);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)sqrt(val));
            break;
        case PLUMBER_INIT:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, (SPFLOAT)sqrt(val));
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, sqrt(val));
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            stack->error++;
            return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

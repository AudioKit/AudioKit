/*
 * Tinyprop
 * By Paul Batchelor
 *
 * A tiny C implementation of prop, a proportional rhythmic notation system
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

enum {
PTYPE_OFF,
PTYPE_ON,
PMODE_INSERT,
PMODE_SETDIV,
PMODE_SETMUL,
PMODE_UNSETMUL,
PMODE_INIT,
PSTATUS_NOTOK,
PSTATUS_OK
};

int sp_prop_create(sp_prop **p)
{
    *p = malloc(sizeof(sp_prop));
    return SP_OK;
}

int sp_prop_destroy(sp_prop **p)
{
    sp_prop *pp = *p;
    prop_destroy(&pp->prp);
    free(*p);
    return SP_OK;
}

int sp_prop_init(sp_data *sp, sp_prop *p, const char *str)
{
    p->count = 0;

    prop_create(&p->prp);
    if(prop_parse(p->prp, str) == PSTATUS_NOTOK) {
        fprintf(stderr,"There was an error parsing the string.\n");
        return SP_NOT_OK;
    }
    p->bpm = 60;
    p->lbpm = 60;
    return SP_OK;
}

int sp_prop_compute(sp_data *sp, sp_prop *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->count == 0) {
        if(p->bpm != p->lbpm) {
            p->prp->scale = (SPFLOAT) 60.0 / p->bpm;
            p->lbpm = p->bpm;
        }
        p->evt = prop_next(p->prp);
        p->count = prop_time(p->prp, p->evt) * sp->sr;
        if(p->evt.type == PTYPE_ON) {
            *out = 1.0;
        } else {
            *out = 0.0;
        }
        return SP_OK;
    }
    *out = 0;
    p->count--;

    return SP_OK;
}

static int stack_push(prop_stack *ps, uint32_t val)
{
    if(ps->pos++ < 16) {
        ps->stack[ps->pos] = val;
    }
    return SP_OK;
}

static void stack_init(prop_stack *ps)
{
    ps->pos = -1;
    int n;
    for(n = 0; n < 16; n++) ps->stack[n] = 1;
}

static uint32_t stack_pop(prop_stack *ps)
{
    if(ps->pos >= 0) {
        return ps->stack[ps->pos--];
    }
    return 1;
}

static void mode_insert(prop_data *pd, char type)
{
#ifdef DEBUG_PROP
    if(type == PTYPE_ON) {
        printf("mode_insert: PTYPE_ON\n");
    } else {
        printf("mode_insert: PTYPE_OFF\n");
    }
    printf("\tval/mul = %d, pos = %d, cons = %d, div = %d\n", 
            pd->mul, pd->num, pd->cons_mul, pd->div);
#endif

    prop_event *evt = malloc(sizeof(prop_event));
    evt->type = type;
    evt->val = pd->mul;
    evt->pos = pd->num;
    evt->cons = pd->cons_mul;
    pd->last->next = evt;
    pd->last = evt;
    pd->num++;

}

static void mode_setdiv(prop_data *pd, char n)
{
    if(pd->tmp == 0 && n == 0) n = 1;
    pd->tmp *= 10;
    pd->tmp += n;
}

static void mode_setmul(prop_data *pd)
{
    pd->mul *= pd->tmp;
    pd->div = pd->tmp;
    stack_push(&pd->mstack, pd->tmp);
    pd->tmp = 0;
}

static void mode_unsetmul(prop_data *pd)
{
    uint32_t div = stack_pop(&pd->mstack);
#ifdef DEBUG_PROP
    printf("mul / div = %d / %d\n", pd->mul, div);
#endif
    pd->mul /= div;
}

static void mode_setcons(prop_data *pd)
{
    pd->cons_mul *= pd->tmp;
    pd->cons_div = pd->tmp;
    stack_push(&pd->cstack, pd->tmp);
    pd->tmp = 0;
}

static void mode_unsetcons(prop_data *pd)
{
    uint32_t div = stack_pop(&pd->cstack);
#ifdef DEBUG_PROP
    printf("mul / div = %d / %d\n", pd->cons_mul, div);
#endif
    pd->cons_mul /= div;
}

int prop_create(prop_data **pd)
{
    *pd = malloc(sizeof(prop_data));
    prop_data *pdp = *pd;

    pdp->num = 0;
    pdp->mul = 1;
    pdp->div = 0;
    pdp->scale = 1;
    pdp->cons_mul = 1;
    pdp->cons_div = 0;
    pdp->mode = PMODE_INIT;
    pdp->pos = 1;
    pdp->evtpos = 0;
    pdp->last = &pdp->root;
    pdp->tmp = 0;

    stack_init(&pdp->mstack);
    stack_init(&pdp->cstack);

    return PSTATUS_OK;
}

int prop_parse(prop_data *pd, const char *str)
{
    char c;
    while(*str != 0) {
        c = str[0];

        switch(c) {

            case '+':
                mode_insert(pd, PTYPE_ON);
                break;
            case '-':
                mode_insert(pd, PTYPE_OFF);
                break;

            case '0':
                mode_setdiv(pd, 0);
                break;
            case '1':
                mode_setdiv(pd, 1);
                break;
            case '2':
                mode_setdiv(pd, 2);
                break;
            case '3':
                mode_setdiv(pd, 3);
                break;
            case '4':
                mode_setdiv(pd, 4);
                break;
            case '5':
                mode_setdiv(pd, 5);
                break;
            case '6':
                mode_setdiv(pd, 6);
                break;
            case '7':
                mode_setdiv(pd, 7);
                break;
            case '8':
                mode_setdiv(pd, 8);
                break;
            case '9':
                mode_setdiv(pd, 9);
                break;
            case '(':
                mode_setmul(pd);
                break;
            case ')':
                mode_unsetmul(pd);
                break;
            case '[':
                mode_setcons(pd);
                break;
            case ']':
                mode_unsetcons(pd);
                break;
            case ' ': break;
            case '\n': break;
            case '\t': break;

            default:
                return PSTATUS_NOTOK;
        }
        pd->pos++;
        str++;
    }
    pd->last = &pd->root;
    return PSTATUS_OK;
}

prop_event prop_next(prop_data *pd)
{
    if(pd->evtpos >= pd->num ) {
        pd->last = &pd->root;
        pd->evtpos = 0;
    }
    prop_event p = *pd->last->next;
    pd->last = pd->last->next;
    pd->evtpos++;
    return p;
}

float prop_time(prop_data *pd, prop_event evt)
{
    return evt.cons * (pd->scale / evt.val);
}

int prop_destroy(prop_data **pd)
{
    uint32_t i;
    prop_data *pdp = *pd;
    prop_event *evt, *next;

    evt = pdp->root.next;

    for(i = 0; i < pdp->num; i++) {
        next = evt->next;
        free(evt);
        evt = next;
    }

    free(*pd);
    return PSTATUS_OK;
}

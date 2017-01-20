/*
 * Tinyprop
 * By Paul Batchelor
 *
 * A tiny C implementation of prop, a proportional rhythmic notation system
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

typedef struct {
    uint32_t size;
    prop_list **ar;
} prop_slice;

static int prop_create(prop_data **pd);
static int prop_parse(prop_data *pd, const char *str);
static prop_event prop_next(sp_data *sp, prop_data *pd);
static float prop_time(prop_data *pd, prop_event evt);
static int prop_destroy(prop_data **pd);

static int prop_val_free(prop_val val);
static int prop_list_init(prop_list *lst);
static int prop_list_destroy(prop_list *lst);
static int prop_list_append(prop_list *lst, prop_val val);
static void prop_list_reset(prop_list *lst);
static int prop_list_copy(prop_list *src, prop_list **dst);

static void mode_insert_event(prop_data *pd, char type);
static void mode_insert_slice(prop_data *pd);
static void mode_list_start(prop_data *pd);
static void mode_list_end(prop_data *pd);
static void prop_slice_encap(prop_data *pd);
static void prop_slice_append(prop_data *pd);
static void reset(prop_data *pd);
static void back_to_top(prop_data *pd);

enum {
PTYPE_SLICE,
PTYPE_LIST,
PTYPE_EVENT,
PTYPE_OFF,
PTYPE_ON,
PTYPE_MAYBE,
PMODE_INSERT,
PMODE_SETDIV,
PMODE_SETMUL,
PMODE_UNSETMUL,
PMODE_INIT,
PSTATUS_NOTOK,
PSTATUS_OK,
PTYPE_NULL
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
        p->evt = prop_next(sp, p->prp);
        p->count = prop_time(p->prp, p->evt) * sp->sr;
        switch(p->evt.type) {
            case PTYPE_ON: 
                *out = 1.0;
                break;
            case PTYPE_MAYBE: 
                if( ((SPFLOAT) sp_rand(sp) / SP_RANDMAX) > 0.5) *out = 1.0;
                else *out = 0.0;
                break;
            default:
                *out = 0.0;
                break;
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

static void mode_insert_event(prop_data *pd, char type)
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

    prop_val val;
    val.type = PTYPE_EVENT;
    prop_event *evt = malloc(sizeof(prop_event));
    evt->type = type;
    evt->val = pd->mul;
    evt->cons = pd->cons_mul;
    val.ud = evt;
    prop_list_append(pd->main, val);
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

static int prop_create(prop_data **pd)
{
    *pd = malloc(sizeof(prop_data));
    prop_data *pdp = *pd;

    pdp->mul = 1;
    pdp->div = 0;
    pdp->scale = 1;
    pdp->cons_mul = 1;
    pdp->cons_div = 0;
    pdp->mode = PMODE_INIT;
    pdp->pos = 1;
    pdp->main = &pdp->top;
    pdp->main->lvl = 0;
    pdp->tmp = 0;

    stack_init(&pdp->mstack);
    stack_init(&pdp->cstack);
    prop_list_init(pdp->main);

    return PSTATUS_OK;
}

static int prop_parse(prop_data *pd, const char *str)
{
    char c;
    while(*str != 0) {
        c = str[0];

        switch(c) {
            case '+':
                mode_insert_event(pd, PTYPE_ON);
                break;
            case '?':
                mode_insert_event(pd, PTYPE_MAYBE);
                break;
            case '-':
                mode_insert_event(pd, PTYPE_OFF);
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
            case '|':
                mode_insert_slice(pd);
                break;
            case '{':
                mode_list_start(pd);
                break;
            case '}':
                mode_list_end(pd);
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
    prop_list_reset(&pd->top);
    pd->main = &pd->top;
    return PSTATUS_OK;
}

prop_val prop_list_iterate(prop_list *lst)
{
    if(lst->pos >= lst->size) {
        prop_list_reset(lst);
    }
    prop_val val = lst->last->val;
    lst->last = lst->last->next;
    lst->pos++;
    return val; 
}

static void back_to_top(prop_data *pd)
{
    prop_list *lst = pd->main;
    prop_list_reset(lst);
    pd->main = lst->top;
    reset(pd);
}

static void reset(prop_data *pd)
{
    prop_list *lst = pd->main;
    if(lst->pos >= lst->size) {
        back_to_top(pd);
    }
}

prop_event prop_next(sp_data *sp, prop_data *pd)
{
/*
    prop_list *lst = pd->main;

    if(lst->pos >= lst->size) {
        //prop_list_reset(lst);
        pd->main = lst->top;
    }
*/
    reset(pd); 
    prop_list *lst = pd->main;

    prop_val val = lst->last->val;
    lst->last = lst->last->next;
    lst->pos++;

    switch(val.type) {
        case PTYPE_SLICE: {
            prop_slice *slice = (prop_slice *)val.ud;

            uint32_t pos = floor(
                ((SPFLOAT)sp_rand(sp) / SP_RANDMAX) 
                * slice->size);

            pd->main = slice->ar[pos];
            prop_list_reset(pd->main);
            return prop_next(sp, pd);
            break;
        }
        case PTYPE_LIST: {
            prop_list *lst = (prop_list *)val.ud;
            pd->main = lst;
            prop_list_reset(pd->main);
            return prop_next(sp, pd);
            break;
        }
        default:
            break;
    }
    prop_event *p = (prop_event *)val.ud;
    return *p;
}

static float prop_time(prop_data *pd, prop_event evt)
{
    float val = evt.cons * (pd->scale / evt.val);
    return val;
}

static int prop_destroy(prop_data **pd)
{
    prop_data *pdp = *pd;

    prop_list_destroy(&pdp->top);

    free(*pd);
    return PSTATUS_OK;
}

static int prop_list_init(prop_list *lst)
{
    lst->last = &lst->root;
    lst->size = 0;
    lst->pos = 0;
    lst->root.val.type = PTYPE_NULL;
    lst->top = lst;
    return PSTATUS_OK;
}

static int prop_list_append(prop_list *lst, prop_val val)
{
    prop_entry *new = malloc(sizeof(prop_entry));
    new->val = val;
    lst->last->next = new;
    lst->last = new;
    lst->size++;
    return PSTATUS_OK;
}

static int prop_slice_free(prop_slice *slice)
{
    uint32_t i;
    for(i = 0; i < slice->size; i++) {
        prop_list_destroy(slice->ar[i]);   
        free(slice->ar[i]); 
    }
    free(slice->ar);
    return PSTATUS_OK;
}

static int prop_val_free(prop_val val)
{
    switch(val.type) {
        case PTYPE_SLICE:
            prop_slice_free((prop_slice *)val.ud);
            free(val.ud);
            break;
        case PTYPE_LIST:
            prop_list_destroy((prop_list *)val.ud);
            free(val.ud);
            break;
        default:
            free(val.ud);
            break;
    }
    return PSTATUS_OK;
}

static int prop_list_destroy(prop_list *lst) 
{
    prop_entry *entry = lst->root.next;
    prop_entry *next;
    uint32_t i;

    for(i = 0; i < lst->size; i++) {
        next = entry->next;
        prop_val_free(entry->val);
        free(entry);
        entry = next;
    }
    return PSTATUS_OK;
}

static void prop_list_reset(prop_list *lst)
{
    lst->last = lst->root.next;
    lst->pos = 0;
}   

static void mode_insert_slice(prop_data *pd)
{
    prop_entry *entry = pd->main->top->last;
    if(entry->val.type != PTYPE_SLICE) {
        prop_slice_encap(pd);
    } else {
        prop_slice_append(pd);
    }
}

static void prop_slice_encap(prop_data *pd)
{
    prop_val val;
    prop_list *top = pd->main->top;
    val.type = PTYPE_SLICE;
    prop_slice *slice = malloc(sizeof(prop_slice));
    val.ud = slice;
    prop_list *lst, *new;
    prop_list_copy(pd->main, &lst);
    new = malloc(sizeof(prop_list));
    new->lvl = pd->main->lvl;
    slice->size = 2;
    slice->ar = 
        (prop_list **)malloc(sizeof(prop_list *) * slice->size);
    slice->ar[0] = lst;
    /* reinit main list */
    prop_list_init(pd->main);
    prop_list_append(pd->main, val);
    slice->ar[1] = new;
    prop_list_init(slice->ar[1]);
    pd->main = slice->ar[1];

    slice->ar[0]->top = top;
    slice->ar[1]->top = top;
}

static void prop_slice_append(prop_data *pd)
{
    prop_entry *entry = pd->main->top->last;
    prop_slice *slice = (prop_slice *)entry->val.ud;
    
    prop_list *new = malloc(sizeof(prop_list));
    prop_list_init(new);
    slice->size++;
    slice->ar = (prop_list **)
        realloc(slice->ar, sizeof(prop_list *) * slice->size);
    slice->ar[slice->size - 1] = new;
    new->top = pd->main->top;
    pd->main = new;
}

static int prop_list_copy(prop_list *src, prop_list **dst)
{
    *dst = malloc(sizeof(prop_list));
    prop_list *pdst = *dst;
    pdst->root = src->root;
    pdst->last = src->last;
    pdst->size = src->size;
    pdst->pos = src->pos;
    pdst->lvl = src->lvl;
    return PSTATUS_OK;
}

static void mode_list_start(prop_data *pd)
{
    prop_val val;
    val.type = PTYPE_LIST;
    prop_list *new = malloc(sizeof(prop_list));
    prop_list_init(new);
    new->lvl = pd->main->lvl + 1;
    val.ud = new;
    prop_list_append(pd->main, val);
    new->top = pd->main;
    pd->main = new;
}

static void mode_list_end(prop_data *pd)
{
    pd->main = pd->main->top;
}

int sp_prop_reset(sp_data *sp, sp_prop *p)
{
    back_to_top(p->prp);
    p->count = 0;
    return SP_OK;
}

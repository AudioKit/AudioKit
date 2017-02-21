#include <stdlib.h>
#include "plumber.h"

typedef struct {
    sp_oscmorph *data;
    sp_ftbl **ft;
    char **ftname;
    int nft;
    SPFLOAT phase;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT wtpos;
} sporth_oscmorph;

static void get_strings(sporth_stack *stack, sporth_oscmorph *om)
{
    int n;
    for(n = 0; n < om->nft; n++) {
        om->ftname[om->nft - 1 - n] = sporth_stack_pop_string(stack);
    }
}

static int search_for_ft(plumber_data *pd, sporth_oscmorph *om)
{
    int n;
    for(n = 0; n < om->nft; n++) {
        if(plumber_ftmap_search(pd, om->ftname[n], &om->ft[n]) == PLUMBER_NOTOK) {
            return PLUMBER_NOTOK;
        }
    }
    return PLUMBER_OK;
}

/*TODO: remove */
static void free_strings(sporth_oscmorph *om)
{
    int n;
    for(n = 0; n < om->nft; n++) {

    }
}

static void pop_args(sporth_stack *stack, sporth_oscmorph *om)
{
    om->phase = sporth_stack_pop_float(stack);
    om->wtpos = sporth_stack_pop_float(stack);
    om->amp = sporth_stack_pop_float(stack);
    om->freq = sporth_stack_pop_float(stack);
}

static void set_args(sporth_oscmorph *om)
{
    om->data->freq = om->freq;
    om->data->amp = om->amp;
    om->data->wtpos = om->wtpos;
}


int sporth_oscmorph4(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sporth_oscmorph *oscmorph;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "oscmorph: Creating\n");
#endif
            oscmorph = malloc(sizeof(sporth_oscmorph));
            sp_oscmorph_create(&oscmorph->data);
            oscmorph->nft = 4;
            oscmorph->ft = malloc(sizeof(sp_ftbl *) * 4);
            oscmorph->ftname = malloc(sizeof(char *) * 4);
            plumber_add_ugen(pd, SPORTH_OSCMORPH4, oscmorph);

            if(sporth_check_args(stack, "ffffssss") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for oscmorph\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            get_strings(stack, oscmorph);
            pop_args(stack, oscmorph);

            if(search_for_ft(pd, oscmorph) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sporth_stack_push_float(stack, 0);
            free_strings(oscmorph);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "oscmorph: Initialising\n");
#endif

            oscmorph = pd->last->ud;
            get_strings(stack, oscmorph);

            pop_args(stack, oscmorph);

            sp_oscmorph_init(pd->sp, oscmorph->data, oscmorph->ft, oscmorph->nft, oscmorph->phase);

            sporth_stack_push_float(stack, 0);
            free_strings(oscmorph);
            break;
        case PLUMBER_COMPUTE:
            oscmorph = pd->last->ud;
            pop_args(stack, oscmorph);
            
            set_args(oscmorph);

            sp_oscmorph_compute(pd->sp, oscmorph->data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            oscmorph = pd->last->ud;
            free(oscmorph->ftname);
            free(oscmorph->ft);
            sp_oscmorph_destroy(&oscmorph->data);
            free(oscmorph);
            break;
        default:
            plumber_print(pd, "oscmorph: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

/*TODO: remove malloc from here */
int sporth_oscmorph2(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sporth_oscmorph *oscmorph;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "oscmorph2: Creating\n");
#endif
            oscmorph = malloc(sizeof(sporth_oscmorph));
            sp_oscmorph_create(&oscmorph->data);
            oscmorph->nft = 2;
            oscmorph->ft = malloc(sizeof(sp_ftbl *) * 2);
            oscmorph->ftname = malloc(sizeof(char *) * 2);
            plumber_add_ugen(pd, SPORTH_OSCMORPH2, oscmorph);

            if(sporth_check_args(stack, "ffffss") != SPORTH_OK) {
                plumber_print(pd,"Oscmorph2: not enough arguments\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            get_strings(stack, oscmorph);
            pop_args(stack, oscmorph);

            if(search_for_ft(pd, oscmorph) == PLUMBER_NOTOK) {
                stack->error++;
                free_strings(oscmorph);
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            free_strings(oscmorph);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "oscmorph2: Initialising\n");
#endif

            oscmorph = pd->last->ud;
            get_strings(stack, oscmorph);

            pop_args(stack, oscmorph);

            sp_oscmorph_init(pd->sp, oscmorph->data, oscmorph->ft, oscmorph->nft, oscmorph->phase);

            sporth_stack_push_float(stack, 0);
            free_strings(oscmorph);
            break;
        case PLUMBER_COMPUTE:
            oscmorph = pd->last->ud;
            pop_args(stack, oscmorph);
            
            set_args(oscmorph);

            sp_oscmorph_compute(pd->sp, oscmorph->data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            oscmorph = pd->last->ud;
            free(oscmorph->ftname);
            free(oscmorph->ft);
            sp_oscmorph_destroy(&oscmorph->data);
            free(oscmorph);
            break;
        default:
            plumber_print(pd, "oscmorph2: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}


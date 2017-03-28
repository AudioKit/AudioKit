#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

typedef struct {
    char **list;
    int len;
} slist_d;

static int slist_parse(slist_d *sl, char *filename, uint32_t size)
{
    sl->len = 0;
    FILE *fp = fopen(filename, "r");
    uint32_t i;
    size_t len = 0;
    ssize_t read = 0;
    char *line = NULL;
    sl-> list = malloc(sizeof(char *) * size); 
    if(fp == NULL) {
        return PLUMBER_NOTOK;
    }

    for(i = 0; i < size; i++) {
        if((read = sporth_getline(&line, &len, fp)) == -1) break;
        sl->list[i] = malloc(read + 1);
        memset(sl->list[i], 0, read + 1);
        strncpy(sl->list[i], line, read - 1);
        sl->len++;
    }
    free(line);
    fclose(fp);
    return PLUMBER_OK;
}

static void slist_destroy(slist_d *sl)
{
    uint32_t i;

    for(i = 0; i < sl->len; i++) {
        free(sl->list[i]);
    }

    if(sl->list != NULL) {
        free(sl->list);
    }
}

int sporth_slist(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    char *filename;
    uint32_t size;
    slist_d *sl;

    switch(pd->mode){
        case PLUMBER_CREATE:
            sl = malloc(sizeof(slist_d));
            sl->list = NULL;
            plumber_add_ugen(pd, SPORTH_SLIST, sl);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
               plumber_print(pd,"Not enough arguments for slist\n");
                return PLUMBER_NOTOK;
            }
            filename = sporth_stack_pop_string(stack);
            size = sporth_stack_pop_float(stack);
            ftname = sporth_stack_pop_string(stack);
            if(slist_parse(sl, filename, size) != PLUMBER_OK) {
                plumber_print(pd, 
                        "slist: could not load file %s\n",
                        filename);
                return PLUMBER_NOTOK;
            }
            plumber_ftmap_add_userdata(pd, ftname, sl);

            break;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            sl = pd->last->ud;
            slist_destroy(sl);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_sget(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    uint32_t index = 0;
    slist_d *sl;
    char **str = NULL;
    switch(pd->mode){
        case PLUMBER_CREATE:
            str = malloc(sizeof(char *));
            plumber_add_ugen(pd, SPORTH_SGET, str);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
               plumber_print(pd,"Not enough arguments for sget\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            index = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search_userdata(pd,ftname, (void *)&sl) != 
                    PLUMBER_OK) {
                plumber_print(pd, "Could not find ftable %s\n", ftname);
                return PLUMBER_NOTOK;
            }
            if(index > sl->len - 1) {
                plumber_print(pd, "Index %d exceeds slist length %d\n",
                        index, sl->len);
                return PLUMBER_NOTOK;
            }
            *str = sl->list[index];
            sporth_stack_push_string(stack, &sl->list[index]);
            break;

        case PLUMBER_INIT:
            str = pd->last->ud;
            sporth_stack_pop_string(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_push_string(stack, str);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            str = pd->last->ud;
            free(str);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_slick(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    uint32_t index = 0;
    slist_d *sl;
    char **str = NULL;
    switch(pd->mode){
        case PLUMBER_CREATE:
            str = malloc(sizeof(char *));
            plumber_add_ugen(pd, SPORTH_SLICK, str);

            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               plumber_print(pd,"Not enough arguments for slick\n");
                return PLUMBER_NOTOK;
            }

            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search_userdata(pd,ftname, (void *)&sl) != 
                    PLUMBER_OK) {
                plumber_print(pd, "Could not find ftable %s\n", ftname);
                return PLUMBER_NOTOK;
            }
            index = (uint32_t)(((SPFLOAT)sp_rand(pd->sp) / SP_RANDMAX) * sl->len);
            *str = sl->list[index];
            sporth_stack_push_string(stack, &sl->list[index]);
            break;

        case PLUMBER_INIT:
            str = pd->last->ud;
            sporth_stack_pop_string(stack);
            sporth_stack_push_string(stack, str);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            str = pd->last->ud;
            free(str);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

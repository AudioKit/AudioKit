#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "plumber.h"

#define SPORTH_UGEN(key, func, macro) int func(sporth_stack *stack, void *ud);
#include "ugens.h"
#undef SPORTH_UGEN

enum {
    SPACE,
    QUOTE,
    LEX_START,
    LEX_FLOAT,
    LEX_FLOAT_DOT,
    LEX_FLOAT_POSTDOT,
    LEX_POS,
    LEX_NEG,
    LEX_FUNC,
    LEX_ERROR
};

int sporth_f_default(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "Default user function in create mode.\n");
#endif

            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "Default user function in init mode.\n");
#endif
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            fprintf(stderr, "Default user function in destroy mode.\n");
#endif
            break;

        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int plumber_init(plumber_data *plumb)
{
    plumb->mode = PLUMBER_CREATE;
    plumb->last = &plumb->root;
    plumb->npipes = 0;
    plumb->nchan = 1;
    sporth_stack_init(&plumb->sporth.stack);
    plumber_ftmap_init(plumb);
    plumb->seed = time(NULL);
    plumb->fp = NULL;
    int pos;
    for(pos = 0; pos < 16; pos++) plumb->p[pos] = 0;
    for(pos = 0; pos < 16; pos++) plumb->f[pos] = sporth_f_default;
    return PLUMBER_OK;
}

int plumber_compute(plumber_data *plumb, int mode)
{
    plumb->mode = mode;
    plumber_pipe *pipe = plumb->root.next, *next;
    uint32_t n;
    float *fval;
    char *sval;
    sporth_data *sporth = &plumb->sporth;
    if(sporth->stack.error > 0) return PLUMBER_NOTOK;
    for(n = 0; n < plumb->npipes; n++) {
        next = pipe->next;
        switch(pipe->type) {
            case SPORTH_FLOAT:
                fval = pipe->ud;
                if(mode != PLUMBER_DESTROY)
                sporth_stack_push_float(&sporth->stack, *fval);
                break;
            case SPORTH_STRING:
                sval = pipe->ud;
                if(mode == PLUMBER_INIT)
                sporth_stack_push_string(&sporth->stack, sval);
                break;
            default:
                plumb->last = pipe;
                sporth->flist[pipe->type - SPORTH_FOFFSET].func(&sporth->stack,
                        sporth->flist[pipe->type - SPORTH_FOFFSET].ud);
                break;
        }
       pipe = next;
    }
    return PLUMBER_OK;
}

int plumber_show_pipes(plumber_data *plumb)
{
    plumber_pipe *pipe = plumb->root.next, *next;
    uint32_t n;
    float *fval;
    int rc;
    sporth_data *sporth = &plumb->sporth;
    for(n = 0; n < plumb->npipes; n++) {
        next = pipe->next;
       fprintf(stderr,"type = %d size = %d", pipe->type, pipe->size);
        if(pipe->type == SPORTH_FLOAT) {
            fval = pipe->ud;
           fprintf(stderr," val = %g\n", *fval);
        } else {
           fprintf(stderr,"\n");
        }
        pipe = next;
    }
    return PLUMBER_OK;
}

int plumber_pipes_destroy(plumber_data *plumb)
{
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = plumb->root.next;
    for(n = 0; n < plumb->npipes; n++) {
        next = pipe->next;
        if(pipe->type == SPORTH_FLOAT || pipe->type == SPORTH_STRING)
            free(pipe->ud);
        free(pipe);
        pipe = next;
    }
    return PLUMBER_OK;
}

int plumber_clean(plumber_data *plumb)
{
    plumber_compute(plumb, PLUMBER_DESTROY);
    sporth_htable_destroy(&plumb->sporth.dict);
    plumber_pipes_destroy(plumb);
    plumber_ftmap_destroy(plumb);
    if(plumb->fp != NULL) fclose(plumb->fp);
    free(plumb->sporth.flist);
    return PLUMBER_OK;
}

int plumber_add_float(plumber_data *plumb, float num)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
       fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = SPORTH_FLOAT;
    new->size = sizeof(SPFLOAT);
    new->ud = malloc(new->size);
    float *val = new->ud;
    *val = num;
    if(new->ud == NULL) {
       fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    plumb->last->next = new;
    plumb->last = new;
    plumb->npipes++;
    return PLUMBER_OK;
}

int plumber_add_string(plumber_data *plumb, const char *str)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
       fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = SPORTH_STRING;
    new->size = sizeof(char) * strlen(str) + 1;
    new->ud = malloc(new->size);
    char *sval = new->ud;
    strncpy(sval, str, new->size);
    if(new->ud == NULL) {
       fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    plumb->last->next = new;
    plumb->last = new;
    plumb->npipes++;
    return PLUMBER_OK;
}

int plumber_add_module(plumber_data *plumb,
        uint32_t id, size_t size, void *ud)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
       fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = id;
    new->size = size;
    new->ud = ud;

    plumb->last->next = new;
    plumb->last = new;
    plumb->npipes++;
    return PLUMBER_OK;
}
int plumber_parse_string(plumber_data *plumb, char *str)
{
    char *out, *tmp;
    uint32_t prev = 0, pos = 0, offset = 0, len = 0;
    uint32_t size = strlen(str);

    pos = 0;
    offset = 0;
    len = 0;
    prev = 0;
    while(pos < size) {
        out = sporth_tokenizer(&plumb->sporth, str, size, &pos);
        len = strlen(out);

        switch(sporth_lexer(&plumb->sporth, out, len)) {
            case SPORTH_FLOAT:
#ifdef DEBUG_MODE
                fprintf(stderr, "%s is a float!\n", out);
#endif
                plumber_add_float(plumb, atof(out));
                break;
            case SPORTH_STRING:
                tmp = out;
                tmp[len - 1] = '\0';
                tmp++;
#ifdef DEBUG_MODE
                fprintf(stderr, "%s is a string!\n", out);
#endif
                plumber_add_string(plumb, tmp);
                break;
            case SPORTH_FUNC:
#ifdef DEBUG_MODE
                fprintf(stderr, "%s is a function!\n", out);
#endif
                if(sporth_exec(&plumb->sporth, out) == SPORTH_NOTOK) {
                    plumb->sporth.stack.error++;
                }
                break;
            case SPORTH_IGNORE:
                break;
            default:
#ifdef DEBUG_MODE
                fprintf(stderr,"No idea what %s is!\n", out);
#endif
                break;
        }
        free(out);
    }

    return PLUMBER_OK;
}

int plumber_parse(plumber_data *plumb)
{
    FILE *fp = plumb->fp;
    char *line = NULL;
    size_t length = 0;
    ssize_t read;
    char *out, *tmp;
    uint32_t prev = 0, pos = 0, offset = 0, len = 0;
    plumb->mode = PLUMBER_CREATE;
    while((read = getline(&line, &length, fp)) != -1) {
        pos = 0;
        offset = 0;
        len = 0;
        prev = 0;
        while(pos < read - 1) {
            out = sporth_tokenizer(&plumb->sporth, line, read - 1, &pos);
            len = strlen(out);

            switch(sporth_lexer(&plumb->sporth, out, len)) {
                case SPORTH_FLOAT:
#ifdef DEBUG_MODE
                    fprintf(stderr, "%s is a float!\n", out);
#endif
                    plumber_add_float(plumb, atof(out));
                    break;
                case SPORTH_STRING:
                    tmp = out;
                    tmp[len - 1] = '\0';
                    tmp++;
#ifdef DEBUG_MODE
                    fprintf(stderr, "%s is a string!\n", out);
#endif
                    plumber_add_string(plumb, tmp);
                    break;
                case SPORTH_FUNC:
#ifdef DEBUG_MODE
                    fprintf(stderr, "%s is a function!\n", out);
#endif
                    if(sporth_exec(&plumb->sporth, out) == SPORTH_NOTOK) {
                        plumb->sporth.stack.error++;
                    }
                    break;
                case SPORTH_IGNORE:
                    break;
                default:
#ifdef DEBUG_MODE
                    fprintf(stderr,"No idea what %s is!\n", out);
#endif
                    break;
            }
            free(out);
        }
    }
    free(line);
    return PLUMBER_OK;
}
int plumber_recompile(plumber_data *plumb)
{
    fprintf(stderr, "Recompiling...\n");
    plumber_pipe *tmp1 = plumb->root.next;
    plumb->last = &plumb->root;
    plumber_pipe *tmp2;
    plumb->mode = PLUMBER_CREATE;
    uint32_t oldnpipes = plumb->npipes;
    uint32_t newnpipes; 
    int error = 0;
    plumb->npipes = 0;
    fseek(plumb->fp, 0L, SEEK_SET);
    sporth_stack_init(&plumb->sporth.stack);
    if(plumber_parse(plumb) == PLUMBER_OK) {
        fprintf(stderr, "Successful parse...\n");
        plumber_compute(plumb, PLUMBER_INIT);
        error = plumb->sporth.stack.error;
        fprintf(stderr, "at stack position %d\n", 
                plumb->sporth.stack.pos);
        fprintf(stderr, "%d errors\n", 
                plumb->sporth.stack.error);
    } else {
        error++;
    }


    if(error) {
        fprintf(stderr, "Did not recompile...\n");
        fprintf(stderr, "%d pipes\n", plumb->npipes);
        plumber_pipes_destroy(plumb);
        plumb->npipes = oldnpipes;
        fprintf(stderr, "%d old pipes\n", plumb->npipes);
        plumb->root.next = tmp1;
        sporth_stack_init(&plumb->sporth.stack);
        plumb->sp->pos = 0;
    } else {
        fprintf(stderr, "Recompiling...\n");
        tmp2 = plumb->root.next;
        plumb->root.next = tmp1;
        newnpipes = plumb->npipes;
        plumb->npipes = oldnpipes;
        plumber_pipes_destroy(plumb);
        plumb->npipes = newnpipes;
        plumb->root.next = tmp2;
        plumb->sp->pos = 0;
    }

    return PLUMBER_OK;
}

int plumber_error(plumber_data *plumb, const char *str)
{
   fprintf(stderr,"%s\n", str);
    exit(1);
}

int plumber_ftmap_init(plumber_data *plumb)
{
    int pos;

    for(pos = 0; pos < 256; pos++) {
        plumb->ftmap[pos].nftbl = 0;
        plumb->ftmap[pos].last= &plumb->ftmap[pos].root;
    }


    return PLUMBER_OK;
}

int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft)
{
    uint32_t pos = sporth_hash(str);
    plumber_ftentry *entry = &plumb->ftmap[pos];
    entry->nftbl++;
    plumber_ftbl *new = malloc(sizeof(plumber_ftbl));
    new->ft = ft;
    new->name = malloc(sizeof(char) * strlen(str) + 1);
    strcpy(new->name, str);
    entry->last->next = new;
    entry->last = new;
    return PLUMBER_OK;
}

int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft)
{
    uint32_t pos = sporth_hash(str);
    uint32_t n;
    plumber_ftentry *entry = &plumb->ftmap[pos];
    plumber_ftbl *ftbl = entry->root.next;
    plumber_ftbl *next;
    for(n = 0; n < entry->nftbl; n++) {
        next = ftbl->next;
        if(!strcmp(str, ftbl->name)){
            *ft = ftbl->ft;
            return PLUMBER_OK;
        }
        ftbl = next;
    }
   fprintf(stderr,"Could not find an ftable match for %s.\n", str);
    return PLUMBER_NOTOK;
}

int plumber_ftmap_destroy(plumber_data *plumb)
{
    int pos, n;
    plumber_ftbl *ftbl, *next;

    for(pos = 0; pos < 256; pos++) {
        ftbl = plumb->ftmap[pos].root.next;
        for(n = 0; n < plumb->ftmap[pos].nftbl; n++) {
            next = ftbl->next;
            free(ftbl->name);
            sp_ftbl_destroy(&ftbl->ft);
            free(ftbl);
            ftbl = next;
        }
    }

    return PLUMBER_OK;
}

int plumber_register(plumber_data *plumb)
{
    #define SPORTH_UGEN(key, func, macro) {key, func, plumb},
    sporth_func flist[] = {
    #include "ugens.h"
    {NULL, NULL, NULL}
    };
    #undef SPORTH_UGEN

    sporth_htable_init(&plumb->sporth.dict);
    sporth_register_func(&plumb->sporth, flist);

    sporth_func *flist2 = malloc(sizeof(sporth_func) * plumb->sporth.nfunc);
    flist2 = memcpy(flist2, flist, sizeof(sporth_func) * plumb->sporth.nfunc);
    plumb->sporth.flist = flist2;
    return PLUMBER_OK;
}

static uint32_t str2time(plumber_data *pd, char *str)
{
    int len = strlen(str);
    char last = str[len - 1];
    switch(last) {
        case 's':
            str[len - 1] = '\0';
            return atof(str) * pd->sp->sr;
            break;
        default:
            return atoi(str);
            break;
    }
}



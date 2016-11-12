#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <signal.h>

#include "plumber.h"

#define SPORTH_UGEN(key, func, macro, ninputs, noutputs) \
    int func(sporth_stack *stack, void *ud);
#include "ugens.h"
#undef SPORTH_UGEN

#ifdef BUILD_JACK
int sp_process_jack(plumber_data *pd, 
        void *ud, void (*callback)(sp_data *, void *), int port);
#endif 

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

enum {
    DRIVER_FILE,
    DRIVER_RAW,
    DRIVER_PLOT,
    DRIVER_SPA,
    DRIVER_JACK,
    DRIVER_NULL
};

int plumbing_init(plumbing *pipes)
{
    pipes->tick = 1;
    pipes->last = &pipes->root;
    pipes->npipes = 0;
    return PLUMBER_OK;
}

int plumber_init(plumber_data *plumb)
{
    plumb->mode = PLUMBER_CREATE;
    plumb->current_pipe = 0;
    plumb->ftmap = plumb->ft1;
    plumb->pipes= &plumb->main;
    plumb->tmp = &plumb->main;
    plumbing_init(plumb->pipes);
    plumb->nchan = 1;
    sporth_stack_init(&plumb->sporth.stack);
    plumber_ftmap_delete(plumb, 1);
    plumber_ftmap_init(plumb);
    plumb->seed = (int) time(NULL);
    plumb->fp = NULL;
    plumb->recompile = 0;
    int pos;
    for(pos = 0; pos < 16; pos++) plumb->p[pos] = 0;
    plumb->showprog = 0;
    return PLUMBER_OK;
}

int plumbing_compute(plumber_data *plumb, plumbing *pipes, int mode)
{
    plumb->mode = mode;
    plumber_pipe *pipe = pipes->root.next;
    uint32_t n;
    float *fval;
    char *sval;
    sporth_data *sporth = &plumb->sporth;
    /* swap out the current plumbing */
    plumbing *prev = plumb->pipes;
    /* save top level next pipe */
    plumber_pipe *top_next = plumb->next;

    plumb->pipes = pipes;

    /* save temp */
    plumbing *tmp = plumb->tmp;

    if(mode == PLUMBER_DESTROY) {
        sporth_stack_init(&plumb->sporth.stack);
    }
    for(n = 0; n < pipes->npipes; n++) {
        plumb->next = pipe->next;
        switch(pipe->type) {
            case SPORTH_FLOAT:
                fval = pipe->ud;
                if(mode != PLUMBER_DESTROY)
                    sporth_stack_push_float(&sporth->stack, *fval);
                break;
            case SPORTH_STRING:
                sval = pipe->ud;
                if(mode == PLUMBER_INIT) 
                    sporth_stack_push_string(&sporth->stack, &sval);
                break;
            default:
                plumb->last = pipe;
                sporth->flist[pipe->type - SPORTH_FOFFSET].func(&sporth->stack,
                                                                sporth->flist[pipe->type - SPORTH_FOFFSET].ud);
                break;
        }
        pipe = plumb->next;
    }
    /* re-swap the main pipes */
    plumb->pipes = prev;
    /* restore top level next pipe */
    plumb->next = top_next;
    /* restore temp */
    plumb->tmp = tmp;
    return PLUMBER_OK;
}

int plumber_compute(plumber_data *plumb, int mode)
{
    plumbing_compute(plumb, plumb->pipes, mode);
    return PLUMBER_OK;
}

void plumber_show_pipes(plumber_data *plumb)
{
    return plumbing_show_pipes(plumb, plumb->pipes);
}

void plumbing_show_pipes(plumber_data *plumb, plumbing *pipes)
{
    fprintf(stderr, "\nShowing pipes: \n");
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = pipes->root.next;
    for(n = 0; n < pipes->npipes; n++) {
        next = pipe->next;
        fprintf(stderr, "\ttype = %d ", pipe->type);
        switch(pipe->type) {
            case SPORTH_FLOAT:
                fprintf(stderr, "(float)\n");
                break;
            case SPORTH_STRING:
                fprintf(stderr, "(string)\n");
                break;
            default:
                fprintf(stderr, "(%s)\n", 
                        plumb->sporth.flist[pipe->type - SPORTH_FOFFSET].name);
                break;
        }

        pipe = next;
    }
    fprintf(stderr, "%d pipes total. \n\n", pipes->npipes);
}

void plumbing_write_code(plumber_data *plumb, plumbing *pipes, FILE *fp)
{
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = pipes->root.next;
    SPFLOAT *ptr;
    for(n = 0; n < pipes->npipes; n++) {
        next = pipe->next;
        switch(pipe->type) {
            case SPORTH_FLOAT:
                ptr = (SPFLOAT *)pipe->ud;
                fprintf(fp, "%g ", *ptr);
                break;
            case SPORTH_STRING:
                fprintf(fp, "\'%s\' ", (char *) pipe->ud);
                break;
            default:
                fprintf(fp, "%s ", 
                        plumb->sporth.flist[pipe->type - SPORTH_FOFFSET].name);
                break;
        }

        pipe = next;
    }
}

void plumber_write_code(plumber_data *plumb, FILE *fp)
{
    plumbing_write_code(plumb, plumb->pipes, fp);
}

int plumbing_destroy(plumbing *pipes)
{
#ifdef DEBUG_MODE
    fprintf(stderr, "----Plumber Destroy----\n");
#endif
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = pipes->root.next;
    for(n = 0; n < pipes->npipes; n++) {
        next = pipe->next;
#ifdef DEBUG_MODE
        fprintf(stderr, "Pipe %d\ttype %d\n", n, pipe->type);
#endif

        if(pipe->type == SPORTH_FLOAT || pipe->type == SPORTH_STRING) {
            free(pipe->ud);
        }

        free(pipe);
        pipe = next;
    }
    return PLUMBER_OK;
}

int plumber_clean(plumber_data *plumb)
{
    plumber_compute(plumb, PLUMBER_DESTROY);
    sporth_htable_destroy(&plumb->sporth.dict);
    plumbing_destroy(plumb->pipes);
    plumber_ftmap_destroy(plumb);
    if(plumb->fp != NULL) fclose(plumb->fp);
    free(plumb->sporth.flist);
    return PLUMBER_OK;
}

int plumbing_add_pipe(plumbing *pipes, plumber_pipe *pipe)
{
    pipes->last->next = pipe;
    pipes->last = pipe;
    pipes->npipes++;
    return PLUMBER_OK;
}

int plumber_add_float(plumber_data *plumb, plumbing *pipes, float num)
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

    plumbing_add_pipe(pipes, new);
    return PLUMBER_OK;
}

char * plumber_add_string(plumber_data *plumb, plumbing *pipes, const char *str)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
        fprintf(stderr,"Memory error\n");
        return NULL;
    }

    new->type = SPORTH_STRING;
    new->size = sizeof(char) * strlen(str) + 1;
    new->ud = malloc(new->size);
    char *sval = new->ud;
    strncpy(sval, str, new->size);
    if(new->ud == NULL) {
        fprintf(stderr,"Memory error\n");
        return NULL;
    }

    plumbing_add_pipe(pipes, new);
    return sval;
}

int plumber_add_ugen(plumber_data *plumb, uint32_t id, void *ud)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
        fprintf(stderr,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = id;
    new->ud = ud;

    plumbing_add_pipe(plumb->tmp, new);
    return PLUMBER_OK;
}

int plumber_parse_string(plumber_data *plumb, char *str)
{
    return plumbing_parse_string(plumb, plumb->pipes, str);
}

int plumber_lexer(plumber_data *plumb, plumbing *pipes, char *out, uint32_t len)
{
    char *tmp;
    float flt = 0;
    int rc;
    switch(sporth_lexer(out, len)) {
        case SPORTH_FLOAT:
#ifdef DEBUG_MODE
            fprintf(stderr, "%s is a float!\n", out);
#endif
            flt = atof(out);
            plumber_add_float(plumb, pipes, flt);
            sporth_stack_push_float(&plumb->sporth.stack, flt);
            break;
        case SPORTH_STRING:
            tmp = out;
            tmp[len - 1] = '\0';
            tmp++;
#ifdef DEBUG_MODE
            fprintf(stderr, "%s is a string!\n", out);
#endif
            tmp = plumber_add_string(plumb, pipes, tmp);
            sporth_stack_push_string(&plumb->sporth.stack, &tmp);
            break;
        case SPORTH_WORD:
            /* A sporth word is like a string, except it looks like _this
             * instead of "this" or 'this'.
             * It saves a character, and it can make things look nicer. 
             * A sporth word has no spaces, hence the name.
             */
            tmp = out;
            /* don't truncate the last character here like the string */
            tmp[len] = '\0';
            tmp++;
#ifdef DEBUG_MODE
            fprintf(stderr, "%s is a word!\n", out);
#endif
            tmp = plumber_add_string(plumb, pipes, tmp);
            sporth_stack_push_string(&plumb->sporth.stack, &tmp);
            break;
        case SPORTH_FUNC:
#ifdef DEBUG_MODE
            fprintf(stderr, "%s is a function!\n", out);
#endif
            rc = sporth_exec(&plumb->sporth, out);
            if(rc == PLUMBER_NOTOK || rc == SPORTH_NOTOK) {
                fprintf(stderr, "%s returned an error.\n", out);
#ifdef DEBUG_MODE
            fprintf(stderr, "plumber_lexer: error with function %s\n", out);
#endif
                plumb->sporth.stack.error++;
                return PLUMBER_NOTOK;
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
    return PLUMBER_OK;
}

int plumbing_parse(plumber_data *plumb, plumbing *pipes)
{
    FILE *fp = plumb->fp;
    char *line = NULL;
    size_t length = 0;
    ssize_t read;
    char *out;
    uint32_t pos = 0, len = 0;
    int err = PLUMBER_OK;
    plumb->mode = PLUMBER_CREATE;

    /* save top level tmp variable. */
    plumbing *top_tmp = plumb->tmp;
    plumb->tmp = pipes;

    while((read = getline(&line, &length, fp)) != -1 && err == PLUMBER_OK) {
        pos = 0;
        len = 0;
        while(pos < read - 1) {
            out = sporth_tokenizer(line, (unsigned int)read - 1, &pos);
            len = (unsigned int)strlen(out);
            err = plumber_lexer(plumb, pipes, out, len);
            free(out);
            if(err == PLUMBER_NOTOK) break;
        }
    }
    free(line);

    /* restore tmp */
    plumb->tmp = top_tmp;
    return err;

}

int plumbing_parse_string(plumber_data *plumb, plumbing *pipes, char *str)
{
    char *out;
    uint32_t pos = 0, len = 0;
    uint32_t size = (unsigned int)strlen(str);
    int err = PLUMBER_OK;
    pos = 0;
    len = 0;
    plumb->mode = PLUMBER_CREATE;

    /* save top level tmp variable. */
    plumbing *top_tmp = plumb->tmp;
    plumb->tmp = pipes;

    while(pos < size) {
        out = sporth_tokenizer(str, size, &pos);
        len = (unsigned int)strlen(out);
        err = plumber_lexer(plumb, pipes, out, len);
        free(out);
        if(err == PLUMBER_NOTOK) break;
    }

    /* restore tmp */
    plumb->tmp = top_tmp;
    return err;
}

int plumber_parse(plumber_data *plumb)
{
    return plumbing_parse(plumb, plumb->pipes);
}

plumbing *plumbing_choose(plumber_data *plumb, 
        plumbing *main, plumbing *alt, int *current_pipe)
{
    plumbing *newpipes = NULL;

    if(*current_pipe == 0) {
#ifdef DEBUG_MODE
        fprintf(stderr, "compiling to alt\n");
#endif
        newpipes = alt;
        *current_pipe = 1;
        plumb->ftmap = plumb->ft2;
        plumb->ftnew = plumb->ft2;
        plumb->ftold = plumb->ft1;
    } else if(*current_pipe == 1) {
#ifdef DEBUG_MODE
        fprintf(stderr, "compiling to main\n");
#endif
        newpipes = main;
        *current_pipe = 0; 
        plumb->ftmap = plumb->ft1;
        plumb->ftnew = plumb->ft1;
        plumb->ftold = plumb->ft2;
    }

    return newpipes;
}

int plumber_reinit(plumber_data *plumb)
{
    plumbing *newpipes = plumbing_choose(plumb, 
            &plumb->main, &plumb->alt, &plumb->current_pipe);
    plumbing_init(newpipes);
    plumb->tmp = newpipes;
    if(plumb->fp != NULL) fseek(plumb->fp, 0L, SEEK_SET);
    sporth_stack_init(&plumb->sporth.stack);
    plumber_ftmap_init(plumb);
    return PLUMBER_OK;
}

int plumber_reparse(plumber_data *plumb) 
{
    if(plumbing_parse(plumb, plumb->tmp) == PLUMBER_OK) {
        plumbing_compute(plumb, plumb->tmp, PLUMBER_INIT);
#ifdef DEBUG_MODE
        fprintf(stderr, "Successful parse...\n");
        fprintf(stderr, "at stack position %d\n",
                plumb->sporth.stack.pos);
        fprintf(stderr, "%d errors\n",
                plumb->sporth.stack.error);
#endif
    } else {
       return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int plumber_reparse_string(plumber_data *plumb, char *str) 
{
    plumbing *pipes = plumb->tmp;
    if(plumbing_parse_string(plumb, pipes, str) == PLUMBER_OK) {
#ifdef DEBUG_MODE
        fprintf(stderr, "Successful parse...\n");
        fprintf(stderr, "at stack position %d\n",
                plumb->sporth.stack.pos);
        fprintf(stderr, "%d errors\n",
                plumb->sporth.stack.error);
#endif
        plumb->tmp = pipes;
    } else {
        plumb->tmp = pipes;
        return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int plumber_swap(plumber_data *plumb, int error)
{
    if(error == PLUMBER_NOTOK) {
        fprintf(stderr, "Did not recompile...\n");
        plumbing_compute(plumb, plumb->tmp, PLUMBER_DESTROY);
        plumbing_destroy(plumb->tmp);
        sporth_stack_init(&plumb->sporth.stack);
        plumber_ftmap_destroy(plumb);
        plumb->ftmap = plumb->ftold;
        plumb->current_pipe = (plumb->current_pipe == 0) ? 1 : 0;
        if(plumb->current_pipe == 1) {
#ifdef DEBUG_MODE
            fprintf(stderr, "Reverting to alt\n");
#endif
            plumb->pipes = &plumb->alt;
        } else {
#ifdef DEBUG_MODE
            fprintf(stderr, "Reverting to main\n");
#endif
            plumb->pipes = &plumb->main;
        }
        plumb->sp->pos = 0;
    } else {
#ifdef DEBUG_MODE
        fprintf(stderr, "Recompiling...\n");
#endif
        plumbing_compute(plumb, plumb->pipes, PLUMBER_DESTROY);
        plumbing_destroy(plumb->pipes);
        plumb->ftmap = plumb->ftold;
        plumber_ftmap_destroy(plumb);
        plumb->ftmap = plumb->ftnew;
        plumb->pipes = plumb->tmp;
        plumb->sp->pos = 0;
        plumbing_compute(plumb, plumb->pipes, PLUMBER_INIT);
    }
    return PLUMBER_OK;
}

int plumber_recompile(plumber_data *plumb)
{
    int error;
    plumber_reinit(plumb);
    error = plumber_reparse(plumb);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

int plumber_recompile_string(plumber_data *plumb, char *str)
{

    int error;
#ifdef DEBUG_MODE
    fprintf(stderr, "** Attempting to compile string '%s' **\n", str);
#endif
    /* file pointer needs to be NULL for reinit to work with strings */
    plumb->fp = NULL;
    plumber_reinit(plumb);
    error = plumber_reparse_string(plumb, str);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

/* This version of plumber_recompile_string includes a callback function,
 * to be called after it is reinitialized, but before the string
 * is parsed. Useful for adding global ftables.
 */
int plumber_recompile_string_v2(plumber_data *plumb, 
        char *str, 
        void *ud,
        int (*callback)(plumber_data *, void *))
{

    int error;
#ifdef DEBUG_MODE
    fprintf(stderr, "** Attempting to compile string '%s' **\n", str);
#endif
    /* file pointer needs to be NULL for reinit to work with strings */
    plumb->fp = NULL;
    plumber_reinit(plumb);
    callback(plumb, ud);
    error = plumber_reparse_string(plumb, str);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

int plumber_open_file(plumber_data *plumb, char *filename)
{
    plumb->fp = fopen(filename, "r");
    if(plumb->fp == NULL) {
        fprintf(stderr, "There was a problem opening the file %s\n", filename);
        return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int plumber_close_file(plumber_data *plumb)
{
    fclose(plumb->fp);
    plumb->fp = NULL;
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
        plumb->ftmap[pos].root.to_delete = plumb->delete_ft;
        plumb->ftmap[pos].last= &plumb->ftmap[pos].root;
    }

    return PLUMBER_OK;
}

int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft)
{
    uint32_t pos = sporth_hash(str);
#ifdef DEBUG_MODE
    fprintf(stderr, "ftmap_add: Adding new table %s, position %d\n", str, pos);
#endif
    plumber_ftentry *entry = &plumb->ftmap[pos];
    entry->nftbl++;
    plumber_ftbl *new = malloc(sizeof(plumber_ftbl));
    new->ud = (void *)ft;
    new->type = PTYPE_TABLE;
    new->to_delete = plumb->delete_ft;
    new->name = malloc(sizeof(char) * strlen(str) + 1);
    strcpy(new->name, str);
    entry->last->next = new;
    entry->last = new;
    return PLUMBER_OK;
}

int plumber_ftmap_add_userdata(plumber_data *plumb, const char *str, void *ud)
{
    uint32_t pos = sporth_hash(str);
#ifdef DEBUG_MODE
    fprintf(stderr, "ftmap_add_userdata: Adding new generic table %s, position %d\n", str, pos);
#endif
    plumber_ftentry *entry = &plumb->ftmap[pos];
    entry->nftbl++;
#ifdef DEBUG_MODE
    fprintf(stderr, "ftmap_add_userdata: there are now %d in position %d\n", 
            entry->nftbl, pos);
#endif
    plumber_ftbl *new = malloc(sizeof(plumber_ftbl));
    new->ud = ud;
    new->type = PTYPE_USERDATA;
    new->to_delete = plumb->delete_ft;
    new->name = malloc(sizeof(char) * strlen(str) + 1);
    strcpy(new->name, str);
    entry->last->next = new;
    entry->last = new;
    return PLUMBER_OK;
}

int plumber_ftmap_add_function(plumber_data *plumb, 
        const char *str, plumber_dyn_func f, void *ud)
{
    sporth_fload_d *fd = malloc(sizeof(sporth_func_d));
    fd->fun = f;
    fd->ud = ud;
    return plumber_ftmap_add_userdata(plumb, str, (void *)fd);
}

int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft)
{
    plumber_ftbl *ftbl;
    if(plumber_search(plumb, str, &ftbl) != PLUMBER_OK) {
        return PLUMBER_NOTOK;
    } else if(ftbl->type != PTYPE_TABLE) {
        fprintf(stderr, "Error: value '%s' is not of type ftable\n", str);
        return PLUMBER_NOTOK;
    } else {
        *ft = (sp_ftbl *)ftbl->ud;
        return PLUMBER_OK;
    }
}

int plumber_ftmap_search_userdata(plumber_data *plumb, const char *str, void **ud)
{
    plumber_ftbl *ftbl;

    if(plumber_search(plumb, str, &ftbl) != PLUMBER_OK) {
        return PLUMBER_NOTOK;
    } else if(ftbl->type != PTYPE_USERDATA) {
        fprintf(stderr, "Error: value '%s' is not of type userdata\n", str);
        return PLUMBER_NOTOK;
    } else {
        *ud = ftbl->ud;
        return PLUMBER_OK;
    }

}

int plumber_search(plumber_data *plumb, const char *str, plumber_ftbl **ft)
{
    uint32_t pos = sporth_hash(str);

    uint32_t n;
    plumber_ftentry *entry = &plumb->ftmap[pos];
    plumber_ftbl *ftbl = entry->root.next;
    plumber_ftbl *next;
    for(n = 0; n < entry->nftbl; n++) {
        next = ftbl->next;
        if(!strcmp(str, ftbl->name)){
            *ft = ftbl;
            return PLUMBER_OK;
        }
        ftbl = next;
    }
    fprintf(stderr,"Could not find an ftable match for %s.\n", str);
    return PLUMBER_NOTOK;
}

int plumber_ftmap_delete(plumber_data *plumb, char mode)
{
    plumb->delete_ft = mode;
    return PLUMBER_OK;
}

void plumber_ftmap_dump(plumber_ftentry *ft)
{
    uint32_t i, k;
    plumber_ftbl *cur, *next;
    for(i = 0; i < 256; i ++) {
        cur = ft[i].root.next;
        for(k = 0; k < ft[i].nftbl; k++) {
            next = cur->next;
            printf("%s\n", cur->name);
            cur = next; 
        }
    }
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
            if(ftbl->to_delete) {
                if(ftbl->type == PTYPE_TABLE) 
                    sp_ftbl_destroy((sp_ftbl **)&ftbl->ud);
                else free(ftbl->ud);
            }
            free(ftbl);
            ftbl = next;
        }
    }

    return PLUMBER_OK;
}

int plumber_register(plumber_data *plumb)
{
#define SPORTH_UGEN(key, func, macro, ninputs, noutputs) {key, func, plumb},
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
    int len = (int)strlen(str);
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

void sporth_run(plumber_data *pd, int argc, char *argv[],
    void *ud, void (*process)(sp_data *, void *))
{
    char filename[60];
    sprintf(filename, "test.wav");
    int sr = 44100;
    int nchan = 1;
    char *time = NULL;
    argv++;
    argc--;
    int driver = DRIVER_FILE;
    int nullfile = 0;
    int write_code = 0;
    int i;
    int rc;
#ifdef BUILD_JACK
    int port = 6449;
#endif

    while(argc > 0 && argv[0][0] == '-') {
        switch(argv[0][1]) {
            case 'd':
                if(--argc) {
                    argv++;
#ifdef DEBUG_MODE
                   fprintf(stderr,"setting duration to %s\n", argv[0]);
#endif
                    time = argv[0];
                } else {
                   fprintf(stderr,"There was a problem setting the length..\n");
                    exit(1);
                }
                break;
            case 'o':
                if(--argc) {
                    argv++;
                    if(!strcmp(argv[0], "raw")) {
                        driver = DRIVER_RAW;
                    } else {
#ifdef DEBUG_MODE
                       fprintf(stderr,"setting filename to %s\n", argv[0]);
#endif
                       strncpy(filename, argv[0], 60);
                    }
                } else {
                   fprintf(stderr,"There was a problem setting the output file..\n");
                    exit(1);
                }
                break; 
            case 'P':
                pd->showprog = 1;
                break;
            case 'r':
                if(--argc) {
                    argv++;
#ifdef DEBUG_MODE
                   fprintf(stderr,"setting samplerate to %s\n", argv[0]);
#endif
                    sr = atoi(argv[0]);
                } else {
                   fprintf(stderr,"There was a problem setting the samplerate..\n");
                    exit(1);
                }
                break;
            case 'c':
                if(--argc) {
                    argv++;
#ifdef DEBUG_MODE
                   fprintf(stderr,"setting nchannels to %s\n", argv[0]);
#endif
                    nchan = atoi(argv[0]);
                } else {
                   fprintf(stderr,"There was a problem setting the channels..\n");
                    exit(1);
                }
                break;
            case 'b':
                if(--argc) {
                    argv++;
                    if (!strcmp(argv[0], "file")) {
                        driver = DRIVER_FILE;
                    } else if ((!strcmp(argv[0], "raw"))) {
                        driver = DRIVER_RAW;
                    } else if ((!strcmp(argv[0], "plot"))) {
                        driver = DRIVER_PLOT;
                    } else if ((!strcmp(argv[0], "spa"))) {
                        driver = DRIVER_SPA;
#ifdef BUILD_JACK
                    } else if ((!strcmp(argv[0], "jack"))) {
                        driver = DRIVER_JACK;
#endif
                    } else {
                       fprintf(stderr,"Could not find driver \"%s\".\n", argv[0]);
                        exit(1);
                    }
                } else {
                   fprintf(stderr,"There was a problem setting the driver..\n");
                    exit(1);
                }
                break;
            case 'h':
                fprintf(stderr,"Usage: sporth input.sp\n");
                exit(1);
                break;
            case 'n':
                driver = DRIVER_NULL;
                break;
            case '0':
                nullfile = 1;
                break;
            case 'p':
#ifdef BUILD_JACK
                argv++;
                if(--argc) { 
                    port = atoi(argv[0]);
                } else {
                    fprintf(stderr, "Please specify a port number for jack\n");
                    exit(1);
                }
#endif
                break;
            case 'w':
                write_code = 1;
                break;
            case 's':
                argv++;
                if(--argc) { 
                    pd->seed = (uint32_t)atol(argv[0]);
                } else {
                    fprintf(stderr, "Seed needs an argument.\n");
                    exit(1);
                }
                break;
            default:
                fprintf(stderr,"default.. \n");
                exit(1);
                break;
        }
        argv++;
        argc--;
    }


    if(argc == 0) {
        pd->fp = stdin;
    } else {
        pd->fp = fopen(argv[0], "r");
        pd->filename = argv[0];
        if(pd->fp == NULL) {
            fprintf(stderr,
                    "There was an issue opening the file %s.\n", argv[0]);
            exit(1);
        }
    }

    plumber_register(pd);
    pd->nchan = nchan;
    srand(pd->seed);
    sp_data *sp;
    sp_createn(&sp, pd->nchan);
    strncpy(sp->filename, filename, 60);
    pd->sp = sp;
    sp_srand(pd->sp, pd->seed);
    sp->sr = sr;
    if(time != NULL) sp->len = str2time(pd, time);
    pd->ud = ud;
    if(pd->showprog) {
        sp_progress_create(&pd->prog);
        sp_progress_init(sp, pd->prog);
    }
    if(nullfile) {
        pd->mode = PLUMBER_CREATE;
        for(i = 0; i < nchan; i++) {
            plumber_add_float(pd, pd->pipes, 0);
            sporth_stack_push_float(&pd->sporth.stack, 0);
        }
        rc = PLUMBER_OK;
    } else {
        rc  = plumber_parse(pd);
    }
    if(write_code) {
        plumbing_write_code(pd, pd->pipes, stdout);
        fflush(stdout);
    }

    if(rc == PLUMBER_OK){
        plumber_compute(pd, PLUMBER_INIT);
        pd->sporth.stack.pos = 0;
#ifdef DEBUG_MODE
        plumber_show_pipes(pd);
#endif
        switch(driver) {
            case DRIVER_FILE:
#ifndef NO_LIBSNDFILE
                sp_process(sp, ud, process);
#endif
                break;
            case DRIVER_RAW:
                sp_process_raw(sp, ud, process);
                break;
            case DRIVER_PLOT:
                sp_process_plot(sp, ud, process);
                break;
            case DRIVER_SPA:
#ifdef USE_SPA
                sp_process_spa(sp, ud, process);
#endif
                break;
#ifdef BUILD_JACK
            case DRIVER_JACK:
                sp_process_jack(pd, ud, process, port);
                break;
#endif
            case DRIVER_NULL:
                plumber_process_null(sp, ud, process);
                break;
            default:
#ifndef NO_LIBSNDFILE
                sp_process(sp, ud, process);
#endif
                break;
        }
    }
    if(pd->sporth.stack.error > 0) {
       fprintf(stderr,"Uh-oh! Sporth created %d error(s).\n",
                pd->sporth.stack.error);
    }

    if(pd->showprog){
        sp_progress_destroy(&pd->prog);
    }

    plumber_clean(pd);
    sp_destroy(&sp);
}

static volatile int running = 1;

void plumber_interrupt(int dummy)
{
    fprintf(stderr, "Cleaning up...\n");
    running = 0;
}

int plumber_process_null(sp_data *sp, void *ud, void (*callback)(sp_data *, void *))
{
    if(sp->len == 0) {
        signal(SIGINT, plumber_interrupt);
        while(running) {
            callback(sp, ud);
            sp->len--;
//            usleep(100);
        }
    } else {
        while(sp->len > 0) {
            callback(sp, ud);
            sp->len--;
            sp->pos++;
        }
    }
    return SP_OK;
}

plumbing * plumber_get_pipes(plumber_data *plumb)
{
    return plumb->tmp;
}

int plumber_argtbl_create(plumber_data *plumb, plumber_argtbl **at, uint32_t size)
{
    plumber_argtbl *atp = malloc(sizeof(plumber_argtbl));
    atp->size = size;
    atp->tbl = malloc(sizeof(SPFLOAT *) * size);
    *at = atp;
    return PLUMBER_OK;
}

int plumber_argtbl_destroy(plumber_data *plumb, plumber_argtbl **at)
{
    plumber_argtbl *atp = *at;
    free(atp->tbl);
    free(atp);
    return PLUMBER_OK;
}

int plumber_get_userdata(plumber_data *plumb, const char *name, plumber_ptr **p)
{
    plumber_ptr *pp = *p;
    return plumber_ftmap_search_userdata(plumb, name, &pp->ud);
}

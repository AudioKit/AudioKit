#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <signal.h>
#include <stdarg.h>

#include "plumber.h"

#define SPORTH_UGEN(key, func, macro, ninputs, noutputs) \
    int func(sporth_stack *stack, void *ud);
#include "ugens.h"
#undef SPORTH_UGEN

#ifdef BUILD_JACK
int sp_process_jack(plumber_data *pd, 
        void *ud, void (*callback)(sp_data *, void *), int port, int wait);
#endif 

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
    plumb->log = stderr;
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
    plumber_print(plumb, "\nShowing pipes: \n");
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = pipes->root.next;
    for(n = 0; n < pipes->npipes; n++) {
        next = pipe->next;
        plumber_print(plumb, "\ttype = %d ", pipe->type);
        switch(pipe->type) {
            case SPORTH_FLOAT:
                plumber_print(plumb, "(float)\n");
                break;
            case SPORTH_STRING:
                plumber_print(plumb, "(string)\n");
                break;
            default:
                plumber_print(plumb, "(%s)\n", 
                        plumb->sporth.flist[pipe->type - SPORTH_FOFFSET].name);
                break;
        }

        pipe = next;
    }
    plumber_print(plumb, "%d pipes total. \n\n", pipes->npipes);
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
    plumber_print(plumb, "----Plumber Destroy----\n");
#endif
    uint32_t n;
    plumber_pipe *pipe, *next;
    pipe = pipes->root.next;
    for(n = 0; n < pipes->npipes; n++) {
        next = pipe->next;
#ifdef DEBUG_MODE
        plumber_print(plumb, "Pipe %d\ttype %d\n", n, pipe->type);
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
        plumber_print(plumb,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = SPORTH_FLOAT;
    new->size = sizeof(SPFLOAT);
    new->ud = malloc(new->size);
    float *val = new->ud;
    *val = num;
    if(new->ud == NULL) {
        plumber_print(plumb,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    plumbing_add_pipe(pipes, new);
    return PLUMBER_OK;
}

char * plumber_add_string(plumber_data *plumb, plumbing *pipes, const char *str)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
        plumber_print(plumb,"Memory error\n");
        return NULL;
    }

    new->type = SPORTH_STRING;
    new->size = sizeof(char) * strlen(str) + 1;
    new->ud = malloc(new->size);
    char *sval = new->ud;
    strncpy(sval, str, new->size);
    if(new->ud == NULL) {
        plumber_print(plumb,"Memory error\n");
        return NULL;
    }

    plumbing_add_pipe(pipes, new);
    return sval;
}

int plumber_add_ugen(plumber_data *plumb, uint32_t id, void *ud)
{
    plumber_pipe *new = malloc(sizeof(plumber_pipe));

    if(new == NULL) {
        plumber_print(plumb,"Memory error\n");
        return PLUMBER_NOTOK;
    }

    new->type = id;
    new->ud = ud;

    plumbing_add_pipe(plumb->tmp, new);
    return PLUMBER_OK;
}

plumbing *plumbing_choose(plumber_data *plumb, 
        plumbing *main, plumbing *alt, int *current_pipe)
{
    plumbing *newpipes = NULL;

    if(*current_pipe == 0) {
#ifdef DEBUG_MODE
        plumber_print(plumb, "compiling to alt\n");
#endif
        newpipes = alt;
        *current_pipe = 1;
        plumb->ftmap = plumb->ft2;
        plumb->ftnew = plumb->ft2;
        plumb->ftold = plumb->ft1;
    } else if(*current_pipe == 1) {
#ifdef DEBUG_MODE
        plumber_print(plumb, "compiling to main\n");
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

int plumber_open_file(plumber_data *plumb, char *filename)
{
    plumb->fp = fopen(filename, "r");
    if(plumb->fp == NULL) {
        plumber_print(plumb, "There was a problem opening the file %s\n", filename);
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
    plumber_print(plumb,"%s\n", str);
    exit(1);
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
    plumber_print(plumb,"Could not find an ftable match for %s.\n", str);
    return PLUMBER_NOTOK;
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
    int wait = 1;
#endif

    while(argc > 0 && argv[0][0] == '-') {
        switch(argv[0][1]) {
            case 'd':
                if(--argc) {
                    argv++;
#ifdef DEBUG_MODE
                    plumber_print(pd, "setting duration to %s\n", argv[0]);
#endif
                    time = argv[0];
                } else {
                    plumber_print(pd, "There was a problem setting the length..\n");
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
                       plumber_print(pd, "setting filename to %s\n", argv[0]);
#endif
                       strncpy(filename, argv[0], 60);
                    }
                } else {
                   plumber_print(pd, "There was a problem setting the output file..\n");
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
                   plumber_print(pd, "setting samplerate to %s\n", argv[0]);
#endif
                    sr = atoi(argv[0]);
                } else {
                   plumber_print(pd, "There was a problem setting the samplerate..\n");
                    exit(1);
                }
                break;
            case 'c':
                if(--argc) {
                    argv++;
#ifdef DEBUG_MODE
                   plumber_print(pd, "setting nchannels to %s\n", argv[0]);
#endif
                    nchan = atoi(argv[0]);
                } else {
                   plumber_print(pd, "There was a problem setting the channels..\n");
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
                       plumber_print(pd, "Could not find driver \"%s\".\n", argv[0]);
                        exit(1);
                    }
                } else {
                   plumber_print(pd, "There was a problem setting the driver..\n");
                    exit(1);
                }
                break;
            case 'h':
                plumber_print(pd, "Usage: sporth input.sp\n");
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
                    plumber_print(pd, "Please specify a port number for jack\n");
                    exit(1);
                }
#endif
                break;
            case 'w':
                write_code = 1;
                break;
#ifdef BUILD_JACK
            case 'S':
                wait = 0;
                break;
#endif
            case 's':
                argv++;
                if(--argc) { 
                    pd->seed = atol(argv[0]);
                } else {
                    plumber_print(pd, "Seed needs an argument.\n");
                    exit(1);
                }
                break;
            default:
                plumber_print(pd, "default.. \n");
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
            plumber_print(pd,
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
//                sp_process_spa(sp, ud, process);
                break;
#ifdef BUILD_JACK
            case DRIVER_JACK:
                sp_process_jack(pd, ud, process, port, wait);
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


#ifdef BUILD_JACK
    if(!wait) return ;
#endif

    if(pd->sporth.stack.error > 0) {
       plumber_print(pd, "Uh-oh! Sporth created %d error(s).\n",
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

int plumber_get_userdata(plumber_data *plumb, const char *name, plumber_ptr **p)
{
    plumber_ptr *pp = *p;
    return plumber_ftmap_search_userdata(plumb, name, &pp->ud);
}

void plumber_print(plumber_data *pd, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vfprintf(pd->log, fmt, args);
    va_end(args);
    fflush(pd->log);
}

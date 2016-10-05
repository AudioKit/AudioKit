#include <stdlib.h>
#include <dlfcn.h>
#include "plumber.h"

typedef struct {
    void *handle;
    char *name;
} sporth_fclose_d;

int sporth_f(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    unsigned int fnum;
    sporth_func_d *fd;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "aux (f)unction: creating\n");
#endif
            fd = malloc(sizeof(sporth_func_d));
           if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for aux (f)unction\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            plumber_add_ugen(pd, SPORTH_F, fd);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "aux (f)unction: initialising\n");
#endif
            fnum = (int)sporth_stack_pop_float(stack);

            if(fnum > 16) {
                fprintf(stderr, "Invalid function number %d\n", fnum);
                stack->error++;
                return PLUMBER_NOTOK;
            }

            fd = pd->last->ud;
            fd->fun = pd->f[fnum];

            pd->mode = PLUMBER_CREATE;
            fd->fun(stack, ud);

            pd->mode = PLUMBER_INIT;
            fd->fun(stack, ud);

            break;

        case PLUMBER_COMPUTE:
            fnum = (int)sporth_stack_pop_float(stack);
            fd = pd->last->ud;
            fd->fun(stack, ud);
            break;

        case PLUMBER_DESTROY:
            fd = pd->last->ud;
            fd->fun(stack, ud);
            free(fd);
            break;
        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_fload(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "fload: creating\n");
#endif
            fload = malloc(sizeof(sporth_fload_d));
            plumber_add_ugen(pd, SPORTH_FLOAD, fload);
            if(sporth_check_args(stack, "ss") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for fload\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fload->filename= sporth_stack_pop_string(stack);
            fload->name = sporth_stack_pop_string(stack);
           
            fload->handle = dlopen(fload->filename, RTLD_NOW);
            if(fload->handle == NULL) {
                fprintf(stderr, "Error loading %s: %s\n", fload->name, dlerror());
                return PLUMBER_NOTOK;
            }

            fload->getter = dlsym(fload->handle, "sporth_return_ugen");
            fload->fun = fload->getter();
            plumber_ftmap_add_userdata(pd, fload->name, (void *)fload);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "fload: initialising\n");
#endif
            fload = pd->last->ud;
            fload->filename= sporth_stack_pop_string(stack);
            fload->name = sporth_stack_pop_string(stack);

            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr, "fload: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_fclose(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_fclose_d *fclose;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "fclose: creating\n");
#endif
            fclose = malloc(sizeof(sporth_fclose_d));
            plumber_add_ugen(pd, SPORTH_FCLOSE, fclose);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for fclose\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fclose->name = sporth_stack_pop_string(stack);
           
            if(plumber_ftmap_search_userdata(pd, fclose->name, (void *)&fload) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fclose->handle = fload->handle;
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "fclose: initialising\n");
#endif
            fclose = pd->last->ud;
            fclose->name = sporth_stack_pop_string(stack);

            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            fprintf(stderr, "fclose: destroying\n");
#endif
            fclose= pd->last->ud;
            dlclose(fclose->handle);
            free(fclose);
            break;
        default:
            fprintf(stderr, "fclose: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_fexec(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_fload_d *fexec;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "fexec: creating\n");
#endif
            fexec = malloc(sizeof(sporth_fload_d));
            plumber_add_ugen(pd, SPORTH_FEXEC, fexec);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for fclose\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fexec->name = sporth_stack_pop_string(stack);
           
            if(plumber_ftmap_search_userdata(pd, fexec->name, (void *)&fload) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fexec->fun = fload->fun;
            fexec->fun(pd, stack, &fexec->ud);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "fexec: initialising\n");
#endif
            fexec = pd->last->ud;
            fexec->name = sporth_stack_pop_string(stack);

            fexec->fun(pd, stack, &fexec->ud);
            break;

        case PLUMBER_COMPUTE:
            fexec = pd->last->ud;
            fexec->fun(pd, stack, &fexec->ud);
            break;

        case PLUMBER_DESTROY:
            fexec = pd->last->ud;
            fexec->fun(pd, stack, &fexec->ud);
            free(fexec);
            break;
        default:
            fprintf(stderr, "fexec: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

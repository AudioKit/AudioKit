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
    sporth_fload_d *fexec;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:
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
            fexec->ud = fload->ud;
            break;

        case PLUMBER_INIT:
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

        default: break;
    }
    return PLUMBER_OK;
}

int sporth_fload(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_fload_d *fload;
    char buf[512];
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
          
            if(getenv("SPORTH_PLUGIN_PATH") != NULL && 
                fload->filename[0] != '.') {
                sprintf(buf, "%s/%s", 
                        getenv("SPORTH_PLUGIN_PATH"),
                        fload->filename);
                fload->handle = dlopen(buf, RTLD_NOW);
            } else {
                fload->handle = dlopen(fload->filename, RTLD_NOW);
            }
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

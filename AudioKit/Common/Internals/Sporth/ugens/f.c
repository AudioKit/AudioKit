#include <stdlib.h>
#ifndef NO_LIBDL
#include <dlfcn.h>
#endif
#include "plumber.h"

typedef struct {
    void *handle;
    const char *name;
} sporth_fclose_d;

int sporth_fload(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
#ifdef NO_LIBDL
    plumber_print(pd, "fload is not implemented in this version of Sporth\n");
    return PLUMBER_NOTOK;
#else
    sporth_fload_d *fload;
    char buf[512];
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fload: creating\n");
#endif
            fload = malloc(sizeof(sporth_fload_d));
            plumber_add_ugen(pd, SPORTH_FLOAD, fload);
            if(sporth_check_args(stack, "ss") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fload\n");
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
                fload->handle = dlopen(buf, RTLD_NOW | RTLD_GLOBAL);
            } else {
                fload->handle = dlopen(fload->filename, RTLD_NOW | RTLD_GLOBAL);
            }
            if(fload->handle == NULL) {
                plumber_print(pd, "Error loading %s: %s\n", fload->name, dlerror());
                return PLUMBER_NOTOK;
            }

            fload->getter = dlsym(fload->handle, "sporth_return_ugen");
            fload->fun = fload->getter();
            plumber_ftmap_add_userdata(pd, fload->name, (void *)fload);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "fload: initialising\n");
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
            plumber_print(pd, "fload: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
#endif
}

int sporth_fclose(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
#ifdef NO_LIBDL
    plumber_print(pd, "fclose is not implemented in this version of Sporth\n");
    return PLUMBER_NOTOK;
#else
    sporth_fclose_d *fclose;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fclose: creating\n");
#endif
            fclose = malloc(sizeof(sporth_fclose_d));
            plumber_add_ugen(pd, SPORTH_FCLOSE, fclose);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fclose\n");
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
            plumber_print(pd, "fclose: initialising\n");
#endif
            fclose = pd->last->ud;
            fclose->name = sporth_stack_pop_string(stack);

            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            plumber_print(pd, "fclose: destroying\n");
#endif
            fclose= pd->last->ud;
            if(fclose->handle != NULL) dlclose(fclose->handle);
            free(fclose);
            break;
        default:
            plumber_print(pd, "fclose: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
#endif
}

int sporth_fexec(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_fload_d *fexec;
    sporth_fload_d *fload;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fexec: creating\n");
#endif
            fexec = malloc(sizeof(sporth_fload_d));
            plumber_add_ugen(pd, SPORTH_FEXEC, fexec);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fexec\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fexec->name = sporth_stack_pop_string(stack);
           
            if(plumber_ftmap_search_userdata(pd, fexec->name, (void *)&fload) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fexec->fun = fload->fun;
            fexec->ud = fload->ud;
            fexec->fun(pd, stack, &fexec->ud);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "fexec: initialising\n");
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
            plumber_print(pd, "fexec: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_floadi(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
#ifdef NO_LIBDL
    plumber_print(pd, "floadi is not implemented in this version of Sporth\n");
    return PLUMBER_NOTOK;
#else
    sporth_fload_d *fload;
    char buf[512];
    int num;
    switch(pd->mode) {
        case PLUMBER_CREATE:

            fload = malloc(sizeof(sporth_fload_d));
            plumber_add_ugen(pd, SPORTH_FLOADI, fload);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fload\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fload->filename= sporth_stack_pop_string(stack);
            num = sporth_stack_pop_float(stack);
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
                plumber_print(pd, "Error loading %s: %s\n", fload->name, dlerror());
                return PLUMBER_NOTOK;
            }

            fload->getter_multi = 
                dlsym(fload->handle, "sporth_return_ugen_multi");
            if(fload->getter_multi(num, &fload->fun) != PLUMBER_OK) {
                plumber_print(pd, "fli: could not load\n");
                return PLUMBER_NOTOK;
            }
            plumber_ftmap_add_userdata(pd, fload->name, (void *)fload);
            break;

        case PLUMBER_INIT:
            fload = pd->last->ud;
            fload->filename= sporth_stack_pop_string(stack);
            num = sporth_stack_pop_float(stack);
            fload->name = sporth_stack_pop_string(stack);

            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;
    }
    return PLUMBER_OK;
#endif
}

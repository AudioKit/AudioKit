#include "soundpipe.h"
#include "sporth.h"

/* implement macros */
#define SPORTH_UGEN(key, func, macro, ninputs, noutputs)  macro,
enum {
SP_DUMMY = SPORTH_FOFFSET - 1,
#include "ugens.h"
SPORTH_LAST
};
#undef SPORTH_UGEN

/* Do not remove this line below! It is needed for a script. */
/* ---- */

#ifndef PLUMBER_H
#define PLUMBER_H

/* it just so happens that PLUMBER_OK and SPORTH_OK are the same values */
enum {
PLUMBER_CREATE,
PLUMBER_INIT,
PLUMBER_COMPUTE,
PLUMBER_DESTROY,
PLUMBER_NOTOK,
PLUMBER_OK,
PLUMBER_PANIC
};

enum {
PTYPE_NIL,
PTYPE_TABLE,
PTYPE_USERDATA
};

typedef int (* plumber_func) (sporth_stack *, void *) ;

typedef struct plumber_ftbl {
    void *ud;
    char *name;
    char to_delete;
    char type;
    struct plumber_ftbl *next;
} plumber_ftbl;

typedef struct {
    uint32_t nftbl;
    plumber_ftbl root;
    plumber_ftbl *last;
} plumber_ftentry;

typedef struct plumber_pipe {
    uint32_t type;
    size_t size;
    void *ud;
    struct plumber_pipe *next;
} plumber_pipe;

typedef struct {
    plumber_func fun;
    void *ud;
} sporth_func_d;

typedef struct {
    uint32_t npipes;
    int tick;
    plumber_pipe root;
    plumber_pipe *last;
} plumbing;

typedef struct plumber_data {
    int nchan;
    int mode;
    uint32_t seed;
    sp_data *sp;
    FILE *fp;
    char *filename;
    sporth_data sporth;
    plumbing *pipes;
    /* for add_module function */
    plumbing *tmp;
    int current_pipe;
    plumbing main, alt;

    plumber_ftentry ft1[256];
    plumber_ftentry ft2[256];
    plumber_ftentry *ftmap;
    plumber_ftentry *ftnew, *ftold;
    char delete_ft;

    SPFLOAT p[16];
    void *ud;
    plumber_pipe *next;
    plumber_pipe *last;
    sp_progress *prog;
    int showprog;
    int recompile;
    char *str;

    FILE *log;
} plumber_data;

typedef int (* plumber_dyn_func) (plumber_data *, sporth_stack *, void **);

/* needed for dynamic loading */
typedef struct {
    sporth_func_d *fd;
    plumber_dyn_func fun;
    plumber_dyn_func (*getter)();
    char *filename;
    char *name;
    void *handle;
    void *ud;
} sporth_fload_d; 

#ifdef LIVE_CODING
#include <pthread.h>
typedef struct {
    plumber_data *pd;
    int start;
    pthread_t thread;
    int portno;
} sporth_listener;
void sporth_start_listener(sporth_listener *sl);
#endif

typedef struct {
    unsigned short type;
    void *ud;
} plumber_ptr;

typedef struct scheme scheme;
typedef struct cell *pointer;

int plumber_init(plumber_data *plumb);
int plumber_register(plumber_data *plumb);
int plumber_clean(plumber_data *plumb);

int plumber_add_float(plumber_data *plumb, plumbing *pipes, float num);
char * plumber_add_string(plumber_data *plumb, plumbing *pipes, const char *str);
int plumber_add_ugen(plumber_data *plumb, uint32_t id, void *ud);

int plumber_compute(plumber_data *plumb, int mode);

int plumber_parse(plumber_data *plumb);
int plumber_parse_string(plumber_data *plumb, char *str);

int plumber_recompile(plumber_data *plumb);
int plumber_recompile_string(plumber_data *plumb, char *str);
plumbing *plumbing_choose(plumber_data *plumb, 
        plumbing *main, plumbing *alt, int *current_pipe);
int plumber_reinit(plumber_data *plumb);
int plumber_reparse(plumber_data *plumb);
int plumber_reparse_string(plumber_data *plumb, char *str);
int plumber_recompile_string(plumber_data *plumb, char *str);
int plumber_recompile_string_v2(plumber_data *plumb, 
        char *str, 
        void *ud,
        int (*callback)(plumber_data *, void *));
int plumber_swap(plumber_data *plumb, int error);
int plumber_open_file(plumber_data *plumb, char *filename);
int plumber_close_file(plumber_data *plumb);

int plumber_gettype(plumber_data *plumb, char *str, int mode);
void plumber_show_pipes(plumber_data *plumb);
int plumber_error(plumber_data *plumb, const char *str);

int plumber_ftmap_init(plumber_data *plumb);
int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft);
int plumber_ftmap_add_userdata(plumber_data *plumb, const char *str, void *ud);
int plumber_ftmap_add_function(plumber_data *plumb, 
        const char *str, plumber_dyn_func f, void *ud);
int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft);
int plumber_ftmap_search_userdata(plumber_data *plumb, const char *str, void **ud);
int plumber_ftmap_destroy(plumber_data *plumb);
int plumber_ftmap_delete(plumber_data *plumb, char mode);
void plumber_ftmap_dump(plumber_ftentry *ft);
plumbing * plumber_get_pipes(plumber_data *plumb);
int plumber_search(plumber_data *plumb, const char *str, plumber_ftbl **ft);

void sporth_run(plumber_data *pd, int argc, char *argv[],
    void *ud, void (*process)(sp_data *, void *));

int plumber_lexer(plumber_data *plumb, plumbing *pipes, char *out, uint32_t len);

int plumbing_init(plumbing *pipes);
int plumbing_destroy(plumbing *pipes);
int plumbing_add_pipe(plumbing *pipes, plumber_pipe *pipe);
int plumbing_compute(plumber_data *plumb, plumbing *pipes, int mode);
int plumbing_parse(plumber_data *plumb, plumbing *pipes);
int plumbing_parse_string(plumber_data *plumb, plumbing *pipes, char *str);
void plumbing_show_pipes(plumber_data *plumb, plumbing *pipes);
void plumbing_write_code(plumber_data *plumb, plumbing *pipes, FILE *fp);
void plumber_write_code(plumber_data *plumb, FILE *fp);
int plumber_process_null(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));

int plumber_create_var(plumber_data *pd, char *name, SPFLOAT **var);

int plumber_get_userdata(plumber_data *plumb, const char *name, plumber_ptr **p);
int polysporth_eval(plumber_ptr *p, const char *str);

void plumber_print(plumber_data *pd, const char *fmt, ...);
#endif

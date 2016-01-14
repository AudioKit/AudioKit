#include <soundpipe.h>
#include "sporth.h"

/* implement macros */
#define SPORTH_UGEN(key, func, macro)  macro,
enum {
SP_DUMMY = SPORTH_FOFFSET - 1,
#include "ugens.h"
SPORTH_LAST
};
#undef SPORTH_UGEN

/* Do not remove this line below! It is needed for a script. */
/* ---- */

enum {
PLUMBER_CREATE,
PLUMBER_INIT,
PLUMBER_COMPUTE,
PLUMBER_DESTROY,
PLUMBER_OK,
PLUMBER_NOTOK,
PLUMBER_PANIC
};

enum {
DRIVER_FILE,
DRIVER_RAW
};

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
    int (*fun)(sporth_stack *, void *);
    void *ud;
} sporth_func_d;

typedef struct {
    uint32_t npipes;
    plumber_pipe root;
    plumber_pipe *last;
} plumbing;

typedef struct plumber_data {
    int nchan;
    int mode;
    int seed;
    sp_data *sp;
    FILE *fp;
    char *filename;
    sporth_data sporth;
    plumbing *pipes;
    /* for add_module function */
    plumbing *tmp;
    int current_pipe;
    plumbing main, alt;

    plumber_ftentry *ftmap;
    plumber_ftentry *ftnew, *ftold;
    plumber_ftentry ft1[256];
    plumber_ftentry ft2[256];
    char delete_ft;

    SPFLOAT p[16];
    int (*f[16])(sporth_stack *, void *);
    void *ud;
    plumber_pipe *next;
    plumber_pipe *last;
} plumber_data;

int plumber_init(plumber_data *plumb);
int plumber_register(plumber_data *plumb);
int plumber_clean(plumber_data *plumb);

int plumber_add_float(plumber_data *plumb, plumbing *pipes, float num);
int plumber_add_string(plumber_data *plumb, plumbing *pipes, const char *str);
int plumber_add_ugen(plumber_data *plumb, uint32_t id, void *ud);

int plumber_compute(plumber_data *plumb, int mode);

int plumber_parse(plumber_data *plumb);
int plumber_parse_string(plumber_data *plumb, char *str);

int plumber_recompile(plumber_data *plumb);
int plumber_recompile_string(plumber_data *plumb, char *str);
int plumber_reinit(plumber_data *plumb);
int plumber_reparse(plumber_data *plumb);
int plumber_reparse_string(plumber_data *plumb, char *str);
int plumber_recompile_string(plumber_data *plumb, char *str);
int plumber_swap(plumber_data *plumb, int error);

int plumber_gettype(plumber_data *plumb, char *str, int mode);
int plumber_show_pipes(plumber_data *plumb);
int plumber_error(plumber_data *plumb, const char *str);

int plumber_ftmap_init(plumber_data *plumb);
int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft);
int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft);
int plumber_ftmap_destroy(plumber_data *plumb);
int plumber_ftmap_delete(plumber_data *plumb, char mode);

void sporth_run(plumber_data *pd, int argc, char *argv[],
    void *ud, void (*process)(sp_data *, void *));

int plumber_lexer(plumber_data *plumb, plumbing *pipes, char *out, uint32_t len);

int plumbing_init(plumbing *pipes);
int plumbing_destroy(plumbing *pipes);
int plumbing_add_pipe(plumbing *pipes, plumber_pipe *pipe);
int plumbing_compute(plumber_data *plumb, plumbing *pipes, int mode);
int plumbing_parse(plumber_data *plumb, plumbing *pipes);
int plumbing_parse_string(plumber_data *plumb, plumbing *pipes, char *str);

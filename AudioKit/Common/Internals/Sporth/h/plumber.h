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
    sp_ftbl *ft;
    char *name;
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

typedef struct plumber_data {
    int nchan;
    int mode;
    int seed;
    sp_data *sp;
    FILE *fp;
    char *filename;
    sporth_data sporth;
    sp_ftbl tbl_stack[32];
    uint32_t npipes;
    plumber_pipe root;
    plumber_pipe *last;

    plumber_ftentry ftmap[256];

    SPFLOAT p[16];
    int (*f[16])(sporth_stack *, void *);
    void *ud;
} plumber_data;

int plumber_init(plumber_data *plumb);
int plumber_register(plumber_data *plumb);
int plumber_clean(plumber_data *plumb);
int plumber_add_float(plumber_data *plumb, float num);
int plumber_add_string(plumber_data *plumb, const char *str);
int plumber_add_module(plumber_data *plumb,
        uint32_t id, size_t size, void *ud);
int plumber_compute(plumber_data *plumb, int mode);
int plumber_parse(plumber_data *plumb);
int plumber_parse_string(plumber_data *plumb, char *str);
int plumber_recompile(plumber_data *plumb);
int plumber_gettype(plumber_data *plumb, char *str, int mode);
int plumber_show_pipes(plumber_data *plumb);
int plumber_pipes_destroy(plumber_data *plumb);
int plumber_error(plumber_data *plumb, const char *str);
int plumber_ftmap_init(plumber_data *plumb);
int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft);
int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft);
int plumber_ftmap_destroy(plumber_data *plumb);
void sporth_run(plumber_data *pd, int argc, char *argv[],
    void *ud, void (*process)(sp_data *, void *));

#ifdef MINIMAL
#include <stdlib.h>
#endif

enum {
SPORTH_FLOAT,
SPORTH_STRING,
SPORTH_IGNORE,
SPORTH_FUNC,
SPORTH_NOTOK,
SPORTH_OK,
SPORTH_WORD
};

#define SPORTH_FOFFSET 2
#define SPORTH_MAXCHAR 200
#define SPORTH_STACK_SIZE 32

typedef struct {
    float fval;
    char *sval;
    int type;
} sporth_stack_val;

typedef struct {
    int pos;
    uint32_t error;
    sporth_stack_val stack[SPORTH_STACK_SIZE];
} sporth_stack;

typedef struct sporth_entry {
    uint32_t val;
    char *key;
    struct sporth_entry *next;
} sporth_entry;

typedef struct {
    uint32_t count;
    sporth_entry root;
    sporth_entry *last;
} sporth_list ;

typedef struct {
    sporth_list list[256];
} sporth_htable;

typedef struct {
    const char *name;
    int (*func)(sporth_stack *, void *);
    void *ud;
} sporth_func;

typedef struct sporth_data {
    sporth_htable dict;
    uint32_t nfunc;
    sporth_func *flist;
    sporth_stack stack;
} sporth_data;

uint32_t sporth_hash(const char *str);
int sporth_search(sporth_htable *ht, const char *key, uint32_t *val);
int sporth_htable_add(sporth_htable *ht, const char *key, uint32_t val);
int sporth_htable_init(sporth_htable *ht);
int sporth_htable_destroy(sporth_htable *ht);

int sporth_stack_init(sporth_stack *stack);
int sporth_stack_push_float(sporth_stack *stack, float val);
int sporth_stack_push_string(sporth_stack *stack, char **str);
float sporth_stack_pop_float(sporth_stack *stack);
char * sporth_stack_pop_string(sporth_stack *stack);
int sporth_check_args(sporth_stack *stack, const char *args);
int sporth_register_func(sporth_data *sporth, sporth_func *flist);
int sporth_exec(sporth_data *sporth, const char *keyword);
int sporth_init(sporth_data *sporth);
int sporth_destroy(sporth_data *sporth);

int sporth_gettype(sporth_data *sporth, char *str, int mode);
int sporth_parse(sporth_data *sporth, const char *filename);
char * sporth_tokenizer(char *str,
        uint32_t size, uint32_t *pos);
int sporth_lexer(char *str, int32_t size);


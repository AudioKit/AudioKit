#ifndef POOLS_H
#define POOLS_H

#define POOL_SIZE 256

typedef struct myflt_pool {
    CS_VAR_MEM* values;
    int max;
    int count;
} MYFLT_POOL;

MYFLT_POOL* myflt_pool_create(CSOUND* csound);
int myflt_pool_indexof(MYFLT_POOL* pool, MYFLT value);
int myflt_pool_find_or_add(CSOUND* csound, MYFLT_POOL* pool, MYFLT value);
int myflt_pool_find_or_addc(CSOUND* csound, MYFLT_POOL* pool, char* s);
void myflt_pool_free(CSOUND *csound, MYFLT_POOL *pool);

#endif


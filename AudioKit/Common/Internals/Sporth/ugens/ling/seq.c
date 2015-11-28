#include <stdint.h>
#ifdef DEBUG_MODE
#include <stdio.h>
#endif
#include "sporth.h"
#include "ling.h"

int ling_seq_init(ling_seq *seq)
{
    seq->num = 0;
    seq->last = &seq->root;
    return LING_OK;
}

int ling_seq_add_entry(ling_seq *seq, int type, uint32_t val)
{
    ling_entry *new = malloc(sizeof(ling_entry));
    new->type = type;
    new->val = val;

    seq->last->next = new;
    seq->last = new;
    seq->num++;
    return LING_OK;
}

int ling_seq_destroy(ling_seq *seq)
{
    uint32_t n;
    ling_entry *entry = seq->root.next;
    ling_entry *next;
    
    for(n = 0; n < seq->num; n++) {
        next = entry->next;
        free(entry);
        entry = next;
    }

    return LING_OK;
}

int ling_seq_run(ling_data *ld)
{
    uint32_t n;
    ling_entry *entry = ld->seq.root.next;
    ling_entry *next;
    
    for(n = 0; n < ld->seq.num; n++) {
        next = entry->next;
        if(entry->type == LING_INT) {
#ifdef DEBUG_MODE
            fprintf(stderr, "ling_run: pushing value %d\n", entry->val);
#endif
            ling_stack_push(&ld->stack, entry->val);
        } else if(entry->type == LING_FUNC) {
#ifdef DEBUG_MODE
            fprintf(stderr, "ling_run: running function %d\n", entry->val);
#endif
            ld->flist[entry->val].func(&ld->stack, 
                    ld->flist[entry->val].ud);
        }
        entry = next;
    }

    return LING_OK;
}

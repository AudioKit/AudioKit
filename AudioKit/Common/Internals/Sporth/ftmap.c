#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int plumber_ftmap_init(plumber_data *plumb)
{
    int pos;

    for(pos = 0; pos < 256; pos++) {
        plumb->ftmap[pos].nftbl = 0;
        plumb->ftmap[pos].root.to_delete = plumb->delete_ft;
        plumb->ftmap[pos].last= &plumb->ftmap[pos].root;
    }

    return PLUMBER_OK;
}

int plumber_ftmap_add(plumber_data *plumb, const char *str, sp_ftbl *ft)
{
    uint32_t pos = sporth_hash(str);
#ifdef DEBUG_MODE
    plumber_print(plumb, "ftmap_add: Adding new table %s, position %d\n", str, pos);
#endif
    plumber_ftentry *entry = &plumb->ftmap[pos];
    entry->nftbl++;
    plumber_ftbl *new = malloc(sizeof(plumber_ftbl));
    new->ud = (void *)ft;
    new->type = PTYPE_TABLE;
    new->to_delete = plumb->delete_ft;
    new->name = malloc(sizeof(char) * strlen(str) + 1);
    strcpy(new->name, str);
    entry->last->next = new;
    entry->last = new;
    return PLUMBER_OK;
}

int plumber_ftmap_add_userdata(plumber_data *plumb, const char *str, void *ud)
{
    uint32_t pos = sporth_hash(str);
#ifdef DEBUG_MODE
    plumber_print(plumb, "ftmap_add_userdata: Adding new generic table %s, position %d\n", str, pos);
#endif
    plumber_ftentry *entry = &plumb->ftmap[pos];
    entry->nftbl++;
#ifdef DEBUG_MODE
    plumber_print(plumb, "ftmap_add_userdata: there are now %d in position %d\n", 
            entry->nftbl, pos);
#endif
    plumber_ftbl *new = malloc(sizeof(plumber_ftbl));
    new->ud = ud;
    new->type = PTYPE_USERDATA;
    new->to_delete = plumb->delete_ft;
    new->name = malloc(sizeof(char) * strlen(str) + 1);
    strcpy(new->name, str);
    entry->last->next = new;
    entry->last = new;
    return PLUMBER_OK;
}

int plumber_ftmap_add_function(plumber_data *plumb, 
        const char *str, plumber_dyn_func f, void *ud)
{
    sporth_fload_d *fd = malloc(sizeof(sporth_fload_d));
    fd->fun = f;
    fd->ud = ud;
    return plumber_ftmap_add_userdata(plumb, str, (void *)fd);
}

int plumber_ftmap_search(plumber_data *plumb, const char *str, sp_ftbl **ft)
{
    plumber_ftbl *ftbl;
    if(plumber_search(plumb, str, &ftbl) != PLUMBER_OK) {
        return PLUMBER_NOTOK;
    } else if(ftbl->type != PTYPE_TABLE) {
        plumber_print(plumb, "Error: value '%s' is not of type ftable\n", str);
        return PLUMBER_NOTOK;
    } else {
        *ft = (sp_ftbl *)ftbl->ud;
        return PLUMBER_OK;
    }
}

int plumber_ftmap_search_userdata(plumber_data *plumb, const char *str, void **ud)
{
    plumber_ftbl *ftbl;

    if(plumber_search(plumb, str, &ftbl) != PLUMBER_OK) {
        return PLUMBER_NOTOK;
    } else if(ftbl->type != PTYPE_USERDATA) {
        plumber_print(plumb, "Error: value '%s' is not of type userdata\n", str);
        return PLUMBER_NOTOK;
    } else {
        *ud = ftbl->ud;
        return PLUMBER_OK;
    }

}

int plumber_ftmap_delete(plumber_data *plumb, char mode)
{
    plumb->delete_ft = mode;
    return PLUMBER_OK;
}

void plumber_ftmap_dump(plumber_ftentry *ft)
{
    uint32_t i, k;
    plumber_ftbl *cur, *next;
    for(i = 0; i < 256; i ++) {
        cur = ft[i].root.next;
        for(k = 0; k < ft[i].nftbl; k++) {
            next = cur->next;
            printf("%s\n", cur->name);
            cur = next; 
        }
    }
}

int plumber_ftmap_destroy(plumber_data *plumb)
{
    int pos, n;
    plumber_ftbl *ftbl, *next;
    for(pos = 0; pos < 256; pos++) {
        ftbl = plumb->ftmap[pos].root.next;
        for(n = 0; n < plumb->ftmap[pos].nftbl; n++) {
            next = ftbl->next;
            free(ftbl->name);
            if(ftbl->to_delete) {
                if(ftbl->type == PTYPE_TABLE) 
                    sp_ftbl_destroy((sp_ftbl **)&ftbl->ud);
                else free(ftbl->ud);
            }
            free(ftbl);
            ftbl = next;
        }
    }

    return PLUMBER_OK;
}

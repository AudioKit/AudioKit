/*
 csound_data_structures.h:

 Copyright (C) 2013 Steven Yi

 This file is part of Csound.

 The Csound Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 */

#ifndef __CSOUND_DATA_STRUCTURES_H
#define __CSOUND_DATA_STRUCTURES_H

#ifdef __cplusplus
extern "C" {
#endif

#define HASH_SIZE 4099

typedef struct _cons {
    void* value; // should be car, but using value
    struct _cons* next; // should be cdr, but to follow csound
    // linked list conventions
} CONS_CELL;

typedef struct _cs_hash_bucket_item {
    char* key;
    void* value;
    struct _cs_hash_bucket_item* next;
} CS_HASH_TABLE_ITEM;

typedef struct _cs_hash_table {
    CS_HASH_TABLE_ITEM* buckets[HASH_SIZE];
} CS_HASH_TABLE;

/* FUNCTIONS FOR CONS CELL */

/** Given a value and CONS_CELL, create a new CONS_CELL that holds the
 value, then set the ->next value to the passed-in cons cell.  This
 operation effectively appends a value to the head of cons list. The
 function returns the head of the cons list.  It is safe to pass in
 a NULL for the cons argument; the returned value will be just the
 newly generated cons cell. */
PUBLIC CONS_CELL* cs_cons(CSOUND* csound, void* val, CONS_CELL* cons);

/** Appends the cons2 CONS_CELL list to the tail of the cons1 */
PUBLIC CONS_CELL* cs_cons_append(CONS_CELL* cons1, CONS_CELL* cons2);

/** Returns length of CONS_CELL list */
PUBLIC int cs_cons_length(CONS_CELL* head);

/** Frees CONS_CELL list but does not free ->value pointers */
PUBLIC void cs_cons_free(CSOUND* csound, CONS_CELL* head);

/** Frees CONS_CELL list also frees ->value pointers */
PUBLIC void cs_cons_free_complete(CSOUND* csound, CONS_CELL* head);

/* FUNCTIONS FOR HASH SET */

/** Create CS_HASH_TABLE */
PUBLIC CS_HASH_TABLE* cs_hash_table_create(CSOUND* csound);

/** Retreive void* value for given char* key.  Returns NULL if no
    items founds for key. */
PUBLIC void* cs_hash_table_get(CSOUND* csound,
                               CS_HASH_TABLE* hashTable, char* key);

/** Retreive char* key from internal hash item for given char* key.
    Useful when using CS_HASH_TABLE as a Set<String> type. Returns
    NULL if there is no entry for given key. */
PUBLIC char* cs_hash_table_get_key(CSOUND* csound,
                                   CS_HASH_TABLE* hashTable, char* key);

/** Adds an entry into the hashtable using the given key and value.
 If an existing entry is found, overwrites the value for that key with
 the new value passed in. */
PUBLIC void cs_hash_table_put(CSOUND* csound,
                              CS_HASH_TABLE* hashTable, char* key, void* value);

/** Adds an entry into the hashtable using the given key and NULL
 value.  Returns the internal char* used for the hash item key. */
PUBLIC char* cs_hash_table_put_key(CSOUND* csound,
                                   CS_HASH_TABLE* hashTable, char* key);

/** Removes an entry from the hashtable using the given key.  If no
 entry found for key, simply returns. Calls mfree on the table
 item. */
PUBLIC void cs_hash_table_remove(CSOUND* csound,
                                 CS_HASH_TABLE* hashTable, char* key);

/** Merges in all items from the the source table into the target
 table.  Entries with identical keys from the source table will
 replace entries in the target table. Note: wipes out source table. */
PUBLIC void cs_hash_table_merge(CSOUND* csound,
                                CS_HASH_TABLE* target, CS_HASH_TABLE* source);

/** Returns char* keys as a cons list */
PUBLIC CONS_CELL* cs_hash_table_keys(CSOUND* csound, CS_HASH_TABLE* hashTable);

/** Returns void* values as a cons list */
PUBLIC CONS_CELL* cs_hash_table_values(CSOUND* csound, CS_HASH_TABLE* hashTable);

/** Frees hash table and hash table items using mfree. Does not call
    free on ->value pointer. */
PUBLIC void cs_hash_table_free(CSOUND* csound, CS_HASH_TABLE* hashTable);

/** Frees hash table and hash table keys using mfree. Does call mfree
    on ->value pointer. */
PUBLIC void cs_hash_table_mfree_complete(CSOUND* csound, CS_HASH_TABLE* hashTable);

/** Frees hash table hash table keys using mfree. Does call free on
    ->value pointer. */
PUBLIC void cs_hash_table_free_complete(CSOUND* csound, CS_HASH_TABLE* hashTable);

#ifdef __cplusplus
}
#endif

#endif

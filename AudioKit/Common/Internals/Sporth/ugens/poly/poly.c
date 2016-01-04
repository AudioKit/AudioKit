#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "poly.h"

int poly_init(poly_data *cd) 
{
    poly_iterator *itr = &cd->itr;
    itr->nevents = 0;
    itr->root = &cd->root;
    cd->total_events = 0;
    cd->pos = 0;
    cd->last = &cd->root;
    cd->end_of_events = 0;
    return 0;
}

int poly_destroy(poly_data *cd)
{
    poly_event *evt = cd->root.next;
    poly_event *next;
    uint32_t n; 
    for(n = 0; n < cd->total_events; n++) {
        next = evt->next;
        free(evt->p);
        free(evt);
        evt = next;
    }
    return 0;
}

int poly_itr_reset(poly_data *cd)
{
    poly_iterator *itr = &cd->itr;
    itr->last = itr->root;
    return 0;
}

poly_event * poly_itr_next(poly_data *cd)
{
    poly_iterator *itr = &cd->itr;
    poly_event *evt = itr->last;
    itr->last = evt->next;
    return evt;
}

int poly_add(poly_data *cd, uint32_t delta, uint16_t nvals)
{
    uint32_t n;
    poly_event *evt = malloc(sizeof(poly_event));
    evt->delta = delta;
    evt->timer = delta;
    evt->pos = cd->total_events;
    evt->p= malloc(sizeof(float) * nvals);
    evt->nvals = nvals;
    for(n = 0; n < nvals; n++) evt->p[n] = 0;
    cd->last->next = evt;
    cd->last = evt;
    cd->total_events++;
    return 0;
}

int poly_compute(poly_data *cd)
{
    poly_iterator *itr = &cd->itr;
    poly_event *evt;
    itr->root = cd->last;
    itr->nevents = 0;
    poly_itr_reset(cd);
    while(cd->end_of_events == 0){
        evt = poly_itr_next(cd);
        cd->last = evt;
        if(evt->timer == 0) {
            itr->nevents++;
            if(evt->pos + 1 == cd->total_events) {
                cd->end_of_events = 1;
            }
        } else {
            evt->timer--;
            break;
        }

    }

    return 0;
}

uint32_t poly_nevents(poly_data *cd)
{
    return cd->itr.nevents;
}

int poly_end(poly_data *cd)
{
    cd->last = cd->root.next;
    return 0;
}

int poly_pset(poly_data *cd, uint32_t pos, float val)
{
    poly_event *evt = cd->last;
    if(pos + 1 > evt->nvals) {
        fprintf(stderr, "Warning: pfield not set\n");    
        return 1;
    }
    evt->p[pos] = val;
    return 0;
}

int poly_cluster_init(poly_cluster *clust, int nvals)
{
    int n;
    clust->stack = malloc(sizeof(float) * nvals);
    clust->voice = malloc(sizeof(poly_voice) * nvals);
    clust->pos = nvals;
    clust->total_voices = nvals;
    clust->nvoices = 0;
    for(n = 0; n < nvals; n++) {
        clust->stack[n] = n;
    }
    clust->last = &clust->root;
    return 0;
}

int poly_cluster_destroy(poly_cluster *clust)
{
    //int n;
    /* root ID. you don't want this */
    clust->root.val = -999; 
    //for(n = 0; n < clust->nvoices;n++) {
    //    next = voice->next;
    //    free(voice);
    //    voice = next;
    //}
    free(clust->stack);
    free(clust->voice);
    return 0; 
}

int poly_cluster_add(poly_cluster *clust, int *id)
{
    if(clust->pos == 0) {
        fprintf(stderr, 
                "Warning: Maximum number of voices (%d) already reached\n", clust->total_voices);
        return 1;
    }
    *id = clust->stack[clust->pos - 1];
#ifdef POLY_DEBUG
    printf("Popping voice id %d from voicestack\n", *id);
#endif
    clust->pos--;
    clust->nvoices++;

    //poly_voice *voice = &clust->voice[clust->nvoices - 1];
    poly_voice *voice = &clust->voice[*id];
    voice->val = *id;
    voice->next = NULL;

    clust->last->next = voice;
    clust->last = voice;

#ifdef POLY_DEBUG
    printf("There are now %d active voices\n", clust->nvoices);
#endif

    return 0; 
}

int poly_cluster_remove(poly_cluster *clust, int id)
{
#ifdef POLY_DEBUG
    printf("Removing voice id %d\n", id);
#endif
    poly_voice *voice = clust->root.next;
    poly_voice *prev = NULL;
    poly_voice *next = NULL;
    int n;

#ifdef POLY_DEBUG
    printf("nvoices is %d\n", clust->nvoices);
#endif

    for(n = 0; n < clust->nvoices; n++) {
        next = voice->next;
#ifdef POLY_DEBUG
        printf("%d: voice->val = %d, target id %d\n", n, voice->val, id);
#endif
        if(voice->val == id) {
#ifdef POLY_DEBUG
            printf("Found id %d at position %d\n", id, n);
#endif
            break;
        } else {
            prev = voice;
            voice = next;
        }
    }
#ifdef POLY_DEBUG
    printf("n is %d of %d\n", n, clust->nvoices);
#endif

    if(clust->nvoices == 1) {
#ifdef POLY_DEBUG
        printf("--removing only voice in linked list...\n");
#endif
        clust->last = &clust->root;
    } else if(n == 0) {
#ifdef POLY_DEBUG
        printf("--removing first voice in linked list...\n");
#endif
        /* (root) -> voice -> next to (root) -> next */
        clust->root.next = next;
    } else if(n == clust->nvoices - 1) {
#ifdef POLY_DEBUG
        printf("--removing last voice in linked list...\n");
#endif
        /* prev -> voice to prev -> NULL */
        prev->next = NULL;
    } else {
        /* prev -> voice -> next to prev -> next */
#ifdef POLY_DEBUG
        printf("--removing a voice in linked list...\n");
#endif
        prev->next = next;
    }

    clust->stack[clust->pos] = id;
    clust->nvoices--;
    clust->pos++;
    return 0;
}

poly_voice* poly_next_voice(poly_cluster *clust)
{
    poly_voice *voice = clust->tmp;
    clust->tmp= voice->next;
    return voice;
}

int poly_cluster_reset(poly_cluster *clust)
{
    clust->tmp = clust->root.next;
    return 0;
}

int poly_cluster_nvoices(poly_cluster *clust)
{
    return clust->nvoices;
}

int poly_binary_open(poly_data *cd, char *filename)
{
    cd->fp = fopen(filename, "wb");
    return 0;
}

int poly_binary_close(poly_data *cd)
{
    fclose(cd->fp);
    return 0;
}

int poly_binary_write(poly_data *cd, float delta, uint16_t nvals, float *vals)
{
    float *dp = &delta;
    uint16_t *np = &nvals;
    fwrite(dp, sizeof(float), 1, cd->fp);
    fwrite(np, sizeof(uint16_t), 1, cd->fp);
    fwrite(vals, sizeof(float), nvals, cd->fp);
    return 0;
}

int poly_binary_parse(poly_data *cd, char *filename, float scale)
{
    FILE *fp = fopen(filename, "rb");
    if(fp == NULL) {
        return 1;
    }
    float delta, val;
    uint16_t nvals;
    uint32_t n;
    while(1){

        fread(&delta, sizeof(float), 1, fp);

        if(feof(fp)){
            break;
        }
#ifdef POLY_DEBUG
        printf("reading delta value of %g\n", delta);
#endif
        fread(&nvals, sizeof(uint16_t), 1, fp);
#ifdef POLY_DEBUG
        printf("reading %d nvals\n", nvals);
#endif
        poly_add(cd, (uint32_t) scale * delta, nvals);
        for(n = 0; n < nvals; n++) {
            fread(&val, sizeof(float), 1, fp);
#ifdef POLY_DEBUG
            printf("---- reading %g\n", val);
#endif
            poly_pset(cd, n, val);
        }

    }
    fclose(fp);
    return 0;
}

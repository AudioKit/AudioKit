// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DebugDSP.h"

#include "md5.h"
#include <stddef.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

#define MAX_SLOTS 16

static md5_state_t state[MAX_SLOTS];
static bool active = false;

void AKDebugDSPSetActive(bool activate) {
    active = activate;
    if(active) {
        for(int i=0;i<MAX_SLOTS;++i) {
            md5_init(state+i);
        }
    }
}

void AKDebugDSP(int slot, float value) {
    if(active) {
        assert(slot < MAX_SLOTS);
        md5_append(state+slot, (md5_byte_t*)&value, sizeof(float));
    }
}

bool AKDebugDSPCheck(int slot, const char* expected) {
    assert(slot < MAX_SLOTS);

    md5_byte_t digest[16];
    md5_finish(state+slot, digest);

    char digestStr[33];
    for(int i=0;i<16;++i) {
        sprintf(digestStr+2*i, "%02x", digest[i]);
    }

    if(strcmp(digestStr, expected)) {
        printf("Debug hash %s does not match expected hash %s\n", digestStr, expected);
        return false;
    }
    return true;
}

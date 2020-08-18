// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

typedef struct {
    const char *name;
    plumber_dyn_func func;
    void *userData;
} AKCustomUgenInfo;

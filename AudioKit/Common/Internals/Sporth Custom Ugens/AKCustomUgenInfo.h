//
//  AKCustomUgenInfo.h
//  AudioKit
//
//  Created by Joseph Constantakis, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

typedef struct {
    const char *name;
    plumber_dyn_func func;
    void *userData;
} AKCustomUgenInfo;

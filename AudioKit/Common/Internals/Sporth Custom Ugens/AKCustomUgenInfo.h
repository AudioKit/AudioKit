//
//  AKCustomUgenInfo.h
//  AudioKit
//
//  Created by Joseph Constantakis on 3/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

typedef struct {
    const char *name;
    plumber_dyn_func func;
    void *userData;
} AKCustomUgenInfo;

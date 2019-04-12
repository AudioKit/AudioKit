//
//  RageProcessor.h
//
//  Created by Mike Gazzaruso, revision history on Githbub.
//  Copyright © 2015 Mike Gazzaruso. All rights reserved.
//

#pragma once
#include "MikeFilter.h"

class RageProcessor {
public:
    RageProcessor(int iSampleRate);
    float doRage(float fCurrentSample, float fKhorne, float fNurgle);
    MikeFilter filterToneZ;
    void setNumStages(int theStages);
    
private:
    int iSampleRate, iNumStages;
};



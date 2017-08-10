//
//  RageProcessor.h
//
//  Created by Mike Gazzaruso on 11/10/15.
//  Copyright © 2015 Mike Gazzaruso. All rights reserved.
//

#ifndef RageProcessor_hpp
#define RageProcessor_hpp

#include "Filter.h"

class RageProcessor
{
    public: RageProcessor(int iSampleRate);
    public: float doRage(float fCurrentSample, float fKhorne, float fNurgle);

    public: MikeFilter filterToneZ;
    public: void setNumStages (int theStages);
    
    private: int iSampleRate, iNumStages;
};

#endif /* RageProcessor_h */

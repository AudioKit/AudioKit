//
//  RageProcessor.h
//
//  Created by Mike Gazzaruso on 11/10/15.
//  Copyright © 2015 Mike Gazzaruso. All rights reserved.
//

#pragma once
#include "Filter.h"

class RageProcessor {
public:
  RageProcessor(int iSampleRate);
  float doRage(float fCurrentSample, float fKhorne, float fNurgle);
  MikeFilter filterToneZ;
  void setNumStages(int theStages);

private:
  int iSampleRate, iNumStages;
};



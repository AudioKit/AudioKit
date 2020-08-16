// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "RageProcessor.h"
#include <math.h>

RageProcessor::RageProcessor(int iSampleRate)
: iSampleRate(iSampleRate), iNumStages(2) {
    filterToneZ.calc_filter_coeffs(4400.0, (int)iSampleRate);
}

void RageProcessor::setNumStages(int theStages) {
    this->iNumStages = theStages;
}

float RageProcessor::doRage(float fCurrentSample, float fKhorne,
                            float fNurgle) {
    ////////
    // Tube non-linear Processing
    //////

    float f_xn = fCurrentSample;

    // Cascaded stages

    for (int s = 0; s < iNumStages; s++) {
        if (f_xn >= 0)
            f_xn = (1.0f / atanf(fKhorne)) * atanf(fKhorne * f_xn);
        else
            f_xn = (1.0f / atanf(fNurgle)) * atanf(fNurgle * f_xn);

        // Invert every other stage
        if (s % 2 == 0)
            f_xn *= -1.0f;
    }
    return filterToneZ.filter(f_xn);
}

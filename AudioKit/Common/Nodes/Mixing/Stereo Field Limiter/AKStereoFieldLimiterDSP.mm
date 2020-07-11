// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKStereoFieldLimiterDSP.hpp"

extern "C" AKDSPRef createStereoFieldLimiterDSP() {
    return new AKStereoFieldLimiterDSP();
}




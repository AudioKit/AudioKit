// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef AKSoulDSPBase_hpp
#define AKSoulDSPBase_hpp

#import "AKDSPBase.hpp"

template<class SoulPatchType>
class AKSoulDSPBase : public AKDSPBase {

public:
    SoulPatchType patch;
    
    // Need to override this since it's pure virtual.
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // Do nothing.
    }
    
};

#endif /* AKSoulDSPBase_hpp */

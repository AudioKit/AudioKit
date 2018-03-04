#include "AUInstrumentBase.h"
#include "AKSampler.hpp"

#define kAKSamplerVersion   0x00010000
#define kAKSamplerSubtype   'aksp'

class AKSampler_Plugin : public AUInstrumentBase, public AKSampler
{
public:
	AKSampler_Plugin(AudioUnit inComponentInstance);
	virtual	~AKSampler_Plugin();
				
	virtual OSStatus Initialize();
	virtual void Cleanup();
	virtual OSStatus Version() { return kAKSamplerVersion; }

    virtual OSStatus GetPropertyInfo(   AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        UInt32&                     outDataSize,
                                        Boolean&                    outWritable );
    
    virtual OSStatus GetProperty(       AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        void*                       outData);
    
	virtual OSStatus GetParameterInfo(  AudioUnitScope              inScope,
                                        AudioUnitParameterID        inParameterID,
                                        AudioUnitParameterInfo&     outParameterInfo);

    virtual OSStatus SetParameter(      AudioUnitParameterID        inParameterID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        AudioUnitParameterValue     inValue,
                                        UInt32                      inBufferOffsetInFrames);

    virtual OSStatus HandleNoteOn(      UInt8 inChannel, UInt8 inNoteNumber,
                                        UInt8 inVelocity, UInt32 inStartFrame);
    
    virtual OSStatus HandleNoteOff(     UInt8 inChannel, UInt8 inNoteNumber,
                                        UInt8 inVelocity, UInt32 inStartFrame);

    virtual OSStatus HandleControlChange(   UInt8 inChannel,
                                            UInt8 inController,
                                            UInt8 inValue,
                                            UInt32 inStartFrame);
    
    virtual OSStatus HandlePitchWheel(  UInt8 inChannel,
                                        UInt8 inPitch1,
                                        UInt8 inPitch2,
                                        UInt32 inStartFrame);

    virtual OSStatus Render(            AudioUnitRenderActionFlags& ioActionFlags,
                                        const AudioTimeStamp&       inTimeStamp,
                                        UInt32 nFrames);
};

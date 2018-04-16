#include "AUEffectBase.h"
#include "ModulatedDelay.hpp"

#define kAKChorusVersion   0x00010000
#define kAKChorusSubtype   'chrs'

class AKChorus_Plugin : public AUEffectBase, public AudioKitCore::ModulatedDelay
{
public:
	AKChorus_Plugin(AudioUnit inComponentInstance);
	virtual	~AKChorus_Plugin();
				
	virtual OSStatus Initialize();
	virtual void Cleanup();
	virtual OSStatus Version() { return kAKChorusVersion; }

    virtual OSStatus GetPropertyInfo(   AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        UInt32 &                    outDataSize,
                                        Boolean &                   outWritable );
    
    virtual OSStatus GetProperty(       AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        void *                      outData);
    
    virtual OSStatus SetProperty(       AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        const void *                inData,
                                        UInt32                      inDataSize);
    
	virtual OSStatus GetParameterInfo(  AudioUnitScope              inScope,
                                        AudioUnitParameterID        inParameterID,
                                        AudioUnitParameterInfo &    outParameterInfo);

    virtual OSStatus GetParameter(      AudioUnitParameterID        inParameterID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        AudioUnitParameterValue &   outValue);
    
    virtual OSStatus SetParameter(      AudioUnitParameterID        inParameterID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        AudioUnitParameterValue     inValue,
                                        UInt32                      inBufferOffsetInFrames);

    virtual OSStatus ProcessBufferLists(AudioUnitRenderActionFlags& ioActionFlags,
                                        const AudioBufferList&      inBuffer,
                                        AudioBufferList&            outBuffer,
                                        UInt32                      inFramesToProcess);

private:
    float feedback;
};

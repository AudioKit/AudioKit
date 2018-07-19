#include "AUInstrumentBase.h"
#include "Sampler.hpp"

#define kAKSamplerVersion   0x00010000
#define kAKSamplerSubtype   'aksp'

class AKSampler_Plugin : public AUInstrumentBase, public AudioKitCore::Sampler
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

    virtual OSStatus SaveState(         CFPropertyListRef *         outData);
    
    virtual OSStatus RestoreState(      CFPropertyListRef           inData);

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
    
private:
    CFStringRef presetFolderPath;
    CFStringRef presetName;
    void initForTesting();
    bool loadCompressedSampleFile(AKSampleFileDescriptor& sfd, float volBoostDb=0.0f);
    void loadDemoSamples();
    OSStatus loadPreset();
};

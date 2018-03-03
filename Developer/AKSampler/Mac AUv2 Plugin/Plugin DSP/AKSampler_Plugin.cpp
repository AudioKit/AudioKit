#include "AKSampler_Plugin.h"

AUDIOCOMPONENT_ENTRY(AUMusicDeviceFactory, AKSampler_Plugin)

#define kGlobalVolumeParam  0

static const CFStringRef kGlobalVolumeName = CFSTR("global volume");

// OSErr definitions taken from deprecated CarbonCore/MacErrors.h
// Somewhere there's a newer header file I should be using
enum {
    fnfErr                        = -43,  /*File not found*/
};


AKSampler_Plugin::AKSampler_Plugin(AudioUnit inComponentInstance)
	: AUInstrumentBase(inComponentInstance, 0, 1)    // 0 inputs, 1 output
    , AKSampler()
{
	CreateElements();
	Globals()->UseIndexedParameters(1); // we're only defining one param
	Globals()->SetParameter (kGlobalVolumeParam, 1.0);
}

AKSampler_Plugin::~AKSampler_Plugin()
{
}

OSStatus AKSampler_Plugin::Initialize()
{
	AUInstrumentBase::Initialize();
    AKSampler::init();
    
    // Download http://getdunne.com/download/TX_LoTine81z.zip
    // Put folder wherever you wish (e.g. inside a "Compressed Sounds" folder on your Mac desktop
    // and edit paths below accordingly

    loadCompressedSampleFile(48, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_048_c2.wv", 0, 51, 0, 43);
    loadCompressedSampleFile(48, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_048_c2.wv", 0, 51, 44, 86);
    loadCompressedSampleFile(48, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_048_c2.wv", 0, 51, 87, 127);
    
    loadCompressedSampleFile(54, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_054_f#2.wv", 52, 57, 0, 43);
    loadCompressedSampleFile(54, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_054_f#2.wv", 52, 57, 44, 86);
    loadCompressedSampleFile(54, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_054_f#2.wv", 52, 57, 87, 127);
    
    loadCompressedSampleFile(60, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_060_c3.wv", 58, 63, 0, 43);
    loadCompressedSampleFile(60, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_060_c3.wv", 58, 63, 44, 86);
    loadCompressedSampleFile(60, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_060_c3.wv", 58, 63, 87, 127);
    
    loadCompressedSampleFile(66, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_066_f#3.wv", 64, 69, 0, 43);
    loadCompressedSampleFile(66, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_066_f#3.wv", 64, 69, 44, 86);
    loadCompressedSampleFile(66, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_066_f#3.wv", 64, 69, 87, 127);
    
    loadCompressedSampleFile(72, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_072_c4.wv", 70, 75, 0, 43);
    loadCompressedSampleFile(72, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_072_c4.wv", 70, 75, 44, 86);
    loadCompressedSampleFile(72, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_072_c4.wv", 70, 75, 87, 127);
    
    loadCompressedSampleFile(78, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_078_f#4.wv", 76, 81, 0, 43);
    loadCompressedSampleFile(78, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_078_f#4.wv", 76, 81, 44, 86);
    loadCompressedSampleFile(78, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_078_f#4.wv", 76, 81, 87, 127);
    
    loadCompressedSampleFile(84, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms2_084_c5.wv", 82, 127, 0, 43);
    loadCompressedSampleFile(84, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms1_084_c5.wv", 82, 127, 44, 86);
    loadCompressedSampleFile(84, "/Users/shane/Desktop/Compressed Sounds/TX LoTine81z/TX LoTine81z_ms0_084_c5.wv", 82, 127, 87, 127);

    buildKeyMap();
    
    ampAttackTime = 0.01f;
    ampDecayTime = 0.1f;
    ampSustainLevel = 0.8f;
    ampReleaseTime = 0.5f;
    updateAmpADSR();
    
    // per-voice filter is still experimental and buggy
    //    filterEnable = true;
    //    filterAttackTime = 1.0f;
    //    filterDecayTime = 1.0f;
    //    filterSustainLevel = 0.5f;
    //    filterReleaseTime = 10.0f;
    //    updateFilterADSR();
    
    return noErr;
}

void AKSampler_Plugin::Cleanup()
{
    AKSampler::deinit();
}

OSStatus AKSampler_Plugin::GetPropertyInfo( AudioUnitPropertyID         inID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            UInt32&                     outDataSize,
                                            Boolean&                    outWritable )
{
    if (inScope == kAudioUnitScope_Global)
    {
        switch (inID)
        {
            case kAudioUnitProperty_CocoaUI:
                outWritable = false;
                outDataSize = sizeof (AudioUnitCocoaViewInfo);
                return noErr;
        }
    }
    
    return AUInstrumentBase::GetPropertyInfo (inID, inScope, inElement, outDataSize, outWritable);
}

OSStatus AKSampler_Plugin::GetProperty( AudioUnitPropertyID         inID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        void*                       outData)
{
    if (inScope == kAudioUnitScope_Global) {
        switch (inID) {
            case kAudioUnitProperty_CocoaUI:
            {
                // Look for a resource in the main bundle by name and type.
                CFBundleRef bundle = CFBundleGetBundleWithIdentifier( CFSTR("io.audiokit.AKSampler") );
                
                if (bundle == NULL) {
                    printf("Could not find bundle specified for GUI resources\n");
                    return fnfErr;
                }
                
                CFURLRef bundleURL = CFBundleCopyResourceURL( bundle,
                                                             CFSTR("AKSamplerUI"),
                                                             CFSTR("bundle"),
                                                             NULL);
                
                if (bundleURL == NULL) {
                    printf("Could not create resource URL for GUI\n");
                    return fnfErr;
                }
                
                CFStringRef className = CFSTR("AKSampler_ViewFactory");
                AudioUnitCocoaViewInfo cocoaInfo = { bundleURL, { className } };
                *((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;
                
                return noErr;
            }
        }
    }
    
    return AUInstrumentBase::GetProperty (inID, inScope, inElement, outData);
}


OSStatus AKSampler_Plugin::GetParameterInfo(    AudioUnitScope          inScope,
                                                AudioUnitParameterID    inParameterID,
                                                AudioUnitParameterInfo& outParameterInfo)
{
	if (inParameterID != kGlobalVolumeParam) return kAudioUnitErr_InvalidParameter;
	if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;

	outParameterInfo.flags = SetAudioUnitParameterDisplayType (0, kAudioUnitParameterFlag_DisplaySquareRoot);
    outParameterInfo.flags += kAudioUnitParameterFlag_IsWritable;
	outParameterInfo.flags += kAudioUnitParameterFlag_IsReadable;

	AUBase::FillInParameterName (outParameterInfo, kGlobalVolumeName, false);
	outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
	outParameterInfo.minValue = 0;
	outParameterInfo.maxValue = 1.0;
	outParameterInfo.defaultValue = 1.0;
	return noErr;
}

OSStatus AKSampler_Plugin::SetParameter(    AudioUnitParameterID        inID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            AudioUnitParameterValue     inValue,
                                            UInt32                      inBufferOffsetInFrames)
{
    return noErr;
}

OSStatus AKSampler_Plugin::Render(AudioUnitRenderActionFlags &ioActionFlags, const AudioTimeStamp &inTimeStamp, UInt32 nFrames)
{
    AUOutputElement* outputBus = GetOutput(0);
    outputBus->PrepareBuffer(nFrames); // prepare the output buffer list
    
    AudioBufferList& outputBufList = outputBus->GetBufferList();
    AUBufferList::ZeroBuffer(outputBufList);
    
    float* outBuffers[2];
    outBuffers[0] = (float*)(outputBufList.mBuffers[0].mData);
    outBuffers[1] = (float*)(outputBufList.mBuffers[1].mData);
    
    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < nFrames; frameIndex += CHUNKSIZE) {
        int chunkSize = nFrames - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;
        
        masterVolume = Globals()->GetParameter(kGlobalVolumeParam);
        
        unsigned channelCount = outputBufList.mNumberBuffers;
        AKSampler::Render(channelCount, chunkSize, outBuffers);
        
        outBuffers[0] += CHUNKSIZE;
        outBuffers[1] += CHUNKSIZE;
    }
    
    return noErr;
}

OSStatus AKSampler_Plugin::HandleNoteOn(UInt8 inChannel, UInt8 inNoteNumber, UInt8 inVelocity, UInt32 inStartFrame)
{
    //printf("note on: ch%d nn%d vel%d\n", inChannel, inNoteNumber, inVelocity);
    playNote(inNoteNumber, inVelocity, 440.0f * pow(2.0f, (inNoteNumber - 69.0f)/12.0f));
    return noErr;
}

OSStatus AKSampler_Plugin::HandleNoteOff(UInt8 inChannel, UInt8 inNoteNumber, UInt8 inVelocity, UInt32 inStartFrame)
{
    //printf("note off: ch%d nn%d vel%d\n", inChannel, inNoteNumber, inVelocity);
    stopNote(inNoteNumber, false);
    return noErr;
}

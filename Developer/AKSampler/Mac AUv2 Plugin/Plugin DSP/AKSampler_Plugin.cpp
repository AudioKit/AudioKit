#include "AKSampler_Plugin.h"
#include "AKSampler_Params.h"
#include "AUMidiDefs.h"

AUDIOCOMPONENT_ENTRY(AUMusicDeviceFactory, AKSampler_Plugin)

static const CFStringRef paramName[] =
{
    CFSTR("Master Volume"),
    CFSTR("Pitch Offset"),
    CFSTR("Filter Enable"),
    CFSTR("Filter Cutoff"),
    
    CFSTR("Amp EG Attack"),
    CFSTR("Amp EG Decay"),
    CFSTR("Amp EG Sustain"),
    CFSTR("Amp EG Release"),

    CFSTR("Flt EG Attack"),
    CFSTR("Flt EG Decay"),
    CFSTR("Flt EG Sustain"),
    CFSTR("Flt EG Release"),
};

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
	Globals()->UseIndexedParameters(kNumberOfParams);
    
    Globals()->SetParameter(kMasterVolumeFraction, 1.0f);
    Globals()->SetParameter(kPitchOffsetSemitones, 0.0f);
    Globals()->SetParameter(kFilterCutoffHarmonic, 1000.0f);
    Globals()->SetParameter(kFilterEnable, 0.0f);
    
    Globals()->SetParameter(kAmpEgAttackTimeSeconds, 0.01f);
    Globals()->SetParameter(kAmpEgDecayTimeSeconds, 0.1f);
    Globals()->SetParameter(kAmpEgSustainFraction, 0.8f);
    Globals()->SetParameter(kAmpEgReleaseTimeSeconds, 0.5f);
    
    Globals()->SetParameter(kFilterEgAttackTimeSeconds, 0.0f);
    Globals()->SetParameter(kFilterEgDecayTimeSeconds, 0.0f);
    Globals()->SetParameter(kFilterEgSustainFraction, 1.0f);
    Globals()->SetParameter(kFilterEgReleaseTimeSeconds, 0.0f);
}

AKSampler_Plugin::~AKSampler_Plugin()
{
}

OSStatus AKSampler_Plugin::Initialize()
{
	AUInstrumentBase::Initialize();
    AKSampler::init();
    
    // Download http://getdunne.com/download/TX_LoTine81z.zip
    // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
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
    
    Globals()->SetParameter(kMasterVolumeFraction, 1.0f);
    Globals()->SetParameter(kPitchOffsetSemitones, 0.0f);
    Globals()->SetParameter(kFilterCutoffHarmonic, 1000.0f);
    Globals()->SetParameter(kFilterEnable, 0.0f);
    
    Globals()->SetParameter(kAmpEgAttackTimeSeconds, 0.01f);
    Globals()->SetParameter(kAmpEgDecayTimeSeconds, 0.1f);
    Globals()->SetParameter(kAmpEgSustainFraction, 0.8f);
    Globals()->SetParameter(kAmpEgReleaseTimeSeconds, 0.5f);
    
    return noErr;
}

void AKSampler_Plugin::Cleanup()
{
    AKSampler::deinit();
}

OSStatus AKSampler_Plugin::GetPropertyInfo( AudioUnitPropertyID         inPropertyID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            UInt32&                     outDataSize,
                                            Boolean&                    outWritable )
{
    if (inScope == kAudioUnitScope_Global)
    {
        switch (inPropertyID)
        {
            case kAudioUnitProperty_CocoaUI:
                outWritable = false;
                outDataSize = sizeof (AudioUnitCocoaViewInfo);
                return noErr;
        }
    }
    
    return AUInstrumentBase::GetPropertyInfo (inPropertyID, inScope, inElement, outDataSize, outWritable);
}

OSStatus AKSampler_Plugin::GetProperty( AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        void*                       outData)
{
    if (inScope == kAudioUnitScope_Global) {
        switch (inPropertyID) {
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

    return AUInstrumentBase::GetProperty (inPropertyID, inScope, inElement, outData);
}


OSStatus AKSampler_Plugin::GetParameterInfo(    AudioUnitScope          inScope,
                                                AudioUnitParameterID    inParameterID,
                                                AudioUnitParameterInfo& outParameterInfo)
{
	if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;

    outParameterInfo.flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable;

    switch (inParameterID) {
        case kMasterVolumeFraction:
            outParameterInfo.flags += SetAudioUnitParameterDisplayType (0, kAudioUnitParameterFlag_DisplaySquareRoot);
            AUBase::FillInParameterName (outParameterInfo, paramName[kMasterVolumeFraction], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 1.0;
            outParameterInfo.defaultValue = 1.0;
            break;
            
        case kPitchOffsetSemitones:
            AUBase::FillInParameterName (outParameterInfo, paramName[kPitchOffsetSemitones], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_RelativeSemiTones;
            outParameterInfo.minValue = -24.0;
            outParameterInfo.maxValue = 24.0;
            outParameterInfo.defaultValue = 0.0;
            break;
    
        case kFilterEnable:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterEnable], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Boolean;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 1.0;
            outParameterInfo.defaultValue = 0.0;
            break;
            
        case kFilterCutoffHarmonic:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterCutoffHarmonic], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Generic;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 1000.0;
            outParameterInfo.defaultValue = 1000.0;
            break;
    
        case kAmpEgAttackTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kAmpEgAttackTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
    
        case kAmpEgDecayTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kAmpEgDecayTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
            
        case kAmpEgSustainFraction:
            AUBase::FillInParameterName (outParameterInfo, paramName[kAmpEgSustainFraction], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 1.0;
            outParameterInfo.defaultValue = 1.0;
            break;
    
        case kAmpEgReleaseTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kAmpEgReleaseTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
    
        case kFilterEgAttackTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterEgAttackTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
    
        case kFilterEgDecayTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterEgDecayTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
    
        case kFilterEgSustainFraction:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterEgSustainFraction], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 1.0;
            outParameterInfo.defaultValue = 1.0;
            break;
            
        case kFilterEgReleaseTimeSeconds:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFilterEgReleaseTimeSeconds], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Seconds;
            outParameterInfo.minValue = 0;
            outParameterInfo.maxValue = 10.0;
            outParameterInfo.defaultValue = 0.0;
            break;
            
        default:
            return kAudioUnitErr_InvalidParameter;
    }
    
	return noErr;
}

OSStatus AKSampler_Plugin::SetParameter(    AudioUnitParameterID        inParameterID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            AudioUnitParameterValue     inValue,
                                            UInt32                      inBufferOffsetInFrames)
{
    if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;
    
    switch (inParameterID)
    {
        case kMasterVolumeFraction:
            masterVolume = inValue;
            break;
            
        case kPitchOffsetSemitones:
            pitchOffset = inValue;
            break;
            
        case kFilterEnable:
            filterEnable = (inValue > 0.5f);
            break;
            
        case kFilterCutoffHarmonic:
            cutoffMultiple = inValue;
            break;
            
        case kAmpEgAttackTimeSeconds:
            ampAttackTime = inValue;
            updateAmpADSR();
            break;
            
        case kAmpEgDecayTimeSeconds:
            ampDecayTime = inValue;
            updateAmpADSR();
           break;
            
        case kAmpEgSustainFraction:
            ampSustainLevel = inValue;
            updateAmpADSR();
            break;
            
        case kAmpEgReleaseTimeSeconds:
            ampReleaseTime = inValue;
            updateAmpADSR();
            break;
            
        case kFilterEgAttackTimeSeconds:
            filterAttackTime = inValue;
            updateFilterADSR();
            break;
            
        case kFilterEgDecayTimeSeconds:
            filterDecayTime = inValue;
            updateFilterADSR();
            break;
            
        case kFilterEgSustainFraction:
            filterSustainLevel = inValue;
            updateFilterADSR();
            break;
            
        case kFilterEgReleaseTimeSeconds:
            filterReleaseTime = inValue;
            updateFilterADSR();
            break;
            
        default:
            return kAudioUnitErr_InvalidParameter;
    }
    
    return AUInstrumentBase::SetParameter(inParameterID, inScope, inElement, inValue, inBufferOffsetInFrames);
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
        
        // Any ramping parameters would be updated here...
        
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
    if (sustainLogic.keyDownAction(inNoteNumber) == AKSustainLogic::kStopNoteThenPlay)
        stopNote(inNoteNumber, false);
    playNote(inNoteNumber, inVelocity, 440.0f * pow(2.0f, (inNoteNumber - 69.0f)/12.0f));
    return noErr;
}

OSStatus AKSampler_Plugin::HandleNoteOff(UInt8 inChannel, UInt8 inNoteNumber, UInt8 inVelocity, UInt32 inStartFrame)
{
    //printf("note off: ch%d nn%d vel%d\n", inChannel, inNoteNumber, inVelocity);
    if (sustainLogic.keyUpAction(inNoteNumber) == AKSustainLogic::kStopNote)
        stopNote(inNoteNumber, false);
    return noErr;
}

OSStatus AKSampler_Plugin::HandleControlChange(UInt8 inChannel, UInt8 inController, UInt8 inValue, UInt32 inStartFrame)
{
    if (inController == kMidiController_Sustain)
    {
        bool pedalDown = inValue != 0;
        if (pedalDown) sustainLogic.pedalDown();
        else {
            for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
            {
                if (sustainLogic.isNoteSustaining(nn))
                    stopNote(nn, false);
            }
            sustainLogic.pedalUp();
        }
    }
    else if (inController == kMidiController_ModWheel)
    {
        float value = inValue / 127.0f;
        // TODO: apply vibrato
    }
    return noErr;
}

OSStatus AKSampler_Plugin::HandlePitchWheel(UInt8 inChannel, UInt8 inPitch1, UInt8 inPitch2, UInt32 inStartFrame)
{
    int intValue = ((inPitch2 << 7) | inPitch1) - (64 << 7);
    float floatValue = intValue / 8192.0f;
    pitchOffset = 2.0f * floatValue;
    return noErr;
}

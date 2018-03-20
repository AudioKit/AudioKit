#include "AKFlanger_Plugin.h"
#include "AKFlanger_Params.h"
#include "ModulatedDelay_Defines.h"
#include <cstring>
#include <ctype.h>
#include <math.h>

// OSErr definitions taken from deprecated CarbonCore/MacErrors.h
// Somewhere there's a newer header file I should be using
enum {
    fnfErr                        = -43,  /*File not found*/
};

AUDIOCOMPONENT_ENTRY(AUBaseProcessFactory, AKFlanger_Plugin)


static const CFStringRef paramName[] =
{
    CFSTR("Mod Freq"),
    CFSTR("Mod Depth"),
    CFSTR("Feedback"),
    CFSTR("Dry/Wet Mix"),
};


AKFlanger_Plugin::AKFlanger_Plugin(AudioUnit inComponentInstance)
	: AUEffectBase(inComponentInstance)
    , AudioKitCore::ModulatedDelay(kFlanger)
    , feedback(kFlangerDefaultFeedback)
{
	CreateElements();
	Globals()->UseIndexedParameters(kNumberOfParams);
    
    SetParameter(kModFrequency, kAudioUnitScope_Global, 0, kFlangerDefaultModFreqHz, 0);
    SetParameter(kModDepth, kAudioUnitScope_Global, 0, kFlangerDefaultDepth, 0);
    SetParameter(kFeedback, kAudioUnitScope_Global, 0, kFlangerDefaultFeedback, 0);
    SetParameter(kDryWetMix, kAudioUnitScope_Global, 0, kFlangerDefaultMix, 0);
}

AKFlanger_Plugin::~AKFlanger_Plugin()
{
}

OSStatus AKFlanger_Plugin::Initialize()
{
    printf("AudioKitCore::AKFlanger_Plugin::Initialize\n");
    OSStatus stat = AUEffectBase::Initialize();
    AudioKitCore::ModulatedDelay::init(GetOutput(0)->GetStreamFormat().mChannelsPerFrame,
                                       GetOutput(0)->GetStreamFormat().mSampleRate);
    return stat;
}

void AKFlanger_Plugin::Cleanup()
{
    printf("AudioKitCore::AKFlanger_Plugin::Cleanup\n");
    AudioKitCore::ModulatedDelay::deinit();
}

OSStatus AKFlanger_Plugin::GetPropertyInfo( AudioUnitPropertyID         inPropertyID,
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
    
    return AUEffectBase::GetPropertyInfo (inPropertyID, inScope, inElement, outDataSize, outWritable);
}

OSStatus AKFlanger_Plugin::GetProperty( AudioUnitPropertyID         inPropertyID,
                                        AudioUnitScope              inScope,
                                        AudioUnitElement            inElement,
                                        void*                       outData)
{
    if (inScope == kAudioUnitScope_Global) {
        switch (inPropertyID) {
            case kAudioUnitProperty_CocoaUI:
            {
                // Look for a resource in the main bundle by name and type.
                CFBundleRef bundle = CFBundleGetBundleWithIdentifier( CFSTR("io.audiokit.AKFlanger") );
                
                if (bundle == NULL) {
                    printf("Could not find bundle specified for GUI resources\n");
                    return fnfErr;
                }
                
                CFURLRef bundleURL = CFBundleCopyResourceURL( bundle,
                                                             CFSTR("AKFlangerUI"),
                                                             CFSTR("bundle"),
                                                             NULL);
                
                if (bundleURL == NULL) {
                    printf("Could not create resource URL for GUI\n");
                    return fnfErr;
                }
                
                CFStringRef className = CFSTR("AKFlanger_ViewFactory");
                AudioUnitCocoaViewInfo cocoaInfo = { bundleURL, { className } };
                *((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;
                
                return noErr;
            }
        }
    }

    return AUEffectBase::GetProperty (inPropertyID, inScope, inElement, outData);
}

OSStatus AKFlanger_Plugin::SetProperty(         AudioUnitPropertyID         inPropertyID,
                                                AudioUnitScope              inScope,
                                                AudioUnitElement            inElement,
                                                const void *                inData,
                                                UInt32                      inDataSize)
{
    // Default implementation for all non-custom properties
    return AUEffectBase::SetProperty(inPropertyID, inScope, inElement, inData, inDataSize);
}


OSStatus AKFlanger_Plugin::GetParameterInfo(    AudioUnitScope          inScope,
                                                AudioUnitParameterID    inParameterID,
                                                AudioUnitParameterInfo& outParameterInfo)
{
	if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;

    outParameterInfo.flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable;

    switch (inParameterID) {
        case kModFrequency:
            AUBase::FillInParameterName (outParameterInfo, paramName[kModFrequency], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Hertz;
            outParameterInfo.minValue = kFlangerMinModFreqHz;
            outParameterInfo.maxValue = kFlangerMaxModFreqHz;
            outParameterInfo.defaultValue = kFlangerDefaultModFreqHz;
            break;
            
        case kModDepth:
            AUBase::FillInParameterName (outParameterInfo, paramName[kModDepth], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Generic;
            outParameterInfo.minValue = kFlangerMinDepth;
            outParameterInfo.maxValue = kFlangerMaxDepth;
            outParameterInfo.defaultValue = kFlangerDefaultDepth;
            break;
    
        case kFeedback:
            AUBase::FillInParameterName (outParameterInfo, paramName[kFeedback], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Generic;
            outParameterInfo.minValue = kFlangerMinFeedback;
            outParameterInfo.maxValue = kFlangerMaxFeedback;
            outParameterInfo.defaultValue = kFlangerDefaultFeedback;
            break;
            
        case kDryWetMix:
            AUBase::FillInParameterName (outParameterInfo, paramName[kDryWetMix], false);
            outParameterInfo.unit = kAudioUnitParameterUnit_Generic;
            outParameterInfo.minValue = kFlangerMinDryWetMix;
            outParameterInfo.maxValue = kFlangerMaxDryWetMix;
            outParameterInfo.defaultValue = kFlangerDefaultMix;
            break;
            
        default:
            return kAudioUnitErr_InvalidParameter;
    }
    
	return noErr;
}

OSStatus AKFlanger_Plugin::GetParameter(    AudioUnitParameterID        inParameterID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            AudioUnitParameterValue &   outValue)
{
    if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;
    
    switch (inParameterID)
    {
        case kModFrequency:
            outValue = getModFrequencyHz();
            break;
            
        case kModDepth:
            outValue = getModDepthFraction();
            break;
            
        case kFeedback:
            outValue = feedback;
            break;
            
        case kDryWetMix:
            outValue = dryWetMix;
            break;
            
        default:
            return kAudioUnitErr_InvalidParameter;
    }
    
    return noErr;
}

OSStatus AKFlanger_Plugin::SetParameter(    AudioUnitParameterID        inParameterID,
                                            AudioUnitScope              inScope,
                                            AudioUnitElement            inElement,
                                            AudioUnitParameterValue     inValue,
                                            UInt32                      inBufferOffsetInFrames)
{
    if (inScope != kAudioUnitScope_Global) return kAudioUnitErr_InvalidScope;
    
    switch (inParameterID)
    {
        case kModFrequency:
            setModFrequencyHz(inValue);
            break;
            
        case kModDepth:
            setModDepthFraction(inValue);
            break;
            
        case kFeedback:
            feedback = inValue;
            leftDelayLine.setFeedback(feedback);
            rightDelayLine.setFeedback(feedback);
            break;
            
        case kDryWetMix:
            dryWetMix = inValue;
            break;

        default:
            return kAudioUnitErr_InvalidParameter;
    }
    
    return noErr;
}

#define CHUNKSIZE 16

OSStatus AKFlanger_Plugin::ProcessBufferLists(AudioUnitRenderActionFlags &ioActionFlags,
                                       const AudioBufferList &inBuffer,
                                       AudioBufferList &outBuffer,
                                       UInt32 inFramesToProcess)
{
    float* inBuffers[2];
    inBuffers[0] = (Float32 *)inBuffer.mBuffers[0].mData;
    inBuffers[1] = (Float32 *)inBuffer.mBuffers[1].mData;
    float* outBuffers[2];
    outBuffers[0] = (Float32 *)outBuffer.mBuffers[0].mData;
    outBuffers[1] = (Float32 *)outBuffer.mBuffers[1].mData;
    
    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < inFramesToProcess; frameIndex += CHUNKSIZE) {
        int chunkSize = inFramesToProcess - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;
        
        // Any ramping parameters would be updated here...
        
        unsigned channelCount = outBuffer.mNumberBuffers;
        if (channelCount > 2) channelCount = 2;
        AudioKitCore::ModulatedDelay::Render(channelCount, chunkSize, inBuffers, outBuffers);
        
        inBuffers[0] += CHUNKSIZE;
        inBuffers[1] += CHUNKSIZE;
        outBuffers[0] += CHUNKSIZE;
        outBuffers[1] += CHUNKSIZE;
    }
    
    return noErr;
}

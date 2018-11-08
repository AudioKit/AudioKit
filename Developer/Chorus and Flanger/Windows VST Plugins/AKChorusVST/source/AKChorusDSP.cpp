#include "AKChorusDSP.h"
#include "AKChorusGUI.h"
#include "AKChorusParams.h"
#include "ModulatedDelay_Defines.h"
#include "TRACE.h"
#include <ShlObj.h>
#include <stdlib.h>


AudioEffect* createEffectInstance (audioMasterCallback audioMaster)
{
	return new AKChorusDSP (audioMaster, 1);
}

AKChorusDSP::AKChorusDSP (audioMasterCallback audioMaster, VstInt32 numPrograms)
    : AudioEffectX (audioMaster, numPrograms, kNumParams)
    , AudioKitCore::ModulatedDelay(kChorus)
    , feedback(kChorusDefaultFeedback)
{
	if (audioMaster)
	{
		setNumInputs(2);
		setNumOutputs(2);
		canProcessReplacing();
		setUniqueID('AKch');
	}
	suspend();

    editor = new AKChorusGUI(this);

    double sampleRateHz = (double)getSampleRate();
    init(2, sampleRateHz);

    // note arguments to setParameter are all fractions, but our frequency parameter is not
    setParameter(kModFreq, (kChorusDefaultModFreqHz - kChorusMinModFreqHz) / (kChorusMaxModFreqHz - kChorusMinModFreqHz));
    setParameter(kModDepth, kChorusDefaultDepth);
    setParameter(kFeedback, kChorusDefaultFeedback);
    setParameter(kDryWetMix, kChorusDefaultMix);
}

AKChorusDSP::~AKChorusDSP ()
{
}

bool AKChorusDSP::getOutputProperties (VstInt32 index, VstPinProperties* properties)
{
	if (index < 2)
	{
		vst_strncpy (properties->label, "Vstx ", 63);
		char temp[11] = {0};
		int2string (index + 1, temp, 10);
		vst_strncat (properties->label, temp, 63);

		properties->flags = kVstPinIsActive;
		if (index < 2)
			properties->flags |= kVstPinIsStereo;	// make channel 1+2 stereo
		return true;
	}
	return false;
}

bool AKChorusDSP::getEffectName (char* name)
{
	vst_strncpy (name, "AKChorus", kVstMaxEffectNameLen);
	return true;
}

bool AKChorusDSP::getVendorString (char* text)
{
	vst_strncpy (text, "AudioKit", kVstMaxVendorStrLen);
	return true;
}

bool AKChorusDSP::getProductString (char* text)
{
	vst_strncpy (text, "AKChorus", kVstMaxProductStrLen);
	return true;
}

VstInt32 AKChorusDSP::getVendorVersion ()
{ 
	return 1000; 
}

VstInt32 AKChorusDSP::canDo (char* text)
{
    if (!strcmp (text, "hasEditor"))
        return 1;
	if (!strcmp (text, "receiveVstEvents"))
		return 1;
	return -1;	// explicitly can't do; 0 => don't know
}

void AKChorusDSP::getParameterName (VstInt32 index, char* label)
{
	switch (index)
	{
        // note kVstMaxParamStrLen is only 8 chars
		case kModFreq:
            vst_strncpy (label, "Rate", kVstMaxParamStrLen); 
            break;
        case kModDepth:
            vst_strncpy(label, "Depth", kVstMaxParamStrLen);
            break;
        case kFeedback:
            vst_strncpy(label, "Feedback", kVstMaxParamStrLen);
            break;
        case kDryWetMix:
            vst_strncpy(label, "Mix", kVstMaxParamStrLen);
            break;
    }
}

void AKChorusDSP::getParameterDisplay (VstInt32 index, char* text)
{
	text[0] = 0;
	switch (index)
	{
		case kModFreq:
            float2string(getModFrequencyHz(), text, kVstMaxParamStrLen);
            break;
        case kModDepth:
            float2string(getModDepthFraction(), text, kVstMaxParamStrLen);
            break;
        case kFeedback:
            float2string(feedback, text, kVstMaxParamStrLen);
            break;
        case kDryWetMix:
            float2string(dryWetMix, text, kVstMaxParamStrLen);
            break;
    }
}

void AKChorusDSP::getParamString(VstInt32 index, char* text)
{
    text[0] = 0;
    switch (index)
    {
    case kModFreq:
        sprintf(text, "%.1f Hz", getModFrequencyHz());
        break;
    case kModDepth:
        sprintf(text, "%.1f %%", 100.0f * getModDepthFraction());
        break;
    case kFeedback:
        sprintf(text, "%.1f %%", 100.0f * feedback);
        break;
    case kDryWetMix:
        sprintf(text, "%.1f %%", 100.0f * dryWetMix);
        break;
    }
}

void AKChorusDSP::setParamFraction(VstInt32 index, float value)
{
    switch (index)
    {
        // value is a fraction which may require conversion to actual parameter range
    case kModFreq:
        setModFrequencyHz(kChorusMinModFreqHz + value * (kChorusMaxModFreqHz - kChorusMinModFreqHz));
        break;
    case kModDepth:
        setModDepthFraction(value);
        break;
    case kFeedback:
        feedback = value;
        leftDelayLine.setFeedback(feedback);
        rightDelayLine.setFeedback(feedback);
        break;
    case kDryWetMix:
        dryWetMix = value;
        break;
    }
}

void AKChorusDSP::setParameter (VstInt32 index, float value)
{
    setParamFraction(index, value);
    if (editor) ((AKChorusGUI*)editor)->setParameter (index, value);
}

float AKChorusDSP::getParameter (VstInt32 index)
{
	float value = 0;    // converted output value must be a fraction, range 0.0 - 1.0
	switch (index)
	{
		case kModFreq:
            value = (getModFrequencyHz() - kChorusMinModFreqHz) / (kChorusMaxModFreqHz - kChorusMinModFreqHz);
            break;
        case kModDepth:
            value = getModDepthFraction();
            break;
        case kFeedback:
            value = feedback;
            break;
        case kDryWetMix:
            value = dryWetMix;
            break;
    }
	return value;
}

float AKChorusDSP::getParamValue(VstInt32 index)
{
    switch (index)
    {
    case kModFreq:
        return getModFrequencyHz();
    case kModDepth:
        return getModDepthFraction();
    case kFeedback:
        return feedback;
    case kDryWetMix:
        return dryWetMix;
    }
    return 0.0f;
}

#define CHUNKSIZE 16

void AKChorusDSP::processReplacing (float** inputs, float** outputs, VstInt32 nFrames)
{
    // take copies of these pointers so we can increment them
    float *inBuffers[2];
    inBuffers[0] = inputs[0];
    inBuffers[1] = inputs[1];
    float *outBuffers[2];
    outBuffers[0] = outputs[0];
    outBuffers[1] = outputs[1];

    // Clear output buffers before adding anything (some hosts pass in dirty buffers)
    //memset(outputs[0], 0, nFrames * sizeof(float));
    //if (outputs[1]) memset(outputs[1], 0, nFrames * sizeof(float));

    for (int frameIndex = 0; frameIndex < nFrames; frameIndex += CHUNKSIZE)
    {
        int chunkSize = nFrames - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // Any ramping parameters would be updated here...

        AudioKitCore::ModulatedDelay::Render(2, chunkSize, inBuffers, outBuffers);

        inBuffers[0] += CHUNKSIZE;
        inBuffers[1] += CHUNKSIZE;
        outBuffers[0] += CHUNKSIZE;
        outBuffers[1] += CHUNKSIZE;
    }
}

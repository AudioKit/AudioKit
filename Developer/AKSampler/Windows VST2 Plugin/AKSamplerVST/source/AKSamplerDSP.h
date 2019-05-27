#pragma once
#include "public.sdk/source/vst2.x/audioeffectx.h"
#include "AKCoreSampler.hpp"

struct VSTFloatParam
{
    float &value;
    float minValue, maxValue;

    VSTFloatParam(float& target, float min, float max)
        : value(target), minValue(min), maxValue(max) {}

    float asFraction() { return (value - minValue) / (maxValue - minValue); }
    void setFraction(float f) { value = minValue + f * (maxValue - minValue); }
};

struct VSTBoolParam
{
    bool &value;

    VSTBoolParam(bool& target) : value(target) {}

    float asFraction() { return value ? 1.0f : 0.0f; }
    void setFraction(float f) { value = f < 0.5f; }
};

class AKSamplerDSP : public AudioEffectX, public AKCoreSampler
{
public:
	AKSamplerDSP (audioMasterCallback audioMaster, VstInt32 numPrograms);
	~AKSamplerDSP ();

	virtual bool getOutputProperties (VstInt32 index, VstPinProperties* properties);
	virtual bool getEffectName (char* name);
	virtual bool getVendorString (char* text);
	virtual bool getProductString (char* text);
	virtual VstInt32 getVendorVersion ();
	virtual VstInt32 canDo (char* text);
	virtual VstInt32 getNumMidiInputChannels ();
	virtual VstInt32 getNumMidiOutputChannels ();

	virtual void getParameterName (VstInt32 index, char* text);
	virtual void getParameterDisplay (VstInt32 index, char* text);
	virtual void setParameter (VstInt32 index, float value);
	virtual float getParameter (VstInt32 index);
	virtual VstInt32 processEvents (VstEvents* events);

	virtual void processReplacing (float** inputs, float** outputs, VstInt32 nFrames);

public:
    // for use by GUI
    char presetFolderPath[200];
    char presetName[50];
    bool loadPreset();

    void setParamFraction(VstInt32 index, float value);
    float getParamFraction(VstInt32 index) { return getParameter(index); } // an alias
    float getParamValue(VstInt32 index);
    void getParamString(VstInt32 index, char* text);

protected:
    bool loadSoundFile(AKSampleFileDescriptor &sfd);
    bool loadCompressedSampleFile(AKSampleFileDescriptor& sfd);

    void loadAifDemoSamples();
    void loadWvDemoSamples();
};

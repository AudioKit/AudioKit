/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Part of Core Audio AUBase Classes
*/

#include "AUPlugInDispatch.h"
#include "CAXException.h"
#include "ComponentBase.h"
#include "AUBase.h"

#define ACPI ((AudioComponentPlugInInstance *)self)
#define AUI	((AUBase *)&ACPI->mInstanceStorage)

#define AUI_LOCK CAMutex::Locker auLock(AUI->GetMutex());

// ------------------------------------------------------------------------------------------------
static OSStatus AUMethodInitialize(void *self)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->DoInitialize();
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodUninitialize(void *self)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		AUI->DoCleanup();
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodGetPropertyInfo(void *self, AudioUnitPropertyID prop, AudioUnitScope scope, AudioUnitElement elem, UInt32 *outDataSize, Boolean *outWritable)
{
	OSStatus result = noErr;
	try {
		UInt32 dataSize = 0;        // 13517289 GetPropetyInfo was returning an uninitialized value when there is an error. This is a problem for auval.
		Boolean writable = false;
		
		AUI_LOCK
		result = AUI->DispatchGetPropertyInfo(prop, scope, elem, dataSize, writable);
		if (outDataSize != NULL)
			*outDataSize = dataSize;
		if (outWritable != NULL)
			*outWritable = writable;
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodGetProperty(void *self, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement, void *outData, UInt32 *ioDataSize)
{
	OSStatus result = noErr;
	try {
		UInt32 actualPropertySize, clientBufferSize;
		Boolean writable;
		char *tempBuffer;
		void *destBuffer;
		
		AUI_LOCK
		if (ioDataSize == NULL) {
			ca_debug_string("AudioUnitGetProperty: null size pointer");
			result = kAudio_ParamError;
			goto finishGetProperty;
		}
		if (outData == NULL) {
			UInt32 dataSize;
			
			result = AUI->DispatchGetPropertyInfo(inID, inScope, inElement, dataSize, writable);
			*ioDataSize = dataSize;
			goto finishGetProperty;
		}
		
		clientBufferSize = *ioDataSize;
		if (clientBufferSize == 0)
		{
			ca_debug_string("AudioUnitGetProperty: *ioDataSize == 0 on entry");
			// $$$ or should we allow this as a shortcut for finding the size?
			result = kAudio_ParamError;
			goto finishGetProperty;
		}
		
		result = AUI->DispatchGetPropertyInfo(inID, inScope, inElement, actualPropertySize, writable);
		if (result != noErr) 
			goto finishGetProperty;
		
		if (clientBufferSize < actualPropertySize) 
		{
			tempBuffer = new char[actualPropertySize];
			destBuffer = tempBuffer;
		} else {
			tempBuffer = NULL;
			destBuffer = outData;
		}
		
		result = AUI->DispatchGetProperty(inID, inScope, inElement, destBuffer);
		
		if (result == noErr) {
			if (clientBufferSize < actualPropertySize && tempBuffer != NULL)
			{
				memcpy(outData, tempBuffer, clientBufferSize);
				delete[] tempBuffer;
				// ioDataSize remains correct, the number of bytes we wrote
			} else
				*ioDataSize = actualPropertySize;
		} else
			*ioDataSize = 0;
	}
	COMPONENT_CATCH
finishGetProperty:
	return result;
}

static OSStatus AUMethodSetProperty(void *self, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement, const void *inData, UInt32 inDataSize)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		if (inData && inDataSize)
			result = AUI->DispatchSetProperty(inID, inScope, inElement, inData, inDataSize);
		else {
			if (inData == NULL && inDataSize == 0) {
				result = AUI->DispatchRemovePropertyValue(inID, inScope, inElement);
			} else {
				if (inData == NULL) {
					ca_debug_string("AudioUnitSetProperty: inData == NULL");
					result = kAudio_ParamError;
					goto finishSetProperty;
				}

				if (inDataSize == 0) {
					ca_debug_string("AudioUnitSetProperty: inDataSize == 0");
					result = kAudio_ParamError;
					goto finishSetProperty;
				}
			}
		}
	}
	COMPONENT_CATCH
finishSetProperty:
	return result;
}

static OSStatus AUMethodAddPropertyListener(void *self, AudioUnitPropertyID prop, AudioUnitPropertyListenerProc proc, void *userData)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->AddPropertyListener(prop, proc, userData);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodRemovePropertyListener(void *self, AudioUnitPropertyID prop, AudioUnitPropertyListenerProc proc)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->RemovePropertyListener(prop, proc, NULL, false);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodRemovePropertyListenerWithUserData(void *self, AudioUnitPropertyID prop, AudioUnitPropertyListenerProc proc, void *userData)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->RemovePropertyListener(prop, proc, userData, true);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodAddRenderNotify(void *self, AURenderCallback proc, void *userData)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->SetRenderNotification(proc, userData);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodRemoveRenderNotify(void *self, AURenderCallback proc, void *userData)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->RemoveRenderNotification(proc, userData);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodGetParameter(void *self, AudioUnitParameterID param, AudioUnitScope scope, AudioUnitElement elem, AudioUnitParameterValue *value)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = (value == NULL ? kAudio_ParamError : AUI->GetParameter(param, scope, elem, *value));
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodSetParameter(void *self, AudioUnitParameterID param, AudioUnitScope scope, AudioUnitElement elem, AudioUnitParameterValue value, UInt32 bufferOffset)
{
	OSStatus result = noErr;
	try {
		// this is a (potentially) realtime method; no lock
		result = AUI->SetParameter(param, scope, elem, value, bufferOffset);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodScheduleParameters(void *self, const AudioUnitParameterEvent *events, UInt32 numEvents)
{
	OSStatus result = noErr;
	try {
		// this is a (potentially) realtime method; no lock
		result = AUI->ScheduleParameter(events, numEvents);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodRender(void *self, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	OSStatus result = noErr;

#if !TARGET_OS_IPHONE
	try {
#endif
		// this is a processing method; no lock
		AudioUnitRenderActionFlags tempFlags;
		
		if (inTimeStamp == NULL || ioData == NULL)
			result = kAudio_ParamError;
		else {
			if (ioActionFlags == NULL) {
				tempFlags = 0;
				ioActionFlags = &tempFlags;
			}
			result = AUI->DoRender(*ioActionFlags, *inTimeStamp, inOutputBusNumber, inNumberFrames, *ioData);
		}

#if !TARGET_OS_IPHONE
	}
	COMPONENT_CATCH
#endif

	return result;
}

static OSStatus AUMethodComplexRender(void *self, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberOfPackets, UInt32 *outNumberOfPackets, AudioStreamPacketDescription *outPacketDescriptions, AudioBufferList *ioData, void *outMetadata, UInt32 *outMetadataByteSize)
{
	OSStatus result = noErr;

#if !TARGET_OS_IPHONE
	try {
#endif
		// this is a processing method; no lock
		AudioUnitRenderActionFlags tempFlags;
		
		if (inTimeStamp == NULL || ioData == NULL)
			result = kAudio_ParamError;
		else {
			if (ioActionFlags == NULL) {
				tempFlags = 0;
				ioActionFlags = &tempFlags;
			}
			result = AUI->ComplexRender(*ioActionFlags, *inTimeStamp, inOutputBusNumber, inNumberOfPackets, outNumberOfPackets, outPacketDescriptions, *ioData, outMetadata, outMetadataByteSize);
		}

#if !TARGET_OS_IPHONE
	}
	COMPONENT_CATCH
#endif

	return result;
}

static OSStatus AUMethodReset(void *self, AudioUnitScope scope, AudioUnitElement elem)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->Reset(scope, elem);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodProcess (void *self, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	OSStatus result = noErr;

#if !TARGET_OS_IPHONE
	try {
#endif
		// this is a processing method; no lock
		bool doParamCheck = true;

		AudioUnitRenderActionFlags tempFlags;

		if (ioActionFlags == NULL) {
			tempFlags = 0;
			ioActionFlags = &tempFlags;
		} else {
			if (*ioActionFlags & (1 << 9)/*kAudioUnitRenderAction_DoNotCheckRenderArgs*/)
				doParamCheck = false;
		}
		
		if (doParamCheck && (inTimeStamp == NULL || ioData == NULL))
			result = kAudio_ParamError;
		else {
			result = AUI->DoProcess(*ioActionFlags, *inTimeStamp, inNumberFrames, *ioData);
		}

#if !TARGET_OS_IPHONE
	}
	COMPONENT_CATCH
#endif

	return result;
}

static OSStatus AUMethodProcessMultiple (void *self, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, UInt32 inNumberInputBufferLists, const AudioBufferList **inInputBufferLists, UInt32 inNumberOutputBufferLists, AudioBufferList **ioOutputBufferLists)
{
	OSStatus result = noErr;
	
#if !TARGET_OS_IPHONE
	try {
#endif
		// this is a processing method; no lock
		bool doParamCheck = true;
		
		AudioUnitRenderActionFlags tempFlags;
		
		if (ioActionFlags == NULL) {
			tempFlags = 0;
			ioActionFlags = &tempFlags;
		} else {
			if (*ioActionFlags & (1 << 9)/*kAudioUnitRenderAction_DoNotCheckRenderArgs*/)
				doParamCheck = false;
		}

		if (doParamCheck && (inTimeStamp == NULL || inInputBufferLists == NULL || ioOutputBufferLists == NULL))
			result = kAudio_ParamError;
		else {
			result = AUI->DoProcessMultiple(*ioActionFlags, *inTimeStamp, inNumberFrames, inNumberInputBufferLists, inInputBufferLists, inNumberOutputBufferLists, ioOutputBufferLists);
		}
		
#if !TARGET_OS_IPHONE
	}
	COMPONENT_CATCH
#endif

	return result;
}
// ------------------------------------------------------------------------------------------------

static OSStatus AUMethodStart(void *self)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->Start();
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodStop(void *self)
{
	OSStatus result = noErr;
	try {
		AUI_LOCK
		result = AUI->Stop();
	}
	COMPONENT_CATCH
	return result;
}

// ------------------------------------------------------------------------------------------------

#if !CA_BASIC_AU_FEATURES
// I don't know what I'm doing here; conflicts with the multiple inheritence in MusicDeviceBase.
static OSStatus AUMethodMIDIEvent(void *self, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		result = AUI->MIDIEvent(inStatus, inData1, inData2, inOffsetSampleFrame);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodSysEx(void *self, const UInt8 *inData, UInt32 inLength)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		result = AUI->SysEx(inData, inLength);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodStartNote(void *self, MusicDeviceInstrumentID inInstrument, MusicDeviceGroupID inGroupID, NoteInstanceID *outNoteInstanceID, UInt32 inOffsetSampleFrame, const MusicDeviceNoteParams *inParams)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		if (inParams == NULL || outNoteInstanceID == NULL) 
			result = kAudio_ParamError;
		else
			result = AUI->StartNote(inInstrument, inGroupID, outNoteInstanceID, inOffsetSampleFrame, *inParams);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodStopNote(void *self, MusicDeviceGroupID inGroupID, NoteInstanceID inNoteInstanceID, UInt32 inOffsetSampleFrame)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		result = AUI->StopNote(inGroupID, inNoteInstanceID, inOffsetSampleFrame);
	}
	COMPONENT_CATCH
	return result;
}

#if !TARGET_OS_IPHONE
static OSStatus AUMethodPrepareInstrument (void *self, MusicDeviceInstrumentID inInstrument)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		result = AUI->PrepareInstrument(inInstrument);
	}
	COMPONENT_CATCH
	return result;
}

static OSStatus AUMethodReleaseInstrument (void *self, MusicDeviceInstrumentID inInstrument)
{
	OSStatus result = noErr;
	try {
		// this is a potential render-time method; no lock
		result = AUI->ReleaseInstrument(inInstrument);
	}
	COMPONENT_CATCH
	return result;
}
#endif // TARGET_OS_IPHONE
#endif // CA_BASIC_AU_FEATURES


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pragma mark -
#pragma mark Lookup Methods

AudioComponentMethod AUBaseLookup::Lookup (SInt16 selector)
{
	switch (selector) {
		case kAudioUnitInitializeSelect:		return (AudioComponentMethod)AUMethodInitialize;
		case kAudioUnitUninitializeSelect:		return (AudioComponentMethod)AUMethodUninitialize;
		case kAudioUnitGetPropertyInfoSelect:	return (AudioComponentMethod)AUMethodGetPropertyInfo;
		case kAudioUnitGetPropertySelect:		return (AudioComponentMethod)AUMethodGetProperty;
		case kAudioUnitSetPropertySelect:		return (AudioComponentMethod)AUMethodSetProperty;
		case kAudioUnitAddPropertyListenerSelect:return (AudioComponentMethod)AUMethodAddPropertyListener;
		case kAudioUnitRemovePropertyListenerSelect:
												return (AudioComponentMethod)AUMethodRemovePropertyListener;
		case kAudioUnitRemovePropertyListenerWithUserDataSelect:
												return (AudioComponentMethod)AUMethodRemovePropertyListenerWithUserData;
		case kAudioUnitAddRenderNotifySelect:	return (AudioComponentMethod)AUMethodAddRenderNotify;
		case kAudioUnitRemoveRenderNotifySelect:return (AudioComponentMethod)AUMethodRemoveRenderNotify;
		case kAudioUnitGetParameterSelect:		return (AudioComponentMethod)AUMethodGetParameter;
		case kAudioUnitSetParameterSelect:		return (AudioComponentMethod)AUMethodSetParameter;
		case kAudioUnitScheduleParametersSelect:return (AudioComponentMethod)AUMethodScheduleParameters;
		case kAudioUnitRenderSelect:			return (AudioComponentMethod)AUMethodRender;
		case kAudioUnitResetSelect:				return (AudioComponentMethod)AUMethodReset;
		default:
			break;
	}
	return NULL;
}

AudioComponentMethod AUOutputLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;

	switch (selector) {
		case kAudioOutputUnitStartSelect:	return (AudioComponentMethod)AUMethodStart;
		case kAudioOutputUnitStopSelect:	return (AudioComponentMethod)AUMethodStop;
		default:
			break;
	}
	return NULL;
}

AudioComponentMethod AUComplexOutputLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;
	
	method = AUOutputLookup::Lookup(selector);
	if (method) return method;
	
	if (selector == kAudioUnitComplexRenderSelect)
		return (AudioComponentMethod)AUMethodComplexRender;
	return NULL;
}

AudioComponentMethod AUBaseProcessLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;
	
	if (selector == kAudioUnitProcessSelect)
		return (AudioComponentMethod)AUMethodProcess;
	
	return NULL;
}

AudioComponentMethod AUBaseProcessMultipleLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;
    
	if (selector == kAudioUnitProcessMultipleSelect)
		return (AudioComponentMethod)AUMethodProcessMultiple;
	
	return NULL;
}

AudioComponentMethod AUBaseProcessAndMultipleLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;

	method = AUBaseProcessMultipleLookup::Lookup(selector);
	if (method) return method;
    
	method = AUBaseProcessLookup::Lookup(selector);
	if (method) return method;

	return NULL;
}

#if !CA_BASIC_AU_FEATURES
inline AudioComponentMethod MIDI_Lookup (SInt16 selector)
{
	switch (selector) {
		case kMusicDeviceMIDIEventSelect:	return (AudioComponentMethod)AUMethodMIDIEvent;
		case kMusicDeviceSysExSelect:		return (AudioComponentMethod)AUMethodSysEx;
		default:
			break;
	}
	return NULL;
}

AudioComponentMethod AUMIDILookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;
	
	return MIDI_Lookup(selector);
}

AudioComponentMethod AUMIDIProcessLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseProcessLookup::Lookup(selector);
	if (method) return method;
	
	return MIDI_Lookup(selector);
}

AudioComponentMethod AUMusicLookup::Lookup (SInt16 selector)
{
	AudioComponentMethod method = AUBaseLookup::Lookup(selector);
	if (method) return method;

	switch (selector) {
		case kMusicDeviceStartNoteSelect:	return (AudioComponentMethod)AUMethodStartNote;
		case kMusicDeviceStopNoteSelect:	return (AudioComponentMethod)AUMethodStopNote;
#if !TARGET_OS_IPHONE
		case kMusicDevicePrepareInstrumentSelect:	return (AudioComponentMethod)AUMethodPrepareInstrument;
		case kMusicDeviceReleaseInstrumentSelect:	return (AudioComponentMethod)AUMethodReleaseInstrument;
#endif
		default:		
			break;
	}
	return MIDI_Lookup (selector);
}

AudioComponentMethod AUAuxBaseLookup::Lookup (SInt16 selector)
{
	switch (selector) {
		case kAudioUnitGetPropertyInfoSelect:	return (AudioComponentMethod)AUMethodGetPropertyInfo;
		case kAudioUnitGetPropertySelect:		return (AudioComponentMethod)AUMethodGetProperty;
		case kAudioUnitSetPropertySelect:		return (AudioComponentMethod)AUMethodSetProperty;
            
		case kAudioUnitGetParameterSelect:		return (AudioComponentMethod)AUMethodGetParameter;
		case kAudioUnitSetParameterSelect:		return (AudioComponentMethod)AUMethodSetParameter;
            
		default:
			break;
	}
	return NULL;
}
#endif


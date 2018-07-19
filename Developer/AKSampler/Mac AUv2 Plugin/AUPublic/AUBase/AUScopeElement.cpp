/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Part of Core Audio AUBase Classes
*/

#include "AUScopeElement.h"
#include <AudioUnit/AudioUnitProperties.h>
#include "AUBase.h"

//_____________________________________________________________________________
//
//	By default, parameterIDs may be arbitrarily spaced, and an STL map
//  will be used for access.  Calling UseIndexedParameters() will
//	instead use an STL vector for faster indexed access.
//	This assumes the paramIDs are numbered 0.....inNumberOfParameters-1
//	Call this before defining/adding any parameters with SetParameter()
//
void	AUElement::UseIndexedParameters(int inNumberOfParameters)
{
	mIndexedParameters.resize (inNumberOfParameters);	
	mUseIndexedParameters = true;
}

//_____________________________________________________________________________
//
//	Helper method.
//	returns the ParameterMapEvent object associated with the paramID
//
inline ParameterMapEvent&	AUElement::GetParamEvent(AudioUnitParameterID paramID)
{
	ParameterMapEvent *event;
	
	if(mUseIndexedParameters)
	{
		if(paramID >= mIndexedParameters.size() )
			COMPONENT_THROW(kAudioUnitErr_InvalidParameter);
		
		event = &mIndexedParameters[paramID];
	}
	else
	{
		ParameterMap::iterator i = mParameters.find(paramID);
		if (i == mParameters.end())
			COMPONENT_THROW(kAudioUnitErr_InvalidParameter);
			
		event = &(*i).second;
	}
	
	return *event;
}

//_____________________________________________________________________________
//
//	Helper method.
//	returns whether the specified paramID is known to the element
//
bool		AUElement::HasParameterID (AudioUnitParameterID paramID) const
{	
	if(mUseIndexedParameters)
	{
		if(paramID >= mIndexedParameters.size() )
			return false;
		
		return true;
	}
	
	ParameterMap::const_iterator i = mParameters.find(paramID);
	if (i == mParameters.end())
		return false;
		
	return true;
}

//_____________________________________________________________________________
//
//	caller assumes that this is actually an immediate parameter
//
AudioUnitParameterValue		AUElement::GetParameter(AudioUnitParameterID paramID)
{
	ParameterMapEvent &event = GetParamEvent(paramID);
	
	return event.GetValue();
}


//_____________________________________________________________________________
//
void			AUElement::GetRampSliceStartEnd(	AudioUnitParameterID		paramID,
													AudioUnitParameterValue &	outStartValue,
													AudioUnitParameterValue &	outEndValue,
													AudioUnitParameterValue &	outValuePerFrameDelta )

{
	ParameterMapEvent &event = GetParamEvent(paramID);
		
	// works even if the value is constant (immediate parameter value)
	event.GetRampSliceStartEnd(outStartValue, outEndValue, outValuePerFrameDelta );
}

//_____________________________________________________________________________
//
AudioUnitParameterValue			AUElement::GetEndValue(	AudioUnitParameterID		paramID)

{
	ParameterMapEvent &event = GetParamEvent(paramID);
		
	// works even if the value is constant (immediate parameter value)
	return event.GetEndValue();
}

//_____________________________________________________________________________
//
void			AUElement::SetParameter(AudioUnitParameterID paramID, AudioUnitParameterValue inValue, bool okWhenInitialized)
{
	if(mUseIndexedParameters)
	{
		ParameterMapEvent &event = GetParamEvent(paramID);
		event.SetValue(inValue);
	}
	else
	{
		ParameterMap::iterator i = mParameters.find(paramID);
	
		if (i == mParameters.end())
		{
			if (mAudioUnit->IsInitialized() && !okWhenInitialized) {
				// The AU should not be creating new parameters once initialized.
				// If a client tries to set an undefined parameter, we could throw as follows, 
				// but this might cause a regression. So it is better to just fail silently.
				// COMPONENT_THROW(kAudioUnitErr_InvalidParameter);
#if DEBUG
				fprintf(stderr, "WARNING: %s SetParameter for undefined param ID %d while initialized. Ignoring..\n", 
								mAudioUnit->GetLoggingString(), (int)paramID);
#endif
			} else {
				// create new entry in map for the paramID (only happens first time)
				ParameterMapEvent event(inValue);		
				mParameters[paramID] = event;
			}
		}
		else
		{
			// paramID already exists in map so simply change its value
			ParameterMapEvent &event = (*i).second;
			event.SetValue(inValue);
		}
	}
}

//_____________________________________________________________________________
//
void			AUElement::SetScheduledEvent(	AudioUnitParameterID 			paramID,
												const AudioUnitParameterEvent 	&inEvent,
												UInt32 							inSliceOffsetInBuffer,
												UInt32							inSliceDurationFrames,
												bool							okWhenInitialized )
{
	if(mUseIndexedParameters)
	{
		ParameterMapEvent &event = GetParamEvent(paramID);
		event.SetScheduledEvent(inEvent, inSliceOffsetInBuffer, inSliceDurationFrames );
	}
	else
	{
		ParameterMap::iterator i = mParameters.find(paramID);
	
		if (i == mParameters.end())
		{
			if (mAudioUnit->IsInitialized() && !okWhenInitialized) {
				// The AU should not be creating new parameters once initialized.
				// If a client tries to set an undefined parameter, we could throw as follows, 
				// but this might cause a regression. So it is better to just fail silently.
				// COMPONENT_THROW(kAudioUnitErr_InvalidParameter);
#if DEBUG
				fprintf(stderr, "WARNING: %s SetScheduledEvent for undefined param ID %d while initialized. Ignoring..\n", 
								mAudioUnit->GetLoggingString(), (int)paramID);
#endif
			} else {
				// create new entry in map for the paramID (only happens first time)
				ParameterMapEvent event(inEvent, inSliceOffsetInBuffer, inSliceDurationFrames);		
				mParameters[paramID] = event;
			}
		}
		else
		{
			// paramID already exists in map so simply change its value
			ParameterMapEvent &event = (*i).second;
			
			event.SetScheduledEvent(inEvent, inSliceOffsetInBuffer, inSliceDurationFrames );
		}
	}
}



//_____________________________________________________________________________
//
void			AUElement::GetParameterList(AudioUnitParameterID *outList)
{
	if(mUseIndexedParameters)
	{
		UInt32 nparams = static_cast<UInt32>(mIndexedParameters.size());
		for (UInt32 i = 0; i < nparams; i++ )
			*outList++ = (AudioUnitParameterID)i;
	}
	else
	{
		for (ParameterMap::iterator i = mParameters.begin(); i != mParameters.end(); ++i)
			*outList++ = (*i).first;
	}
}

//_____________________________________________________________________________
//
void			AUElement::SaveState(AudioUnitScope scope, CFMutableDataRef data)
{
	AudioUnitParameterInfo paramInfo;
	CFIndex countOffset = CFDataGetLength(data);
	UInt32 nparams, nOmitted = 0, theData;

	if(mUseIndexedParameters)
	{
		nparams = static_cast<UInt32>(mIndexedParameters.size());
		theData = CFSwapInt32HostToBig(nparams);
		CFDataAppendBytes(data, (UInt8 *)&theData, sizeof(nparams));
	
		for (UInt32 i = 0; i < nparams; i++)
		{
			struct {
				UInt32				paramID;
				//CFSwappedFloat32	value; crashes gcc3 PFE
				UInt32				value;	// really a big-endian float
			} entry;

			if (mAudioUnit->GetParameterInfo(scope, i, paramInfo) == noErr) {
				if ((paramInfo.flags & kAudioUnitParameterFlag_CFNameRelease) && paramInfo.cfNameString)
					CFRelease(paramInfo.cfNameString);
				if (paramInfo.flags & kAudioUnitParameterFlag_OmitFromPresets) {
					++nOmitted;
					continue;
				}
			}
			
			entry.paramID = CFSwapInt32HostToBig(i);
	
			AudioUnitParameterValue v = mIndexedParameters[i].GetValue();
			entry.value = CFSwapInt32HostToBig(*(UInt32 *)&v );
	
			CFDataAppendBytes(data, (UInt8 *)&entry, sizeof(entry));
		}
	}
	else
	{
		nparams = static_cast<uint32_t>(mParameters.size());
		theData = CFSwapInt32HostToBig(nparams);
		CFDataAppendBytes(data, (UInt8 *)&theData, sizeof(nparams));
	
		for (ParameterMap::iterator i = mParameters.begin(); i != mParameters.end(); ++i) {
			struct {
				UInt32				paramID;
				//CFSwappedFloat32	value; crashes gcc3 PFE
				UInt32				value;	// really a big-endian float
			} entry;
			
			if (mAudioUnit->GetParameterInfo(scope, (*i).first, paramInfo) == noErr) {
				if ((paramInfo.flags & kAudioUnitParameterFlag_CFNameRelease) && paramInfo.cfNameString)
					CFRelease(paramInfo.cfNameString);
				if (paramInfo.flags & kAudioUnitParameterFlag_OmitFromPresets) {
					++nOmitted;
					continue;
				}
			}

			entry.paramID = CFSwapInt32HostToBig((*i).first);
	
			AudioUnitParameterValue v = (*i).second.GetValue();
			entry.value = CFSwapInt32HostToBig(*(UInt32 *)&v );
	
			CFDataAppendBytes(data, (UInt8 *)&entry, sizeof(entry));
		}
	}
	if (nOmitted > 0) {
		theData = CFSwapInt32HostToBig(nparams - nOmitted);
		*(UInt32 *)(CFDataGetBytePtr(data) + countOffset) = theData;
	}
}

//_____________________________________________________________________________
//
const UInt8 *	AUElement::RestoreState(const UInt8 *state)
{
	union FloatInt32 { UInt32 i; AudioUnitParameterValue f; };
	const UInt8 *p = state;
	UInt32 nparams = CFSwapInt32BigToHost(*(UInt32 *)p);
	p += sizeof(UInt32);
	
	for (UInt32 i = 0; i < nparams; ++i) {
		struct {
			AudioUnitParameterID		paramID;
			AudioUnitParameterValue		value;
		} entry;
		
		entry.paramID = CFSwapInt32BigToHost(*(UInt32 *)p);
		p += sizeof(UInt32);
		FloatInt32 temp;
		temp.i = CFSwapInt32BigToHost(*(UInt32 *)p);
		entry.value = temp.f;
		p += sizeof(AudioUnitParameterValue);
		
		SetParameter(entry.paramID, entry.value);
	}
	return p;
}

//_____________________________________________________________________________
//
void	AUElement::SetName (CFStringRef inName) 
{ 
	if (mElementName) CFRelease (mElementName);
	mElementName = inName; 
	if (mElementName) CFRetain (mElementName);
}


//_____________________________________________________________________________
//
AUIOElement::AUIOElement(AUBase *audioUnit) :
	AUElement(audioUnit),
	mWillAllocate (true)
{
	mStreamFormat = CAStreamBasicDescription(kAUDefaultSampleRate, 2, CAStreamBasicDescription::kPCMFormatFloat32, audioUnit->AudioUnitAPIVersion() == 1);
		// stereo
		// interleaved if API version 1, deinterleaved if version 2
}

//_____________________________________________________________________________
//
OSStatus		AUIOElement::SetStreamFormat(const CAStreamBasicDescription &desc)
{
	mStreamFormat = desc;
	return AUBase::noErr;
}

//_____________________________________________________________________________
// inFramesToAllocate == 0 implies the AudioUnit's max-frames-per-slice will be used
void			AUIOElement::AllocateBuffer(UInt32 inFramesToAllocate)
{
	if (GetAudioUnit()->HasBegunInitializing())
	{
		UInt32 framesToAllocate = inFramesToAllocate > 0 ? inFramesToAllocate : GetAudioUnit()->GetMaxFramesPerSlice();
		
//		printf ("will allocate: %d\n", (int)((mWillAllocate && NeedsBufferSpace()) ? framesToAllocate : 0));
		
		mIOBuffer.Allocate(mStreamFormat, (mWillAllocate && NeedsBufferSpace()) ? framesToAllocate : 0);
	}
}

//_____________________________________________________________________________
//
void			AUIOElement::DeallocateBuffer()
{
	mIOBuffer.Deallocate();
}

//_____________________________________________________________________________
//
//		AudioChannelLayout support

// outLayoutTagsPtr WILL be NULL if called to find out how many
// layouts that Audio Unit will report 
// return 0 (ie. NO channel layouts) if the AU doesn't require channel layout knowledge
UInt32		AUIOElement::GetChannelLayoutTags (AudioChannelLayoutTag		*outLayoutTagsPtr)
{
	return 0;
}
		
// As the AudioChannelLayout can be a variable length structure 
// (though in most cases it won't be!!!)
// The size of the ACL is always returned by the method
// if outMapPtr is NOT-NULL, then AU should copy into this pointer (outMapPtr) the current ACL that it has in use. 
// the AU should also return whether the property is writable (that is the client can provide any arbitrary ACL that the audio unit will then honour)
// or if the property is read only - which is the generally preferred mode.
// If the AU doesn't require an AudioChannelLayout, then just return 0.
UInt32		AUIOElement::GetAudioChannelLayout (AudioChannelLayout	*outMapPtr, 
												Boolean				&outWritable)
{
	return 0;
}

// the incoming channel map will be at least as big as a basic AudioChannelLayout
// but its contents will determine its actual size
// Subclass should overide if channel map is writable
OSStatus	AUIOElement::SetAudioChannelLayout (const AudioChannelLayout &inData)
{
	return kAudioUnitErr_InvalidProperty;
}

// Some units support optional usage of channel maps - typically converter units
// that can do channel remapping between different maps. In that optional case
// the user should be able to remove a channel map if that is possible.
// Typically this is NOT the case (e.g., the 3DMixer even in the stereo case
// needs to know if it is rendering to speakers or headphones)
OSStatus	AUIOElement::RemoveAudioChannelLayout ()
{
	return kAudioUnitErr_InvalidPropertyValue;
}


//_____________________________________________________________________________
//
AUScope::~AUScope()
{
	for (ElementVector::iterator it = mElements.begin(); it != mElements.end(); ++it)
		delete *it;
}

//_____________________________________________________________________________
//
void	AUScope::SetNumberOfElements(UInt32 numElements)
{
	if (mDelegate)
		return mDelegate->SetNumberOfElements(numElements);

	if (numElements > mElements.size()) {
		mElements.reserve(numElements);
		while (numElements > mElements.size()) {
			AUElement *elem = mCreator->CreateElement(GetScope(), static_cast<UInt32>(mElements.size()));
			mElements.push_back(elem);
		}
	} else
		while (numElements < mElements.size()) {
			AUElement *elem = mElements.back();
			mElements.pop_back();
			delete elem;
		}
}

//_____________________________________________________________________________
//
bool	AUScope::HasElementWithName () const
{
	for (UInt32 i = 0; i < GetNumberOfElements(); ++i) {
		AUElement *	el = const_cast<AUScope*>(this)->GetElement (i);
		if (el && el->HasName()) {
			return true;
		}
	}
	return false;
}

//_____________________________________________________________________________
//

void	AUScope::AddElementNamesToDict (CFMutableDictionaryRef & inNameDict)
{
	if (HasElementWithName())
	{
		static char string[32];
		CFMutableDictionaryRef elementDict = CFDictionaryCreateMutable	(NULL, 0,
								&kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CFStringRef str;
		for (UInt32 i = 0; i < GetNumberOfElements(); ++i) {
			AUElement *	el = GetElement (i);
			if (el && el->HasName()) {
				snprintf (string, sizeof(string), "%d", int(i));
				str = CFStringCreateWithCString (NULL, string, kCFStringEncodingASCII);
				CFDictionarySetValue (elementDict, str, el->GetName());
				CFRelease (str);
			}
		}

		snprintf (string, sizeof(string), "%d", int(mScope));
		str = CFStringCreateWithCString (NULL, string, kCFStringEncodingASCII);
		CFDictionarySetValue (inNameDict, str, elementDict);
		CFRelease (str);
		CFRelease (elementDict);
	}
}

//_____________________________________________________________________________
//
bool	AUScope::RestoreElementNames (CFDictionaryRef& inNameDict)
{
	static char string[32];

	//first we have to see if we have enough elements
	bool didAddElements = false;
	unsigned int maxElNum = GetNumberOfElements();
	
	int dictSize = static_cast<int>(CFDictionaryGetCount(inNameDict));
	CFStringRef * keys = (CFStringRef*)CA_malloc (dictSize * sizeof (CFStringRef));
	CFDictionaryGetKeysAndValues (inNameDict, reinterpret_cast<const void**>(keys), NULL);
	for (int i = 0; i < dictSize; i++)
	{
		unsigned int intKey = 0;
		CFStringGetCString (keys[i], string, 32, kCFStringEncodingASCII);
		int result = sscanf (string, "%u", &intKey);
        // check if sscanf succeeded and element index is less than max elements.
		if (result && UInt32(intKey) < maxElNum)
        {
            CFStringRef elName = reinterpret_cast<CFStringRef>(CFDictionaryGetValue (inNameDict,  keys[i]));
            AUElement* element = GetElement (intKey);
            if (element)
                element->SetName (elName);
        }
	}
	free (keys);
	
	return didAddElements;
}

void    AUScope::SaveState(CFMutableDataRef data)
{
    AudioUnitElement nElems = GetNumberOfElements();
    for (AudioUnitElement ielem = 0; ielem < nElems; ++ielem) {
        AUElement *element = GetElement(ielem);
        UInt32 nparams = element->GetNumberOfParameters();
        if (nparams > 0) {
            struct {
                UInt32	scope;
                UInt32	element;
            } hdr;
            
            hdr.scope = CFSwapInt32HostToBig(GetScope());
            hdr.element = CFSwapInt32HostToBig(ielem);
            CFDataAppendBytes(data, (UInt8 *)&hdr, sizeof(hdr));
            
            element->SaveState(mScope, data);
        }
    }
}

const UInt8 *	AUScope::RestoreState(const UInt8 *state)
{
    const UInt8 *p = state;
    UInt32 elementIdx = CFSwapInt32BigToHost(*(UInt32 *)p);	p += sizeof(UInt32);
    AUElement *element = GetElement(elementIdx);
    if (!element) {
        struct {
            AudioUnitParameterID		paramID;
            AudioUnitParameterValue		value;
        } entry;
        UInt32 nparams = CFSwapInt32BigToHost(*(UInt32 *)p);
        p += sizeof(UInt32);
        
        p += nparams * sizeof(entry);
    } else
        p = element->RestoreState(p);
    
    return p;
}

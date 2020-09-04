// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKDSPBase.hpp"
#import "ParameterRamper.hpp"
#import <map>
#import <string>

AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP)
{
    return pDSP->internalRenderBlock();
}

size_t inputBusCountDSP(AKDSPRef pDSP)
{
    return pDSP->inputBufferLists.size();
}

size_t outputBusCountDSP(AKDSPRef pDSP)
{
    return 1; // We don't currently support multiple output busses.
}

bool canProcessInPlaceDSP(AKDSPRef pDSP)
{
    return pDSP->canProcessInPlace();
}

void setBufferDSP(AKDSPRef pDSP, AVAudioPCMBuffer* buffer, size_t busIndex)
{
    pDSP->setBuffer(buffer, busIndex);
}

void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format)
{
    pDSP->init(format.channelCount, format.sampleRate);
}

void deallocateRenderResourcesDSP(AKDSPRef pDSP)
{
    pDSP->deinit();
}

void resetDSP(AKDSPRef pDSP)
{
    pDSP->reset();
}

void setParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value)
{
    pDSP->setParameter(address, value, false);
}

AUValue getParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address)
{
    return pDSP->getParameter(address);
}

void startDSP(AKDSPRef pDSP)
{
    pDSP->start();
}

void stopDSP(AKDSPRef pDSP)
{
    pDSP->stop();
}

void triggerDSP(AKDSPRef pDSP)
{
    pDSP->trigger();
}

void triggerFrequencyDSP(AKDSPRef pDSP, AUValue frequency, AUValue amplitude)
{
    pDSP->triggerFrequencyAmplitude(frequency, amplitude);
}

void setWavetableDSP(AKDSPRef pDSP, const float* table, size_t length, int index)
{
    pDSP->setWavetable(table, length, index);
}

void deleteDSP(AKDSPRef pDSP)
{
    delete pDSP;
}

AKDSPBase::AKDSPBase(int inputBusCount)
: channelCount(2)   // best guess
, sampleRate(44100) // best guess
, inputBufferLists(inputBusCount)
{
    std::fill(parameters, parameters+maxParameters, nullptr);
}

void AKDSPBase::setBuffer(const AVAudioPCMBuffer* buffer, size_t busIndex)
{
    if (internalBuffers.size() <= busIndex) internalBuffers.resize(busIndex + 1);
    internalBuffers[busIndex] = buffer;
}

AUInternalRenderBlock AKDSPBase::internalRenderBlock()
{
    return ^AUAudioUnitStatus(
        AudioUnitRenderActionFlags *actionFlags,
        const AudioTimeStamp       *timestamp,
        AUAudioFrameCount           frameCount,
        NSInteger                   outputBusNumber,
        AudioBufferList            *outputData,
        const AURenderEvent        *realtimeEventListHead,
        AURenderPullInputBlock      pullInputBlock)
    {

        assert( (outputBusNumber == 0) && "We don't yet support multiple output busses" );

        if (pullInputBlock) {
            if (bCanProcessInPlace && inputBufferLists.size() == 1) {
                // pull input directly to output buffer
                inputBufferLists[0] = outputData;
                AudioUnitRenderActionFlags inputFlags = 0;
                pullInputBlock(&inputFlags, timestamp, frameCount, 0, inputBufferLists[0]);
            }
            else {
                // pull input to internal buffer
                for (size_t i = 0; i < inputBufferLists.size(); i++) {
                    inputBufferLists[i] = internalBuffers[i].mutableAudioBufferList;
                    
                    UInt32 byteSize = frameCount * sizeof(float);
                    inputBufferLists[i]->mNumberBuffers = internalBuffers[i].audioBufferList->mNumberBuffers;
                    for (UInt32 ch = 0; ch < inputBufferLists[i]->mNumberBuffers; ch++) {
                        inputBufferLists[i]->mBuffers[ch].mDataByteSize = byteSize;
                        inputBufferLists[i]->mBuffers[ch].mNumberChannels = internalBuffers[i].audioBufferList->mBuffers[ch].mNumberChannels;
                        inputBufferLists[i]->mBuffers[ch].mData = internalBuffers[i].audioBufferList->mBuffers[ch].mData;
                    }
                    
                    AudioUnitRenderActionFlags inputFlags = 0;
                    pullInputBlock(&inputFlags, timestamp, frameCount, i, inputBufferLists[i]);
                }
            }
        }
        
        outputBufferList = outputData;
        
        processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

void AKDSPBase::setParameter(AUParameterAddress address, float value, bool immediate)
{
    assert(address < maxParameters);
    if(auto parameter = parameters[address]) {
        if (immediate || !isInitialized) {
            parameter->setImmediate(value);
        }
        else {
            parameter->setUIValue(value);
        }
    }
}

float AKDSPBase::getParameter(AUParameterAddress address)
{
    assert(address < maxParameters);
    if(auto parameter = parameters[address]) {
        return parameter->getUIValue();
    }
    return 0.0f;
}

void AKDSPBase::init(int channelCount, double sampleRate)
{
    this->channelCount = channelCount;
    this->sampleRate = sampleRate;
    isInitialized = true;
    
    // update parameter ramp durations with new sample rate
    for(int index = 0; index < maxParameters; ++index) {
        if(parameters[index]) {
            parameters[index]->init(sampleRate);
        }
    }
}

void AKDSPBase::deinit()
{
    isInitialized = false;
}

void AKDSPBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                                  AURenderEvent const *events)
{
    now = timestamp->mSampleTime;

    // Chceck for parameter updates from the UI.
    for(int index = 0; index < maxParameters; ++index) {
        if(parameters[index]) {
            parameters[index]->dezipperCheck();
        } else {
            break;
        }
    }

    AUAudioFrameCount framesRemaining = frameCount;
    AURenderEvent const *event = events;

    while (framesRemaining > 0) {
        // If there are no more events, we can process the entire remaining segment and exit.
        if (event == nullptr) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesRemaining, bufferOffset);
            return;
        }

        // start late events late.
        auto timeZero = AUEventSampleTime(0);
        auto headEventTime = event->head.eventSampleTime;
        AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));

        // Compute everything before the next event.
        if (framesThisSegment > 0) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesThisSegment, bufferOffset);

            // Advance frames.
            framesRemaining -= framesThisSegment;
            // Advance time.
            now += framesThisSegment;
        }
        performAllSimultaneousEvents(now, event);
    }
    
}

/** From Apple Example code */
void AKDSPBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event)
{
    do {
        handleOneEvent(event);
        event = event->head.next;

        // While event is not null and is simultaneous (or late).
    } while (event && event->head.eventSampleTime <= now);
}

/** From Apple Example code */
void AKDSPBase::handleOneEvent(AURenderEvent const *event)
{
    switch (event->head.eventType) {
        case AURenderEventParameter:
        case AURenderEventParameterRamp: {
            startRamp(event->parameter);
            break;
        }
        case AURenderEventMIDI:
            handleMIDIEvent(event->MIDI);
            break;
        default:
            break;
    }
}

void AKDSPBase::startRamp(const AUParameterEvent& event)
{
    auto address = event.parameterAddress;
    assert(address < maxParameters);
    auto ramper = parameters[address];
    if(ramper == nullptr) return;
    ramper->startRamp(event.value, event.rampDurationSampleFrames);
}

using DSPFactoryMap = std::map<std::string, AKDSPBase::CreateFunction>;

// A registry of creation functions.
//
// Note that this is a pointer because we can't guarantee the
// order of initialization code. So we lazily init.
static DSPFactoryMap* factoryMap = nullptr;

void AKDSPBase::addCreateFunction(const char* name, CreateFunction func) {

    if(factoryMap == nullptr) {
        factoryMap = new DSPFactoryMap;
    }

    (*factoryMap)[std::string(name)] = func;
}

AKDSPRef AKDSPBase::create(const char* name) {

    assert(factoryMap && "Fatal error: node factory not initialized.");

    auto iter = factoryMap->find(name);

    if(iter == factoryMap->end()) {
        printf("Unknown AKDSPBase subclass: %s\n", name);
        return nullptr;
    }

    return iter->second();

}

AKDSPRef akCreateDSP(const char* name) {
    return AKDSPBase::create(name);
}

using DSPParameterMap = std::map< std::string, AUParameterAddress >;

static DSPParameterMap* paramMap = nullptr;

AUParameterAddress akGetParameterAddress(const char* name) {

    assert(paramMap && "akGetParameterAddress: Fatal error: parameter map not initialized.");

    auto iter = paramMap->find(name);

    if(iter == paramMap->end()) {
        printf("akGetParameterAddress: Unknown parameter name: %s\n", name);
        return 0;
    }

    return iter->second;
}

void AKDSPBase::addParameter(const char* name, AUParameterAddress address) {

    if(paramMap == nullptr) {
        paramMap = new DSPParameterMap;
    }

    assert(paramMap->count(name) == 0 && "Parameter already registered.");

    (*paramMap)[name] = address;

}

void akSetSeed(unsigned int seed) {
    srand(seed);
}

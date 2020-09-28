// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "DSPBase.h"
#import "ParameterRamper.h"
#import <map>
#import <string>

AUInternalRenderBlock internalRenderBlockDSP(DSPRef pDSP)
{
    return pDSP->internalRenderBlock();
}

size_t inputBusCountDSP(DSPRef pDSP)
{
    return pDSP->inputBufferLists.size();
}

size_t outputBusCountDSP(DSPRef pDSP)
{
    return 1; // We don't currently support multiple output busses.
}

bool canProcessInPlaceDSP(DSPRef pDSP)
{
    return pDSP->canProcessInPlace();
}

void setBufferDSP(DSPRef pDSP, AVAudioPCMBuffer* buffer, size_t busIndex)
{
    pDSP->setBuffer(buffer, busIndex);
}

void allocateRenderResourcesDSP(DSPRef pDSP, AVAudioFormat* format)
{
    pDSP->init(format.channelCount, format.sampleRate);
}

void deallocateRenderResourcesDSP(DSPRef pDSP)
{
    pDSP->deinit();
}

void resetDSP(DSPRef pDSP)
{
    pDSP->reset();
}

void setParameterValueDSP(DSPRef pDSP, AUParameterAddress address, AUValue value)
{
    pDSP->setParameter(address, value, false);
}

AUValue getParameterValueDSP(DSPRef pDSP, AUParameterAddress address)
{
    return pDSP->getParameter(address);
}

void startDSP(DSPRef pDSP)
{
    pDSP->start();
}

void stopDSP(DSPRef pDSP)
{
    pDSP->stop();
}

void triggerDSP(DSPRef pDSP)
{
    pDSP->trigger();
}

void triggerFrequencyDSP(DSPRef pDSP, AUValue frequency, AUValue amplitude)
{
    pDSP->triggerFrequencyAmplitude(frequency, amplitude);
}

void setWavetableDSP(DSPRef pDSP, const float* table, size_t length, int index)
{
    pDSP->setWavetable(table, length, index);
}

void deleteDSP(DSPRef pDSP)
{
    delete pDSP;
}

DSPBase::DSPBase(int inputBusCount)
: channelCount(2)   // best guess
, sampleRate(44100) // best guess
, inputBufferLists(inputBusCount)
{
    std::fill(parameters, parameters+maxParameters, nullptr);

    TPCircularBufferInit(&leftBuffer, 4096 * sizeof(float));
    TPCircularBufferInit(&rightBuffer, 4096 * sizeof(float));
}

void DSPBase::setBuffer(const AVAudioPCMBuffer* buffer, size_t busIndex)
{
    if (internalBuffers.size() <= busIndex) internalBuffers.resize(busIndex + 1);
    internalBuffers[busIndex] = buffer;
}

AUInternalRenderBlock DSPBase::internalRenderBlock()
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

void DSPBase::setParameter(AUParameterAddress address, float value, bool immediate)
{
    assert(address < maxParameters);
    if(auto parameter = parameters[address]) {
        if (immediate || !isInitialized) {
            parameter->startRamp(value, 0);
        }
        else {
            parameter->setUIValue(value);
        }
    }
}

float DSPBase::getParameter(AUParameterAddress address)
{
    assert(address < maxParameters);
    if(auto parameter = parameters[address]) {
        return parameter->getUIValue();
    }
    return 0.0f;
}

void DSPBase::init(int channelCount, double sampleRate)
{
    this->channelCount = channelCount;
    this->sampleRate = sampleRate;
    isInitialized = true;
}

void DSPBase::deinit()
{
    isInitialized = false;
}
DSPBase::~DSPBase()
{
    TPCircularBufferCleanup(&leftBuffer);
    TPCircularBufferCleanup(&rightBuffer);
}

void DSPBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                                  AURenderEvent const *events)
{
    now = timestamp->mSampleTime;

    // Chceck for parameter updates from the UI.
    for(int index = 0; index < maxParameters; ++index) {
        if(parameters[index]) {
            parameters[index]->dezipperCheck(sampleRate * 0.02f);
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
            break;
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
    if (tapCount > 0) {
        TPCircularBufferProduceBytes(&leftBuffer,  outputBufferList->mBuffers[0].mData, frameCount * sizeof(float));
        TPCircularBufferProduceBytes(&rightBuffer, outputBufferList->mBuffers[1].mData, frameCount * sizeof(float));
    }
}

/** From Apple Example code */
void DSPBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event)
{
    do {
        handleOneEvent(event);
        event = event->head.next;

        // While event is not null and is simultaneous (or late).
    } while (event && event->head.eventSampleTime <= now);
}

/** From Apple Example code */
void DSPBase::handleOneEvent(AURenderEvent const *event)
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

void DSPBase::startRamp(const AUParameterEvent& event)
{
    auto address = event.parameterAddress;
    assert(address < maxParameters);
    auto ramper = parameters[address];
    if(ramper == nullptr) return;
    ramper->startRamp(event.value, event.rampDurationSampleFrames);
}

using DSPFactoryMap = std::map<std::string, DSPBase::CreateFunction>;

// A registry of creation functions.
//
// Note that this is a pointer because we can't guarantee the
// order of initialization code. So we lazily init.
static DSPFactoryMap* factoryMap = nullptr;

void DSPBase::addCreateFunction(const char* name, CreateFunction func) {

    if(factoryMap == nullptr) {
        factoryMap = new DSPFactoryMap;
    }

    (*factoryMap)[std::string(name)] = func;
}

DSPRef DSPBase::create(const char* name) {

    assert(factoryMap && "Fatal error: node factory not initialized.");

    auto iter = factoryMap->find(name);

    if(iter == factoryMap->end()) {
        printf("Unknown DSPBase subclass: %s\n", name);
        return nullptr;
    }

    return iter->second();

}

DSPRef akCreateDSP(const char* name) {
    return DSPBase::create(name);
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

void DSPBase::addParameter(const char* name, AUParameterAddress address) {

    if(paramMap == nullptr) {
        paramMap = new DSPParameterMap;
    }

    assert(paramMap->count(name) == 0 && "Parameter already registered.");

    (*paramMap)[name] = address;

}

void DSPBase::installTap() {
    tapCount++;
}

void DSPBase::removeTap() {
    if (tapCount > 0) { tapCount--; }
}

bool DSPBase::getTapData(size_t frames, float* leftData, float* rightData) {
    // Consume bytes and return arrays

    int availableBytes = 0;
    float *data = (float*) TPCircularBufferTail(&leftBuffer, &availableBytes);
    int n = availableBytes / sizeof(float);
    if (n < frames) { return false; }
    for(int i = 0; i < frames; i++) {
        leftData[i] = data[i];
    }

    data = (float*) TPCircularBufferTail(&rightBuffer, &availableBytes);
    n = availableBytes / sizeof(float);
    if (n < frames) { return false; }
    for(int i = 0; i < frames; i++) {
        rightData[i] = data[i];
    }

    filledTapCount++;

    if (filledTapCount >= tapCount) {
        TPCircularBufferConsume(&leftBuffer, frames * sizeof(float));
        TPCircularBufferConsume(&rightBuffer, frames * sizeof(float));
        filledTapCount = 0;
    }

    return true;
}

void akSetSeed(unsigned int seed) {
    srand(seed);
}

AK_API void akInstallTap(DSPRef dspRef) {
    auto dsp = dynamic_cast<DSPBase *>(dspRef);
    assert(dsp);
    dsp->installTap();
}
AK_API void akRemoveTap(DSPRef dspRef) {
    auto dsp = dynamic_cast<DSPBase *>(dspRef);
    assert(dsp);
    dsp->removeTap();
}
AK_API bool akGetTapData(DSPRef dspRef, size_t frames, float* leftData, float* rightData) {
    auto dsp = dynamic_cast<DSPBase *>(dspRef);
    assert(dsp);
    return dsp->getTapData(frames, leftData, rightData);
}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef AKSoulDSP_hpp
#define AKSoulDSP_hpp

#import "AKDSPBase.hpp"

template<typename SoulPatchType>
class AKSoulDSP : public AKDSPBase {

public:
    SoulPatchType patch;
    
    using MIDIMessage = typename SoulPatchType::MIDIMessage;
    using ParameterProperties = typename SoulPatchType::ParameterProperties;
    
    std::vector<MIDIMessage> midiMessages;
    std::vector<ParameterProperties> properties;
    
    AKSoulDSP() {
        // Reserve space for MIDI messages so we don't have to allocate.
        midiMessages.reserve(1024);
        properties = patch.getParameterProperties();
    }
    
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        if(address < properties.size()) {
            properties[address].setValue(value);
        }
    }
    
    void init(int channelCount, double sampleRate) override {
        // I'm not sure what sessionID is for.
        patch.init(sampleRate, /*sessionID*/ 0);
        
        // init will clear the properties, so set them back to their value
        for(auto& property : properties) {
            property.setValue(property.currentValue);
        }
    }
    
    void reset() override {
        patch.reset();
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        MIDIMessage message;
        message.frameIndex = 0;
        message.byte0 = midiEvent.data[0];
        message.byte1 = midiEvent.data[1];
        message.byte2 = midiEvent.data[2];
        midiMessages.push_back(message);
    }

    void startRamp(const AUParameterEvent &event) override {
        auto address = event.parameterAddress;
        if(address < properties.size()) {
            properties[address].setValue(event.value);
        }
    }
    
    // Need to override this since it's pure virtual.
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        // Zero output channels.
        for(int channel=0; channel<channelCount; ++channel) {
            float* outputChannel = ((float *)outputBufferList->mBuffers[channel].mData) + bufferOffset;
            std::fill(outputChannel, outputChannel+frameCount, 0.0f);
        }
        
        typename SoulPatchType::template RenderContext<float> context;
        
        context.numFrames = frameCount;
        context.inputChannels[0] = ((const float *)inputBufferLists[0]->mBuffers[0].mData) + bufferOffset;
        context.outputChannels[0] = ((float *)outputBufferList->mBuffers[0].mData) + bufferOffset;
        context.incomingMIDI.messages = midiMessages.data();
        context.incomingMIDI.numMessages = (uint32_t) midiMessages.size();
        
        patch.render(context);
        
        midiMessages.clear();
        
    }
    
};

#endif /* AKSoulDSP_hpp */

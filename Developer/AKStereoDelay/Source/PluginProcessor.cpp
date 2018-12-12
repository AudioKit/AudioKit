#include "PluginProcessor.h"
#include "PluginEditor.h"

PingPongDelayAudioProcessor::PingPongDelayAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
    : AudioProcessor(BusesProperties()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
        .withInput("Input", AudioChannelSet::stereo(), true)
#endif
        .withOutput("Output", AudioChannelSet::stereo(), true)
#endif
    )
#endif
    , paramTree(*this, nullptr, "PARAMETERS", {
            std::make_unique<AudioParameterBool>("pingpong", "Ping-Pong", false),
            std::make_unique<AudioParameterFloat>("delaySec", "DelaySec", 0.0f, 2.0f, 0.5f),
            std::make_unique<AudioParameterFloat>("feedback", "Feedback", 0.0f, 1.0f, 0.0f),
            std::make_unique<AudioParameterFloat>("fxLevel", "Effect Level", 0.0f, 1.0f, 0.8f),
        })
{
    paramTree.addParameterListener("pingpong", this);
    paramTree.addParameterListener("delaySec", this);
    paramTree.addParameterListener("feedback", this);
    paramTree.addParameterListener("fxLevel", this);
}

PingPongDelayAudioProcessor::~PingPongDelayAudioProcessor()
{
}

void PingPongDelayAudioProcessor::parameterChanged(const String& parameterID, float newValue)
{
    if (parameterID == "pingpong")
    {
        delay.setPingPongMode(newValue > 0.5f);
    }
    else if (parameterID == "delaySec")
    {
        delay.setDelayMs(1000.0f * newValue);
    }
    else if (parameterID == "feedback")
    {
        delay.setFeedback(newValue);
    }
    else if (parameterID == "fxLevel")
    {
        delay.setEffectLevel(newValue);
    }
}

const String PingPongDelayAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool PingPongDelayAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool PingPongDelayAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool PingPongDelayAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double PingPongDelayAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int PingPongDelayAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int PingPongDelayAudioProcessor::getCurrentProgram()
{
    return 0;
}

void PingPongDelayAudioProcessor::setCurrentProgram (int /*index*/)
{
}

const String PingPongDelayAudioProcessor::getProgramName (int /*index*/)
{
    return {};
}

void PingPongDelayAudioProcessor::changeProgramName (int /*index*/, const String& /*newName*/)
{
}

void PingPongDelayAudioProcessor::prepareToPlay (double sampleRate, int /*samplesPerBlock*/)
{
    bool pingPong = *paramTree.getRawParameterValue("pingpong") > 0.5f;
    float delayTimeSeconds = *paramTree.getRawParameterValue("delaySec");
    float feedbackFraction = *paramTree.getRawParameterValue("feedback");
    float effectLevelFraction = *paramTree.getRawParameterValue("fxLevel");

    DBG("prepareToPlay: pingPong is " + String(pingPong ? "TRUE" : "FALSE"));

    delay.init(sampleRate, 2000.0);
    delay.setPingPongMode(pingPong);
    delay.setDelayMs(float(1000.0 * delayTimeSeconds));
    delay.setFeedback(feedbackFraction);
    delay.setEffectLevel(effectLevelFraction);
}

void PingPongDelayAudioProcessor::releaseResources()
{
    delay.deinit();
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool PingPongDelayAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    ignoreUnused (layouts);
    return true;
  #else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    if (layouts.getMainOutputChannelSet() != AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void PingPongDelayAudioProcessor::processBlock (AudioBuffer<float>& buffer, MidiBuffer& /*midiMessages*/)
{
    ScopedNoDenormals noDenormals;

    const float *inBuffers[2] = { buffer.getReadPointer(0), buffer.getReadPointer(1) };
    float* outBuffers[2] = { buffer.getWritePointer(0), buffer.getWritePointer(1) };

    delay.render(buffer.getNumSamples(), inBuffers, outBuffers);
}

bool PingPongDelayAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

AudioProcessorEditor* PingPongDelayAudioProcessor::createEditor()
{
    return new PingPongDelayAudioProcessorEditor (*this);
}

void PingPongDelayAudioProcessor::getStateInformation (MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
    destData.setSize(1);    // make VstHost happy
}

void PingPongDelayAudioProcessor::setStateInformation (const void* /*data*/, int /*sizeInBytes*/)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new PingPongDelayAudioProcessor();
}

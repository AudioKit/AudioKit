/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class PingPongDelayAudioProcessorEditor  : public AudioProcessorEditor
{
public:
    PingPongDelayAudioProcessorEditor (PingPongDelayAudioProcessor&);
    ~PingPongDelayAudioProcessorEditor();

    //==============================================================================
    void paint (Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    PingPongDelayAudioProcessor& processor;

    ComboBox modeCombo;
    Slider delaySecSlider, feedbackSlider, fxLevelSlider;
    Label modeLabel, delaySecLabel, feedbackLabel, fxLevelLabel;

    ScopedPointer<AudioProcessorValueTreeState::ComboBoxAttachment> modeAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> delaySecAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> feedbackAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> fxLevelAttachment;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PingPongDelayAudioProcessorEditor)
};

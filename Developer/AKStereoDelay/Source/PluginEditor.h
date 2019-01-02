/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include "JuceHeader.h"
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class AKStereoDelayProcessorEditor  : public AudioProcessorEditor
{
public:
    AKStereoDelayProcessorEditor (AKStereoDelayProcessor&);
    ~AKStereoDelayProcessorEditor();

    //==============================================================================
    void paint (Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    AKStereoDelayProcessor& processor;

    ComboBox modeCombo;
    Slider delaySecSlider, feedbackSlider, dryWetMixSlider;
    Label modeLabel, delaySecLabel, feedbackLabel, dryWetMixLabel;

    ScopedPointer<AudioProcessorValueTreeState::ComboBoxAttachment> modeAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> delaySecAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> feedbackAttachment;
    ScopedPointer<AudioProcessorValueTreeState::SliderAttachment> dryWetMixAttachment;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (AKStereoDelayProcessorEditor)
};

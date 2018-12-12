/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
PingPongDelayAudioProcessorEditor::PingPongDelayAudioProcessorEditor (PingPongDelayAudioProcessor& p)
    : AudioProcessorEditor (&p), processor (p)
{
    modeCombo.addItem("Stereo", 1);
    modeCombo.addItem("Ping-Pong", 2);
    addAndMakeVisible(&modeCombo);
    modeAttachment = new AudioProcessorValueTreeState::ComboBoxAttachment(processor.paramTree, "pingpong", modeCombo);

    delaySecSlider.setSliderStyle(Slider::SliderStyle::LinearHorizontal);
    delaySecSlider.setRange(0.0, 2.0);
    delaySecSlider.setValue(0.5f);
    delaySecSlider.setTextBoxStyle(Slider::NoTextBox, false, 0, 0);
    addAndMakeVisible(&delaySecSlider);
    delaySecAttachment = new AudioProcessorValueTreeState::SliderAttachment(processor.paramTree, "delaySec", delaySecSlider);

    feedbackSlider.setSliderStyle(Slider::SliderStyle::LinearHorizontal);
    feedbackSlider.setRange(0.0, 1.0);
    feedbackSlider.setValue(0.0f);
    feedbackSlider.setTextBoxStyle(Slider::NoTextBox, false, 0, 0);
    addAndMakeVisible(&feedbackSlider);
    feedbackAttachment = new AudioProcessorValueTreeState::SliderAttachment(processor.paramTree, "feedback", feedbackSlider);

    fxLevelSlider.setSliderStyle(Slider::SliderStyle::LinearHorizontal);
    fxLevelSlider.setRange(0.0, 1.0);
    fxLevelSlider.setValue(0.8f);
    fxLevelSlider.setTextBoxStyle(Slider::NoTextBox, false, 0, 0);
    addAndMakeVisible(&fxLevelSlider);
    fxLevelAttachment = new AudioProcessorValueTreeState::SliderAttachment(processor.paramTree, "fxLevel", fxLevelSlider);

    modeLabel.setText("Mode", NotificationType::dontSendNotification);
    modeLabel.setJustificationType(Justification::right);
    addAndMakeVisible(modeLabel);

    delaySecLabel.setText("Delay Time", NotificationType::dontSendNotification);
    delaySecLabel.setJustificationType(Justification::right);
    addAndMakeVisible(delaySecLabel);

    feedbackLabel.setText("Feedback", NotificationType::dontSendNotification);
    feedbackLabel.setJustificationType(Justification::right);
    addAndMakeVisible(feedbackLabel);

    fxLevelLabel.setText("Effect Level", NotificationType::dontSendNotification);
    fxLevelLabel.setJustificationType(Justification::right);
    addAndMakeVisible(fxLevelLabel);

    setSize (400, 300);
}

PingPongDelayAudioProcessorEditor::~PingPongDelayAudioProcessorEditor()
{
}

//==============================================================================
void PingPongDelayAudioProcessorEditor::paint (Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));
}

void PingPongDelayAudioProcessorEditor::resized()
{
    auto bounds = getLocalBounds().reduced(20);
    auto row = bounds.removeFromTop(40);
    modeLabel.setBounds(row.removeFromLeft(100)); row.removeFromLeft(10);
    modeCombo.setBounds(row);
    bounds.removeFromTop(10);
    row = bounds.removeFromTop(40);
    delaySecLabel.setBounds(row.removeFromLeft(100)); row.removeFromLeft(10);
    delaySecSlider.setBounds(row);
    row = bounds.removeFromTop(40);
    feedbackLabel.setBounds(row.removeFromLeft(100)); row.removeFromLeft(10);
    feedbackSlider.setBounds(row);
    row = bounds.removeFromTop(40);
    fxLevelLabel.setBounds(row.removeFromLeft(100)); row.removeFromLeft(10);
    fxLevelSlider.setBounds(row);
}

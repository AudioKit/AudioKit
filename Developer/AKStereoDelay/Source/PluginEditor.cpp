#include "PluginProcessor.h"
#include "PluginEditor.h"

AKStereoDelayProcessorEditor::AKStereoDelayProcessorEditor (AKStereoDelayProcessor& p)
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

    dryWetMixSlider.setSliderStyle(Slider::SliderStyle::LinearHorizontal);
    dryWetMixSlider.setRange(0.0, 1.0);
    dryWetMixSlider.setValue(0.5f);
    dryWetMixSlider.setTextBoxStyle(Slider::NoTextBox, false, 0, 0);
    addAndMakeVisible(&dryWetMixSlider);
    dryWetMixAttachment = new AudioProcessorValueTreeState::SliderAttachment(processor.paramTree, "dryWetMix", dryWetMixSlider);

    modeLabel.setText("Mode", NotificationType::dontSendNotification);
    modeLabel.setJustificationType(Justification::right);
    addAndMakeVisible(modeLabel);

    delaySecLabel.setText("Delay Time", NotificationType::dontSendNotification);
    delaySecLabel.setJustificationType(Justification::right);
    addAndMakeVisible(delaySecLabel);

    feedbackLabel.setText("Feedback", NotificationType::dontSendNotification);
    feedbackLabel.setJustificationType(Justification::right);
    addAndMakeVisible(feedbackLabel);

    dryWetMixLabel.setText("Dry/Wet Mix", NotificationType::dontSendNotification);
    dryWetMixLabel.setJustificationType(Justification::right);
    addAndMakeVisible(dryWetMixLabel);

    setSize (400, 300);
}

AKStereoDelayProcessorEditor::~AKStereoDelayProcessorEditor()
{
}

//==============================================================================
void AKStereoDelayProcessorEditor::paint (Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));
}

void AKStereoDelayProcessorEditor::resized()
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
    dryWetMixLabel.setBounds(row.removeFromLeft(100)); row.removeFromLeft(10);
    dryWetMixSlider.setBounds(row);
}

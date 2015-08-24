//
//  AKPlayground.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#pragma clang diagnostic ignored "-Warc-retain-cycles"

#import <UIKit/UIKit.h>
#import <KZPlayground/KZPPlayground.h>
#import <KZPTimelineViewController.h>

#import "AKFoundation.h"

@interface AKPlayground : KZPPlayground
{
    KZPTimelineViewController *timelineViewController;
}

/// Add a label to the timeline that denotes a section
/// @param title Title of the section
- (void)makeSection:(NSString *)title;

/// Add or hide/show a view on the right hand side of the playground
/// @param view View to add, hide, or show
- (void)toggleView:(UIView *)view;

/// Add a waveform representation of the audio input, usually the microphone
- (void)addAudioInputPlot;

/// Add a monophonic audio output plot
- (void)addAudioOutputPlot;

/// Add a stereo audio plot with the left channel on top and right on the bottom
- (void)addStereoOutputPlot;

/// Add a FFT of the audio input
- (void)addAudioInputFFTPlot;

/// Add a FFT of the audio output
- (void)addAudioOutputFFTPlot;

/// Add a plot of a given instrument property
/// @param property Instrument property to be plotted
/// @param label    Label to adhere to the plot and toggle switch
- (void)addPlotForInstrumentProperty:(AKInstrumentProperty *)property withLabel:(NSString *)label;

/// Add a plot of any floating point number
/// @param plot  An AKFloatPlot plot type
/// @param label Label to attach to the plot and toggle switch
- (void)addFloatPlot:(AKFloatPlot *)plot withLabel:(NSString *)label;

/// Add a table plot to the timeline
/// @param table Table to be plotted
- (void)addTablePlot:(AKTable *)table;

/// Add a plot of the input rolling waveform
- (void)addAudioInputRollingWaveformPlot;

/// Add a plot of the output rolling waveform
- (void)addAudioOutputRollingWaveformPlot;

/// Add a button to the timeline that executes the given code
/// @param title  Title of the button
/// @param aBlock Code to execute when the button is pressed
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())aBlock;

/// Add a slider to the timeline for a given property
/// @param property Instrument or note property to assign to the slider
/// @param title    Label for the slider group
- (void)addSliderForProperty:(id)property title:(NSString *)title;

/// Add a slider control for spawning recurring phrases
/// @param instrument   Instrument playing the phrase
/// @param phrase       Phrase to be played
/// @param minFrequency Lowest frequency to repeat the phrase at
/// @param maxFrequency Highest frequency to repeat the phrase at
- (void)addRepeatSliderForInstrument:(AKInstrument *)instrument
                              phrase:(AKPhrase *)phrase
                    minimumFrequency:(float)minFrequency
                    maximumFrequency:(float)maxFrequency;

@end

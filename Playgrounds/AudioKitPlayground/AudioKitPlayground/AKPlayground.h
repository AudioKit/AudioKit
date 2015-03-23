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
#import "AKStereoOutputPlot.h"
#import "AKAudioOutputPlot.h"
#import "AKAudioInputPlot.h"
#import "AKInstrumentPropertyPlot.h"
#import "AKFFTPlot.h"
#import "AKTablePlot.h"
#import "AKFloatPlot.h"
//#import "AKRollingWaveformView.h"

#define AKPlaygroundTablePlot(__table__)  KZPShow([[AKTablePlot alloc] initWithFrame:CGRectMake(0, 0, 500, 500) table:__table__]);

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@interface AKPlayground : KZPPlayground

@property NSMutableArray *views;
@property NSMutableArray *shownViews;

- (void)makeSection:(NSString *)title;
- (void)toggleView:(UIView *)view;

- (void)addAudioInputPlot;
- (void)addAudioOutputPlot;
- (void)addStereoOutputPlot;
- (void)addFFTPlot;
- (void)addPlotForInstrumentProperty:(AKInstrumentProperty *)property withLabel:(NSString *)label;
- (void)addFloatPlot:(AKFloatPlot *)plot withLabel:(NSString *)label;
//- (void)addRollingWaveformView;

- (void)addRepeatSliderForInstrument:(AKInstrument *)instrument
                              phrase:(AKPhrase *)phrase
                    minimumFrequency:(float)minFrequency
                    maximumFrequency:(float)maxFrequency;

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())aBlock;
- (void)addSliderForProperty:(id)property title:(NSString *)title;
@end

//
//  AKPlayground.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KZPlayground/KZPPlayground.h>

#import "AKFoundation.h"
#import "AKStereoOutputPlot.h"
#import "AKAudioOutputPlot.h"
#import "AKAudioInputPlot.h"
#import "AKInstrumentPropertyPlot.h"
#import "AKFFTPlot.h"
#import "AKTablePlot.h"
#import "AKFloatPlot.h"
//#import "AKRollingWaveformView.h"


#define AKPlaygroundPropertySlider(__name__, __property__) KZPAdjustValue(__name__, __property__.minimum, __property__.maximum).defaultValue(__property__.value); KZPAnimate(^{ __property__.value = __name__; });

#define AKPlaygroundSliderOverride(__name__, __property__, __value__, __min__, __max__) KZPAdjustValue(__name__, __min__, __max__).defaultValue(__value__); KZPAnimate(^{ __property__.value = __name__; });

#define AKPlaygroundButton(__label__, __block__) KZPAction(__label__, ^{ __block__ });

#define AKPlaygroundTablePlot(__table__)  KZPShow([[AKTablePlot alloc] initWithFrame:CGRectMake(0, 0, 500, 500) table:__table__]);

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@interface AKPlayground : KZPPlayground

@property NSMutableArray *views;
@property NSMutableArray *shownViews;

- (void)makeSection:(NSString *)title;
- (void)toggleView:(UIView *)view;

- (void)addAudioInputPlot;
- (void)addAudioOutputPlot;
- (void)addStereoAudioOutputPlot;
- (void)addFFTPlot;
- (void)addPlotForInstrumentProperty:(AKInstrumentProperty *)property withLabel:(NSString *)label;
- (void)addFloatPlot:(AKFloatPlot *)plot withLabel:(NSString *)label;
//- (void)addRollingWaveformView;

- (void)addRepeatSliderForInstrument:(AKInstrument *)instrument
                              phrase:(AKPhrase *)phrase
                    minimumFrequency:(float)minFrequency
                    maximumFrequency:(float)maxFrequency;

@end

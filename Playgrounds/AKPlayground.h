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
#import "AKAudioOutputAmplitudeView.h"
#import "AKAudioOutputSpectralView.h"
#import "AKAudioInputPlot.h"
#import "AKInstrumentPropertyView.h"
#import "AKFFTView.h"
#import "AKRollingWaveformView.h"
#import "AKTableView.h"

#import <EZAudio/EZAudio.h>
#import <Accelerate/Accelerate.h>

#define AKPlaygroundSlider(__name__, __property__) KZPAdjustValue(__name__, __property__.minimum, __property__.maximum).defaultValue(__property__.value); KZPAnimate(^{ __property__.value = __name__; });

#define AKPlaygroundSliderOverride(__name__, __property__, __value__, __min__, __max__) KZPAdjustValue(__name__, __min__, __max__).defaultValue(__value__); KZPAnimate(^{ __property__.value = __name__; });

#define AKPlaygroundButton(__label__, __block__) KZPAction(__label__, ^{ __block__ });

#define AKPlaygroundTablePlot(__table__)  KZPShow([[AKTablePlot alloc] initWithFrame:CGRectMake(0, 0, 500, 500) table:__table__]);

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@interface AKPlayground : KZPPlayground

@property NSMutableArray *views;
@property NSMutableArray *shownViews;

- (void)makeSection:(NSString *)title;
- (void)toggleView:(UIView *)view;

- (void)addAudioInputView;
- (void)addStereoAudioOutputPlot;
- (void)addFFTView;
- (void)addRollingWaveformView;

@end

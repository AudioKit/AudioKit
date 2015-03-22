//
//  AKPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlayground.h"

@implementation AKPlayground
{
    CsoundObj *cs;
    
    AKFFTPlot *fftPlot;
    AKStereoOutputPlot *stereoPlot;
    AKAudioOutputPlot *audioPlot;
    AKAudioInputPlot  *inputPlot;
//    AKAudioOutputAmplitudeView *audioOutputAmplitudeView;
//    AKRollingWaveformView *rollingWaveformView;
}

- (void)makeSection:(NSString *)title
{
    KZPShow(@" ");
    NSString *starredTitle = [NSString stringWithFormat:@"%@︎", title];
    KZPShow(starredTitle);
}

- (void)placeViews
{
    float fullWidth  = self.worksheetView.bounds.size.width;
    float fullHeight = self.worksheetView.bounds.size.height;
    NSUInteger shownCount = [_shownViews count];

    int i = 0;
    for (UIView *view in _views) {
        if ([_shownViews containsObject:view]) {
            [view setFrame:CGRectMake(0, 0, fullWidth, fullHeight/shownCount)];
            view.center = CGPointMake(self.worksheetView.center.x, self.worksheetView.center.y / shownCount * (2 * i + 1));
            [self.worksheetView addSubview:view];
            i++;
        } else {
            [view removeFromSuperview];
        }
    }
}

- (void)toggleView:(UIView *)view
{
    if (![_views containsObject:view]) [_views addObject:view];
    [_shownViews containsObject:view] ? [_shownViews removeObject:view] : [_shownViews addObject:view];
    [self placeViews];
}


- (void)addLabel:(NSString *)labelText toView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    label.text = labelText;
    [view addSubview:label];
}


- (void)addAudioInputPlot
{
    inputPlot = [[AKAudioInputPlot alloc] init];
    [inputPlot setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.502 alpha:1.000]];
    [cs addBinding:inputPlot];
    [self addLabel:@"Microphone" toView:inputPlot];
    [self toggleView:inputPlot];
    KZPAction(@"Microphone",   ^{ [self toggleView:inputPlot ]; });
}

- (void)addStereoAudioOutputPlot
{
    stereoPlot = [[AKStereoOutputPlot alloc] init];
    [stereoPlot setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:stereoPlot];
    [self addLabel:@"Stereo Output" toView:stereoPlot];
    [self toggleView:stereoPlot];
    KZPAction(@"Stereo Output", ^{ [self toggleView:stereoPlot]; });
}

- (void)addAudioOutputPlot
{
    audioPlot = [[AKAudioOutputPlot alloc] init];
    [audioPlot setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:audioPlot];
    [self addLabel:@"Audio Output" toView:audioPlot];
    [self toggleView:audioPlot];
    KZPAction(@"Audio Output", ^{ [self toggleView:audioPlot]; });
}

- (void)addPlotForInstrumentProperty:(AKInstrumentProperty *)property withLabel:(NSString *)label
{
    AKInstrumentPropertyPlot *plot = [[AKInstrumentPropertyPlot alloc] init];
    plot.property = property;
    [plot setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:plot];
    [self addLabel:label toView:plot];
    [self toggleView:plot];
    KZPAction(label, ^{ [self toggleView:plot]; });
}


- (void)addFloatPlot:(AKFloatPlot *)plot withLabel:(NSString *)label
{
    [self addLabel:label toView:plot];
    [self toggleView:plot];
    KZPAction(label, ^{ [self toggleView:plot]; });
}

- (void)addFFTPlot
{
    fftPlot = [[AKFFTPlot alloc] init];
    [fftPlot setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:fftPlot];
    [self addLabel:@"Audio Output FFT" toView:fftPlot];
    [self toggleView:fftPlot];
    KZPAction(@"Audio Output FFT", ^{ [self toggleView:fftPlot]; });
}

//- (void)addRollingWaveformView
//{
//    rollingWaveformView = [[AKRollingWaveformView alloc] init];
//    NSLog(@"setting to green");
//    [rollingWaveformView setBackgroundColor:[UIColor greenColor]];
//    [cs addBinding:rollingWaveformView];
//    [self toggleView:rollingWaveformView];
//    KZPAction(@"Rolling", ^{ [self toggleView:rollingWaveformView]; });
//}

- (void)addRepeatSliderForInstrument:(AKInstrument *)instrument
                              phrase:(AKPhrase *)phrase
                    minimumFrequency:(float)minFrequency
                    maximumFrequency:(float)maxFrequency
{
    KZPValueAdjustComponent *component = KZPAdjust(@"", minFrequency, maxFrequency, ^(float frequency) {
        [instrument stopPhrase];
        [instrument repeatPhrase:phrase duration:1.0/frequency];
    });
    [component.valueSlider setContinuous:NO];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())aBlock
{
    KZPAction(title, aBlock);
}

- (void)setup
{
    [AKOrchestra start];
    
    _views = [[NSMutableArray alloc] init];
    _shownViews = [[NSMutableArray alloc] init];
    
    AKManager *manager = [AKManager sharedManager];
    [manager enableAudioInput];
    cs = manager.engine;
}

- (void)run {
    [_views removeAllObjects];
    [_shownViews removeAllObjects];
    [self placeViews];
}


@end

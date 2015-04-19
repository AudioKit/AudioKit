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

    AKAudioInputFFTPlot *inputFFTPlot;
    AKAudioOutputFFTPlot *outputFFTPlot;
    AKStereoOutputPlot *stereoPlot;
    AKAudioOutputPlot *audioPlot;
    AKAudioInputPlot  *inputPlot;
    AKAudioInputRollingWaveformPlot *rollingInputPlot;
    AKAudioOutputRollingWaveformPlot *rollingOutputPlot;

    NSMutableArray *views;
    NSMutableArray *shownViews;

    KZPTimelineViewController *timelineViewController;
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
    NSUInteger shownCount = [shownViews count];

    int i = 0;
    for (UIView *view in views) {
        if ([shownViews containsObject:view]) {
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
    if (![views containsObject:view]) [views addObject:view];
    [shownViews containsObject:view] ? [shownViews removeObject:view] : [shownViews addObject:view];
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


- (void)addPlot:(UIView *)plot title:(NSString *)title {
    [plot setBackgroundColor:[UIColor blackColor]];
    [self addLabel:title toView:plot];
    [self toggleView:plot];
}

- (void)addToggleWithTitle:(NSString *)title selector:(SEL)selector
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    label.text = title;
    [timelineViewController addView:label];
    UISwitch *toggleSwitch = [[UISwitch alloc] init];
    [toggleSwitch setOn:YES];
    [toggleSwitch addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    [timelineViewController addView:toggleSwitch];
}


- (void)toggleAudioInputPlot:(UISwitch *)sender {
    [self toggleView:inputPlot];
}

- (void)addAudioInputPlot
{
    inputPlot = [[AKAudioInputPlot alloc] init];
    [self addPlot:inputPlot title:@"Audio Input"];
    [inputPlot setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.502 alpha:1.000]];
    [self addToggleWithTitle:@"Audio Input Plot" selector:@selector(toggleAudioInputPlot:)];
}

- (void)toggleStereoOutputPlot:(UISwitch *)sender {
    [self toggleView:stereoPlot];
}

- (void)addStereoOutputPlot
{
    stereoPlot = [[AKStereoOutputPlot alloc] init];
    [self addPlot:stereoPlot title:@"Stereo Output"];
    [self addToggleWithTitle:@"Stereo Output Plot" selector:@selector(toggleStereoOutputPlot:)];
}

- (void)toggleAudioOutputPlot:(UISwitch *)sender {
    [self toggleView:audioPlot];
}

- (void)addAudioOutputPlot
{
    audioPlot = [[AKAudioOutputPlot alloc] init];
    [self addPlot:audioPlot title:@"Audio Output"];
    [self addToggleWithTitle:@"Audio Output Plot" selector:@selector(toggleAudioOutputPlot:)];
}

- (void)toggleAudioInputRollingWaveformPlot:(UISwitch *)sender {
    [self toggleView:rollingInputPlot];
}

- (void)addAudioInputRollingWaveformPlot
{
    rollingInputPlot = [[AKAudioInputRollingWaveformPlot alloc] init];
    [self addPlot:rollingInputPlot title:@"Rolling Input"];
    [self addToggleWithTitle:@"Rolling Input Plot" selector:@selector(toggleAudioInputRollingWaveformPlot:)];
}

- (void)toggleAudioOutputRollingWaveformPlot:(UISwitch *)sender {
    [self toggleView:rollingOutputPlot];
}

- (void)addAudioOutputRollingWaveformPlot
{
    rollingOutputPlot = [[AKAudioOutputRollingWaveformPlot alloc] init];
    [self addPlot:rollingOutputPlot title:@"Rolling Output"];
    [self addToggleWithTitle:@"Rolling Output Plot" selector:@selector(toggleAudioOutputRollingWaveformPlot:)];
}

- (void)addPlotForInstrumentProperty:(AKInstrumentProperty *)property withLabel:(NSString *)label
{
    AKInstrumentPropertyPlot *plot = [[AKInstrumentPropertyPlot alloc] init];
    plot.property = property;
    [plot setBackgroundColor:[UIColor colorWithWhite:0.15 alpha:1.000]];
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

- (void)addTablePlot:(AKTable *)table {
    AKTablePlot *tp = [[AKTablePlot alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    tp.table = table;
    KZPShow(tp);
}

- (void)toggleAudioOutputFFTPlot:(UISwitch *)sender {
    [self toggleView:outputFFTPlot];
}

- (void)addAudioOutputFFTPlot
{
    outputFFTPlot = [[AKAudioOutputFFTPlot alloc] init];
    [self addPlot:outputFFTPlot title:@"Audio Output FFT"];
    [self addToggleWithTitle:@"Ouput FFT Plot" selector:@selector(toggleAudioOutputFFTPlot:)];
}

- (void)toggleAudioInputFFTPlot:(UISwitch *)sender {
    [self toggleView:inputFFTPlot];
}

- (void)addAudioInputFFTPlot
{
    inputFFTPlot = [[AKAudioInputFFTPlot alloc] init];
    [self addPlot:inputFFTPlot title:@"Audio Input FFT"];
    [self addToggleWithTitle:@"Input FFT Plot" selector:@selector(toggleAudioInputFFTPlot:)];
}


- (void)addRepeatSliderForInstrument:(AKInstrument *)instrument
                              phrase:(AKPhrase *)phrase
                    minimumFrequency:(float)minFrequency
                    maximumFrequency:(float)maxFrequency
{
    [instrument stopPhrase];
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


- (void)addSliderForProperty:(id)property title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    label.text = title;
    [timelineViewController addView:label];

    AKPropertyLabel *valueLabel = [[AKPropertyLabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    valueLabel.property = property;
    [timelineViewController addView:valueLabel];

    AKPropertySlider *slider = [[AKPropertySlider alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    slider.property = property;
    [timelineViewController addView:slider];
}

- (void)setup
{
    [AKOrchestra start];

    views = [[NSMutableArray alloc] init];
    shownViews = [[NSMutableArray alloc] init];

    AKManager *manager = [AKManager sharedManager];
    [manager enableAudioInput];
    cs = manager.engine;
    timelineViewController = [KZPTimelineViewController sharedInstance];
}

- (void)run {
    [views removeAllObjects];
    [shownViews removeAllObjects];
    [self placeViews];
}


@end

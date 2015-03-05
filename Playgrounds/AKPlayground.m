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
    
    AKAudioOutputView *audioOutputView;
    AKAudioOutputAmplitudeView *audioOutputAmplitudeView;
    AKFFTView *fftView;
    AKAudioInputView  *audioInputView;
    AKRollingWaveformView *rollingWaveformView;
}

- (void)makeSection:(NSString *)title
{
    KZPShow(@" ");
    NSString *starredTitle = [NSString stringWithFormat:@"▶︎ %@ ◀︎", title];
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
- (void)addAudioInputView
{
    audioInputView = [[AKAudioInputView alloc] init];
    [audioInputView setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.502 alpha:1.000]];
    [cs addBinding:audioInputView];
    [self toggleView:audioInputView];
    KZPAction(@"Microphone",   ^{ [self toggleView:audioInputView ]; });
}

- (void)addAudioOutputView
{
    audioOutputView = [[AKAudioOutputView alloc] init];
    [audioOutputView setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:audioOutputView];
    [self toggleView:audioOutputView];
    KZPAction(@"Audio Output", ^{ [self toggleView:audioOutputView]; });
}

- (void)addFFTView
{
    fftView = [[AKFFTView alloc] init];
    [fftView setBackgroundColor:[UIColor blackColor]];
    [cs addBinding:fftView];
    [self toggleView:fftView];
    KZPAction(@"Audio Output FFT", ^{ [self toggleView:fftView]; });
}

- (void)addRollingWaveformView
{
    rollingWaveformView = [[AKRollingWaveformView alloc] init];
    NSLog(@"setting to green");
    [rollingWaveformView setBackgroundColor:[UIColor greenColor]];
    [cs addBinding:rollingWaveformView];
    [self toggleView:rollingWaveformView];
    KZPAction(@"Rolling", ^{ [self toggleView:rollingWaveformView]; });
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

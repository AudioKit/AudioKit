//
//  ViewController.m
//  Convolution
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "AKTools.h"
#import "ConvolutionInstrument.h"
#import "LevelMeter.h"
#import "AKAudioAnalyzer.h"

@implementation ViewController
{
    ConvolutionInstrument *conv;
    
    AKAudioAnalyzer *analyzer;
    IBOutlet LevelMeter *levelMeter;
    AKSequence *continuouslyUpdateLevelMeter;
    AKEvent *updateLevelMeter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    continuouslyUpdateLevelMeter = [AKSequence sequence];
    updateLevelMeter = [[AKEvent alloc] initWithBlock:^{
        [levelMeter setLevel:analyzer.trackedAmplitude.value];
        [levelMeter setNeedsDisplay];
        [continuouslyUpdateLevelMeter addEvent:updateLevelMeter afterDuration:0.04];
        
    }];
    [continuouslyUpdateLevelMeter addEvent:updateLevelMeter];
    [continuouslyUpdateLevelMeter play];
    
    conv = [[ConvolutionInstrument alloc] init];
    [AKOrchestra addInstrument:conv];
    [[AKManager sharedManager] setIsLogging:YES];
    analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:conv.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    
    [AKOrchestra start];
    [analyzer play];
}

- (IBAction)start:(id)sender {
    [conv play];
}

- (IBAction)stop:(id)sender {
    [conv stop];
}

- (IBAction)changeDryWet:(id)sender {
    [AKTools setProperty:conv.dryWetBalance withSlider:(UISlider *)sender];
}
- (IBAction)changeDishWell:(id)sender {
    [AKTools setProperty:conv.dishWellBalance withSlider:(UISlider *)sender];
}

@end

//
//  ViewController.m
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

#import "AKFoundation.h"
#import "AKTools.h"
#import "GranularInstrument.h"


@interface ViewController ()
{
    GranularInstrument *granularInstrument;
    BOOL isGranularInstrumentPlaying;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    granularInstrument = [[GranularInstrument alloc] init];
    
    [orch addInstrument:granularInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleGranularInstrument:(id)sender
{
    if (isGranularInstrumentPlaying) {
        [granularInstrument stop];
        isGranularInstrumentPlaying = NO;
    } else {
        [granularInstrument play];
        isGranularInstrumentPlaying = YES;
    }
}

- (IBAction)averageGrainDurationControl:(id)sender
{
    [AKTools setProperty:granularInstrument.averageGrainDuration withSlider:(UISlider *)sender];
    UISlider *slider = (UISlider *)sender;
    NSLog(@"Duration value is: %f", slider.value);
    
}

- (IBAction)grainDensityControl:(id)sender
{
    [AKTools setProperty:granularInstrument.grainDensity withSlider:(UISlider *)sender];
    UISlider *slider = (UISlider *)sender;
    NSLog(@"Density value is: %f", slider.value);

}

- (IBAction)freqDevControl:(id)sender
{
    [AKTools setProperty:granularInstrument.granularFrequencyDeviation withSlider:(UISlider *)sender];
    UISlider *slider = (UISlider *)sender;
    NSLog(@"Frequency Deviation value is: %f", slider.value);

}

- (IBAction)amplitudeControl:(id)sender
{
    [AKTools setProperty:granularInstrument.granularAmplitude withSlider:(UISlider *)sender];
    UISlider *slider = (UISlider *)sender;
    NSLog(@"Amplitude value is: %f", slider.value);

}

@end

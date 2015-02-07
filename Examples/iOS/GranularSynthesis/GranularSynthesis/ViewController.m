//
//  ViewController.m
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
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

@property (strong, nonatomic) IBOutlet UISlider *averageGrainDurationSlider;
- (IBAction)averageGrainDurationControl:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *grainDensitySlider;
- (IBAction)grainDensityControl:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *freqDevSlider;
- (IBAction)freqDevControl:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *amplitudeSlider;
- (IBAction)amplitudeControl:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    granularInstrument = [[GranularInstrument alloc] init];
    [AKOrchestra addInstrument:granularInstrument];
    
    [self updateSliders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSliders
{
    [AKTools setSlider:self.averageGrainDurationSlider
          withProperty:granularInstrument.averageGrainDuration];
    [AKTools setSlider:self.grainDensitySlider
          withProperty:granularInstrument.grainDensity];
    [AKTools setSlider:self.freqDevSlider
          withProperty:granularInstrument.granularFrequencyDeviation];
    [AKTools setSlider:self.amplitudeSlider
          withProperty:granularInstrument.granularAmplitude];
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
    [AKTools setProperty:granularInstrument.averageGrainDuration
              withSlider:(UISlider *)sender];
}

- (IBAction)grainDensityControl:(id)sender
{
    [AKTools setProperty:granularInstrument.grainDensity
              withSlider:(UISlider *)sender];
}

- (IBAction)freqDevControl:(id)sender
{
    [AKTools setProperty:granularInstrument.granularFrequencyDeviation
              withSlider:(UISlider *)sender];
}

- (IBAction)amplitudeControl:(id)sender
{
    [AKTools setProperty:granularInstrument.granularAmplitude
              withSlider:(UISlider *)sender];
}

@end

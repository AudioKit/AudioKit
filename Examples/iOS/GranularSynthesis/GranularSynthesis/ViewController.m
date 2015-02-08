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

@property (strong, nonatomic) IBOutlet UISlider *mixSlider;
@property (strong, nonatomic) IBOutlet UISlider *frequencySlider;
@property (strong, nonatomic) IBOutlet UISlider *durationSlider;
@property (strong, nonatomic) IBOutlet UISlider *densitySlider;
@property (strong, nonatomic) IBOutlet UISlider *frequencyVariationSlider;
@property (strong, nonatomic) IBOutlet UISlider *frequencyVariationDistributionSlider;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    granularInstrument = [[GranularInstrument alloc] init];
    [AKOrchestra addInstrument:granularInstrument];
    [AKOrchestra start];
    [self updateSliders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSliders
{
    [AKTools setSlider:self.mixSlider
          withProperty:granularInstrument.mix];
    [AKTools setSlider:self.frequencySlider
          withProperty:granularInstrument.frequency];
    [AKTools setSlider:self.durationSlider
          withProperty:granularInstrument.duration];
    [AKTools setSlider:self.densitySlider
          withProperty:granularInstrument.density];
    [AKTools setSlider:self.frequencyVariationSlider
          withProperty:granularInstrument.frequencyVariation];
    [AKTools setSlider:self.frequencyVariationDistributionSlider
          withProperty:granularInstrument.frequencyVariationDistribution];
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

- (IBAction)mixChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.mix withSlider:sender];
}

- (IBAction)frequencyChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.frequency withSlider:sender];
}

- (IBAction)durationChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.duration withSlider:sender];
}

- (IBAction)denistyChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.density withSlider:sender];
}

- (IBAction)frequencyVariationChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.frequencyVariation withSlider:sender];
}

- (IBAction)frequencyVariationDistributionChanged:(UISlider *)sender {
    [AKTools setProperty:granularInstrument.frequencyVariationDistribution withSlider:sender];
}

@end

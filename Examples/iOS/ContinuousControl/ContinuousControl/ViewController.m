//
//  ViewController.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"

#import "AKTools.h"
#import "ContinuousControlConductor.h"

@implementation ViewController
{
    IBOutlet UISlider *amplitudeSlider;
    IBOutlet UISlider *modulationSlider;
    IBOutlet UISlider *modIndexSlider;
    IBOutlet UILabel *amplitudeLabel;
    IBOutlet UILabel *modulationLabel;
    IBOutlet UILabel *modIndexLabel;
    
    ContinuousControlConductor *conductor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    conductor = [[ContinuousControlConductor alloc] init];
    
    [AKTools setLabel:amplitudeLabel  withProperty:conductor.tweakableInstrument.amplitude];
    [AKTools setLabel:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
    [AKTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    
    [AKTools setSlider:amplitudeSlider  withProperty:conductor.tweakableInstrument.amplitude];
    [AKTools setSlider:modulationSlider withProperty:conductor.tweakableInstrument.modulation];
    [AKTools setSlider:modIndexSlider   withProperty:conductor.tweakableInstrument.modIndex];
    
    [conductor.tweakableInstrument.modIndex addObserver:self
                                    forKeyPath:@"value"
                                       options:NSKeyValueObservingOptionNew
                                       context:Nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [conductor stop];
}

- (IBAction)runInstrument:(id)sender
{
    [conductor start];
}

- (IBAction)stopInstrument:(id)sender
{
    [conductor stop];
}

- (void)sliderTimerFire:(NSTimer *)timer
{
    [AKTools setSlider:modIndexSlider withProperty:conductor.tweakableInstrument.modIndex];
    [AKTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
}

- (IBAction)scaleAmplitude:(id)sender
{
    [AKTools setProperty:conductor.tweakableInstrument.amplitude withSlider:(UISlider *)sender];
    [AKTools setLabel:amplitudeLabel withProperty:conductor.tweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender
{
    [AKTools setProperty:conductor.tweakableInstrument.modulation withSlider:(UISlider *)sender];
    [AKTools setLabel:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKTools setSlider:modIndexSlider withProperty:conductor.tweakableInstrument.modIndex];
        [AKTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}

@end

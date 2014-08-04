//
//  ViewController.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"

#import "AKiOSTools.h"
#import "ContinuousControlConductor.h"

@interface ViewController ()
{
    IBOutlet UISlider *amplitudeSlider;
    IBOutlet UISlider *modulationSlider;
    IBOutlet UISlider *modIndexSlider;
    IBOutlet UILabel *amplitudeLabel;
    IBOutlet UILabel *modulationLabel;
    IBOutlet UILabel *modIndexLabel;
    
    ContinuousControlConductor *conductor;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    conductor = [[ContinuousControlConductor alloc] init];
    
    [AKiOSTools setLabel:amplitudeLabel  withProperty:conductor.tweakableInstrument.amplitude];
    [AKiOSTools setLabel:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
    [AKiOSTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    
    [AKiOSTools setSlider:amplitudeSlider  withProperty:conductor.tweakableInstrument.amplitude];
    [AKiOSTools setSlider:modulationSlider withProperty:conductor.tweakableInstrument.modulation];
    
    [conductor.tweakableInstrument.modIndex addObserver:self
                                    forKeyPath:@"value"
                                       options:NSKeyValueObservingOptionNew
                                       context:Nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [conductor stop];
}

- (IBAction)runInstrument:(id)sender {
    [conductor start];
}

- (IBAction)stopInstrument:(id)sender
{
    [conductor stop];
}

- (void)sliderTimerFire:(NSTimer *)timer
{
    [AKiOSTools setSlider:modIndexSlider withProperty:conductor.tweakableInstrument.modIndex];
    [AKiOSTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
}


- (IBAction)scaleAmplitude:(id)sender {
    [AKiOSTools setProperty:conductor.tweakableInstrument.amplitude withSlider:(UISlider *)sender];
    [AKiOSTools setLabel:amplitudeLabel withProperty:conductor.tweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender {
    [AKiOSTools setProperty:conductor.tweakableInstrument.modulation withSlider:(UISlider *)sender];
    [AKiOSTools setLabel:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKiOSTools setSlider:modIndexSlider withProperty:conductor.tweakableInstrument.modIndex];
        [AKiOSTools setLabel:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}



@end

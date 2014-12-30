//
//  AppDelegate.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AppDelegate.h"
#import "AKTools.h"
#import "ContinuousControlConductor.h"

@implementation AppDelegate
{
    IBOutlet NSSlider *amplitudeSlider;
    IBOutlet NSSlider *modulationSlider;
    IBOutlet NSSlider *modIndexSlider;
    IBOutlet NSTextField *amplitudeLabel;
    IBOutlet NSTextField *modulationLabel;
    IBOutlet NSTextField *modIndexLabel;
    
    ContinuousControlConductor *conductor;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    conductor = [[ContinuousControlConductor alloc] init];
    
    [AKTools setTextField:amplitudeLabel  withProperty:conductor.tweakableInstrument.amplitude];
    [AKTools setTextField:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
    [AKTools setTextField:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    
    [AKTools setSlider:amplitudeSlider  withProperty:conductor.tweakableInstrument.amplitude];
    [AKTools setSlider:modulationSlider withProperty:conductor.tweakableInstrument.modulation];
    [AKTools setSlider:modIndexSlider   withProperty:conductor.tweakableInstrument.modIndex];
    
    [conductor.tweakableInstrument.modIndex addObserver:self
                                             forKeyPath:@"value"
                                                options:NSKeyValueObservingOptionNew
                                                context:Nil];
}

- (IBAction)runInstrument:(id)sender
{
    [conductor start];
}

- (IBAction)stopInstrument:(id)sender
{
    [conductor stop];
}

- (IBAction)scaleAmplitude:(id)sender
{
    [AKTools setProperty:conductor.tweakableInstrument.amplitude withSlider:(NSSlider *)sender];
    [AKTools setTextField:amplitudeLabel withProperty:conductor.tweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender
{
    [AKTools setProperty:conductor.tweakableInstrument.modulation withSlider:(NSSlider *)sender];
    [AKTools setTextField:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKTools setSlider:modIndexSlider    withProperty:conductor.tweakableInstrument.modIndex];
        [AKTools setTextField:modIndexLabel  withProperty:conductor.tweakableInstrument.modIndex];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}



@end


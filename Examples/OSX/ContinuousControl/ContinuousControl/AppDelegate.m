//
//  AppDelegate.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKOSXTools.h"
#import "ContinuousControlConductor.h"

@interface AppDelegate ()
{
    IBOutlet NSSlider *amplitudeSlider;
    IBOutlet NSSlider *modulationSlider;
    IBOutlet NSSlider *modIndexSlider;
    IBOutlet NSTextField *amplitudeLabel;
    IBOutlet NSTextField *modulationLabel;
    IBOutlet NSTextField *modIndexLabel;

    ContinuousControlConductor *conductor;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    conductor = [[ContinuousControlConductor alloc] init];
    
    [AKOSXTools setTextField:amplitudeLabel  withProperty:conductor.tweakableInstrument.amplitude];
    [AKOSXTools setTextField:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
    [AKOSXTools setTextField:modIndexLabel   withProperty:conductor.tweakableInstrument.modIndex];
    
    [AKOSXTools setSlider:amplitudeSlider  withProperty:conductor.tweakableInstrument.amplitude];
    [AKOSXTools setSlider:modulationSlider withProperty:conductor.tweakableInstrument.modulation];
    
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

- (IBAction)scaleAmplitude:(id)sender {
    [AKOSXTools setProperty:conductor.tweakableInstrument.amplitude withSlider:(NSSlider *)sender];
    [AKOSXTools setTextField:amplitudeLabel withProperty:conductor.tweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender {
    [AKOSXTools setProperty:conductor.tweakableInstrument.modulation withSlider:(NSSlider *)sender];
    [AKOSXTools setTextField:modulationLabel withProperty:conductor.tweakableInstrument.modulation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKOSXTools setSlider:modIndexSlider    withProperty:conductor.tweakableInstrument.modIndex];
        [AKOSXTools setTextField:modIndexLabel  withProperty:conductor.tweakableInstrument.modIndex];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}



@end


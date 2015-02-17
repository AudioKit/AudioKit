//
//  ContinuousControlViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ContinuousControlViewController.h"
#import "AKFoundation.h"
#import "TweakableInstrument.h"
#import "AKTools.h"

@implementation ContinuousControlViewController
{
    IBOutlet NSSlider *amplitudeSlider;
    IBOutlet NSSlider *modulationSlider;
    IBOutlet NSSlider *modIndexSlider;
    IBOutlet NSTextField *amplitudeLabel;
    IBOutlet NSTextField *modulationLabel;
    IBOutlet NSTextField *modIndexLabel;
    
    AKSequence *frequencySequence;
    AKSequence *modulationIndexSequence;
    AKEvent *randomizeFrequency;
    AKEvent *randomizeModulationIndex;
    
    TweakableInstrument *tweakableInstrument;
}

- (void)viewDidAppear {
    frequencySequence = [[AKSequence alloc] init];
    modulationIndexSequence = [[AKSequence alloc] init];
    
    randomizeFrequency = [[AKEvent alloc] initWithBlock:^{
        [tweakableInstrument.frequency randomize];
        [frequencySequence addEvent:randomizeFrequency afterDuration:3.0];
    }];
    randomizeModulationIndex = [[AKEvent alloc] initWithBlock:^{
        [tweakableInstrument.modIndex randomize];
        [modulationIndexSequence addEvent:randomizeModulationIndex afterDuration:0.2];
    }];
    
    [frequencySequence addEvent:randomizeFrequency atTime:3.0];
    [modulationIndexSequence addEvent:randomizeModulationIndex atTime:0.2];
    
    tweakableInstrument = [[TweakableInstrument alloc] init];
    [AKOrchestra addInstrument:tweakableInstrument];
    [AKOrchestra start];
    
    [AKTools setTextField:amplitudeLabel  withProperty:tweakableInstrument.amplitude];
    [AKTools setTextField:modulationLabel withProperty:tweakableInstrument.modulation];
    [AKTools setTextField:modIndexLabel   withProperty:tweakableInstrument.modIndex];
    
    [AKTools setSlider:amplitudeSlider  withProperty:tweakableInstrument.amplitude];
    [AKTools setSlider:modulationSlider withProperty:tweakableInstrument.modulation];
    [AKTools setSlider:modIndexSlider   withProperty:tweakableInstrument.modIndex];
    
    [tweakableInstrument.modIndex addObserver:self
                                   forKeyPath:@"value"
                                      options:NSKeyValueObservingOptionNew
                                      context:Nil];
}

- (void)viewDidDisappear {
    [tweakableInstrument stop];
    [[AKManager sharedManager] stop];
    [AKOrchestra reset];
}

- (IBAction)start:(id)sender
{
    [tweakableInstrument play];
    [tweakableInstrument.frequency randomize];
    [frequencySequence play];
    [modulationIndexSequence play];
}

- (IBAction)stop:(id)sender
{
    [tweakableInstrument stop];
    [frequencySequence stop];
    [modulationIndexSequence stop];
}

- (IBAction)scaleAmplitude:(id)sender
{
    [AKTools setProperty:tweakableInstrument.amplitude withSlider:(NSSlider *)sender];
    [AKTools setTextField:amplitudeLabel withProperty:tweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender
{
    [AKTools setProperty:tweakableInstrument.modulation withSlider:(NSSlider *)sender];
    [AKTools setTextField:modulationLabel withProperty:tweakableInstrument.modulation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKTools setSlider:modIndexSlider    withProperty:tweakableInstrument.modIndex];
        [AKTools setTextField:modIndexLabel  withProperty:tweakableInstrument.modIndex];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}

@end

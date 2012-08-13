//
//  MidiViewController.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidiViewController.h"


@interface MidiViewController () <OCSMidiListener>

@end

@implementation MidiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[OCSManager sharedOCSManager] enableMidi];
    [[[OCSManager sharedOCSManager] midi] addListener:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)midiNoteOn:(int)note velocity:(int)velocity {
    NSLog(@"Note On: %i at Velocity: %i", note, velocity);
}

- (void)midiNoteOff:(int)note velocity:(int)velocity {
    NSLog(@"Note Off: %i at Velocity: %i", note, velocity);
}

- (void)midiAftertouchOnNote:(int)note pressure:(int)pressure {
    NSLog(@"Aftertouch: %i at Velocity: %i", note, pressure);
}

- (void)midiController:(int)controller changedToValue:(int)value {
    NSLog(@"Controller: %i = %i", controller, value);
}

- (void)midiAftertouch:(int)pressure  {
    NSLog(@"Aftertouch: %i", pressure);
}

-( void)midiPitchWheel:(int)pitchWheelValue {
    NSLog(@"PitchWheel: %i", pitchWheelValue);
}

- (void)midiModulation:(int)modulation {
    NSLog(@"Modulation: %i", modulation);
}

@end

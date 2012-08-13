//
//  OCSMidi.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol OCSMidiListener <NSObject>

//Nothing is required, use what you need
@optional

// Basic MIDI
- (void)midiNoteOn:(int)note velocity:(int)velocity;
- (void)midiNoteOff:(int)note velocity:(int)velocity;
- (void)midiAftertouchOnNote:(int)note pressure:(int)pressure;
- (void)midiController:(int)controller changedToValue:(int)value;
- (void)midiAftertouch:(int)pressure;
- (void)midiPitchWheel:(int)pitchWheelValue;

// Controller Helpers
- (void)midiModulation:(int)modulation;
- (void)midiPortamento:(int)modulation;
- (void)midiVolume:(int)modulation;
- (void)midiBalance:(int)modulation;
- (void)midiPan:(int)modulation;
- (void)midiExpression:(int)modulation;


@end


@interface OCSMidi : NSObject {
    NSMutableSet *listeners;
}
@property (nonatomic, strong) NSMutableSet *listeners;

-(void)addListener:(id<OCSMidiListener>)listener;

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

@end

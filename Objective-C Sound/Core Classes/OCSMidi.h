//
//  OCSMidi.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

// -----------------------------------------------------------------------------
#  pragma mark OCS MIDI Listener Protocol
// -----------------------------------------------------------------------------

@protocol OCSMidiListener <NSObject>

// All of these are optional, so perhaps we should change to using NotificationCenter
@optional

#pragma mark Basic MIDI

- (void)midiNoteOn:(int)note
          velocity:(int)velocity
           channel:(int)channel;

- (void)midiNoteOff:(int)note
           velocity:(int)velocity
            channel:(int)channel;

- (void)midiAftertouchOnNote:(int)note
                    pressure:(int)pressure
                     channel:(int)channel;

- (void)midiController:(int)controller
        changedToValue:(int)value
               channel:(int)channel;

- (void)midiAftertouch:(int)pressure
               channel:(int)channel;

- (void)midiPitchWheel:(int)pitchWheelValue
               channel:(int)channel;

# pragma mark Controller Name Helpers
- (void)midiModulation:(int)modulation channel:(int)channel;
- (void)midiPortamento:(int)modulation channel:(int)channel;
- (void)midiVolume:(int)modulation     channel:(int)channel;
- (void)midiBalance:(int)modulation    channel:(int)channel;
- (void)midiPan:(int)modulation        channel:(int)channel;
- (void)midiExpression:(int)modulation channel:(int)channel;;


@end

// -----------------------------------------------------------------------------
#  pragma mark - OCS MIDI
// -----------------------------------------------------------------------------


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

//
//  AKMidi.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKMidiEvent.h"

// Notification names broadcasted for MIDI events being received from the inputs.
extern NSString * const AKMidiNoteOnNotification;
extern NSString * const AKMidiNoteOffNotification;
extern NSString * const AKMidiPolyphonicAftertouchNotification;
extern NSString * const AKMidiProgramChangeNotification;
extern NSString * const AKMidiAftertouchNotification;
extern NSString * const AKMidiPitchWheelNotification;
extern NSString * const AKMidiControllerNotification;
extern NSString * const AKMidiModulationNotification;
extern NSString * const AKMidiPortamentoNotification;
extern NSString * const AKMidiVolumeNotification;
extern NSString * const AKMidiBalanceNotification;
extern NSString * const AKMidiPanNotification;
extern NSString * const AKMidiExpressionNotification;

/** AKMidi is the object that handles the MIDI input and output from AK.
 */
@interface AKMidi : NSObject

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

/// Send a MIDI event to Csound
- (void)sendEvent:(AKMidiEvent *)event;

/// Whether received MIDI events are automatically forwarded to Csound (default: YES)
@property BOOL forwardEvents;

/// The number of detected MIDI inputs
@property (readonly) NSUInteger inputs;

@end

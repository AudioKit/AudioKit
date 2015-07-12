//
//  AKMidi.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const AKMidiNoteOn;
extern NSString * const AKMidiNoteOn;
extern NSString * const AKMidiNoteOff;
extern NSString * const AKMidiPolyphonicAftertouch;
extern NSString * const AKMidiProgramChange;
extern NSString * const AKMidiAftertouch;
extern NSString * const AKMidiPitchWheel;
extern NSString * const AKMidiController;
extern NSString * const AKMidiModulation;
extern NSString * const AKMidiPortamento;
extern NSString * const AKMidiVolume;
extern NSString * const AKMidiBalance;
extern NSString * const AKMidiPan;
extern NSString * const AKMidiExpression;

/** AKMidi is the object that handles the MIDI input and output from AK.
 */
@interface AKMidi : NSObject

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

/// The number of detected MIDI inputs
@property (readonly) NSUInteger inputs;

@end

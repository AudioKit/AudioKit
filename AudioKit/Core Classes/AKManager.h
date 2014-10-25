//
//  AKManager.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKInstrument.h"
#import "AKOrchestra.h"
#import "AKEvent.h"
#import "AKMidi.h"
#import "AKSequence.h"

/** The AKManager is a singleton class available to all controllers that need access to audio.
 */
@interface AKManager : NSObject

/// Determines whether or not AudioKit is available to send events to.
@property (readonly) BOOL isRunning;

/// Common midi property shared across the application
@property (readonly) AKMidi *midi;

/// @returns the shared instance of AKManager
+ (AKManager *)sharedAKManager;

/// Run AudioKit using an AKOrchestra
/// @param orchestra The AKOrchestra that will be started.
- (void)runOrchestra:(AKOrchestra *)orchestra;

/// Stop AudioKit from making any more sound.
- (void)stop;

/// Triggers an AKEvent
/// @param event AKEvent to be triggered
- (void)triggerEvent:(AKEvent *)event;

/// Stop all notes of an instrument
/// @param instrument The instrument that needs to be turned off.
- (void)stopInstrument:(AKInstrument *)instrument;

/// Stop playback of a given note
/// @param note Note to stop
- (void)stopNote:(AKNote *)note;

/// Update playback of a given note
/// @param note Note to update
- (void)updateNote:(AKNote *)note;

/// Helper function to get the string out of a file.
/// @param filename Full path of file on disk
+ (NSString *)stringFromFile:(NSString *)filename;

/// Enable Audio Input
- (void)enableAudioInput;

/// Disable AudioInput
- (void)disableAudioInput;

- (void)stopRecording;
- (void)startRecordingToURL:(NSURL *)url;

/// Enable MIDI
- (void)enableMidi;

/// Disable MIDI
- (void)disableMidi;

@end

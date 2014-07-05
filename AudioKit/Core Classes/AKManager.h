//
//  AKManager.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CsoundObj.h"
#import "AKInstrument.h"
#import "AKOrchestra.h"
#import "AKEvent.h"
#import "AKMidi.h"
#import "AKSequence.h"

/** The AKManager is a singleton class available to all controller that need
 to interact with Csound through its simplified protocol.
 */
@interface AKManager : NSObject <CsoundObjCompletionListener> 

/// Determines whether or not Csound is available to send events to.
@property (readonly) BOOL isRunning;

/// Common midi property shared across the application
@property (readonly) AKMidi *midi;

/// @returns the shared instance of AKManager
+ (AKManager *)sharedAKManager;

/// @returns the shared instance of AKManager
- (AKManager *)sharedSwiftManager;

/// Run Csound from a given filename
/// @param filename CSD file use when running Csound.
- (void)runCSDFile:(NSString *)filename;

/// Run Csound using an AKOrechestra 
/// @param orchestra The AKOrchestra that will be used to create the CSD File.
- (void)runOrchestra:(AKOrchestra *)orchestra;

/// Stop Csound
- (void)stop;

/// Triggers an AKEvent
/// @param event AK Event
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

/// Enable MIDI
- (void)enableMidi;

/// Disable MIDI
- (void)disableMidi;

@end

//
//  OCSManager.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CsoundObj.h"
#import "OCSInstrument.h"
#import "OCSOrchestra.h"
#import "OCSEvent.h"
#import "OCSMidi.h"
#import "OCSSequence.h"

/** The OCSManager is a singleton class available to all controller that need
 to interact with Csound through its simplified protocol.
 */
@interface OCSManager : NSObject <CsoundObjCompletionListener> 

/// Determines whether or not Csound is available to send events to.
@property (readonly) BOOL isRunning;

/// Common midi property shared across the application
@property (readonly) OCSMidi *midi;

/// @returns the shared instance of OCSManager
+ (OCSManager *)sharedOCSManager;

/// Run Csound from a given filename
/// @param filename CSD file use when running Csound.
- (void)runCSDFile:(NSString *)filename;

/// Run Csound using an OCSOrechestra 
/// @param orchestra The OCSOrchestra that will be used to create the CSD File.
- (void)runOrchestra:(OCSOrchestra *)orchestra;

/// Stop Csound
- (void)stop;

/// Triggers an OCSEvent
/// @param event OCS Event
- (void)triggerEvent:(OCSEvent *)event;

/// Stop all notes of an instrument
/// @param instrument The instrument that needs to be turned off.
- (void)stopInstrument:(OCSInstrument *)instrument;

/// Stop playback of a given note
/// @param note Note to stop
- (void)stopNote:(OCSNote *)note;

/// Update playback of a given note
/// @param note Note to update
- (void)updateNote:(OCSNote *)note;

/// Helper function to get the string out of a file.
/// @param filename Full path of file on disk
+ (NSString *)stringFromFile:(NSString *)filename;

/// Enable MIDI
- (void)enableMidi;

/// Disable MIDI
- (void)disableMidi;

@end

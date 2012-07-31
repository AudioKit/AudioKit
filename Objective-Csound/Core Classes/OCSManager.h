//
//  OCSManager.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CsoundObj.h"
#import "OCSInstrument.h"
#import "OCSOrchestra.h"
#import "OCSMidi.h"
#import "OCSNoteProperty.h"
#import "OCSEvent.h"
#import "OCSSequence.h"

/** The OCSManager is a singleton class available to all controller that need
 to interact with Csound through its simplified protocol.
 */
@interface OCSManager : NSObject <CsoundObjCompletionListener> 

/// Determines whether or not Csound is available to send events to.
@property (readonly) BOOL isRunning;

/// Determines whether MIDI is enabled
@property (readonly) BOOL isMidiEnabled;

//@property (nonatomic, strong) OCSPropertyManager *myPropertyManager;

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

/// Writes a scoreline to start playing an instrument.
/// @param event OCS Event
- (void)triggerEvent:(OCSEvent *)event;

/// Helper function to get the string out of a file.
/// @param filename Full path of file on disk
+ (NSString *)stringFromFile:(NSString *)filename;

/// Enable/disable Midi in Csound.
- (void)enableMidi;

/// Panic function sends all notes off to csound.
-(void)panic;
@end

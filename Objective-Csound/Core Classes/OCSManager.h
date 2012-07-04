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

//#import "OCSPropertyManager.h"

/** The OCSManager is a singleton class available to all controller that need
 to interact with Csound through its simplified protocol.
 
 TODO: Consider whether or not currentOrchestra should be a property of OCSManager.
 */
@interface OCSManager : NSObject <CsoundObjCompletionListener> 

/// Determines whether or not Csound is available to send events to.
@property (readonly) BOOL isRunning;

/// Determines the value from which to scale all other amplitudes in Csound
@property (nonatomic, strong) NSNumber *zeroDBFullScaleValue;
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
/// @param note       Space deliminated list of parameters starting with the duration in seconds and usually contains only the duration.
/// @param instrument The instrument which needs to play.
- (void)playNote:(NSString *)note OnInstrument:(OCSInstrument *)instrument;

@end

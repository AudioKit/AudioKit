//
//  OCSInstrumentProperty.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSProperty.h"

#import "CsoundObj.h"
#import "CsoundValueCacheable.h"


/** Instrument properties are properties of an instrument that are shared 
 amongst the notes that are created on that instrument.  It is where MIDI
 controller data gets assigned and inserted into Csound.
 */
@interface OCSInstrumentProperty : OCSProperty<CsoundValueCacheable> {
    BOOL mCacheDirty;
    
    //channelName
    MYFLT *channelPtr;
    
    BOOL isMidiEnabled;
    int midiController;
}

/// @name Properties

/// isMidiEnabled
@property (readwrite) BOOL isMidiEnabled;

/// Midi Controller Number (0-127).
@property (readwrite) int midiController;

/// @name Instance Methods

/// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

/// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

/// Enable midi for this property.
/// @param controllerNumber Midi channel number (0-127).
-(void)enableMidiForControllerNumber:(int)controllerNumber;

@end

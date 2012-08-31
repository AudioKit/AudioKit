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
 amongst all the notes that are created on that instrument. 
 */
@interface OCSInstrumentProperty : OCSProperty<CsoundValueCacheable> {
    BOOL mCacheDirty;
    
    //channelName
    MYFLT *channelPtr;
}

/// @name Instance Methods

/// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

/// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

@end

//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "AKFoundation.h"

@interface ___FILEBASENAMEASIDENTIFIER___ : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *pan;

// Audio outlet for global effects processing
@property (readonly) AKStereoAudio *auxilliaryOutput;

@end

@interface ___FILEBASENAMEASIDENTIFIER___Note : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *amplitude;

- (instancetype)initWithFrequency:(float)frequency amplitude:(float)amplitude;

@end

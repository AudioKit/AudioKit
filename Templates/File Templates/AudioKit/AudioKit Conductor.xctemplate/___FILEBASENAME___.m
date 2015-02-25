//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"
#import "AKFoundation.h"

@implementation ___FILEBASENAMEASIDENTIFIER___
{
    // Instruments and other instance variables
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Create and add instruments to the orchestra
        instrument = [Instrument instrument];
        [AKOrchestra addInstrument:instrument];
   }
    return self;
}

@end

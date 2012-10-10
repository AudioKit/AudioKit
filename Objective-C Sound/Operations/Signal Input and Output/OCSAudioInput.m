//
//  OCSAudioInput.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudioInput.h"

@interface OCSAudioInput () {   
    OCSParameter *ar1;
}
@end

@implementation OCSAudioInput

- (id)init {
    self = [super init];
    if (self) {
        ar1  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@",[self operationName]]];

    }
    return self; 
}


- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"%@, aUnused ins", ar1];
}

- (NSString *)description {
    return [ar1 parameterString];
}



@end

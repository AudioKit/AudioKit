//
//  OCSJitter.m
//  Objective-C Sound
//
//  Auto-generated from database on 10/21/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "OCSJitter.h"

@interface OCSJitter () {
    OCSControl *kamp;
    OCSControl *kcpsMax;
    OCSControl *kcpsMin;
}
@end

@implementation OCSJitter 

- (id)initWithAmplitude:(OCSControl *)amplitude
           minFrequency:(OCSControl *)minFrequency
           maxFrequency:(OCSControl *)maxFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
            kamp = amplitude;    
                kcpsMax = maxFrequency;    
                kcpsMin = minFrequency;    
                }
    return self; 
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat: 
            @"%@ jitter %@, %@, %@", 
            self, kamp, kcpsMin, kcpsMax];
}

@end
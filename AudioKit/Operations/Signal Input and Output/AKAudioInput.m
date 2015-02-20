//
//  AKAudioInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioInput.h"

@implementation AKAudioInput

- (instancetype)init {
    self = [super initWithString:[self operationName]];
    self.state = @"connectable";
    return self; 
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"%@, aUnused ins", self];
}

@end

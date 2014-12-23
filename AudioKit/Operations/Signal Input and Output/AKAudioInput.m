//
//  AKAudioInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioInput.h"
#import "AKFoundation.h"

@implementation AKAudioInput

- (instancetype)init {
    self = [super initWithString:[self operationName]];
    return self; 
}

- (NSString *)stringForCSD {
    [[AKManager sharedManager] enableAudioInput];
    return [NSString stringWithFormat:@"%@, aUnused ins", self];
}

@end

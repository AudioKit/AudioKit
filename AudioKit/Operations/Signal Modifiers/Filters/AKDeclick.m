//
//  AKDeclick.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's declick:
//  http://www.csounds.com/manual/html/declick.html
//

#import "AKDeclick.h"

@implementation AKDeclick
{
    AKAudio *ain;
}

- (instancetype)initWithInput:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ declick %@",
            self, ain];
}

- (NSString *) udoFile {
    return [[NSBundle mainBundle] pathForResource: @"declick" ofType: @"udo"];
}

- (NSString *)udoString {
    return @"\n"
    "opcode declick, a, a\n"
    "ain     xin\n"
    "aenv    linseg 0, 0.02, 1, p3 - 0.05, 1, 0.02, 0, 0.01, 0\n"
    "xout ain * aenv         ; apply envelope and write output\n"
    "endop\n";
}


@end
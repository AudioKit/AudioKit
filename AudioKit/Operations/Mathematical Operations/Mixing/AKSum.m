//
//  AKSum.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKSum.h"

@implementation AKSum

- (NSString *)stringForCSD
{
    NSString *inputsCombined = [[self.inputs valueForKey:@"parameterString"] componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"%@ sum %@", self, inputsCombined];
}

@end

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
    NSMutableArray *paramterStrings = [NSMutableArray array];
    
    for (AKParameter *param in self.inputs) {
        [paramterStrings addObject:[NSString stringWithFormat:@"AKAudio(%@)", param.parameterString]];
    }
    NSString *inputsCombined = [paramterStrings componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"%@ sum %@",self, inputsCombined];
}
@end

//
//  AKProduct.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's product:
//  http://www.csounds.com/manual/html/product.html
//


#import "AKProduct.h"

@implementation AKProduct

- (NSString *)stringForCSD
{
    NSMutableArray *parameterStrings = [NSMutableArray array];
    
    for (AKParameter *param in self.inputs) {
        [parameterStrings addObject:[NSString stringWithFormat:@"AKAudio(%@)", param.parameterString]];
    }
    NSString *inputsCombined = [parameterStrings componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"%@ product %@",self, inputsCombined];
}

@end

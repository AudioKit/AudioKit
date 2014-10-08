//
//  AKProduct.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's product:
//  http://www.csounds.com/manual/html/product.html
//


#import "AKProduct.h"

@implementation AKProduct
{
    NSMutableArray *inputs;
}

- (instancetype)initWithOperands:(AKParameter *)firstOperand,... {
    self = [super initWithString:[self operationName]];
    if (self) {
        inputs = [[NSMutableArray alloc] init];
        AKParameter *eachInput;
        va_list argumentList;
        if (firstOperand) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [inputs addObject: firstOperand];
            va_start(argumentList, firstOperand); // Start scanning for arguments after firstObject.
            while ((eachInput = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
                [inputs addObject: eachInput]; // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
    }
    return self; 
}

- (NSString *)stringForCSD
{
    NSString *inputsCombined = [[inputs valueForKey:@"parameterString"] componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"%@ product %@",self, inputsCombined];
}

@end

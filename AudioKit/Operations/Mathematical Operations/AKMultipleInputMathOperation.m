//
//  AKMultipleInputMathOperation.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKMultipleInputMathOperation.h"

@interface AKMultipleInputMathOperation()
@property NSArray *inputs;
@end

@implementation AKMultipleInputMathOperation

- (instancetype)init {
    return [super initWithString:[self operationName]];
}

- (instancetype)initWithOperands:(AKParameter *)firstOperand,... {
    self = [super initWithString:[self operationName]];
    
    if (self) {
        NSMutableArray *inputs = [[NSMutableArray alloc] init];
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
        self.inputs = inputs;
    }
    return self;
}


- (instancetype)initWithFirstOperand:(AKParameter *)firstOperand
                       secondOperand:(AKParameter *)secondOperand;
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        NSMutableArray *inputs = [[NSMutableArray alloc] init];
        [inputs addObject:firstOperand];
        [inputs addObject:secondOperand];
        self.inputs = inputs;
    }
    return self;
}



@end

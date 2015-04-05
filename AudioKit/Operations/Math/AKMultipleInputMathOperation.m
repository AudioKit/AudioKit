//
//  AKMultipleInputMathOperation.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/1/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKMultipleInputMathOperation.h"


@implementation AKMultipleInputMathOperation

- (instancetype)init {
    return [super initWithString:[self operationName]];
}

- (instancetype)initWithInputs:(AKParameter *)firstInput,... {
    self = [super initWithString:[self operationName]];
    
    if (self) {
        NSMutableArray *inputs = [[NSMutableArray alloc] init];
        AKParameter *eachInput;
        va_list argumentList;
        if (firstInput) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [inputs addObject: firstInput];
            va_start(argumentList, firstInput); // Start scanning for arguments after firstObject.
            while ((eachInput = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
                [inputs addObject: eachInput]; // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
        _inputs = inputs;
        self.state = @"connectable";
        self.dependencies = [NSArray arrayWithArray:_inputs ];
    }
    return self;
}


- (instancetype)initWithFirstInput:(AKParameter *)firstInput
                       secondInput:(AKParameter *)secondInput;
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        NSMutableArray *inputs = [[NSMutableArray alloc] init];
        [inputs addObject:firstInput];
        [inputs addObject:secondInput];
        _inputs = inputs;
        self.state = @"connectable";
        self.dependencies = [NSArray arrayWithArray:_inputs ];

    }
    return self;
}



@end

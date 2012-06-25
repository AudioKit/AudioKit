//
//  OCSUserDefinedOpcode.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSUserDefinedOpcode.h"

@implementation OCSUserDefinedOpcode

- (id)init
{
    self = [super init];
    if ( self ) {
        /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        myUDOFile = [NSString stringWithFormat:@"%@/%@.udo", documentsDirectory, [self class]];
         */
    }
    return self;
}

- (NSString *)udoFile {
    return @"Undefined";
}

@end

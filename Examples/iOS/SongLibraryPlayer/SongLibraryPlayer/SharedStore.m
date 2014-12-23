//
//  SharedStore.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Aurelius Prochazka. All rights reserved.
//

#import "SharedStore.h"

@implementation SharedStore

+ (SharedStore *)globals
{
    // the instance of this class is stored here
    static SharedStore *globals = nil;
    
    // check to see if an instance already exists
    if (nil == globals) {
        globals  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return globals;
}

@end

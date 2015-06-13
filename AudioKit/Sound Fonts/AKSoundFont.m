//
//  AKSoundFont.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFont.h"
#import "AKManager.h"

@implementation AKSoundFont

static int currentID = 1;

+ (void)resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            _number = currentID++;
        }
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSString *orchString = [NSString stringWithFormat:
                                @"giSoundFont%d sfload %@\n"
                                @"sfpassign %d, giSoundFont%d\n",
                                self.number, filename, self.number, self.number];
        if ([[AKManager sharedManager] isLogging]) {
            NSLog(@"Sound Font: %@",orchString);
        }
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"giSoundFont%d", _number];
}

@end

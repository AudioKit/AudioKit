//
//  AKSoundFileTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSoundFileTable.h"
#import "AKManager.h"
#import "csound.h"

@implementation AKSoundFileTable


- (instancetype)initWithFilename:(NSString *)filename size:(int)size channel:(NSNumber *)channel
{
    self = [super initWithSize:2];
    if (self) {
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSArray *parameters = @[filename, @0, @0, channel];
        NSString *parameterString = [parameters componentsJoinedByString:@", "];
        NSString *orchString = [NSString stringWithFormat:@"giSoundFileTable%d ftgen %d, 0, %d, 1, %@",
                                self.number, self.number, size, parameterString];
        if ([[AKManager sharedManager] isLogging]) {
           NSLog(@"Sound File Table: %@",orchString);
        }
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
#ifndef AK_TESTING
        self.size = csoundTableLength([[[AKManager sharedManager] engine] getCsound], self.number);
#endif
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename size:(int)size {
    return [self initWithFilename:filename size:size channel:@0];
}

- (instancetype)initWithFilename:(NSString *)filename {
    return [self initWithFilename:filename size:0 channel:@0];
}

- (instancetype)initAsMonoFromLeftChannelOfStereoFile:(NSString *)filename {
    return [self initWithFilename:filename size:0 channel:@1];
}

- (instancetype)initAsMonoFromRightChannelOfStereoFile:(NSString *)filename {
    return [self initWithFilename:filename size:0 channel:@2];
}


- (AKConstant *)channels
{
    AKConstant * new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftchnls(%@)", self]];
    return new;
}

@end

//
//  AKSoundFileTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSoundFileTable.h"
#import "AKManager.h"

@implementation AKSoundFileTable

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super initWithSize:0];
    if (self) {
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSArray *parameters = @[filename, @0, @0, @0];
        NSString *parameterString = [parameters componentsJoinedByString:@", "];
        NSString *orchString = [NSString stringWithFormat:@"giSoundFileTable%d ftgen %d, 0, 0, 1, %@",
                                self.number, self.number, parameterString];
        NSLog(@"%@",orchString);
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
    }
    return self;
}

- (instancetype)initAsMonoFromLeftChannelOfStereoFile:(NSString *)filename
{
    self = [super initWithSize:0];
    if (self) {
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSArray *parameters = @[filename, @0, @0, @1];
        NSString *parameterString = [parameters componentsJoinedByString:@", "];
        NSString *orchString = [NSString stringWithFormat:@"giSoundFileTable%d ftgen %d, 0, 0, 1, %@",
                                self.number, self.number, parameterString];
        NSLog(@"%@",orchString);
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
    }
    return self;
}

- (instancetype)initAsMonoFromRightChannelOfStereoFile:(NSString *)filename
{
    self = [super initWithSize:0];
    if (self) {
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSArray *parameters = @[filename, @0, @0, @2];
        NSString *parameterString = [parameters componentsJoinedByString:@", "];
        NSString *orchString = [NSString stringWithFormat:@"giSoundFileTable%d ftgen %d, 0, 0, 1, %@",
                                self.number, self.number, parameterString];
        NSLog(@"%@",orchString);
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
    }
    return self;
}


- (AKConstant *)channels
{
    AKConstant * new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftchnls(%@)", self]];
    return new;
}

@end

//
//  PlayCSDFileController.m
//  AKMacExample
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayCSDFileController.h"

#import "AKManager.h"

@implementation PlayCSDFileController

- (IBAction)startPlayCSDFile:(id)sender {
    [[AKManager sharedAKManager] runCSDFile:@"example"];
}


- (IBAction)stopPlayCSDFile:(id)sender {
    [[AKManager sharedAKManager] stop];
}

@end

//
//  PlayCSDFileController.m
//  OCSMacExample
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayCSDFileController.h"

#import "OCSManager.h"

@implementation PlayCSDFileController

- (IBAction)startPlayCSDFile:(id)sender {
    [[OCSManager sharedOCSManager] runCSDFile:@"example"];
}


- (IBAction)stopPlayCSDFile:(id)sender {
    [[OCSManager sharedOCSManager] stop];
}

@end

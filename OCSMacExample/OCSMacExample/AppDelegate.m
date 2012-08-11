//
//  AppDelegate.m
//  OCSMacExample
//
//  Created by Aurelius Prochazka on 8/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//


#import "OCSManager.h"

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    
}

- (IBAction)startPlayCSDFile:(id)sender {
    [[OCSManager sharedOCSManager] runCSDFile:@"example"];
}


- (IBAction)stopPlayCSDFile:(id)sender {
    [[OCSManager sharedOCSManager] stop];
}

@end

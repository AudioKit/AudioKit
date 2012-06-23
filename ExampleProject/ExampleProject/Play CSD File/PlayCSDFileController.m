//
//  PlayCSDFileController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayCSDFileController.h"
#import "OCSManager.h"

@implementation PlayCSDFileController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[OCSManager sharedOCSManager] runCSDFile:@"example"];
    
}

- (IBAction)touchButton:(id)sender {
    UIButton *button = sender;
    if ([[OCSManager sharedOCSManager] isRunning]) {
        [[OCSManager sharedOCSManager] stop];
        [button setTitle: @"Run" forState:UIControlStateNormal];
    } else {
        [[OCSManager sharedOCSManager] runCSDFile:@"example"];
        [button setTitle: @"Stop" forState:UIControlStateNormal];
    }
}

@end

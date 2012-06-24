//
//  UDOViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOViewController.h"

#import "OCSManager.h"

@implementation UDOViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    udoInstrument =  [[UDOInstrument alloc] init];
    [orch addInstrument:udoInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [udoInstrument playNoteForDuration:1 Frequency:440];
}

- (IBAction)hit2:(id)sender {
    [udoInstrument playNoteForDuration:1 Frequency:(arc4random()%200+400)];
}

@end

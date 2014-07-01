//
//  ViewController.m
//  UnitGenerators
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "UnitGeneratorInstrument.h"

@interface ViewController ()
{
    UnitGeneratorInstrument *unitGeneratorInstrument;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    unitGeneratorInstrument = [[UnitGeneratorInstrument alloc] init];
    [orch addInstrument:unitGeneratorInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [unitGeneratorInstrument playForDuration:9.0];
}

- (IBAction)hit2:(id)sender {
    [unitGeneratorInstrument playForDuration:3.0];
}

@end

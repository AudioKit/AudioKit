//
//  PhysicalModelViewController.m
//  AK iPad Examples
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PhysicalModelViewController.h"
#import "AKiOSTools.h"
#import "AKManager.h"

#import "AKFoundation.h"

@interface PhysicalModelViewController ()

@end

@implementation PhysicalModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    AKInstrument *instrument = [[AKInstrument alloc] init];
    
    AKMandolin *mandolin = [[AKMandolin alloc] initWithBodySize:akp(1)
                                                        frequency:akp(440)
                                             pairedStringDetuning:akp(1)
                                                    pluckPosition:akp(0.4)
                                                         loopGain:akp(1)
                                                        amplitude:akp(1)];
    [instrument connect:mandolin];
    [orch addInstrument:instrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
}


@end

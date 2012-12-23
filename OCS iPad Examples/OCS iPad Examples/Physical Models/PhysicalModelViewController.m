//
//  PhysicalModelViewController.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PhysicalModelViewController.h"
#import "OCSiOSTools.h"
#import "OCSManager.h"

#import "OCSFoundation.h"

@interface PhysicalModelViewController ()

@end

@implementation PhysicalModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    OCSInstrument *instrument = [[OCSInstrument alloc] init];
    
    OCSMandolin *mandolin = [[OCSMandolin alloc] initWithBodySize:ocsp(1)
                                                        frequency:ocsp(440)
                                             pairedStringDetuning:ocsp(1)
                                                    pluckPosition:ocsp(0.4)
                                                         loopGain:ocsp(1)
                                                        amplitude:ocsp(1)];
    [instrument connect:mandolin];
    [orch addInstrument:instrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}


@end

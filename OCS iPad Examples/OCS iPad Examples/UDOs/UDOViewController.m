//
//  UDOViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOViewController.h"
#import "OCSiOSTools.h"
#import "OCSManager.h"

@interface UDOViewController () {
    UDOInstrument *udoInstrument;
}
@end

@implementation UDOViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    udoInstrument = [[UDOInstrument alloc] init];
    [orch addInstrument:udoInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    UDOInstrumentNote *note = [[UDOInstrumentNote alloc] initWithFrequency:440];
    note.duration.value = 0.5;
    [udoInstrument playNote:note];
}

- (IBAction)hit2:(id)sender { 
    UDOInstrumentNote *note = [[UDOInstrumentNote alloc] init];
    [note.frequency randomize];
    note.duration.value = 0.5;
    [udoInstrument playNote:note];
}


@end

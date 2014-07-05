//
//  ViewController.m
//  UsingUDOs
//
//  Created by Aurelius Prochazka on 7/1/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"

#import "AKiOSTools.h"
#import "AKFoundation.h"

#import "UDOInstrument.h"

@interface ViewController () {
    UDOInstrument *udoInstrument;
}
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    udoInstrument = [[UDOInstrument alloc] init];
    [orch addInstrument:udoInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)play:(id)sender {
    UDOInstrumentNote *note = [[UDOInstrumentNote alloc] init];
    [note.frequency randomize];
    note.duration.value = 0.5;
    [udoInstrument playNote:note];
}



@end

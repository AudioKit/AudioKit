//
//  PlayAudioFileViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileViewController.h"
#import "OCSManager.h"

@implementation PlayAudioFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [orch addInstrument:audioFilePlayer];
    [[OCSManager sharedOCSManager] runOrchestra:orch];

}

- (IBAction)touchButton:(id)sender {
    [audioFilePlayer play];
}
@end

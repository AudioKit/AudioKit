//
//  PlayAudioFileViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileViewController.h"

@implementation PlayAudioFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myOrchestra = [[OCSOrchestra alloc] init];    
    audioFilePlayer =  [[AudioFilePlayer alloc] init];
    [myOrchestra addInstrument:audioFilePlayer];
    [[OCSManager sharedOCSManager] runOrchestra:myOrchestra];

}

- (IBAction)touchButton:(id)sender {
    [audioFilePlayer play];
}
@end

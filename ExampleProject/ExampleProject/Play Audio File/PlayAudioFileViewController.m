//
//  PlayAudioFileViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileViewController.h"
#import "OCSManager.h"
#import "AudioFilePlayer.h"

@interface PlayAudioFileViewController () {
    AudioFilePlayer *audioFilePlayer;
}
@end

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
    float mult = (arc4random()%51)/100.0f + 0.75f;
    [audioFilePlayer playWithFrequencyMultiplier:mult];
}
@end

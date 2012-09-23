//
//  PlayAudioFileViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "AudioFilePlayer.h"

@interface PlayAudioFileViewController () {
    AudioFilePlayer *audioFilePlayer;
    OCSOrchestra *orchestra;
}
@end

@implementation PlayAudioFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create the orchestra and instruments
    orchestra = [[OCSOrchestra alloc] init];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    
    // Add instruments to orchestra
    [orchestra addInstrument:audioFilePlayer];
    
    // Start the orchestra
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];

}

- (IBAction)touchButton:(id)sender {
    AudioFilePlayerNote *note = [audioFilePlayer createNote];
    note.speed.value = [Helper randomFloatFrom:kSpeedMin to:kSpeedMax];
}


@end

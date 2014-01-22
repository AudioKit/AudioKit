//
//  PlayAudioFileViewController.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileViewController.h"
#import "AKManager.h"
#import "AudioFilePlayer.h"

@interface PlayAudioFileViewController () {
    AudioFilePlayer *audioFilePlayer;
    AKOrchestra *orchestra;
}
@end

@implementation PlayAudioFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create the orchestra and instruments
    orchestra = [[AKOrchestra alloc] init];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    
    // Add instruments to orchestra
    [orchestra addInstrument:audioFilePlayer];
    
    // Start the orchestra
    [[AKManager sharedAKManager] runOrchestra:orchestra];

}

- (IBAction)touchButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}


@end

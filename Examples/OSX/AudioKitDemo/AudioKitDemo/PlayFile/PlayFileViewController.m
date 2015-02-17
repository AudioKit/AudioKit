//
//  PlayFileViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "PlayFileViewController.h"
#import "AKFoundation.h"
#import "AudioFilePlayer.h"

@implementation PlayFileViewController
{
    AudioFilePlayer *audioFilePlayer;
}

- (void)viewDidAppear {
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];
    [AKOrchestra start];
}

- (void)viewDidDisappear {
    [audioFilePlayer stop];
    [[AKManager sharedManager] stop];
    [AKOrchestra reset];
}

- (IBAction)touchPlayButton:(id)sender
{
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    note.duration.value = 4.0; //seconds maximum
    [audioFilePlayer playNote:note];
}

@end

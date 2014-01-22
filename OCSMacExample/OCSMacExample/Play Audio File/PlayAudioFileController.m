//
//  PlayAudioFileController.m
//  AKMacExample
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileController.h"
#import "AKManager.h"
#import "AudioFilePlayer.h"

@interface PlayAudioFileController () {
    AudioFilePlayer *audioFilePlayer;
    AKOrchestra *orchestra;
}
@end

@implementation PlayAudioFileController

- (IBAction)start:(id)sender {
    orchestra = [[AKOrchestra alloc] init];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [orchestra addInstrument:audioFilePlayer];
    [[AKManager sharedAKManager] runOrchestra:orchestra];
}

- (IBAction)stop:(id)sender {
    [[AKManager sharedAKManager] stop];
}

- (IBAction)touchButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}

@end

//
//  PlayAudioFileController.m
//  OCSMacExample
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "PlayAudioFileController.h"
#import "Helper.h"
#import "AudioFilePlayer.h"

@interface PlayAudioFileController () {
    AudioFilePlayer *audioFilePlayer;
    OCSOrchestra *orchestra;
}
@end

@implementation PlayAudioFileController

- (IBAction)start:(id)sender {
    orchestra = [[OCSOrchestra alloc] init];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [orchestra addInstrument:audioFilePlayer];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
}

- (IBAction)stop:(id)sender {
    [[OCSManager sharedOCSManager] stop];
}

- (IBAction)touchButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}

@end

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

- (IBAction)touchButton:(id)sender {
    float speed = [Helper randomFloatFrom:kSpeedMin to:kSpeedMax];
    OCSEvent *start = [[OCSEvent alloc]initWithInstrument:audioFilePlayer];
    [start setNoteProperty:[audioFilePlayer speed] toValue:speed];
    [[OCSManager sharedOCSManager] triggerEvent:start];
    OCSEvent *stop = [[OCSEvent alloc] initDeactivation:start afterDuration:5.0f/speed];
    [[OCSManager sharedOCSManager] triggerEvent:stop];
}

@end

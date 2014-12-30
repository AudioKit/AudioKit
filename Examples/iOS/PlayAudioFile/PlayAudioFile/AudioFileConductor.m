//
//  AudioFileConductor.m
//  PlayAudioFile
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AudioFileConductor.h"
#import "AKFoundation.h"
#import "AudioFilePlayer.h"

@implementation AudioFileConductor
{
    AudioFilePlayer *audioFilePlayer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Create the orchestra and instruments
        audioFilePlayer = [[AudioFilePlayer alloc] init];
        [AKOrchestra addInstrument:audioFilePlayer];
        [AKOrchestra start];
    }
    return self;
}

- (IBAction)touchPlayButton:(id)sender
{
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    note.duration.value = 4.0; //seconds maximum
    [audioFilePlayer playNote:note];
}
@end

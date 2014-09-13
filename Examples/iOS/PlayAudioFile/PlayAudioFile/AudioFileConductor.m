//
//  AudioFileConductor.m
//  PlayAudioFile
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 h4y. All rights reserved.
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
        AKOrchestra *orchestra = [[AKOrchestra alloc] init];
        audioFilePlayer = [[AudioFilePlayer alloc] init];
        
        // Add instruments to orchestra
        [orchestra addInstrument:audioFilePlayer];
        
        // Start the orchestra
        [[AKManager sharedAKManager] runOrchestra:orchestra];
    }
    return self;
}

- (IBAction)touchPlayButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}
@end

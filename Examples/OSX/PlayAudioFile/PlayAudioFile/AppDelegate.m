//
//  AppDelegate.m
//  PlayAudioFile
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "AudioFilePlayer.h"

@interface AppDelegate () {
    AudioFilePlayer *audioFilePlayer;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AKOrchestra *orchestra = [[AKOrchestra alloc] init];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    
    // Add instruments to orchestra
    [orchestra addInstrument:audioFilePlayer];
    
    // Start the orchestra
    [[AKManager sharedAKManager] runOrchestra:orchestra];
}

- (IBAction)touchPlayButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}

@end

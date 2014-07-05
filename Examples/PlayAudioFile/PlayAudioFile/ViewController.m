//
//  ViewController.m
//  PlayAudioFile
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "AudioFilePlayer.h"

@interface ViewController () {
    AudioFilePlayer *audioFilePlayer;
    AKOrchestra *orchestra;
}
@end

@implementation ViewController

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

- (IBAction)touchPlayButton:(id)sender {
    AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
    [note.speed randomize];
    [audioFilePlayer playNote:note];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

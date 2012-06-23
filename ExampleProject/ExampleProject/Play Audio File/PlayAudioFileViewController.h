//
//  PlayAudioFileViewController.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"

@interface PlayAudioFileViewController : UIViewController {
    AudioFilePlayer * audioFilePlayer;
}

- (IBAction)touchButton:(id)sender;

@end

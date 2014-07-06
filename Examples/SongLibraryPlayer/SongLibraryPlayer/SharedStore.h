//
//  SharedStore.h
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"
#import "AudioFilePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SharedStore : NSObject

@property (nonatomic, retain) AKOrchestra *orchestra;
@property (nonatomic, retain) AudioFilePlayer *audioFilePlayer;
@property (nonatomic, strong) MPMediaItem *currentSong;
@property (nonatomic, strong) AudioFilePlayerNote *currentPlayback;
@property (nonatomic) BOOL isPlaying;

// message from which our instance is obtained
+ (SharedStore *)globals;

@end

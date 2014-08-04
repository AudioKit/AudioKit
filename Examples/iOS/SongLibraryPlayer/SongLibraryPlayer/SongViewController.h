//
//  SongViewController.h
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SongViewController : UIViewController
@property (nonatomic, strong) MPMediaItem *song;
@end

//
//  SongViewController.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "SongViewController.h"
#import "SharedStore.h"
#import "AKFoundation.h"
#import "AudioFilePlayer.h"

@interface SongViewController () {
    NSString *exportPath;
    SharedStore *global;
}
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@end

@implementation SongViewController

- (void)setSong:(MPMediaItem *)song {
    global = [SharedStore globals];
    
    if ([[song  valueForProperty:MPMediaItemPropertyPersistentID] integerValue] !=
        [[global.currentSong valueForProperty:MPMediaItemPropertyPersistentID] integerValue]) {
        [[AKManager sharedAKManager] stop];
        global.isPlaying = NO;
        _song = song;
        global.currentSong = song;
        [self exportSong:song];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MPMediaItemArtwork *artwork = [global.currentSong valueForProperty:MPMediaItemPropertyArtwork];
    self.albumImageView.image = [artwork imageWithSize:self.view.bounds.size];
    if (global.isPlaying) {
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)play:(id)sender {
    global = [SharedStore globals];
    if ([[(UIButton *)sender titleLabel].text isEqualToString:@"Play"]) {
        [self loadSong];
        global.currentPlayback = [[AudioFilePlayerNote alloc] init];
        [global.audioFilePlayer playNote:global.currentPlayback];
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        global.isPlaying = YES;
    } else {
        [global.audioFilePlayer stop];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        global.isPlaying = NO;
    }

}

- (void)loadSong {
    global = [SharedStore globals];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath] == NO) {
        NSLog(@"File does not exist.");
        return;
    }
    // Create the orchestra and instruments
    global.audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:global.audioFilePlayer];
    [AKOrchestra start];
}


-(void) exportSong:(MPMediaItem *)song {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    exportPath = [NSString stringWithFormat:@"%@/exported.wav", documentsDirectory];
    
    NSURL *url = [song valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];

    NSError *assetError = nil;
    AVAssetReader *assetReader = nil;
    @try {
        assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
        if (assetError) NSLog(@"Error: %@", assetError);
    }
    @catch (NSException *exception) {
        NSLog(@"Error");
    }
    
    
    // Create an asset reader ouput and add it to the reader.
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings:nil];
    if (![assetReader canAddOutput:assetReaderOutput])
        NSLog(@"cant add reader output...die!");
    [assetReader addOutput:assetReaderOutput];
    
    
    // If a file already exists at the export path, remove it.
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        NSLog(@"Deleting said file.");
    [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    
    // Create an asset writer with the export path.
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&assetError];
    if (assetError) { NSLog(@"Error: %@", assetError); return; }
    
    // Define the format settings for the asset writer.  Defined in AVAudioSettings.h
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];
    
    // Create a writer input to encode and write samples in this format.
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    
    // Add the input to the writer.
    if ([assetWriter canAddInput:assetWriterInput])
        [assetWriter addInput:assetWriterInput];
    else { NSLog(@"cant add asset writer input...die!"); return; }
    
    // Change this property to YES if you want to start using
    // the data immediately.
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    // Start reading from the reader and writing to the writer.
    [assetWriter startWriting];
    [assetReader startReading];
    
    // Set the session start time.
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake(0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime:startTime];
    
    // Variable to store the converted bytes.
    __block UInt64 convertedByteCount = 0;
    __block float buffers = 0;
    
    // Create a queue to which the writing block with be submitted.
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
    // Instruct the writer input to invoke a block repeatedly, at its convenience, in
    // order to gather media data for writing to the output.
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^
     {
         // While the writer input can accept more samples, keep appending its buffers
         // with buffers read from the reader output.
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 [assetWriterInput appendSampleBuffer:nextBuffer]; // append buffer
                 // Increment byte count.
                 convertedByteCount += CMSampleBufferGetTotalSampleSize(nextBuffer);
                 buffers += .0002;
             } else {
                 // All done
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWritingWithCompletionHandler:^{
                     //[self loadSong];
                 }];
                 [assetReader cancelReading];
                 break;
             }
             CFRelease(nextBuffer);
         }
     }];
    
}

@end

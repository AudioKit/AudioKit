//
//  AKSettings.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/8/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSettings.h"
#import "AKManager.h"

@implementation AKSettings

static AKSettings *_settings = nil;

+ (AKSettings *)shared
{
    @synchronized(self) {
        if (_settings == nil)
            _settings = [[AKSettings alloc] init];
    }
    return _settings;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Sensible defaults
        _audioOutput = @"dac";
        _audioInput = @"adc";
        _sampleRate = 44100;
        _samplesPerControlPeriod = 64;
        _numberOfChannels = 2;
        _zeroDBFullScaleValue = 1.0;
        _loggingEnabled = NO;
        _messagesEnabled = NO;
        _audioInputEnabled = NO;
        _playbackWhileMuted = NO;
        _MIDIEnabled = YES;
        
        // Try to load from AudioKit.plist if found
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
        if (path) {
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
            if (dict[@"Audio Output"])
                _audioOutput = [dict[@"Audio Output"] copy];
            if (dict[@"Audio Input"])
                _audioInput = [dict[@"Audio Input"] copy];
            if (dict[@"Sample Rate"])
                _sampleRate = [dict[@"Sample Rate"] unsignedIntValue];
            if (dict[@"Samples Per Control Period"])
                _samplesPerControlPeriod = [dict[@"Samples Per Control Period"] unsignedIntValue];
            if (dict[@"Number Of Channels"])
                _numberOfChannels = [dict[@"Number Of Channels"] unsignedIntValue];
            if (dict[@"Zero dB Full Scale Value"])
                _zeroDBFullScaleValue = [dict[@"Zero dB Full Scale Value"] floatValue];
            if (dict[@"Enable Logging By Default"])
                _loggingEnabled = [dict[@"Enable Logging By Default"] boolValue];
            if (dict[@"Enable Audio Input By Default"])
                _audioInputEnabled = [dict[@"Enable Audio Input By Default"] boolValue];
            if (dict[@"Prefix Csound Messages"])
                _messagesEnabled = [dict[@"Prefix Csound Messages"] boolValue];
            if (dict[@"Playback While Muted"])
                _playbackWhileMuted = [dict[@"Playback While Muted"] boolValue];
            if (dict[@"MIDI Enabled"])
                _MIDIEnabled = [dict[@"MIDI Enabled"] boolValue];
        }
    }
    return self;
}

#pragma mark - Property setters that trigger some sort of action

- (void)setAudioInputEnabled:(BOOL)audioInputEnabled
{
    if (audioInputEnabled != _audioInputEnabled) {
        _audioInputEnabled = audioInputEnabled;
        [[AKManager sharedManager].engine resetSession];
    }
}

- (void)setPlaybackWhileMuted:(BOOL)playbackWhileMuted
{
    if (playbackWhileMuted != _playbackWhileMuted) {
        _playbackWhileMuted = playbackWhileMuted;
        [[AKManager sharedManager].engine resetSession];
    }
}

@end

//
//  AKSettings-Bridge.m
//  AudioKit
//
//  Created by Stéphane Peter on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioKit/AudioKit-Swift.h>

#import "AKSettings-Bridge.h"

// Exports the AKSettings properties to vanilla C, for Soundpipe

double _AKSettings_sampleRate(void)
{
    return AKSettings.sampleRate;
}

short _AKSettings_numberOfChannels(void)
{
    return AKSettings.numberOfChannels;
}

int _AKSettings_audioInputEnabled(void)
{
    return AKSettings.audioInputEnabled;
}

int _AKSettings_playbackWhileMuted(void)
{
    return AKSettings.playbackWhileMuted;
}
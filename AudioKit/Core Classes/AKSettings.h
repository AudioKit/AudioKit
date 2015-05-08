//
//  AKSettings.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/8/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKCompatibility.h"

// These values are initialized from AudioKit.plist if it is present in the app bundle

NS_ASSUME_NONNULL_BEGIN
@interface AKSettings : NSObject

+ (AKSettings *)settings;

@property (nonatomic) NSString *audioInput, *audioOutput;
@property (nonatomic) UInt32 sampleRate, samplesPerControlPeriod;
@property (nonatomic) UInt16 numberOfChannels;
@property (nonatomic) float  zeroDBFullScaleValue;
@property (nonatomic) BOOL   loggingEnabled, messagesEnabled;
@property (nonatomic) BOOL   audioInputEnabled, playbackWhileMuted;

@end
NS_ASSUME_NONNULL_END

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

@property (nonatomic, readonly) NSString *audioInput, *audioOutput;
@property (nonatomic, readonly) UInt32 sampleRate, samplesPerControlPeriod;
@property (nonatomic, readonly) UInt16 numberOfChannels;
@property (nonatomic, readonly) float zeroDBFullScaleValue;
@property (nonatomic, readonly) BOOL loggingEnabled, audioInputEnabled, messagesEnabled;

@end
NS_ASSUME_NONNULL_END

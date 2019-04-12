//
//  AKPresetManager.h
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

/// AKPresetZone and AKPresetManager create AUPreset Dictionaries that can be loaded by
/// an AUSampler or AVAudioUnitSampler.
@interface AKPresetZone : NSObject
@property BOOL                  enabled;
@property BOOL                  loopEnabled;
@property BOOL                  pitchTracking;
@property int                   maxKey;
@property int                   minKey;
@property int                   rootKey;
@property NSString * _Nonnull   filePath;

/// Initializes to a non pitch tracking sample (ie: for drums)
-(instancetype _Nullable)initWithFilePath:(NSString * _Nonnull)filePath andKey:(int)key;

/// Initializes to a non pitch tracking sample (ie: for drums)
+(AKPresetZone * _Nullable)zoneWithFilePath:(NSString * _Nonnull)filePath andKey:(int)key;
@end

@interface AKPresetManager : NSObject

/// This creates a preset where each file's note is set to it's index in the filePaths array.
+(NSDictionary * _Nullable)presetWithFilePaths:(NSArray <NSString *>* _Nonnull)filePaths oneShot:(BOOL)oneShot;

/// Creates a preset with an array of zones
+(NSDictionary * _Nullable)presetWithZones:(NSArray <AKPresetZone *> * _Nonnull)presetZones oneShot:(BOOL)oneShot;

/// Retrieve preset from a sampler audio unit.
+(NSDictionary * _Nullable)samplerPreset:(AudioUnit _Nonnull)samplerUnit;

/// Set thre preset for a sampler
+(BOOL)setPreset:(NSDictionary * _Nonnull)preset forSampler:(AudioUnit _Nonnull)sampler error:(NSError *_Nullable * _Nullable)outError;
@end

/// Convenience methods for setting ang getting preset.
@interface AVAudioUnitSampler (PresetLoading)
@property NSDictionary * _Nullable preset;
@end

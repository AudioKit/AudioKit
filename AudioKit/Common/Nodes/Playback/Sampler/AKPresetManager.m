//
//  AKPresetManager.m
//
//  Created by David O'Neill on 1/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKPresetManager.h"
#import <AudioKit/AudioKit-Swift.h>


#define FILEREFPREFIX @"Sample:"
#define STARTINGWAVEFORMID 268435457


@interface NSDictionary (aupreset)
@property (readonly)    NSMutableDictionary *fileReferences;
@property (readonly)    NSMutableArray      *layers;
@property               BOOL                oneShot;
@end

@implementation NSDictionary (aupreset)
-(NSMutableDictionary *)fileReferences{
    return self[@"file-references"];
}
-(NSMutableArray <NSDictionary *> *)layers{
    return self[@"Instrument"][@"Layers"];
}
-(NSMutableArray *)zones{
    return self.layers[0][@"Zones"];
}
-(BOOL)oneShot{
    NSNumber *oneShot = self.layers[0][@"trigger mode"];
    return oneShot && [oneShot isEqual:@11] ? YES : NO;
}
-(void)setOneShot:(BOOL)oneShot{
    if (oneShot) {
        self.layers[0][@"trigger mode"] = @11;
    }
    else{
        [self.layers[0] removeObjectForKey:@"trigger mode"];
    }
}

@end


@interface AKPresetZone ()
@property NSNumber *ID;
@property NSNumber  *waveform;
@end
@implementation AKPresetZone
-(NSDictionary *)asDictionary{
    return @{@"enabled":@(self.enabled),
             @"loop enabled":@(self.loopEnabled),
             @"max key":@(self.maxKey),
             @"min key":@(self.minKey),
             @"root key":@(self.rootKey),
             @"pitch tracking":@(self.pitchTracking),
             @"waveform":self.waveform,
             @"ID":self.ID};
}
-(instancetype)initWithFilePath:(NSString *)filePath andKey:(int)key{
    NSAssert([[NSFileManager defaultManager]fileExistsAtPath:filePath], @"No file at %@",filePath);
    self = [super init];
    if (self) {
        self.enabled = 1;
        self.loopEnabled = 0;
        self.maxKey = self.minKey = self.rootKey = key;
        self.pitchTracking = 0;
        self.filePath = filePath;
    }
    return self;
}
+(AKPresetZone *)zoneWithFilePath:(NSString *)filePath andKey:(int)key{
    return [[AKPresetZone alloc]initWithFilePath:filePath andKey:key];
}
@end


@implementation AKPresetManager
+(NSDictionary *)presetWithFilePaths:(NSArray <NSString *>*)filePaths oneShot:(BOOL)oneShot{
    NSMutableArray *zones = [[NSMutableArray alloc]initWithCapacity:filePaths.count];
    for (int i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSAssert([[NSFileManager defaultManager]fileExistsAtPath:filePath], @"No file at %@",filePath);
        [zones addObject:[AKPresetZone zoneWithFilePath:filePath andKey:i]];
    }
    return [AKPresetManager presetWithZones:zones oneShot:1];
}
+(NSDictionary *)presetWithZones:(NSArray <AKPresetZone *> *)presetZones oneShot:(BOOL)oneShot{
    NSMutableDictionary *preset = mutableSkeleton();
    NSDictionary *waveFormIds = waveformsPathIndexed(presetZones);
    if(!waveFormIds)return NULL;
    for (NSString *path in waveFormIds.allKeys) {
        NSNumber *waveFormId = waveFormIds[path];
        NSString *sampleKey = [FILEREFPREFIX stringByAppendingString:waveFormId.stringValue];
        preset.fileReferences[sampleKey] = path;
    }
    int ID = 1;
    for (AKPresetZone *presetZone in presetZones) {
        presetZone.ID = @(ID);
        presetZone.waveform = waveFormIds[presetZone.filePath];
        [preset.zones addObject:presetZone.asDictionary];
    }
    preset.oneShot = oneShot;
    return preset;
}
+(NSDictionary *)samplerPreset:(AudioUnit)samplerUnit{
    CFPropertyListRef presetPlist;
    UInt32 presetPlistSize;
    AudioUnitGetProperty(samplerUnit, kAudioUnitProperty_ClassInfo, kAudioUnitScope_Global, 0, &presetPlist, &presetPlistSize);
    NSDictionary *presetDict = (__bridge_transfer NSDictionary *)presetPlist;
    return presetDict;
}
+(BOOL)setPreset:(NSDictionary *)preset forSampler:(AudioUnit)sampler error:(NSError **)outError{
    CFPropertyListRef presetPlist = (__bridge CFPropertyListRef)preset;
    OSStatus status = AudioUnitSetProperty(sampler,kAudioUnitProperty_ClassInfo,kAudioUnitScope_Global,0,&presetPlist,sizeof(presetPlist));
    if (status) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                            code:(int)status
                                        userInfo:@{NSLocalizedDescriptionKey:@"Set sampler preset fail"}];
        } else {
            NSLog(@"Set sampler preset fail OSStatus %i", (int)status);
        }
        return false;
    }
    return true;
}

NSDictionary *waveformsPathIndexed(NSArray <AKPresetZone *> *presetZones) {
    NSSet *filePaths = [NSSet setWithArray:[presetZones valueForKey:@"filePath"]];
    NSMutableDictionary *waveformsPathIndexed = [[NSMutableDictionary alloc]init];
    int nextWaveformId = STARTINGWAVEFORMID;
    for (NSString *path in filePaths) {
        waveformsPathIndexed[path] = @(nextWaveformId);
        nextWaveformId++;
    }
    return waveformsPathIndexed;
}
NSMutableDictionary *mutableSkeleton() {
    static NSDictionary *skeleton = NULL;
    if (!skeleton) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[AKOscillator class]];
        NSString *skeletonPath = [[frameworkBundle resourcePath] stringByAppendingPathComponent:@"Skeleton.aupreset"];
        NSCAssert([NSFileManager.defaultManager fileExistsAtPath:skeletonPath],@"Skeleton file not found");
        skeleton = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:skeletonPath]];
    }
    
    
    NSMutableDictionary *_preset = skeleton.mutableCopy;
    _preset[@"file-references"] = [NSMutableDictionary new];
    NSMutableDictionary *_instrument = _preset[@"Instrument"] = [_preset[@"Instrument"] mutableCopy];
    NSMutableArray *layers = _instrument[@"Layers"] = [_instrument[@"Layers"]mutableCopy];
    NSMutableDictionary *layersObject = layers[0] = [layers[0] mutableCopy];
    layersObject[@"Zones"] = [layersObject[@"Zones"] mutableCopy];
    return _preset;
}
@end

@implementation AVAudioUnitSampler (PresetLoading)
-(void)setPreset:(NSDictionary *)preset {
    NSError *error = nil;
    if (![AKPresetManager setPreset:preset forSampler:self.audioUnit error:&error]) {
        NSLog(@"%@",error);
    }
}
- (NSDictionary *)preset {
    return [AKPresetManager samplerPreset:self.audioUnit];
}
@end



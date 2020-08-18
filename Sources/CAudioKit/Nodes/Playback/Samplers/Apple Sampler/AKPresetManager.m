// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPresetManager.h"
//#import <AudioKit/AudioKit-Swift.h>


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
    NSDictionary *waveformIDs = waveformsPathIndexed(presetZones);
    if(!waveformIDs)return NULL;
    for (NSString *path in waveformIDs.allKeys) {
        NSNumber *waveformID = waveformIDs[path];
        NSString *sampleKey = [FILEREFPREFIX stringByAppendingString:waveformID.stringValue];
        preset.fileReferences[sampleKey] = path;
    }
    int ID = 1;
    for (AKPresetZone *presetZone in presetZones) {
        presetZone.ID = @(ID);
        presetZone.waveform = waveformIDs[presetZone.filePath];
        [preset.zones addObject:presetZone.asDictionary];
    }
    preset.oneShot = oneShot;
    return preset;
}
+(NSDictionary *)samplerPreset:(AudioUnit)samplerUnit{
    CFPropertyListRef presetPList;
    UInt32 presetPListSize;
    AudioUnitGetProperty(samplerUnit, kAudioUnitProperty_ClassInfo, kAudioUnitScope_Global, 0, &presetPList, &presetPListSize);
    NSDictionary *presetDict = (__bridge_transfer NSDictionary *)presetPList;
    return presetDict;
}
+(BOOL)setPreset:(NSDictionary *)preset forSampler:(AudioUnit)sampler error:(NSError **)outError{
    CFPropertyListRef presetPList = (__bridge CFPropertyListRef)preset;
    OSStatus status = AudioUnitSetProperty(sampler,kAudioUnitProperty_ClassInfo,kAudioUnitScope_Global,0,&presetPList,sizeof(presetPList));
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
    int nextWaveformID = STARTINGWAVEFORMID;
    for (NSString *path in filePaths) {
        waveformsPathIndexed[path] = @(nextWaveformID);
        nextWaveformID++;
    }
    return waveformsPathIndexed;
}

NSMutableDictionary *mutableSkeleton() {
    static const char *skeletonXML = // The contents of the Skeleton.aupreset file
    " <?xml version=\"1.0\" encoding=\"UTF-8\"?> "
    " <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> "
    " <plist version=\"1.0\"> "
    " <dict> "
    "     <key>AU version</key> "
    "     <real>1</real> "
    "     <key>Instrument</key> "
    "     <dict> "
    "         <key>Layers</key> "
    "         <array> "
    "             <dict> "
    "                 <key>trigger mode</key> "
    "                 <integer>11</integer> "
    "                 <key>Amplifier</key> "
    "                 <dict> "
    "                     <key>ID</key> "
    "                     <integer>0</integer> "
    "                     <key>enabled</key> "
    "                     <true/> "
    "                 </dict> "
    "                 <key>Connections</key> "
    "                 <array> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>0</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>816840704</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <false/> "
    "                         <key>scale</key> "
    "                         <real>12800</real> "
    "                         <key>source</key> "
    "                         <integer>300</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>1</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>1343225856</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <true/> "
    "                         <key>scale</key> "
    "                         <real>-96</real> "
    "                         <key>source</key> "
    "                         <integer>301</integer> "
    "                         <key>transform</key> "
    "                         <integer>2</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>2</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>1343225856</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <true/> "
    "                         <key>scale</key> "
    "                         <real>-96</real> "
    "                         <key>source</key> "
    "                         <integer>7</integer> "
    "                         <key>transform</key> "
    "                         <integer>2</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>3</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>1343225856</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <true/> "
    "                         <key>scale</key> "
    "                         <real>-96</real> "
    "                         <key>source</key> "
    "                         <integer>11</integer> "
    "                         <key>transform</key> "
    "                         <integer>2</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>4</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>1344274432</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <false/> "
    "                         <key>max value</key> "
    "                         <real>0.5080000162124634</real> "
    "                         <key>min value</key> "
    "                         <real>-0.5080000162124634</real> "
    "                         <key>source</key> "
    "                         <integer>10</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>7</integer> "
    "                         <key>control</key> "
    "                         <integer>241</integer> "
    "                         <key>destination</key> "
    "                         <integer>816840704</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <false/> "
    "                         <key>max value</key> "
    "                         <real>12800</real> "
    "                         <key>min value</key> "
    "                         <real>-12800</real> "
    "                         <key>source</key> "
    "                         <integer>224</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>8</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>816840704</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <false/> "
    "                         <key>max value</key> "
    "                         <real>100</real> "
    "                         <key>min value</key> "
    "                         <real>-100</real> "
    "                         <key>source</key> "
    "                         <integer>242</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>6</integer> "
    "                         <key>control</key> "
    "                         <integer>1</integer> "
    "                         <key>destination</key> "
    "                         <integer>816840704</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <false/> "
    "                         <key>max value</key> "
    "                         <real>50</real> "
    "                         <key>min value</key> "
    "                         <real>-50</real> "
    "                         <key>source</key> "
    "                         <integer>268435456</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>5</integer> "
    "                         <key>control</key> "
    "                         <integer>0</integer> "
    "                         <key>destination</key> "
    "                         <integer>1343225856</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                         <key>inverse</key> "
    "                         <true/> "
    "                         <key>scale</key> "
    "                         <real>-96</real> "
    "                         <key>source</key> "
    "                         <integer>536870912</integer> "
    "                         <key>transform</key> "
    "                         <integer>1</integer> "
    "                     </dict> "
    "                 </array> "
    "                 <key>Envelopes</key> "
    "                 <array> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>0</integer> "
    "                         <key>Stages</key> "
    "                         <array> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>20</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>0</integer> "
    "                                 <key>time</key> "
    "                                 <real>0</real> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>22</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>1</integer> "
    "                                 <key>time</key> "
    "                                 <real>0</real> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>20</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>2</integer> "
    "                                 <key>time</key> "
    "                                 <real>0</real> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>20</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>3</integer> "
    "                                 <key>time</key> "
    "                                 <real>0</real> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>level</key> "
    "                                 <real>1</real> "
    "                                 <key>stage</key> "
    "                                 <integer>4</integer> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>20</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>5</integer> "
    "                                 <key>time</key> "
    "                                 <real>0</real> "
    "                             </dict> "
    "                             <dict> "
    "                                 <key>curve</key> "
    "                                 <integer>20</integer> "
    "                                 <key>stage</key> "
    "                                 <integer>6</integer> "
    "                                 <key>time</key> "
    "                                 <real>0.004999999888241291</real> "
    "                             </dict> "
    "                         </array> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                     </dict> "
    "                 </array> "
    "                 <key>Filters</key> "
    "                 <dict> "
    "                     <key>ID</key> "
    "                     <integer>0</integer> "
    "                     <key>cutoff</key> "
    "                     <real>20000</real> "
    "                     <key>enabled</key> "
    "                     <false/> "
    "                     <key>resonance</key> "
    "                     <real>0</real> "
    "                     <key>type</key> "
    "                     <integer>40</integer> "
    "                 </dict> "
    "                 <key>ID</key> "
    "                 <integer>0</integer> "
    "                 <key>LFOs</key> "
    "                 <array> "
    "                     <dict> "
    "                         <key>ID</key> "
    "                         <integer>0</integer> "
    "                         <key>enabled</key> "
    "                         <true/> "
    "                     </dict> "
    "                 </array> "
    "                 <key>Oscillator</key> "
    "                 <dict> "
    "                     <key>ID</key> "
    "                     <integer>0</integer> "
    "                     <key>enabled</key> "
    "                     <true/> "
    "                 </dict> "
    "                 <key>Zones</key> "
    "                 <array/> "
    "             </dict> "
    "         </array> "
    "         <key>name</key> "
    "         <string>Default Instrument</string> "
    "     </dict> "
    "     <key>coarse tune</key> "
    "     <integer>0</integer> "
    "     <key>data</key> "
    "     <data>AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=</data> "
    "     <key>file-references</key> "
    "     <dict/> "
    "     <key>fine tune</key> "
    "     <real>0</real> "
    "     <key>gain</key> "
    "     <real>0</real> "
    "     <key>manufacturer</key> "
    "     <integer>1634758764</integer> "
    "     <key>name</key> "
    "     <string>Skeleton</string> "
    "     <key>output</key> "
    "     <integer>0</integer> "
    "     <key>pan</key> "
    "     <real>0</real> "
    "     <key>subtype</key> "
    "     <integer>1935764848</integer> "
    "     <key>type</key> "
    "     <integer>1635085685</integer> "
    "     <key>version</key> "
    "     <integer>0</integer> "
    "     <key>voice count</key> "
    "     <integer>64</integer> "
    " </dict> "
    " </plist> ";

    static NSDictionary *skeleton = NULL;
    if (!skeleton) {
        NSError *error = nil;
        skeleton = [NSPropertyListSerialization propertyListWithData:[NSData dataWithBytes:skeletonXML length:strlen(skeletonXML)]
                                                             options:NSPropertyListImmutable
                                                              format:nil
                                                               error:&error];
        NSCAssert(error == nil, @"Failed to parse skeleton with error: %@", error);
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



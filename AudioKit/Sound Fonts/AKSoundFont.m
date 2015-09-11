//
//  AKSoundFont.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFont.h"

// Private methods
@interface AKSoundFont ()
- (void)_checkForCompletion;
@end

@implementation AKSoundFont
{
    BOOL _instrumentsLoaded, _presetsLoaded;
    NSMutableArray<AKSoundFontInstrument *> *_instruments;
    NSMutableArray<AKSoundFontPreset *> *_presets;
    AKSoundFontCompletionBlock _completionBlock;
}

static int currentID = 1;

+ (void)resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

- (NSArray<AKSoundFontInstrument *> *)instruments
{
    return _instrumentsLoaded ? _instruments : nil;
}

- (NSArray<AKSoundFontPreset *> *)presets
{
    return _presetsLoaded ? _presets : nil;
}

- (BOOL)loaded
{
    return _instrumentsLoaded && _presetsLoaded;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            _number = currentID++;
        }
        
        if (![[NSFileManager defaultManager] isReadableFileAtPath:filename]) {
            return nil;
        }
        
        _instruments = [NSMutableArray array];
        _presets = [NSMutableArray array];
        
        filename = [NSString stringWithFormat:@"\"%@\"", filename];
        NSString *orchString = [NSString stringWithFormat:
                                @"giSoundFont%d sfload %@\n"
                                @"sfpassign %d, giSoundFont%d\n",
                                self.number, filename, self.number, self.number];
        if ([[AKManager sharedManager] isLogging]) {
            NSLog(@"Sound Font: %@",orchString);
        }
        [[[AKManager sharedManager] engine] updateOrchestra:orchString];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageReceivedFromCsound:)
                                                     name:AKCsoundAPIMessageNotification
                                                   object:nil];
    }
    return self;
}

- (void)fetchPresets:(nullable AKSoundFontCompletionBlock)completionBlock
{
    _instrumentsLoaded = _presetsLoaded = NO;
    _completionBlock = completionBlock;
    NSString *instrumentListRequest = [NSString stringWithFormat:@"sfilistapi giSoundFont%d, %d", self.number, self.number];
    NSString *presetListRequest     = [NSString stringWithFormat:@"sfplistapi giSoundFont%d, %d", self.number, self.number];
    [[[AKManager sharedManager] engine] updateOrchestra:instrumentListRequest];
    [[[AKManager sharedManager] engine] updateOrchestra:presetListRequest];
}

- (void)_checkForCompletion
{
    if (_completionBlock && _instrumentsLoaded && _presetsLoaded) {
        _completionBlock(self);
        _completionBlock = nil;
    }
}

- (void)messageReceivedFromCsound:(NSNotification *)notification
{
    NSString *type = notification.userInfo[@"type"];
    NSArray<NSString *> *fields = [notification.userInfo[@"message"] componentsSeparatedByString:@","];
    
    int number;
    NSString *name;
    
    if ([type isEqualToString:@"SFP"]) { // Preset
        if ([fields[0] intValue] == self.number) {
            if ([fields[1] isEqualToString:@"END"]) {
                _presetsLoaded = YES;
                [self _checkForCompletion];
                return;
            }
            number = [fields[1] intValue];
            name = [fields[2] stringByReplacingOccurrencesOfString:@"'" withString:@""];
            int program = [fields[3] intValue];
            int bank    = [fields[4] intValue];
            
            AKSoundFontPreset *preset = [[AKSoundFontPreset alloc] initWithName:name
                                                                         number:number
                                                                        program:program
                                                                           bank:bank
                                                                      soundFont:self];
            [_presets addObject:preset];
        }
    } else if ([type isEqualToString:@"SFI"]) { // Instrument
        if ([fields[0] intValue] == self.number) {
            if ([fields[1] isEqualToString:@"END"]) {
                _instrumentsLoaded = YES;
                [self _checkForCompletion];
                return;
            }
            number = [fields[1] intValue];
            name = [fields[2] stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            AKSoundFontInstrument *instrument = [[AKSoundFontInstrument alloc] initWithName:name
                                                                                     number:number
                                                                                  soundFont:self];
            [_instruments addObject:instrument];
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"giSoundFont%d", _number];
}

- (AKSoundFontInstrument *)findInstrumentNamed:(NSString *)name
{
    if (_instrumentsLoaded) {
        for (AKSoundFontInstrument *inst in _instruments) {
            if ([inst.name isEqualToString:name]) {
                return inst;
            }
        }
    }
    return nil;
}

- (AKSoundFontPreset *)findPresetNamed:(NSString *)name
{
    if (_presetsLoaded) {
        for (AKSoundFontPreset *preset in _presets) {
            if ([preset.name isEqualToString:name]) {
                return preset;
            }
        }
    }
    return nil;
}

- (AKSoundFontPreset *)findPresetProgram:(NSUInteger)program fromBank:(NSUInteger)bank
{
    if (_presetsLoaded) {
        for (AKSoundFontPreset *preset in _presets) {
            if (preset.program==program && preset.bank==bank) {
                return preset;
            }
        }
    }
    return nil;
}

@end

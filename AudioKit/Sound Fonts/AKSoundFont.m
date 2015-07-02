//
//  AKSoundFont.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFont.h"

@implementation AKSoundFont

static int currentID = 1;

+ (void)resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            _number = currentID++;
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
        NSString *instrumentListRequest = [NSString stringWithFormat:@"sfilistapi giSoundFont%d, %d", self.number, self.number];
        NSString *presetListRequest     = [NSString stringWithFormat:@"sfplistapi giSoundFont%d, %d", self.number, self.number];
        [[[AKManager sharedManager] engine] updateOrchestra:instrumentListRequest];
        [[[AKManager sharedManager] engine] updateOrchestra:presetListRequest];
        
    }
    return self;
}

- (void)messageReceivedFromCsound:(NSNotification *)notification
{
    NSString *type = notification.userInfo[@"type"];
    NSArray *fields = [notification.userInfo[@"message"] componentsSeparatedByString:@","];
    
    int number;
    NSString *name;
    
    if ([type isEqualToString:@"SFP"]) { // Preset
        if ([fields[0] intValue] == self.number) {
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

@end

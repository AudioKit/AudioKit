//
//  AKSoundFont.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFont.h"
#import "AKManager.h"

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
                                                     name:@"CsoundMessage"
                                                   object:nil];
        NSString *instrumentListRequest = [NSString stringWithFormat:@"sfilist giSoundFont%d", self.number];
        NSString *presetListRequest     = [NSString stringWithFormat:@"sfplist giSoundFont%d", self.number];
        [[[AKManager sharedManager] engine] updateOrchestra:instrumentListRequest];
        [[[AKManager sharedManager] engine] updateOrchestra:presetListRequest];
        
    }
    return self;
}

- (void)messageReceivedFromCsound:(NSNotification *)notification
{
    NSString *message = notification.userInfo[@"message"];
    
 
    NSRange range = [message rangeOfString:@"^[0-9]+\\)" options:NSRegularExpressionSearch];

    if (range.location != NSNotFound) {
        if ([message containsString:@"prog:"] && [message containsString:@"bank:"]) {
            // this is a preset
            [_presets addObject:message];
        } else {
            // this is an instrument
            [_instruments addObject:message];
        }
    }

    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"giSoundFont%d", _number];
}

@end

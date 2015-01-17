//
//  Conductor.m
//  Keyboard
//
//  Created by Aurelius Prochazka on 1/3/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "Conductor.h"
#import "AKFoundation.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@implementation Conductor
{
    ToneGenerator *toneGenerator;
    EffectsProcessor *fx;
    NSArray *frequencies;
    NSMutableDictionary *currentNotes;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        frequencies = @[@523.25, @554.37, @587.33, @622.25, @659.26, @698.46, @739.99, @783.99, @830.61, @880, @932.33, @987.77, @1046.5];
        currentNotes = [NSMutableDictionary dictionary];
        
        // Create and add instruments to the orchestra
        toneGenerator = [[ToneGenerator alloc] init];
        fx = [[EffectsProcessor alloc] initWithAudioSource:toneGenerator.auxilliaryOutput];
        [AKOrchestra addInstrument:toneGenerator];
        [AKOrchestra addInstrument:fx];
        
        [AKOrchestra start];
        
        [fx play];
    }
    return self;
}

- (void)play:(NSInteger)key
{
    float frequency = [[frequencies objectAtIndex:key] floatValue];
    ToneGeneratorNote *note = [[ToneGeneratorNote alloc] initWithFrequency:frequency];
    [toneGenerator playNote:note];
    [currentNotes setObject:note forKey:[NSNumber numberWithInt:(int)key]];
}

- (void)release:(NSInteger)key
{
    ToneGeneratorNote *noteToRelease = [currentNotes objectForKey:[NSNumber numberWithInt:(int)key]];
    
    [noteToRelease stop];
    
    [currentNotes removeObjectForKey:[NSNumber numberWithInt:(int)key]];
}

- (void)setReverbFeedbackLevel:(float)feedbackLevel
{
    fx.reverb.value = feedbackLevel;
}

- (void)setToneColor:(float)toneColor
{
    toneGenerator.toneColor.value = toneColor;
}

@end

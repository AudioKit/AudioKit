//
//  MidiInstrumentPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Instrument : AKMidiInstrument
@end

@implementation Instrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self enableParameterLog:@"note number " parameter:self.note.notenumber timeInterval:1000];
        [self enableParameterLog:@"frequency   " parameter:self.note.frequency timeInterval:1000];
        [self enableParameterLog:@"velocity    " parameter:self.note.velocity timeInterval:1000];
        [self enableParameterLog:@"modulation  " parameter:self.note.modulation timeInterval:0.1];
        [self enableParameterLog:@"pitch bend  " parameter:self.note.pitchBend timeInterval:0.1];
        [self enableParameterLog:@"aftertouch  " parameter:self.note.aftertouch timeInterval:0.1];
    }
    return self;
}

@end

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic restart];

    Instrument *instrument = [[Instrument alloc] init];
    [AKOrchestra addInstrument:instrument];
    [instrument startListeningOnAllMidiChannels];

}

@end

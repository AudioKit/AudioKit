//
//  THXDeepNotePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#define boris_random(smallNumber, bigNumber) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (bigNumber - smallNumber)) + smallNumber)

@interface Buzz : AKNote
@property AKNoteProperty *normalFrequency;
@property AKNoteProperty *excitedFrequency;
@end

@interface Swarm : AKInstrument
@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *excitationLevel;
@end

@implementation Swarm

- (instancetype)initWithNumber:(NSUInteger)instrumentNumber
{
    self = [super initWithNumber:instrumentNumber];
    if (self) {

        Buzz *buzz = [[Buzz alloc] init];
        _amplitude = [self createPropertyWithValue:0.0 minimum:0.0 maximum:0.1];
        _excitationLevel = [self createPropertyWithValue:0 minimum:0 maximum:1];

        AKJitter *frequencyJitter = [[AKJitter alloc] initWithAmplitude:akp(30)
                                                       minimumFrequency:akp(1)
                                                       maximumFrequency:akp(3)];

        AKMix *excitedFrequency = [[AKMix alloc] initWithInput1:[buzz.normalFrequency plus:frequencyJitter]
                                                         input2:buzz.excitedFrequency
                                                        balance:_excitationLevel];

        AKVCOscillator *soundSource = [AKVCOscillator oscillator];
        soundSource.frequency = excitedFrequency;
        soundSource.amplitude = _amplitude;

        AKMoogVCF *filter = [AKMoogVCF presetDefaultFilterWithInput:soundSource];
        filter.cutoffFrequency = akp(1000);
        filter.resonance = akp(0.1);

        [self setAudioOutput:filter];
    }
    return self;
}
@end

@implementation Buzz

- (instancetype)init
{
    self = [super init];
    if (self) {
        _normalFrequency  = [self createPropertyWithValue:300
                                                  minimum:200
                                                  maximum:400];
        _excitedFrequency = [self createPropertyWithValue:(powf(2.0,(arc4random() % 3))
                                                           * 150.0f + boris_random(0, 5))
                                                  minimum:0
                                                  maximum:8000];
    }
    return self;
}
@end


@implementation Playground

- (void)run
{
    [super run];

    Swarm *swarm = [[Swarm alloc] initWithNumber:1];
    [AKOrchestra addInstrument:swarm];

    for (int i = 1; i <= 30; i++) {
        Buzz *buzz = [[Buzz alloc] init];
        [buzz.normalFrequency randomize];
        [swarm playNote:buzz];
    }

    [self addSliderForProperty:swarm.amplitude title:@"Amplitude"];
    [self addSliderForProperty:swarm.excitationLevel title:@"Excitation"];
    [self addButtonWithTitle:@"Stop" block:^{
        [swarm stop];
    }];

}
@end

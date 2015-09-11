//
//  AKInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"
#import "AKManager.h"
#import "AKAssignment.h"
#import "AKStereoAudio.h"
#import "AKAudioOutput.h"
#import "AKLog.h"
#import "AKParameterChangeLog.h"

@implementation AKInstrument
{
    NSMutableArray *innerCSDOperations;
    NSMutableArray *connectedOperations;
    AKSequence *repeater;
}


// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

static NSUInteger currentID = 1;

+ (void)resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Since instruments can add tables upon initialization,
        // Start the orchestra immediately
        [AKOrchestra start];
        @synchronized([self class]) {
            _instrumentNumber = currentID++;
        }
        _properties = [[NSMutableArray alloc] init];
        _noteProperties = [[NSMutableArray alloc] init];
        _globalParameters = [[NSMutableSet alloc] init];
        _userDefinedOperations = [[NSMutableSet alloc] init];
        connectedOperations = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)instrument
{
    return [[AKInstrument alloc] init];
}

+ (instancetype)instrumentWithNumber:(NSUInteger)instrumentNumber
{
    return [[AKInstrument alloc] initWithNumber:instrumentNumber];
}


- (instancetype)initWithNumber:(NSUInteger)instrumentNumber
{
    self = [self init];
    if (self) {
        _instrumentNumber = instrumentNumber;
    }
    return self;
}

- (NSString *)uniqueName
{
    NSString *className = [[[self class] description] stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [NSString stringWithFormat:@"%@%@", className, @(self.instrumentNumber)];
}

// -----------------------------------------------------------------------------
#  pragma mark - Properties
// -----------------------------------------------------------------------------


- (void) addProperty:(AKInstrumentProperty *)newProperty
{
    NSString *name = [NSString stringWithFormat:@"%@Property", [self uniqueName]];
    [self addProperty:newProperty withName:name];
}

- (void) addProperty:(AKInstrumentProperty *)newProperty
            withName:(NSString *)name;
{
    [_properties addObject:newProperty];
    [newProperty setName:name];
}

- (AKInstrumentProperty *)createPropertyWithValue:(float)value
                                          minimum:(float)minimum
                                          maximum:(float)maximum
{
    AKInstrumentProperty *property = [[AKInstrumentProperty alloc] initWithValue:value minimum:minimum maximum:maximum];
    [self addProperty:property];
    return property;
}


- (void)addNoteProperty:(AKNoteProperty *)newNoteProperty
{
    [_noteProperties addObject:newNoteProperty];
}



// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

- (void)connect:(AKParameter *)newOperation
{
    if (![connectedOperations containsObject:newOperation]) {
        [connectedOperations addObject:newOperation];
    }
}

- (void)internallyConnect:(AKParameter *)newOperation
{
    if ([newOperation.state isEqualToString:@"connecting"]) {
        [NSException raise:@"Cyclical Reference" format:@"Parameter: %@ is cyclically dependent on itself", newOperation];
    }
    
    if ([newOperation.state isEqualToString:@"connected"]) {
        return;
    }
    
    if ([newOperation.state isEqualToString:@"connectable"]) {
        newOperation.state = @"connecting";
        
        for (AKParameter *dependency in newOperation.dependencies) {
            [self internallyConnect:dependency];
        }
        [_userDefinedOperations addObject:[newOperation udoString]];
        [innerCSDOperations addObject:newOperation];
        newOperation.state  = @"connected";
    } else {
        if ([newOperation isKindOfClass:[AKInstrumentProperty class]]) {
            [self addProperty:(AKInstrumentProperty *)newOperation];
            newOperation.state  = @"connected";
        }
        if ([newOperation isKindOfClass:[AKNoteProperty class]]) {
            [self addNoteProperty:(AKNoteProperty *)newOperation];
            newOperation.state  = @"connected";
        }
    }
}


- (void)reconnectAll
{
    innerCSDOperations = [NSMutableArray array];
    for (AKParameter *parameter in connectedOperations) {
        parameter.state = @"connectable";
        [self internallyConnect:parameter];
    }
    
    NSArray *copy = [innerCSDOperations copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([innerCSDOperations indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [innerCSDOperations removeObjectAtIndex:index];
        }
        index--;
    }
}

- (void)setAudioOutput:(AKParameter *)audio
{
    [self connect:audio];
    AKAudioOutput *output = [[AKAudioOutput alloc] initWithAudioSource:audio];
    [self connect:output];
}

- (void)setAudioOutputWithLeftAudio:(AKParameter *)leftInput rightAudio:(AKParameter *)rightInput;
{
    [self connect:leftInput];
    [self connect:rightInput];
    AKAudioOutput *output = [[AKAudioOutput alloc] initWithLeftAudio:leftInput rightAudio:rightInput];
    [self connect:output];
}

- (void)setStereoAudioOutput:(AKStereoAudio *)stereo;
{
    [self connect:stereo];
    AKAudioOutput *output = [[AKAudioOutput alloc] initWithStereoAudioSource:stereo];
    [self connect:output];
}

- (void)appendOutput:(AKParameter *)output withInput:(AKParameter *)input
{
    [_globalParameters addObject:output];
    
    [self connect:input];
    
    if ([output class] == [AKStereoAudio class] && [input respondsToSelector:@selector(leftOutput)]) {
        AKStereoAudio *stereoOutput = (AKStereoAudio *)output;
        AKStereoAudio *stereoInput  = (AKStereoAudio *)input;
        
        AKAssignment *auxLeftOutputAssign = [[AKAssignment alloc] initWithOutput:stereoOutput.leftOutput
                                                                           input:[stereoInput.leftOutput plus:stereoOutput.leftOutput]];
        [self connect:auxLeftOutputAssign];
        
        AKAssignment *auxRightOutputAssign = [[AKAssignment alloc] initWithOutput:stereoOutput.rightOutput
                                                                            input:[stereoInput.rightOutput plus:stereoOutput.rightOutput]];
        [self connect:auxRightOutputAssign];
        
        
    } else {
        AKAssignment *auxOutputAssign = [[AKAssignment alloc] initWithOutput:output
                                                                       input:[input plus:output]];
        [self connect:auxOutputAssign];
    }
}

- (void)assignOutput:(AKParameter *)output to:(AKParameter *)input
{
    [self appendOutput:output withInput:input];
}

- (void)setParameter:(AKParameter *)parameter to:(AKParameter *)input
{
    [self connect:input];
    
    if ([parameter class] == [AKStereoAudio class] && [input respondsToSelector:@selector(leftOutput)]) {
        AKStereoAudio *stereoOutput = (AKStereoAudio *)parameter;
        AKStereoAudio *stereoInput  = (AKStereoAudio *)input;
        
        AKAssignment *auxLeftOutputAssign = [[AKAssignment alloc] initWithOutput:stereoOutput.leftOutput
                                                                           input:stereoInput.leftOutput];
        [self connect:auxLeftOutputAssign];
        
        AKAssignment *auxRightOutputAssign = [[AKAssignment alloc] initWithOutput:stereoOutput.rightOutput
                                                                            input:stereoInput.rightOutput];
        [self connect:auxRightOutputAssign];
        
        
    } else {
        AKAssignment *auxOutputAssign = [[AKAssignment alloc] initWithOutput:parameter
                                                                       input:input];
        [self connect:auxOutputAssign];
    }
}

- (void)resetParameter:(AKParameter *)parameterToReset
{
    if ([parameterToReset class] == [AKStereoAudio class]) {
        AKStereoAudio *stereoParameterToReset = (AKStereoAudio *)parameterToReset;
        AKAssignment *leftAssignment = [[AKAssignment alloc] initWithOutput:stereoParameterToReset.leftOutput input:akp(0)];
        [self connect:leftAssignment];
         AKAssignment *rightAssignment = [[AKAssignment alloc] initWithOutput:stereoParameterToReset.rightOutput input:akp(0)];
        [self connect:rightAssignment];
    } else {
        AKAssignment *assignment = [[AKAssignment alloc] initWithOutput:parameterToReset input:akp(0)];
        [self connect:assignment];
    }
}


- (void)enableParameterLog:(NSString *)message
                 parameter:(AKParameter *)parameter
              timeInterval:(NSTimeInterval)timeInterval
{
    [self connect:[[AKLog alloc] initWithMessage:message
                                       parameter:parameter
                                    timeInterval:timeInterval]];
}

- (void)logChangesToParameter:(nonnull AKParameter *)parameter
                  withMessage:(nonnull NSString *)message
{
    [self connect:[[AKParameterChangeLog alloc] initWithMessage:message
                                                      parameter:parameter]];
}


// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------
- (NSString *)stringForCSD
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    // Make sure that all dependencies have been connected
    // (can happen if the programmer prematurely connects an operation)
    [self reconnectAll];
    
    if ([_properties count] + [_noteProperties count] > 0 ) {
        [text appendString:@"\n;---- Inputs: Note Properties ----\n"];
        
        for (AKNoteProperty *prop in _noteProperties) {
            [text appendFormat:@"%@ = p%i\n", prop, prop.pValue];
        }
        [text appendString:@"\n;---- Inputs: Instrument Properties ----\n"];
        for (AKInstrumentProperty *prop in _properties) {
            [text appendString:[prop stringForCSDGetValue]];
        }
        [text appendString:@"\n;---- Opcodes ----\n"];
    }
    
    if ([innerCSDOperations count] > 0) {
        for (AKParameter *object in innerCSDOperations) {
            [text appendString:[object stringForCSD]];
            [text appendString:@"\n"];
        }
    }
    
    if ([_properties count] > 0) {
        [text appendString:@"\n;---- Outputs ----\n"];
        for (AKInstrumentProperty *prop in _properties) {
            [text appendString:[prop stringForCSDSetValue]];
        }
    }
    return (NSString *)text;
}

- (NSString *)stopStringForCSD
{
    int deactivatingInstrument = 1000;
    return [NSString stringWithFormat:@"i %d 0 0.1 %@\n", deactivatingInstrument, @(self.instrumentNumber)];
}


- (void)playForDuration:(NSTimeInterval)playDuration
{
    AKNote *myNote = [[AKNote alloc] initWithInstrument:self
                                            forDuration:playDuration];
    [myNote play];
}

- (void)play
{
    AKNote *note = [[AKNote alloc] initWithInstrument:self];
    [note play];
}

- (void)start {
    [self play];
}

- (void)restart {
    [self stop];
    [self playNote:[[AKNote alloc] init] afterDelay:0.1];
}

- (void)playNote:(AKNote *)note
{
    note.instrument = self;
    [note play];
}

- (void)playNote:(AKNote *)note afterDelay:(NSTimeInterval)delay
{
    note.instrument = self;
    [note playAfterDelay:delay];
}

- (void)stopNote:(AKNote *)note
{
    note.instrument = self;
    [note stop];
}

- (void)stopNote:(AKNote *)note afterDelay:(NSTimeInterval)delay
{
    note.instrument = self;
    [note stopAfterDelay:delay];
}

- (void)playPhrase:(AKPhrase *)phrase
{
    [phrase playUsingInstrument:self];
}

- (void)repeatPhrase:(AKPhrase *)phrase
{
    [self repeatPhrase:phrase duration:phrase.duration];
}

- (void)repeatPhrase:(AKPhrase *)phrase duration:(NSTimeInterval)duration
{
    repeater = [[AKSequence alloc] init];
    [[[AKManager sharedManager] sequences] setObject:repeater forKey:@"repeater"];
    AKEvent *playPhrase = [[AKEvent alloc] initWithBlock:^{
        [phrase playUsingInstrument:self];
    }];
    AKEvent *repeat = [[AKEvent alloc] initWithBlock:^{
        if (phrase.count > 0) [self repeatPhrase:phrase duration:duration];
    }];
    
    [repeater addEvent:playPhrase];
    [repeater addEvent:repeat atTime:duration];
    [repeater play];
}

- (void)stopPhrase
{
    [repeater reset];
    
    // This is for playgrounds
    if ([[[[AKManager sharedManager] sequences] objectForKey:@"repeater"] isKindOfClass:[AKSequence class]]) {
        AKSequence *repeater2 = [[[AKManager sharedManager] sequences] objectForKey:@"repeater"];
        [repeater2 reset];
    }

}


- (void)stop
{
    [[AKManager sharedManager] stopInstrument:self];
}

@end

//
//  AKOperationEffectAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKOperationEffectAudioUnit.h"
#import "AKOperationEffectDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

typedef struct UserData {
  AKCustomUgen *ugen;
  SporthStack *stack;
} UserData;


@implementation SporthStack
{
  sporth_stack *_stack;
}

- (void)setStack:(sporth_stack *)stack
{
  _stack = stack;
}

- (char *)popString
{
  return sporth_stack_pop_string(_stack);
}

- (float)popFloat
{
  return sporth_stack_pop_float(_stack);
}

- (void)pushFloat:(float)f
{
  sporth_stack_push_float(_stack, f);
}

- (void)pushString:(char *)str
{
  sporth_stack_push_string(_stack, &str);
}

@end

static int userFunction(plumber_data *pd, sporth_stack *stack, void **ud)
{
    switch(pd->mode) {
        case PLUMBER_CREATE:
            fprintf(stderr, "Default user function in create mode.\n");
            break;
        case PLUMBER_INIT: {
            fprintf(stderr, "Default user function in init mode.\n");

//            UserData *userData = (UserData *)*ud;
//            fprintf(stderr, "userData: %p\n", userData);
            AKCustomUgen *ugen = (__bridge AKCustomUgen *)*ud;
            SporthStack *sporthStack = [SporthStack new];//userData->stack;
            [sporthStack setStack:stack];

            if(sporth_check_args(stack, [ugen.argTypes cStringUsingEncoding:NSUTF8StringEncoding]) != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for userFunction\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ugen.computeFunction(sporthStack);
            break;
        } case PLUMBER_COMPUTE: {
            AKCustomUgen *ugen = (__bridge AKCustomUgen *)*ud;
            SporthStack *sporthStack = [SporthStack new];//userData->stack;
            [sporthStack setStack:stack];

            ugen.computeFunction(sporthStack);
            break;
        } case PLUMBER_DESTROY:
            fprintf(stderr, "Default user function in destroy mode.\n");
//            bd = (bp_data *)*ud;
            break;
        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

@implementation AKOperationEffectAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOperationEffectDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setSporth:(NSString *)sporth {
    _kernel.setSporth((char *)[sporth UTF8String]);
}

- (NSArray *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:14];
    for (int i = 0; i < 14; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.parameters[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray *)parameters {
    float params[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < parameters.count; i++) {
        params[i] =[parameters[i] floatValue];
    }
    _kernel.setParameters(params);
}

- (void)addCustomUgen:(AKCustomUgen *)ugen {
    //TODO: Assert that init hasn't run yet?
    unsigned long nameLength = ugen.name.length + 1;
    char *cName = (char *)malloc(sizeof(char) * nameLength);
    BOOL worked = [ugen.name getCString:cName maxLength:nameLength encoding:NSUTF8StringEncoding];
    if (!worked) {
      printf("getCString failed\n");
    }
//    UserData *userData = (UserData *)malloc(sizeof(UserData));
//    userData->stack = [SporthStack new];
//    userData->ugen = ugen;
    _kernel.addCustomUgen({cName, &userFunction, (__bridge void *)ugen});
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (void)createParameters {
    standardSetup(OperationEffect)
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
    parameterTreeBlock(OperationEffect)
}

AUAudioUnitOverrides(OperationEffect)
@end



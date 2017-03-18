//
//  AKCustomUgenFunction.h
//  AudioKit For iOS
//
//  Created by Joseph Constantakis on 3/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKSporthStack+Internal.h"

static int akCustomUgenFunction(plumber_data *pd, sporth_stack *stack, void **ud)
{
    switch(pd->mode) {
        case PLUMBER_CREATE:
            break;
        case PLUMBER_INIT: {
            // copy the source ugen so that different instances of the same function
            // don't affect each others' userData.
            AKCustomUgen *ugen = [(__bridge AKCustomUgen *)*ud duplicate];
            *ud = (void *)CFBridgingRetain(ugen);
            [ugen.stack setStack:stack];

            const char *argTypes = [ugen.argTypes UTF8String];
            if (sporth_check_args(stack, argTypes) != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for format '%s' "
                "on custom ugen '%s'\n", argTypes, [ugen.name UTF8String]);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ugen.callComputeFunction(ugen);
            break;
        } case PLUMBER_COMPUTE: {
            AKCustomUgen *ugen = (__bridge AKCustomUgen *)*ud;
            [ugen.stack setStack:stack];
            ugen.callComputeFunction(ugen);
            break;
        } case PLUMBER_DESTROY:
            CFBridgingRelease(*ud);
            break;
        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

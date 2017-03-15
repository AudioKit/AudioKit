//
//  AKCustomUgenFunction.h
//  AudioKit For iOS
//
//  Created by Joseph Constantakis on 3/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKSporthStack+Internal.h"

typedef struct {
  AKCustomUgen *ugen;
  AKSporthStack *stack;
} AKUgenFunctionUserData;

static int akCustomUgenFunction(plumber_data *pd, sporth_stack *stack, void **ud)
{
    switch(pd->mode) {
        case PLUMBER_CREATE:
            break;
        case PLUMBER_INIT: {
            AKUgenFunctionUserData *userData = (AKUgenFunctionUserData *)*ud;
            AKCustomUgen *ugen = userData->ugen;
            AKSporthStack *sporthStack = userData->stack;
            [sporthStack setStack:stack];

            if(sporth_check_args(stack, [ugen.argTypes cStringUsingEncoding:NSUTF8StringEncoding]) != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for userFunction\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ugen.computeFunction(sporthStack);
            break;
        } case PLUMBER_COMPUTE: {
            AKUgenFunctionUserData *userData = (AKUgenFunctionUserData *)*ud;
            AKCustomUgen *ugen = userData->ugen;
            AKSporthStack *sporthStack = userData->stack;
            [sporthStack setStack:stack];

            ugen.computeFunction(sporthStack);
            break;
        } case PLUMBER_DESTROY:
            free(*ud);
            break;
        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

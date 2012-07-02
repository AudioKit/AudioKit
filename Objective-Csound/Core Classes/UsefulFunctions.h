//
//  UsefulFunctions.h
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#ifndef ExampleProject_UsefulFunctions_h
#define ExampleProject_UsefulFunctions_h


static float randomFloatBetween(float min, float max)
{
    float diff = max - min;
    return (((float) rand() / RAND_MAX) * diff) + min;
}

#endif

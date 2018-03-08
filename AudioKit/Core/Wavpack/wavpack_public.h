//
//  wavpack_public.h
//  AKSampler for macOS
//
//  Created by Shane Dunne on 2018-03-02.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

// Client code should include this header rather than wavpack.h

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

int wvunpack (int ifd, int ofd);
int getWvData (int ifd, float* pSampleRateHz, int* pNumChannels, int* pNumSamples);
int getWvSamples (int ifd, float* pSampleBuffer);

#ifdef __cplusplus
}
#endif

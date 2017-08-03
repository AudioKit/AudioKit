// Copyright: 2015, Ableton AG, Berlin. All rights reserved.

#pragma once

#include "ABLLink.h"

#ifdef __cplusplus
extern "C"
{
#endif

  /** Calculate the effective Beats Per Minute value for a range of beat values
      over the given number of samples at the given sample rate.
  */
  inline Float64 ABLLinkBpmInRange(
    const Float64 fromBeat,
    const Float64 toBeat,
    const UInt32 numSamples,
    const Float64 sampleRate) {
    return (toBeat - fromBeat) * sampleRate * 60 / numSamples;
  }

#ifdef __cplusplus
}
#endif

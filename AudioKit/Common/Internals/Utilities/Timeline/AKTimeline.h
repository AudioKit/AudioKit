//
//  AKTimeline.h
//  AudioKit
//
//  Created by David O'Neill on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#include <stdio.h>
#include <CoreAudio/CoreAudioTypes.h>
#include "TPCircularBuffer+Unit.h"



/**
 @brief Provides synchcronization conversion from render time to "player time".

 @discussion
 Converts AudioTimeStamp from system audioTime to a timestamp that represents
 the progression of a time in the context of a timeline.  The AudioTimeStamp
 retrieved from the audio thread is constantly incrementing. AKTimeline sets
 a base time that acts as time-zero, giving a reference point with which to
 syncronize with other sources of audio that exibit this behavior.  The timeline
 supports loop start, and loop duration.  In order to use it, instantiate it with
 function pointer to an AKTimelineCallback function. Then, within an audio render
 callback, or a render notify callback, call AKTimelineRender once per render.
 AKTimeline will call the AKTimelineCallback provided with an AudioTimeStamp that
 has a mSampleTime that falls within a zero based timeline.  All time arguments are
 sample times, representing the time within the timeline, or audioTimes, representing
 an audioTimeStamp that is in the context of the audio render thread.  All audioTime
 arguments will discard mHostTime unless mSampleTime is not valid. Changes made on
 threads other than the audio thread will not take effect until AKTimelineRender
 is called from the audio thread, with the exception of AKTimelineSetRenderState,
 which is designed to be called only from the audio render thread.
 */

/**
 A callback with a timeStamp who's mSampleTime represents time in the context
 of the timeline.
 @param refCon User data passed to AKTimeline on init.
 @param timeStamp AudioTimeStamp where mSampleTime reflects the current sample in the
 context of the timeline (rather than core audio's running sample time).
 @param inNumberFrames Number of frames rendered.
 @param offset The number of samples timeStamp->mSampleTime is offset from current
 render start.  Will be non-zero when wrapping around the loop end.
 @param ioData Audio buffer io.
 */
typedef void (*AKTimelineCallback)( void            *refCon,
AudioTimeStamp  *timeStamp,
UInt32          inNumberFrames,
UInt32          offset,
AudioBufferList *ioData);

typedef struct{
    UInt32          loopStart;
    UInt32          loopEnd;
    AudioTimeStamp  baseTime;
    AudioTimeStamp  waitStart;


    UInt32          _loopStart;
    UInt32          _loopEnd;
    AudioTimeStamp  _baseTime;
    AudioTimeStamp  _waitStart;


    AudioStreamBasicDescription format;

    AudioTimeStamp  anchorTime;
    AudioTimeStamp  lastRenderTime;
    UInt32          lastRenderFrames;
    void            *callbackRef;
    AKTimelineCallback callBack;

    TPCircularBuffer messageQueue;
    pthread_mutex_t messageQueueLock;

    Float64         idleTime;

}AKTimeline;

/**
 @brief Initializea an AKTimeline

 @param timeline The timeline.
 @param format Should match the format from the audio context that AKTimelineRender
 will be called from.
 @param callback A callback that provides an AudioTimeStamp with a mSampleTime representing
 a zero based timeline.
 May be called more than once per render cycle if looping.
 @param callbackRef User data that will be passed as an argument to callback when called.
 */
void AKTimelineInit(AKTimeline                  *timeline,
                    AudioStreamBasicDescription format,
                    AKTimelineCallback          callback,
                    void                        *callbackRef);

/**
 @brief Call this every render cycle.

 @param timeline The timeline.
 @param inTimeStamp The timestamp provided by an audio render callback.
 @param inNumberFrames The number of frames to render.
 @param ioData Audio buffer io.
 */
void AKTimelineRender(AKTimeline            *timeline,
                      const AudioTimeStamp  *inTimeStamp,
                      UInt32                inNumberFrames,
                      AudioBufferList       *ioData);

/**
 @brief Starts playback (almost) immediately, (one render cycle after last render time).

 @discussion Will block until after first call to AKTimelineRender.

 @param timeline The timeline.
 */
void AKTimelineStart(AKTimeline *timeline);

/**
 @brief Schedule playback at an audioTime in the future.

 @discussion When started, the timeline's current sample time will correspond
 precisely with audioTime.

 @param timeline The timeline.
 @param audioTime A timestamp representing a time in the audio render context.
 */
void AKTimelineStartAtTime(AKTimeline *timeline, AudioTimeStamp audioTime);

/**
 @brief Stops playback

 @param timeline The timeline.
 */
void AKTimelineStop(AKTimeline *timeline);

/**
 @brief Sets the loop start, and loop duration (in samples)

 @discussion Timeline will shift as if the new loop values were the set when
 the timeline was started.  AKTimelineSetState is recommended if timeline is started.

 @param timeline The timeline.
 @param start The start of the loop.
 @param duration The duration of the loop.
 */
void AKTimelineSetLoop(AKTimeline *timeline, Float64 start, Float64 duration);

/**
 @brief Sets the current time and starts playback if not playing.

 @discussion Call when player is stopped to set the time that timeline will resume
 from when started.

 @param timeline The timeline.
 @param sampleTime Time in the context of the timeline.
 */
void AKTimelineSetTime(AKTimeline *timeline, SInt64 sampleTime);

/**
 @brief Sets the current time and starts playback if not playing.

 @discussion Use AKTimelineSetTime to set time without starting playback.

 @param timeline The timeline.
 @param sampleTime Time in the context of the timeline.
 @param audioTime Time in the audio render context.
 */
void AKTimelineSetTimeAtTime(AKTimeline *timeline, SInt64 sampleTime, AudioTimeStamp audioTime);

/**
 @brief Timeline's sample time at an audioTime.

 @param timeline The timeline.
 @param audioTime A timestamp representing a time in the audio render context.
 */
Float64 AKTimelineTimeAtTime(AKTimeline *timeline, AudioTimeStamp audioTime);

/**
 @brief Timeline's sample time.

 @param timeline The timeline.
 */
Float64 AKTimelineTime(AKTimeline *timeline);

/**
 @brief Is timeline started.

 @param timeline The timeline.
 */
Boolean AKTimelineIsStarted(AKTimeline *timeline);

/**
 @brief Set timeline values in one atomic transaction.

 @discussion Use to ensure renders don't happen in-between the setting of time, loop, and start.

 @param timeline The timeline.
 @param sampleTime The time in the timeline.
 @param loopStart The time in the timeline that looping should start.
 @param loopEnd The time in the timeline that looping should end.  Zero if not looping.
 @param audioTime A timestamp representing a time in the audio render context.
 */
void AKTimelineSetState(AKTimeline      *timeline,
                        SInt64          sampleTime,
                        UInt32          loopStart,
                        UInt32          loopEnd,
                        AudioTimeStamp  audioTime);

/**
 @brief Set timeline values in one atomic transaction, from render thread.

 @discussion Same as AKTimelineIsStarted except meant to be called from render thread.  Changes
 take place immediately.

 @param timeline The timeline.
 @param sampleTime The time in the timeline.
 @param loopStart The time in the timeline that looping should start.
 @param loopEnd The time in the timeline that looping should end.  Zero if not looping.
 @param audioTime A timestamp representing a time in the audio render context.
 */
void AKTimelineSetRenderState(AKTimeline        *timeline,
                              Float64           sampleTime,
                              Float64           loopStart,
                              Float64           loopEnd,
                              AudioTimeStamp    audioTime);

/**
 @brief Get the audioTime for a given sampleTime

 @discussion If looping, will return an AudioTime within the first loop (in the past).

 @param timeline The timeline.
 @param sampleTime The time in the timeline.
 */
AudioTimeStamp AKTimelineAudioTimeAtTime(AKTimeline *timeline, Float64 sampleTime);



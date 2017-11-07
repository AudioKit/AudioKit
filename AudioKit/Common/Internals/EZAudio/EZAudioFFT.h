//
//  EZAudioFFT.h
//  EZAudio
//
//  Created by Syed Haris Ali on 7/10/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@class EZAudioFFT;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

/**
 The EZAudioFFTDelegate provides event callbacks for the EZAudioFFT (and subclasses such as the EZAudioFFTRolling) whenvever the FFT is computed.
 */
@protocol EZAudioFFTDelegate <NSObject>

@optional

///-----------------------------------------------------------
/// @name Getting FFT Output Data
///-----------------------------------------------------------

/**
 Triggered when the EZAudioFFT computes an FFT from a buffer of input data. Provides an array of float data representing the computed FFT.
 @param fft        The EZAudioFFT instance that triggered the event.
 @param fftData    A float pointer representing the float array of FFT data.
 @param bufferSize A vDSP_Length (unsigned long) representing the length of the float array.
 */
- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize;

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFT
//------------------------------------------------------------------------------

/**
 The EZAudioFFT provides a base class to quickly calculate the FFT of incoming audio data using the Accelerate framework. In addition, the EZAudioFFT contains an EZAudioFFTDelegate to receive an event anytime an FFT is computed.
 */
@interface EZAudioFFT : NSObject

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Initializes an EZAudioFFT (or subclass) instance with a maximum buffer size and sample rate. The sample rate is used specifically to calculate the `maxFrequency` property. If you don't care about the `maxFrequency` property then you can set the sample rate to 0.
 @param maximumBufferSize A vDSP_Length (unsigned long) representing the maximum length of the incoming audio data.
 @param sampleRate        A float representing the sample rate of the incoming audio data.

 @return A newly created EZAudioFFT (or subclass) instance.
 */
- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Initializes an EZAudioFFT (or subclass) instance with a maximum buffer size, sample rate, and EZAudioFFTDelegate. The sample rate is used specifically to calculate the `maxFrequency` property. If you don't care about the `maxFrequency` property then you can set the sample rate to 0. The EZAudioFFTDelegate will act as a receive to get an event whenever the FFT is calculated.
 @param maximumBufferSize A vDSP_Length (unsigned long) representing the maximum length of the incoming audio data.
 @param sampleRate        A float representing the sample rate of the incoming audio data.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFT (or subclass) instance.
 */
- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate
                                 delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to initialize an EZAudioFFT (or subclass) instance with a maximum buffer size and sample rate. The sample rate is used specifically to calculate the `maxFrequency` property. If you don't care about the `maxFrequency` property then you can set the sample rate to 0.
 @param maximumBufferSize A vDSP_Length (unsigned long) representing the maximum length of the incoming audio data.
 @param sampleRate        A float representing the sample rate of the incoming audio data.
 @return A newly created EZAudioFFT (or subclass) instance.
 */
+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Class method to initialize an EZAudioFFT (or subclass) instance with a maximum buffer size, sample rate, and EZAudioFFTDelegate. The sample rate is used specifically to calculate the `maxFrequency` property. If you don't care about the `maxFrequency` property then you can set the sample rate to 0. The EZAudioFFTDelegate will act as a receive to get an event whenever the FFT is calculated.
 @param maximumBufferSize A vDSP_Length (unsigned long) representing the maximum length of the incoming audio data.
 @param sampleRate        A float representing the sample rate of the incoming audio data.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFT (or subclass) instance.
 */
+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate
                                delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------

/**
 An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 */
@property (weak, nonatomic) id<EZAudioFFTDelegate> delegate;

//------------------------------------------------------------------------------

/**
 A COMPLEX_SPLIT data structure used to hold the FFT's imaginary and real components.
 */
@property (readonly, nonatomic) COMPLEX_SPLIT complexSplit;

//------------------------------------------------------------------------------

/**
 A float array containing the last calculated FFT data.
 */
@property (readonly, nonatomic) float *fftData;

//------------------------------------------------------------------------------

/**
 An FFTSetup data structure used to internally calculate the FFT using Accelerate.
 */
@property (readonly, nonatomic) FFTSetup fftSetup;

//------------------------------------------------------------------------------

/**
 A float array containing the last calculated inverse FFT data (the time domain signal).
 */
@property (readonly, nonatomic) float *inversedFFTData;

//------------------------------------------------------------------------------

/**
 A float representing the frequency with the highest energy is the last FFT calculation.
 */
@property (readonly, nonatomic) float maxFrequency;

//------------------------------------------------------------------------------

/**
 A vDSP_Length (unsigned long) representing the index of the frequency with the highest energy is the last FFT calculation.
 */
@property (readonly, nonatomic) vDSP_Length maxFrequencyIndex;

//------------------------------------------------------------------------------

/**
 A float representing the magnitude of the frequency with the highest energy is the last FFT calculation.
 */
@property (readonly, nonatomic) float maxFrequencyMagnitude;

//------------------------------------------------------------------------------

/**
 A vDSP_Length (unsigned long) representing the maximum buffer size. This is the maximum length the incoming audio data in the `computeFFTWithBuffer:withBufferSize` method can be.
 */
@property (readonly, nonatomic) vDSP_Length maximumBufferSize;

//------------------------------------------------------------------------------

/**
 A float representing the sample rate of the incoming audio data.
 */
@property (readwrite, nonatomic) float sampleRate;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Computing The FFT
///-----------------------------------------------------------

/**
 Computes the FFT for a float array representing an incoming audio signal. This will trigger the EZAudioFFTDelegate method `fft:updatedWithFFTData:bufferSize:`.
 @param buffer     A float array representing the audio data.
 @param bufferSize The length of the float array of audio data.
 @return A float array containing the computed FFT data. The length of the output will be half the incoming buffer (half the `bufferSize` argument).
 */
- (float *)computeFFTWithBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize;

//------------------------------------------------------------------------------

/**
 Provides the frequency corresponding to an index in the last computed FFT data.
 @param index A vDSP_Length (unsigned integer) representing the index of the frequency bin value you'd like to get
 @return A float representing the frequency value at that index.
 */
- (float)frequencyAtIndex:(vDSP_Length)index;

//------------------------------------------------------------------------------

/**
 Provides the magnitude of the frequenecy corresponding to an index in the last computed FFT data.
 @param index A vDSP_Length (unsigned integer) representing the index of the frequency bin value you'd like to get
 @return A float representing the frequency magnitude value at that index.
 */
- (float)frequencyMagnitudeAtIndex:(vDSP_Length)index;

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTRolling
//------------------------------------------------------------------------------

/**
 The EZAudioFFTRolling, a subclass of EZAudioFFT, provides a class to calculate an FFT for an incoming audio signal while maintaining a history of audio data to allow much higher resolution FFTs. For instance, the EZMicrophone typically provides 512 frames at a time, but you would probably want to provide 2048 or 4096 frames for a decent looking FFT if you're trying to extract precise frequency components. You will typically be using this class for variable length FFTs instead of the EZAudioFFT base class.
 */
@interface EZAudioFFTRolling : EZAudioFFT

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Initializes an EZAudioFFTRolling instance with a window size and a sample rate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT and a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property). The history buffer size in this case is the `windowSize` * 8, which is pretty good for most cases.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @return A newly created EZAudioFFTRolling instance.
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Initializes an EZAudioFFTRolling instance with a window size, a sample rate, and an EZAudioFFTDelegate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property), and an EZAudioFFTDelegate to receive a callback anytime the FFT is calculated. The history buffer size in this case is the `windowSize` * 8, which is pretty good for most cases.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFTRolling instance.
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Initializes an EZAudioFFTRolling instance with a window size, a history buffer size, and a sample rate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a history buffer size representing the maximum length of the sliding window's underlying circular buffer, and a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property).
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param historyBufferSize A vDSP_Length (unsigned long) representing the length of the history buffer. This should be AT LEAST the size of the window. A recommended value for this would be at least 8x greater than the `windowSize` argument.
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @return A newly created EZAudioFFTRolling instance.
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Initializes an EZAudioFFTRolling instance with a window size, a history buffer size, a sample rate, and an EZAudioFFTDelegate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a history buffer size representing the maximum length of the sliding window's underlying circular buffer, a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property), and an EZAudioFFTDelegate to receive a callback anytime the FFT is calculated.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param historyBufferSize A vDSP_Length (unsigned long) representing the length of the history buffer. This should be AT LEAST the size of the window. A recommended value for this would be at least 8x greater than the `windowSize` argument.
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFTRolling instance.
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to initialize an EZAudioFFTRolling instance with a window size and a sample rate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT and a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property). The history buffer size in this case is the `windowSize` * 8, which is pretty good for most cases.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @return A newly created EZAudioFFTRolling instance.
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Class method to initialize an EZAudioFFTRolling instance with a window size, a sample rate, and an EZAudioFFTDelegate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property), and an EZAudioFFTDelegate to receive a callback anytime the FFT is calculated. The history buffer size in this case is the `windowSize` * 8, which is pretty good for most cases.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFTRolling instance.
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class method to initialize an EZAudioFFTRolling instance with a window size, a history buffer size, and a sample rate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a history buffer size representing the maximum length of the sliding window's underlying circular buffer, and a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property).
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param historyBufferSize A vDSP_Length (unsigned long) representing the length of the history buffer. This should be AT LEAST the size of the window. A recommended value for this would be at least 8x greater than the `windowSize` argument.
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @return A newly created EZAudioFFTRolling instance.
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Class method to initialize an EZAudioFFTRolling instance with a window size, a history buffer size, a sample rate, and an EZAudioFFTDelegate. The EZAudioFFTRolling has an internal EZPlotHistoryInfo data structure that writes audio data to a circular buffer and manages sliding windows of audio data to support efficient, large FFT calculations. Here you provide a window size that represents how many audio sample will be used to calculate the FFT, a history buffer size representing the maximum length of the sliding window's underlying circular buffer, a float representing the sample rate of the incoming audio (can be 0 if you don't care about the `maxFrequency` property), and an EZAudioFFTDelegate to receive a callback anytime the FFT is calculated.
 @param windowSize        A vDSP_Length (unsigned long) representing the size of the window (i.e. the resolution) of data that should be used to calculate the FFT. A typical value for this would be something like 1024 - 4096 (or higher for an even higher resolution FFT).
 @param historyBufferSize A vDSP_Length (unsigned long) representing the length of the history buffer. This should be AT LEAST the size of the window. A recommended value for this would be at least 8x greater than the `windowSize` argument.
 @param sampleRate        A float representing the sample rate of the incoming audio signal.
 @param delegate          An EZAudioFFTDelegate to receive an event whenever the FFT is calculated.
 @return A newly created EZAudioFFTRolling instance.
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZAudioFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------

/**
 A vDSP_Length (unsigned long) representing the length of the FFT window.
 */
@property (readonly, nonatomic) vDSP_Length windowSize;

//------------------------------------------------------------------------------

/**
 A float array representing the audio data in the internal circular buffer used to perform the FFT. This will increase as more data is appended to the internal circular buffer via the `computeFFTWithBuffer:withBufferSize:` method. The length of this array is the `timeDomainBufferSize` property.
 */
@property (readonly, nonatomic) float *timeDomainData;

//------------------------------------------------------------------------------

/**
 A UInt32 representing the length of the audio data used to perform the FFT.
 */
@property (readonly, nonatomic) UInt32 timeDomainBufferSize;

@end

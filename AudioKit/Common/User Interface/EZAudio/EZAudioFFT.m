//
//  EZAudioFFT.m
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

#import "EZAudioFFT.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct EZAudioFFTInfo
{
    FFTSetup       fftSetup;
    COMPLEX_SPLIT  complexA;
    float         *outFFTData;
    vDSP_Length    outFFTDataLength;
    float         *inversedFFTData;
    vDSP_Length    maxFrequencyIndex;
    float          maxFrequencyMangitude;
    float          maxFrequency;
} EZAudioFFTInfo;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFT (Interface Extension)
//------------------------------------------------------------------------------

@interface EZAudioFFT ()
@property (assign,    nonatomic) EZAudioFFTInfo *info;
@property (readwrite, nonatomic) vDSP_Length     maximumBufferSize;
@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFT (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioFFT

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    vDSP_destroy_fftsetup(self.info->fftSetup);
    free(self.info->complexA.realp);
    free(self.info->complexA.imagp);
    free(self.info->outFFTData);
    free(self.info->inversedFFTData);
}

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate
{
    return [self initWithMaximumBufferSize:maximumBufferSize
                                sampleRate:sampleRate
                                  delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate
                                 delegate:(id<EZAudioFFTDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.maximumBufferSize = (vDSP_Length)maximumBufferSize;
        self.sampleRate = sampleRate;
        self.delegate = delegate;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate
{
    return [[self alloc] initWithMaximumBufferSize:maximumBufferSize
                                        sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate
                                delegate:(id<EZAudioFFTDelegate>)delegate
{
    return [[self alloc] initWithMaximumBufferSize:maximumBufferSize
                                        sampleRate:sampleRate
                                          delegate:delegate];
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    NSAssert(self.maximumBufferSize > 0, @"Expected FFT buffer size to be greater than 0!");
    
    //
    // Initialize FFT
    //
    float maximumBufferSizeBytes = self.maximumBufferSize * sizeof(float);
    self.info = (EZAudioFFTInfo *)calloc(1, sizeof(EZAudioFFTInfo));
    vDSP_Length log2n = log2f(self.maximumBufferSize);
    self.info->fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    long nOver2 = maximumBufferSizeBytes / 2;
    size_t maximumSizePerComponentBytes = nOver2 * sizeof(float);
    self.info->complexA.realp = (float *)malloc(maximumSizePerComponentBytes);
    self.info->complexA.imagp = (float *)malloc(maximumSizePerComponentBytes);
    self.info->outFFTData = (float *)malloc(maximumSizePerComponentBytes);
    memset(self.info->outFFTData, 0, maximumSizePerComponentBytes);
    self.info->inversedFFTData = (float *)malloc(maximumSizePerComponentBytes);
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (float *)computeFFTWithBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    if (buffer == NULL)
    {
        return NULL;
    }
    
    //
    // Calculate real + imaginary components and normalize
    //
    vDSP_Length log2n = log2f(bufferSize);
    long nOver2 = bufferSize / 2;
    float mFFTNormFactor = 10.0 / (2 * bufferSize);
    vDSP_ctoz((COMPLEX*)buffer, 2, &(self.info->complexA), 1, nOver2);
    vDSP_fft_zrip(self.info->fftSetup, &(self.info->complexA), 1, log2n, FFT_FORWARD);
    vDSP_vsmul(self.info->complexA.realp, 1, &mFFTNormFactor, self.info->complexA.realp, 1, nOver2);
    vDSP_vsmul(self.info->complexA.imagp, 1, &mFFTNormFactor, self.info->complexA.imagp, 1, nOver2);
    vDSP_zvmags(&(self.info->complexA), 1, self.info->outFFTData, 1, nOver2);
    vDSP_fft_zrip(self.info->fftSetup, &(self.info->complexA), 1, log2n, FFT_INVERSE);
    vDSP_ztoc(&(self.info->complexA), 1, (COMPLEX *) self.info->inversedFFTData , 2, nOver2);
    self.info->outFFTDataLength = nOver2;
    
    //
    // Calculate max freq
    //
    if (self.sampleRate > 0.0f)
    {
        vDSP_maxvi(self.info->outFFTData, 1, &self.info->maxFrequencyMangitude, &self.info->maxFrequencyIndex, nOver2);
        self.info->maxFrequency = [self frequencyAtIndex:self.info->maxFrequencyIndex];
    }
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(fft:updatedWithFFTData:bufferSize:)])
    {
        [self.delegate fft:self
        updatedWithFFTData:self.info->outFFTData
                bufferSize:nOver2];
    }
    
    //
    // Return the FFT
    //
    return self.info->outFFTData;
}

//------------------------------------------------------------------------------

- (float)frequencyAtIndex:(vDSP_Length)index
{
    if (!(self.info->outFFTData == NULL || self.sampleRate == 0.0f))
    {
        float nyquistMaxFreq = self.sampleRate / 2.0;
        return ((float)index / (float)self.info->outFFTDataLength) * nyquistMaxFreq;
    }
    return NSNotFound;
}

//------------------------------------------------------------------------------

- (float)frequencyMagnitudeAtIndex:(vDSP_Length)index
{
    if (self.info->outFFTData != NULL)
    {
        return self.info->outFFTData[index];
    }
    return NSNotFound;
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (COMPLEX_SPLIT)complexSplit
{
    return self.info->complexA;
}

//------------------------------------------------------------------------------

- (float *)fftData
{
    return self.info->outFFTData;
}

//------------------------------------------------------------------------------

- (FFTSetup)fftSetup
{
    return self.info->fftSetup;
}

//------------------------------------------------------------------------------

- (float *)inversedFFTData
{
    return self.info->inversedFFTData;
}

//------------------------------------------------------------------------------

- (vDSP_Length)maxFrequencyIndex
{
    return self.info->maxFrequencyIndex;
}

//------------------------------------------------------------------------------

- (float)maxFrequencyMagnitude
{
    return self.info->maxFrequencyMangitude;
}

//------------------------------------------------------------------------------

- (float)maxFrequency
{
    return self.info->maxFrequency;
}

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTRolling
//------------------------------------------------------------------------------

@interface EZAudioFFTRolling ()
@property (assign,    nonatomic) EZPlotHistoryInfo *historyInfo;
@property (readwrite, nonatomic) vDSP_Length        windowSize;

@end

@implementation EZAudioFFTRolling

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [EZAudioUtilities freeHistoryInfo:self.historyInfo];
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate
{
    return [self initWithWindowSize:windowSize
                  historyBufferSize:windowSize * 8
                         sampleRate:sampleRate
                           delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZAudioFFTDelegate>)delegate
{
    return [self initWithWindowSize:windowSize
                  historyBufferSize:windowSize * 8
                         sampleRate:sampleRate
                           delegate:delegate];
}

//------------------------------------------------------------------------------

- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate
{
    return [self initWithWindowSize:windowSize
                  historyBufferSize:historyBufferSize
                         sampleRate:sampleRate
                           delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZAudioFFTDelegate>)delegate
{
    self = [super initWithMaximumBufferSize:historyBufferSize
                                 sampleRate:sampleRate];
    if (self)
    {
        self.delegate = delegate;
        self.windowSize = windowSize;
        
        //
        // Allocate an appropriately sized history buffer in bytes
        //
        self.historyInfo = [EZAudioUtilities historyInfoWithDefaultLength:(UInt32)windowSize
                                                            maximumLength:(UInt32)historyBufferSize];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate
{
    return [[self alloc] initWithWindowSize:windowSize
                                 sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZAudioFFTDelegate>)delegate
{
    return [[self alloc] initWithWindowSize:windowSize
                                 sampleRate:sampleRate
                                   delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate
{
    return [[self alloc] initWithWindowSize:windowSize
                          historyBufferSize:historyBufferSize
                                 sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZAudioFFTDelegate>)delegate
{
    return [[self alloc] initWithWindowSize:windowSize
                          historyBufferSize:historyBufferSize
                                 sampleRate:sampleRate
                                   delegate:delegate];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (float *)computeFFTWithBuffer:(float *)buffer
                 withBufferSize:(UInt32)bufferSize
{
    if (buffer == NULL)
    {
        return NULL;
    }
    
    //
    // Append buffer to history window
    //
    [EZAudioUtilities appendBuffer:buffer
                    withBufferSize:bufferSize
                     toHistoryInfo:self.historyInfo];
    
    //
    // Call super to calculate the FFT of the window
    //
    return [super computeFFTWithBuffer:self.historyInfo->buffer
                        withBufferSize:self.historyInfo->bufferSize];
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (UInt32)timeDomainBufferSize
{
    return self.historyInfo->bufferSize;
}

//------------------------------------------------------------------------------

- (float *)timeDomainData
{
    return self.historyInfo->buffer;
}

@end

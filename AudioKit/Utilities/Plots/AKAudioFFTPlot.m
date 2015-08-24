//
//  AKAudioFFTPlot.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"
#import "AKAudioFFTPlot.h"
#import "AKSettings.h"
#import "CsoundObj.h"

@import Accelerate;

@interface AKAudioFFTPlot() <CsoundBinding>
{
    NSMutableData *_samples;
    UInt32 _sampleSize;
    float *_history;
    int _historySize;
    int _index;
    
    CsoundObj *_cs;
    
    // FFT Stuff
    COMPLEX_SPLIT _A;
    FFTSetup      _FFTSetup;
    vDSP_Length   _log2n;
}
@end

@implementation AKAudioFFTPlot

- (void)defaultValues
{
    _lineWidth = 1.0f;
    _lineColor = [AKColor whiteColor];
}

- (NSMutableData *)bufferWithCsound:(CsoundObj *)cs
{
    NSAssert(nil, @"Override bufferWithCsound: in subclasses.");
    return nil;
}

- (void)dealloc
{
    free(_history);
    free(_A.realp);
    free(_A.imagp);
}

- (void)drawRect:(CGRect)rect
{
#if !TARGET_OS_IPHONE
    [self.backgroundColor setFill];
    NSRectFill(rect);
#endif
    if (!_historySize) // Csound not setup yet
        return;
    
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    const CGFloat yScale = 2;
    const CGFloat deltaX = (self.frame.size.width / (_historySize/2));
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat y2 = 0.0f;
    [wavePath moveToPoint:CGPointMake(x, y)];
#if TARGET_OS_IPHONE
    [wavePath addLineToPoint:CGPointMake(x, y2)];
#elif TARGET_OS_MAC
    [wavePath lineToPoint:CGPointMake(x, y2)];
#endif
    
    for (int i = 0; i <_historySize/2; i++) {
#if TARGET_OS_IPHONE
        y = self.bounds.size.height - (_history[i] * yScale);
#else
        y = _history[i] * yScale;
#endif
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        //NSLog(@"%index:d value:%f x:%f y:%f y2:%f", i%historySize, history[i % historySize], x, y, y2 );
        
        if (isfinite(y)) {
#if TARGET_OS_IPHONE
            [wavePath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
            [wavePath lineToPoint:CGPointMake(x, y)];
#endif
        }
        x += deltaX;
    }
    
    [wavePath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [wavePath stroke];
}

-(void)createFFTWithBufferSize:(float)bufferSize {
    float *data = _samples.mutableBytes;
    
    // Setup the length
    _log2n = log2f(bufferSize);
    
    // Calculate the weights array. This is a one-off operation.
    _FFTSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
    
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Populate *window with the values for a hamming window function
    float *window = (float *)malloc(sizeof(float)*bufferSize);
    vDSP_hamm_window(window, bufferSize, 0);
    // Window the samples
    vDSP_vmul(data, 1, window, 1, data, 1, bufferSize);
    free(window);
    
    // Define complex buffer
    _A.realp = (float *) malloc(nOver2*sizeof(float));
    _A.imagp = (float *) malloc(nOver2*sizeof(float));
    
}

-(void)updateFFTWithBufferSize:(float)bufferSize {
    const float *data = _samples.bytes;
    
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Pack samples:
    // C(re) -> A[n], C(im) -> A[n+1]
    vDSP_ctoz((COMPLEX*)data, 2, &_A, 1, nOver2);
    
    // Perform a forward FFT using fftSetup and A
    // Results are returned in A
    vDSP_fft_zrip(_FFTSetup, &_A, 1, _log2n, FFT_FORWARD);
    
    // Convert COMPLEX_SPLIT A result to magnitudes
    //float amp[nOver2];
    float maxMag = 0;
    
    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
        maxMag = mag > maxMag ? mag : maxMag;
    }
    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
        // Bind the value to be less than 1.0 to fit in the graph
        _history[i] = mag;
    }
    
    // Update the frequency domain plot
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    _cs = csoundObj;
    
    _sampleSize = AKSettings.shared.numberOfChannels * AKSettings.shared.samplesPerControlPeriod;
    
    void *samples = malloc(_sampleSize * sizeof(float));
    bzero(samples, _sampleSize * sizeof(float));
    _samples = [NSMutableData dataWithBytesNoCopy:samples length:_sampleSize * sizeof(float)];
    
    _historySize = 128;
    
    _history = malloc(_historySize * sizeof(float));
    bzero(_history, _historySize * sizeof(float));
    
    [self createFFTWithBufferSize:_sampleSize];
}

- (void)updateValuesFromCsound
{
    _samples = [self bufferWithCsound:_cs];
    
    // Get the FFT data
    [self updateFFTWithBufferSize:_sampleSize];
}

@end

//
//  AKAudioOutputFFTPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputFFTPlot.h"
#import "AKFoundation.h"
#import "CsoundObj.h"
#import <Accelerate/Accelerate.h>

@interface AKAudioOutputFFTPlot() <CsoundBinding>
{
    NSMutableData *outSamples;
    int sampleSize;
    MYFLT *history;
    int historySize;
    int index;
    
    CsoundObj *cs;
    
    // FFT Stuff
    COMPLEX_SPLIT _A;
    FFTSetup      _FFTSetup;
    vDSP_Length   _log2n;
}
@end

@implementation AKAudioOutputFFTPlot

- (void)defaultValues
{
    _lineWidth = 1.0f;
    _lineColor = [AKColor whiteColor];
}

- (void)dealloc
{
    free(history);
    free(_A.realp);
    free(_A.imagp);
}

#if TARGET_OS_IPHONE

- (void)drawRect:(CGRect)rect
{
    // Draw waveform
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    
    CGFloat yOffset = self.bounds.size.height;
    
    //float max = 0;
    //    for (int i = 0; i < historySize; i++) {
    //        if (fabs(history[i]) > max) max = fabs(history[i]);
    //    }
    //NSLog(@"max = %f", max);
    
    //    CGFloat yScale  =  self.bounds.size.height / 2;
    //    if (max > 0) {
    //        yScale  =  self.bounds.size.height / max / 2;
    //    }
    CGFloat yScale = 2;
    
    
    CGFloat deltaX = (self.frame.size.width / (historySize/2));
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat y2 = 0.0f;
    [wavePath moveToPoint:CGPointMake(x, y)];
    [wavePath addLineToPoint:CGPointMake(x, y2)];
    for (int i = 0; i < historySize/2; i++) {
        y = yOffset - (history[i] * yScale);
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        //NSLog(@"%index:d value:%f x:%f y:%f y2:%f", i%historySize, history[i % historySize], x, y, y2 );
        
        [wavePath addLineToPoint:CGPointMake(x, y)];
        
        x += deltaX;
    };
    
    [wavePath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [wavePath stroke];
}

#elif TARGET_OS_MAC
#endif

-(void)createFFTWithBufferSize:(float)bufferSize {
    MYFLT *data = (MYFLT *)outSamples.mutableBytes;

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
    const MYFLT *data = (const MYFLT *)outSamples.bytes;

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
        history[i] = mag;
    }
    
    // Update the frequency domain plot
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}




// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------


- (void)updateValuesFromCsound
{
    outSamples = [cs getMutableOutSamples];
    
    // Get the FFT data
    [self updateFFTWithBufferSize:sampleSize];
}


- (void)setup:(CsoundObj *)csoundObj
{
    cs = csoundObj;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    int samplesPerControlPeriod = [dict[@"Samples Per Control Period"] intValue];
    int numberOfChannels = [dict[@"Number Of Channels"] intValue];
    sampleSize = numberOfChannels * samplesPerControlPeriod;
    
    void *samples = malloc(sampleSize * sizeof(MYFLT));
    bzero(samples, sampleSize * sizeof(MYFLT));
    outSamples = [NSMutableData dataWithBytesNoCopy:samples length:sampleSize * sizeof(MYFLT)];

    historySize = 128;
    
    history = (MYFLT *)malloc(historySize * sizeof(MYFLT));
    bzero(history, historySize * sizeof(MYFLT));
    
    [self createFFTWithBufferSize:sampleSize];
}



@end
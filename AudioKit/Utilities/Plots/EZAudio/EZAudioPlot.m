//
//  EZAudioPlot.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
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

#import "EZAudioPlot.h"
#import "EZAudio.h"

@interface EZAudioPlot () {
    //  BOOL             _hasData;
    //  TPCircularBuffer _historyBuffer;
    
    CGPoint *plotData;
    UInt32   plotLength;
    
    // Rolling History
    float   *_scrollHistory;
    int     _scrollHistoryIndex;
    UInt32  _scrollHistoryLength;
    BOOL    _changingHistorySize;
}
@end

@implementation EZAudioPlot

#pragma mark - Initialization

- (void)defaultValues {
    _backgroundColor = [AKColor blackColor];
    _plotColor       = [AKColor yellowColor];
    _gain            = 1.0;
    _shouldMirror    = YES;
    _shouldFill      = YES;
    plotData             = NULL;
    _scrollHistoryLength = kEZAudioPlotDefaultHistoryBufferLength;
    _scrollHistory       = malloc(_scrollHistoryLength * sizeof(float));
}

#pragma mark - Setters
- (void)setBackgroundColor:(AKColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self updateUI];
}

- (void)setPlotColor:(AKColor *)color {
    _plotColor = color;
    [self updateUI];
}

- (void)setGain:(float)gain {
    _gain = gain;
    [self updateUI];
}

- (void)setShouldFill:(BOOL)shouldFill {
    _shouldFill = shouldFill;
    [self updateUI];
}

- (void)setShouldMirror:(BOOL)shouldMirror {
    _shouldMirror = shouldMirror;
    [self updateUI];
}

#pragma mark - Get Data
- (void)setSampleData:(float *)data
              length:(int)length {
    
    free(plotData);
    plotData   = (CGPoint *)calloc(sizeof(CGPoint),length);
    plotLength = length;
    
    for(int i = 0; i < length; i++) {
        data[i]     = i == 0 ? 0 : data[i];
        plotData[i] = CGPointMake(i,data[i] * _gain);
    }
    
    [self updateUI];
}

#pragma mark - Update
- (void)updateBuffer:(MYFLT *)buffer withBufferSize:(UInt32)bufferSize {
    
    // Update the scroll history datasource
    [EZAudio updateScrollHistory:&_scrollHistory
                      withLength:_scrollHistoryLength
                         atIndex:&_scrollHistoryIndex
                      withBuffer:buffer
                  withBufferSize:bufferSize
            isResolutionChanging:&_changingHistorySize];
    
    //
    [self setSampleData:_scrollHistory
                 length:_scrollHistoryLength];
}

- (void)drawRect:(CGRect)rect
{
#if TARGET_OS_IPHONE
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGRect frame = self.bounds;
#elif TARGET_OS_MAC
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
    NSRect frame = self.bounds;
#endif
    
    // Set the background color
    [self.backgroundColor set];
#if TARGET_OS_IPHONE
    UIRectFill(frame);
#elif TARGET_OS_MAC
    NSRectFill(frame);
#endif
    // Set the waveform line color
    [self.plotColor set];
    
    if(plotLength > 0) {
        
        plotData[plotLength-1] = CGPointMake(plotLength-1,0.0f);
        
        CGMutablePathRef halfPath = CGPathCreateMutable();
        CGPathAddLines(halfPath,
                       NULL,
                       plotData,
                       plotLength);
        CGMutablePathRef path = CGPathCreateMutable();
        
        double xscale = (frame.size.width) / (float)plotLength;
        double halfHeight = floor( frame.size.height / 2.0 );
        
        // iOS drawing origin is flipped by default so make sure we account for that
#if TARGET_OS_IPHONE
        int deviceOriginFlipped = -1;
#elif TARGET_OS_MAC
        int deviceOriginFlipped = 1;
#endif
        
        CGAffineTransform xf = CGAffineTransformIdentity;
        xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y );
        xf = CGAffineTransformScale( xf, xscale, deviceOriginFlipped*halfHeight );
        CGPathAddPath( path, &xf, halfPath );
        
        if( self.shouldMirror ){
            xf = CGAffineTransformIdentity;
            xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y);
            xf = CGAffineTransformScale( xf, xscale, -deviceOriginFlipped*(halfHeight));
            CGPathAddPath( path, &xf, halfPath );
        }
        CGPathRelease( halfPath );
        
        // Now, path contains the full waveform path.
        CGContextAddPath(ctx, path);
        
        // Make this color customizable
        if( self.shouldFill ){
            CGContextFillPath(ctx);
        }
        else {
            CGContextStrokePath(ctx);
        }
        CGPathRelease(path);
    }
    
#if TARGET_OS_IPHONE
    CGContextRestoreGState(ctx);
#elif TARGET_OS_MAC
    [[NSGraphicsContext currentContext] restoreGraphicsState];
#endif
}

#pragma mark - Adjust Resolution
- (int)setRollingHistoryLength:(int)historyLength
{
    historyLength = MIN(historyLength,kEZAudioPlotMaxHistoryBufferLength);
    size_t floatByteSize = sizeof(float);
    _changingHistorySize = YES;
    if( _scrollHistoryLength != historyLength ){
        _scrollHistoryLength = historyLength;
    }
    _scrollHistory = realloc(_scrollHistory,_scrollHistoryLength*floatByteSize);
    if( _scrollHistoryIndex < _scrollHistoryLength ){
        bzero(&_scrollHistory[_scrollHistoryIndex],
              (_scrollHistoryLength-_scrollHistoryIndex)*floatByteSize);
    }
    else {
        _scrollHistoryIndex = _scrollHistoryLength;
    }
    _changingHistorySize = NO;
    return historyLength;
}

- (int)rollingHistoryLength {
    return _scrollHistoryLength;
}

- (void)dealloc {
    free(plotData);
}

@end

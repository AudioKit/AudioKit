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
#if TARGET_OS_IPHONE
    UIImage     *_plot;
#else
    // TODO
#endif
    
    CGPoint     *_plotData;
    NSUInteger   _plotLength;
    
    // Rolling History
    float      *_scrollHistory;
    NSUInteger  _scrollHistoryIndex;
    NSUInteger  _scrollHistoryLength;
    BOOL        _changingHistorySize;
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
    _updateInterval  = 0.1;
    _plotData             = NULL;
    _scrollHistoryLength = kEZAudioPlotDefaultHistoryBufferLength;
    _scrollHistory       = malloc(_scrollHistoryLength * sizeof(float));
}

- (void)dealloc {
    free(_plotData);
    free(_scrollHistory);
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
- (void)setSampleData:(const float *)data
               length:(NSUInteger)length
               update:(BOOL)update
{
    _plotData   = realloc(_plotData, sizeof(CGPoint)*length);
    _plotLength = length;
    
    _plotData[0] = CGPointZero;
    for(int i = 1; i < length; i++) {
        _plotData[i] = CGPointMake(i, data[i] * _gain);
    }
    
    if (update)
        [self updateUI];
}

#pragma mark - Update

- (UIImage *) getPlot
{
    if (!_plot) {
        // Create a blank back image
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
        // Set the background color
        [self.backgroundColor set];
#if TARGET_OS_IPHONE
        UIRectFill(self.bounds);
#elif TARGET_OS_MAC
        NSRectFill(self.bounds);
#endif
        _plot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _plot;
}

- (void)updateBuffer:(const MYFLT *)buffer withBufferSize:(UInt32)bufferSize update:(BOOL)update
{
    
    // Update the scroll history datasource
    BOOL scrolling = [EZAudio updateScrollHistory:&_scrollHistory
                                       withLength:_scrollHistoryLength
                                          atIndex:&_scrollHistoryIndex
                                       withBuffer:buffer
                                   withBufferSize:bufferSize
                             isResolutionChanging:_changingHistorySize];

    [self setSampleData:_scrollHistory
                 length:_scrollHistoryLength
                 update:update];

    //NSLog(@"Scrolling = %@ idx = %@", scrolling ? @"Y" : @"N", @(_scrollHistoryIndex));
    if (scrolling) {
        // TODO: Slide the existing bitmap to the left to make room for the data from the new buffer
        // Only render that new data in the bitmap
        [self renderIntoBitmap:self.bounds];
    } else {
        // TODO: Try to be smart about gradually filling in the bitmap until we start scrolling
        [self renderIntoBitmap:self.bounds];
    }
}

- (void)renderIntoBitmap:(CGRect)rect
{
    UIImage *plot = [self getPlot];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGRect bounds = self.bounds;

    [plot drawAtPoint:CGPointZero];
    
    // Set the background color
    [self.backgroundColor set];
#if TARGET_OS_IPHONE
    UIRectFill(rect);
#elif TARGET_OS_MAC
    NSRectFill(rect);
#endif
    // Set the waveform line color
    [self.plotColor set];
    
    if(_plotLength > 0) {
        CGFloat xscale = bounds.size.width / (float)_plotLength;
        CGFloat halfHeight = floorf(bounds.size.height / 2.0f), lastx = rect.origin.x + rect.size.width;
        
        CGMutablePathRef halfPath = CGPathCreateMutable();
        int lastindx = 0, indx;
        CGPathMoveToPoint(halfPath, NULL, _plotData[0].x, _plotData[0].y);
        for(CGFloat x = rect.origin.x; x < lastx; x += 1.0f) {
            indx = MIN(roundf(x / xscale), _plotLength-1);
            if (indx != lastindx) {
                CGPoint pt = _plotData[indx];
                CGPathAddLineToPoint(halfPath, NULL, pt.x, pt.y);
                lastindx = indx;
            }
        }
        CGPathAddLineToPoint(halfPath, NULL, _plotData[_plotLength-1].x, 0.0f);
        
        // iOS drawing origin is flipped by default so make sure we account for that
#if TARGET_OS_IPHONE
        const int deviceOriginFlipped = -1;
#elif TARGET_OS_MAC
        const int deviceOriginFlipped = 1;
#endif
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGAffineTransform xf = CGAffineTransformIdentity;
        xf = CGAffineTransformTranslate( xf, bounds.origin.x , halfHeight + bounds.origin.y );
        xf = CGAffineTransformScale( xf, xscale, deviceOriginFlipped*halfHeight );
        CGPathAddPath( path, &xf, halfPath );
        
        if( self.shouldMirror ){
            xf = CGAffineTransformIdentity;
            xf = CGAffineTransformTranslate( xf, bounds.origin.x , halfHeight + bounds.origin.y);
            xf = CGAffineTransformScale( xf, xscale, -deviceOriginFlipped*halfHeight);
            CGPathAddPath( path, &xf, halfPath );
        }
        CGPathRelease(halfPath);
        
        // Now, path contains the full waveform path.
        CGContextAddPath(ctx, path);
        
        if( self.shouldFill ){
            CGContextFillPath(ctx);
        }
        else {
            CGContextStrokePath(ctx);
        }
        CGPathRelease(path);
    }
    _plot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawRect:(CGRect)rect
{
#if TARGET_OS_IPHONE
    // TODO: Draw just the subset of the plot needed, cut from rect
    [[self getPlot] drawAtPoint:CGPointZero];
#elif TARGET_OS_MAC
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
#endif
}

#pragma mark - Adjust Resolution
- (void)setRollingHistoryLength:(NSUInteger)historyLength
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
}

@end

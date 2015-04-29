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

#import "AKFoundation.h"
#import "EZAudioPlot.h"
#import "EZAudio.h"

@interface EZAudioPlot () {
    CGLayerRef  _plot;
#if !TARGET_OS_IPHONE
    CGColorSpaceRef _colorSpace;
#endif
    CGFloat     _lastPoint;
    NSUInteger  _sinceLastUpdate, _indexLastUpdate;
    
    CGFloat     *_plotData;
    NSUInteger   _plotLength;
    
    // Rolling History
    float      *_scrollHistory;
    NSUInteger  _scrollHistoryIndex;
    NSUInteger  _scrollHistoryLength;
    BOOL        _changingHistorySize, _startedScrolling;
}
@end

@implementation EZAudioPlot

#pragma mark - Initialization

- (void)defaultValues {
    self.backgroundColor = [AKColor blackColor];
    _plotColor       = [AKColor yellowColor];
    _gain            = 1.0;
    _shouldMirror    = YES;
    _shouldFill      = YES;
    _updateInterval  = 0.1;
    _plotData            = NULL;
    _scrollHistoryLength = kEZAudioPlotDefaultHistoryBufferLength;
    _scrollHistory       = malloc(_scrollHistoryLength * sizeof(float));
}

- (void)dealloc {
    free(_plotData);
    free(_scrollHistory);
#if !TARGET_OS_IPHONE
    CGColorSpaceRelease(_colorSpace);
#endif
    CGLayerRelease(_plot);
}

#pragma mark - Setters
- (void)setBackgroundColor:(AKColor *)backgroundColor {
    super.backgroundColor = backgroundColor;
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
{
    _plotData   = realloc(_plotData, sizeof(CGFloat)*length);
    _plotLength = length;
    
    for(int i = 0; i < length; i++) {
        _plotData[i] = data[i] * _gain;
    }
}

#pragma mark - Update

- (CGLayerRef) getPlot
{
    if (!_plot) {
        // Create a blank back image
#if TARGET_OS_IPHONE
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
        _plot = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), self.bounds.size, NULL);
#elif TARGET_OS_MAC
        if (_colorSpace == nil)
            _colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        CGContextRef ctx = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height,
                                                 8, 0, _colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
        NSAssert(ctx, @"Failed to create bitmap context");
        _plot = CGLayerCreateWithContext(ctx, self.bounds.size, NULL);
#endif
        CGContextRef layer = CGLayerGetContext(_plot);
        
        // Set the background color
        CGContextSetFillColorWithColor(layer, self.backgroundColor.CGColor);
        CGContextFillRect(layer, self.bounds);
        
#if TARGET_OS_IPHONE
        UIGraphicsEndImageContext();
#elif TARGET_OS_MAC
        CGContextRelease(ctx);
#endif
    }
    return _plot;
}

- (void)updateBuffer:(const float *)buffer withBufferSize:(UInt32)bufferSize update:(BOOL)update
{
    // Update the scroll history datasource - this adds one entry to the sliding history
    BOOL scrolling = [EZAudio updateScrollHistory:&_scrollHistory
                                       withLength:_scrollHistoryLength
                                          atIndex:&_scrollHistoryIndex
                                       withBuffer:buffer
                                   withBufferSize:bufferSize
                             isResolutionChanging:_changingHistorySize];

    [self setSampleData:_scrollHistory
                 length:_scrollHistoryLength];
    
    if (update && _sinceLastUpdate>0) {
        if (scrolling) {
            // Slide the existing bitmap to the left to make room for the data from the new buffer
            [self renderIntoBitmapAt:_scrollHistoryIndex-_sinceLastUpdate
                            scrollBy:_startedScrolling ? _sinceLastUpdate-1 : 0];
            _startedScrolling = YES;
        } else {
            // Try to be smart about gradually filling in the bitmap until we start scrolling
            [self renderIntoBitmapAt:_indexLastUpdate scrollBy:0];
            _indexLastUpdate = _scrollHistoryIndex;
        }
        _sinceLastUpdate = 0;
        [self updateUI];
    } else {
        _sinceLastUpdate ++;
    }

}

// iOS drawing origin is flipped by default so make sure we account for that

- (void)renderIntoBitmapAt:(NSUInteger)smp scrollBy:(NSUInteger)xoffset
{
    CGLayerRef plot = [self getPlot];
#if TARGET_OS_IPHONE
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    CGLayerRef layer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), self.bounds.size, NULL);
#else
    CGContextRef bitctx = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height,
                                                8, 0, _colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    NSAssert(bitctx, @"Failed to create bitmap context");
    CGLayerRef layer = CGLayerCreateWithContext(bitctx, self.bounds.size, NULL);
#endif
    CGContextRef ctx = CGLayerGetContext(layer);

    CGRect bounds = self.bounds;
    // How many horizontal points per sample
    CGFloat xscale = bounds.size.width / (CGFloat)_plotLength;
    
    //CGContextClipToRect(ctx, rect);
    CGContextDrawLayerAtPoint(ctx, CGPointMake(ceilf(-xscale * (CGFloat)xoffset), 0.0f), plot);
    CGRect rect = CGRectMake(smp*xscale, 0.0f, xscale*_sinceLastUpdate, self.bounds.size.height);

    // Set the background color
    CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
    CGContextFillRect(ctx, rect);
    // NSLog(@"Rendering at x=%@ w =%@, offset=%@", @(rect.origin.x), @(rect.size.width), @(xoffset));
    
    if(_plotLength > 0) {
        CGFloat halfHeight = floorf(bounds.size.height / 2.0f);
        
        CGMutablePathRef halfPath = CGPathCreateMutable();
        
        if (self.shouldFill) {
            CGPathMoveToPoint(halfPath, NULL, smp, 0.0f);
            for (NSUInteger i = smp; i < smp+_sinceLastUpdate && i < _plotLength; i++) {
                CGPathAddLineToPoint(halfPath, NULL, i, _plotData[i]);
            }
            CGPathAddLineToPoint(halfPath, NULL, smp+_sinceLastUpdate, 0.0f);
        } else { // Connect to the previous point
            CGPathMoveToPoint(halfPath, NULL, smp-1, _lastPoint);
            for (NSUInteger i = smp+1; i < smp+_sinceLastUpdate && i < _plotLength; i++) {
                _lastPoint = _plotData[i];
                CGPathAddLineToPoint(halfPath, NULL, i, _lastPoint);
            }
        }
        
        // Apply transforms to the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGAffineTransform xf;
        xf = CGAffineTransformMakeTranslation(0, halfHeight);
        xf = CGAffineTransformScale( xf, xscale, AK_DEVICE_ORIGIN*halfHeight );
        CGPathAddPath( path, &xf, halfPath );
        
        // If mirroring, add the path again with mirrored transforms
        if( self.shouldMirror ){
            xf = CGAffineTransformMakeTranslation(0, halfHeight);
            xf = CGAffineTransformScale( xf, xscale, -AK_DEVICE_ORIGIN*halfHeight);
            CGPathAddPath( path, &xf, halfPath );
        }
        CGPathRelease(halfPath);
        
        // Now, path contains the full waveform path.
        CGContextAddPath(ctx, path);
        
        if (self.shouldFill) {
            CGContextSetFillColorWithColor(ctx, self.plotColor.CGColor);
            CGContextFillPath(ctx);
        } else {
            CGContextSetStrokeColorWithColor(ctx, self.plotColor.CGColor);
            CGContextStrokePath(ctx);
        }
        CGPathRelease(path);
    }
#if TARGET_OS_IPHONE
    UIGraphicsEndImageContext();
#else
    CGContextRelease(bitctx);
#endif
    @synchronized(self) {
        // Swap out the old layer for the new
        CGLayerRelease(_plot);
        _plot = layer;
    }
}

- (void)drawRect:(CGRect)rect
{
#if TARGET_OS_IPHONE
    // Draw just the subset of the plot needed, cut from rect
    CGContextRef ctx = UIGraphicsGetCurrentContext();
#elif TARGET_OS_MAC
    [self.backgroundColor setFill];
    NSRectFill(rect);
    NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
#endif
    if (!CGRectEqualToRect(rect, self.bounds)) {
        CGContextClipToRect(ctx, rect);
    }
    @synchronized(self) {
        CGContextDrawLayerAtPoint(ctx, CGPointZero, [self getPlot]);
    }
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

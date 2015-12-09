//
//  EZAudioPlot.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
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

#import "EZAudioPlot.h"

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

UInt32 const kEZAudioPlotMaxHistoryBufferLength = 8192;
UInt32 const kEZAudioPlotDefaultHistoryBufferLength = 512;
UInt32 const EZAudioPlotDefaultHistoryBufferLength = 512;
UInt32 const EZAudioPlotDefaultMaxHistoryBufferLength = 8192;

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlot (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioPlot

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [EZAudioUtilities freeHistoryInfo:self.historyInfo];
    free(self.points);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initPlot];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initPlot];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (id)initWithFrame:(CGRect)frameRect
#elif TARGET_OS_MAC
- (id)initWithFrame:(NSRect)frameRect
#endif
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self initPlot];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.waveformLayer.frame = self.bounds;
    [self redraw];
    [CATransaction commit];
}
#elif TARGET_OS_MAC
- (void)layout
{
    [super layout];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.waveformLayer.frame = self.bounds;
    [self redraw];
    [CATransaction commit];
}
#endif

- (void)initPlot
{
    self.shouldCenterYAxis = YES;
    self.shouldOptimizeForRealtimePlot = YES;
    self.gain = 1.0;
    self.plotType = EZPlotTypeBuffer;
    self.shouldMirror = NO;
    self.shouldFill = NO;
    
    // Setup history window
    [self resetHistoryBuffers];
    
    self.waveformLayer = [EZAudioPlotWaveformLayer layer];
    self.waveformLayer.frame = self.bounds;
    self.waveformLayer.lineWidth = 1.0f;
    self.waveformLayer.fillColor = nil;
    self.waveformLayer.backgroundColor = nil;
    self.waveformLayer.opaque = YES;
    
#if TARGET_OS_IPHONE
    self.color = [UIColor colorWithHue:0 saturation:1.0 brightness:1.0 alpha:1.0]; 
#elif TARGET_OS_MAC
    self.color = [NSColor colorWithCalibratedHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
    self.wantsLayer = YES;
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
#endif
    self.backgroundColor = nil;
    [self.layer insertSublayer:self.waveformLayer atIndex:0];
    
    //
    // Allow subclass to initialize plot
    //
    [self setupPlot];
    
    self.points = calloc(EZAudioPlotDefaultMaxHistoryBufferLength, sizeof(CGPoint));
    self.pointCount = [self initialPointCount];
    [self redraw];
}

//------------------------------------------------------------------------------

- (void)setupPlot
{
    //
    // Override in subclass
    //
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)resetHistoryBuffers
{
    //
    // Clear any existing data
    //
    if (self.historyInfo)
    {
        [EZAudioUtilities freeHistoryInfo:self.historyInfo];
    }
    
    self.historyInfo = [EZAudioUtilities historyInfoWithDefaultLength:[self defaultRollingHistoryLength]
                                                        maximumLength:[self maximumRollingHistoryLength]];
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setBackgroundColor:(id)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.layer.backgroundColor = [backgroundColor CGColor];
}

//------------------------------------------------------------------------------

- (void)setColor:(id)color
{
    [super setColor:color];
    self.waveformLayer.strokeColor = [color CGColor];
    if (self.shouldFill)
    {
        self.waveformLayer.fillColor = [color CGColor];
    }
}

//------------------------------------------------------------------------------

- (void)setShouldOptimizeForRealtimePlot:(BOOL)shouldOptimizeForRealtimePlot
{
    _shouldOptimizeForRealtimePlot = shouldOptimizeForRealtimePlot;
    if (shouldOptimizeForRealtimePlot && !self.displayLink)
    {
        self.displayLink = [EZAudioDisplayLink displayLinkWithDelegate:self];
        [self.displayLink start];
    }
    else
    {
        [self.displayLink stop];
        self.displayLink = nil;
    }
}

//------------------------------------------------------------------------------

- (void)setShouldFill:(BOOL)shouldFill
{
    [super setShouldFill:shouldFill];
    self.waveformLayer.fillColor = shouldFill ? [self.color CGColor] : nil;
}

//------------------------------------------------------------------------------
#pragma mark - Drawing
//------------------------------------------------------------------------------

- (void)clear
{
    if (self.pointCount > 0)
    {
        [self resetHistoryBuffers];
        float data[self.pointCount];
        memset(data, 0, self.pointCount * sizeof(float));
        [self setSampleData:data length:self.pointCount];
        [self redraw];
    }
}

//------------------------------------------------------------------------------

- (void)redraw
{
    EZRect frame = [self.waveformLayer frame];
    CGPathRef path = [self createPathWithPoints:self.points
                                     pointCount:self.pointCount
                                         inRect:frame];
    if (self.shouldOptimizeForRealtimePlot)
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.waveformLayer.path = path;
        [CATransaction commit];
    }
    else
    {
        self.waveformLayer.path = path;
    }
    CGPathRelease(path);
}

//------------------------------------------------------------------------------

- (CGPathRef)createPathWithPoints:(CGPoint *)points
                  pointCount:(UInt32)pointCount
                      inRect:(EZRect)rect
{
    CGMutablePathRef path = NULL;
    if (pointCount > 0)
    {
        path = CGPathCreateMutable();
        double xscale = (rect.size.width) / ((float)self.pointCount);
        double halfHeight = floor(rect.size.height / 2.0);
        int deviceOriginFlipped = [self isDeviceOriginFlipped] ? -1 : 1;
        CGAffineTransform xf = CGAffineTransformIdentity;
        CGFloat translateY = 0.0f;
        if (!self.shouldCenterYAxis)
        {
#if TARGET_OS_IPHONE
            translateY = CGRectGetHeight(rect);
#elif TARGET_OS_MAC
            translateY = 0.0f;
#endif
        }
        else
        {
            translateY = halfHeight + rect.origin.y;
        }
        xf = CGAffineTransformTranslate(xf, 0.0, translateY);
        double yScaleFactor = halfHeight;
        if (!self.shouldCenterYAxis)
        {
            yScaleFactor = 2.0 * halfHeight;
        }
        xf = CGAffineTransformScale(xf, xscale, deviceOriginFlipped * yScaleFactor);
        CGPathAddLines(path, &xf, self.points, self.pointCount);
        if (self.shouldMirror)
        {
            xf = CGAffineTransformScale(xf, 1.0f, -1.0f);
            CGPathAddLines(path, &xf, self.points, self.pointCount);
        }
        if (self.shouldFill)
        {
            CGPathCloseSubpath(path);
        }
    }
    return path;
}

//------------------------------------------------------------------------------
#pragma mark - Update
//------------------------------------------------------------------------------

- (void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    // append the buffer to the history
    [EZAudioUtilities appendBufferRMS:buffer
                       withBufferSize:bufferSize
                        toHistoryInfo:self.historyInfo];
    
    // copy samples
    switch (self.plotType)
    {
        case EZPlotTypeBuffer:
            [self setSampleData:buffer
                         length:bufferSize];
            break;
        case EZPlotTypeRolling:
            
            [self setSampleData:self.historyInfo->buffer
                         length:self.historyInfo->bufferSize];
            break;
        default:
            break;
    }
    
    // update drawing
    if (!self.shouldOptimizeForRealtimePlot)
    {
        [self redraw];
    }
}

//------------------------------------------------------------------------------

- (void)setSampleData:(float *)data length:(int)length
{
    CGPoint *points = self.points;
    for (int i = 0; i < length; i++)
    {
        points[i].x = i;
        points[i].y = data[i] * self.gain;
    }
    points[0].y = points[length - 1].y = 0.0f;
    self.pointCount = length;
}

//------------------------------------------------------------------------------
#pragma mark - Adjusting History Resolution
//------------------------------------------------------------------------------

- (int)rollingHistoryLength
{
    return self.historyInfo->bufferSize;
}

//------------------------------------------------------------------------------

- (int)setRollingHistoryLength:(int)historyLength
{
    self.historyInfo->bufferSize = MIN(EZAudioPlotDefaultMaxHistoryBufferLength, historyLength);
    return self.historyInfo->bufferSize;
}

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

- (int)defaultRollingHistoryLength
{
    return EZAudioPlotDefaultHistoryBufferLength;
}

//------------------------------------------------------------------------------

- (int)initialPointCount
{
    return 100;
}

//------------------------------------------------------------------------------

- (int)maximumRollingHistoryLength
{
    return EZAudioPlotDefaultMaxHistoryBufferLength;
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

- (BOOL)isDeviceOriginFlipped
{
    BOOL isDeviceOriginFlipped = NO;
#if TARGET_OS_IPHONE
    isDeviceOriginFlipped = YES;
#elif TARGET_OS_MAC
#endif
    return isDeviceOriginFlipped;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLinkDelegate
//------------------------------------------------------------------------------

- (void)displayLinkNeedsDisplay:(EZAudioDisplayLink *)displayLink
{
    [self redraw];
}

//------------------------------------------------------------------------------

@end

////------------------------------------------------------------------------------
#pragma mark - EZAudioPlotWaveformLayer (Implementation)
////------------------------------------------------------------------------------

@implementation EZAudioPlotWaveformLayer

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"path"])
    {
        if ([CATransaction disableActions])
        {
            return nil;
        }
        else
        {
            CABasicAnimation *animation = [CABasicAnimation animation];
            animation.timingFunction = [CATransaction animationTimingFunction];
            animation.duration = [CATransaction animationDuration];
            return animation;
        }
        return nil;
    }
    return [super actionForKey:event];
}

@end
//
//  EZAudioDisplayLink.m
//  EZAudio
//
//  Created by Syed Haris Ali on 6/25/15.
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

#import "EZAudioDisplayLink.h"

//------------------------------------------------------------------------------
#pragma mark - CVDisplayLink Callback (Declaration)
//------------------------------------------------------------------------------

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
static CVReturn EZAudioDisplayLinkCallback(CVDisplayLinkRef displayLinkRef,
                                           const CVTimeStamp *now,
                                           const CVTimeStamp *outputTime,
                                           CVOptionFlags flagsIn,
                                           CVOptionFlags *flagsOut,
                                           void   *displayLinkContext);
#endif

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLink (Interface Extension)
//------------------------------------------------------------------------------

@interface EZAudioDisplayLink ()
#if TARGET_OS_IPHONE
@property (nonatomic, strong) CADisplayLink *displayLink;
#elif TARGET_OS_MAC
@property (nonatomic, assign) CVDisplayLinkRef displayLink;
#endif
@property (nonatomic, assign) BOOL stopped;
@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLink (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioDisplayLink

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
#if TARGET_OS_IPHONE
    [self.displayLink invalidate];
#elif TARGET_OS_MAC
    CVDisplayLinkStop(self.displayLink);
    CVDisplayLinkRelease(self.displayLink);
    self.displayLink = nil;
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Class Initialization
//------------------------------------------------------------------------------

+ (instancetype)displayLinkWithDelegate:(id<EZAudioDisplayLinkDelegate>)delegate
{
    EZAudioDisplayLink *displayLink = [[self alloc] init];
    displayLink.delegate = delegate;
    return displayLink;
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    self.stopped = YES;
#if TARGET_OS_IPHONE
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#elif TARGET_OS_MAC
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink,
                                   EZAudioDisplayLinkCallback,
                                   (__bridge void *)(self));
    CVDisplayLinkStart(self.displayLink);
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)start
{
#if TARGET_OS_IPHONE
    self.displayLink.paused = NO;
#elif TARGET_OS_MAC
    CVDisplayLinkStart(self.displayLink);
#endif
    self.stopped = NO;
}

//------------------------------------------------------------------------------

- (void)stop
{
#if TARGET_OS_IPHONE
    self.displayLink.paused = YES;
#elif TARGET_OS_MAC
    CVDisplayLinkStop(self.displayLink);
#endif
    self.stopped = YES;
}

//------------------------------------------------------------------------------

- (void)update
{
    if (!self.stopped)
    {
        if ([self.delegate respondsToSelector:@selector(displayLinkNeedsDisplay:)])
        {
            [self.delegate displayLinkNeedsDisplay:self];
        }
    }
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------
#pragma mark - CVDisplayLink Callback (Implementation)
//------------------------------------------------------------------------------

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
static CVReturn EZAudioDisplayLinkCallback(CVDisplayLinkRef displayLinkRef,
                                           const CVTimeStamp *now,
                                           const CVTimeStamp *outputTime,
                                           CVOptionFlags flagsIn,
                                           CVOptionFlags *flagsOut,
                                           void   *displayLinkContext)
{
    EZAudioDisplayLink *displayLink = (__bridge EZAudioDisplayLink*)displayLinkContext;
    [displayLink update];
    return kCVReturnSuccess;
}
#endif
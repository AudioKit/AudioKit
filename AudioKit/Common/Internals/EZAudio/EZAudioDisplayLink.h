//
//  EZAudioDisplayLink.h
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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class EZAudioDisplayLink;

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLinkDelegate
//------------------------------------------------------------------------------

/**
 The EZAudioDisplayLinkDelegate provides a means for an EZAudioDisplayLink instance to notify a receiver when it should redraw itself.
 */
@protocol EZAudioDisplayLinkDelegate <NSObject>

@required
/**
 Required method for an EZAudioDisplayLinkDelegate to implement. This fires at the screen's display rate (typically 60 fps).
 @param displayLink An EZAudioDisplayLink instance used by a receiver to draw itself at the screen's refresh rate.
 */
- (void)displayLinkNeedsDisplay:(EZAudioDisplayLink *)displayLink;

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLink
//------------------------------------------------------------------------------

/**
 The EZAudioDisplayLink provides a cross-platform (iOS and Mac) abstraction over the CADisplayLink for iOS and CVDisplayLink for Mac. The purpose of this class is to provide an accurate timer for views that need to redraw themselves at 60 fps. This class is used by the EZAudioPlot and, eventually, the EZAudioPlotGL to provide a timer mechanism to draw real-time plots.
 */
@interface EZAudioDisplayLink : NSObject

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

/**
 Class method to create an EZAudioDisplayLink. The caller should implement the EZAudioDisplayLinkDelegate protocol to receive the `displayLinkNeedsDisplay:` delegate method to know when to redraw itself.
 @param delegate An instance that implements the EZAudioDisplayLinkDelegate protocol.
 @return An instance of the EZAudioDisplayLink.
 */
+ (instancetype)displayLinkWithDelegate:(id<EZAudioDisplayLinkDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 The EZAudioDisplayLinkDelegate for which to receive the redraw calls.
 */
@property (nonatomic, weak) id<EZAudioDisplayLinkDelegate> delegate;

//------------------------------------------------------------------------------
#pragma mark - Instance Methods
//------------------------------------------------------------------------------

/**
 Method to start the display link and provide the `displayLinkNeedsDisplay:` calls to the `delegate`
 */
- (void)start;

/**
 Method to stop the display link from providing the `displayLinkNeedsDisplay:` calls to the `delegate`
 */
- (void)stop;

//------------------------------------------------------------------------------

@end

//
//  EZAudioPlot.h
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


@class EZAudio;

#define kEZAudioPlotMaxHistoryBufferLength (8192)

#define kEZAudioPlotDefaultHistoryBufferLength (1024)

/**
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. 
 
 The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    
 * Buffer (`EZPlotTypeBuffer`) - A plot that only consists of the current buffer and buffer size from the last call to `updateBuffer:withBufferSize:`. This looks similar to the default openFrameworks input audio example.
 * Rolling (`EZPlotTypeRolling`) - A plot that consists of a rolling history of values averaged from each buffer. This is the traditional waveform look.
 
 #Parent Methods and Properties#
 
 See EZPlot for full API methods and properties (colors, plot type, update function)
 
 */

#import "AKFoundation.h"
#import "AKPlotView.h"

IB_DESIGNABLE
@interface EZAudioPlot : AKPlotView

#pragma mark - Adjust Resolution
///-----------------------------------------------------------
/// @name Adjusting The Resolution
///-----------------------------------------------------------

/**
 Sets the length of the rolling history display. Can grow or shrink the display up to the maximum size specified by the kEZAudioPlotMaxHistoryBufferLength macro. Will return the actual set value, which will be either the given value if smaller than the kEZAudioPlotMaxHistoryBufferLength or kEZAudioPlotMaxHistoryBufferLength if a larger value is attempted to be set. 
 @param  historyLength The new length of the rolling history buffer.
 @return The new value equal to the historyLength or the kEZAudioPlotMaxHistoryBufferLength.
 */
-(int)setRollingHistoryLength:(int)historyLength;

/**
 Provides the length of the rolling history buffer
 *  @return An int representing the length of the rolling history buffer
 */
-(int)rollingHistoryLength;

#pragma mark - Subclass Methods

/**
 <#Description#>
 @param data   <#theplotData description#>
 @param length <#length description#>
 */
-(void)setSampleData:(float *)data
              length:(int)length;


#if TARGET_OS_IPHONE
@property (nonatomic,strong) IBInspectable UIColor *backgroundColor;
#else
@property (nonatomic,strong) IBInspectable NSColor *backgroundColor;
#endif

/**
 The default color of the plot's data (i.e. waveform, y-axis values). For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is red.
 */
#if TARGET_OS_IPHONE
@property (nonatomic,strong) IBInspectable UIColor *plotColor;
#else
@property (nonatomic,strong) IBInspectable NSColor *plotColor;
#endif

/**
 The plot's gain value, which controls the scale of the y-axis values. The default value of the gain is 1.0f and should always be greater than 0.0f.
 */
@property (nonatomic,assign,setter=setGain:) IBInspectable float gain;


/**
 A boolean indicating whether or not to fill in the graph. A value of YES will make a filled graph (filling in the space between the x-axis and the y-value), while a value of NO will create a stroked graph (connecting the points along the y-axis).
 */
@property (nonatomic,assign,setter=setShouldFill:) IBInspectable BOOL shouldFill;

/**
 A boolean indicating whether the graph should be rotated along the x-axis to give a mirrored reflection. This is typical for audio plots to produce the classic waveform look. A value of YES will produce a mirrored reflection of the y-values about the x-axis, while a value of NO will only plot the y-values.
 */
@property (nonatomic,assign,setter=setShouldMirror:) IBInspectable BOOL shouldMirror;

#pragma mark - Get Samples
///-----------------------------------------------------------
/// @name Updating The Plot
///-----------------------------------------------------------

/**
 Updates the plot with the new buffer data and tells the view to redraw itself. Caller will provide a float array with the values they expect to see on the y-axis. The plot will internally handle mapping the x-axis and y-axis to the current view port, any interpolation for fills effects, and mirroring.
 @param buffer     A float array of values to map to the y-axis.
 @param bufferSize The size of the float array that will be mapped to the y-axis.
 @warning The bufferSize is expected to be the same, constant value once initial triggered. For plots using OpenGL a vertex buffer object will be allocated with a maximum buffersize of (2 * the initial given buffer size) to account for any interpolation necessary for filling in the graph. Updates use the glBufferSubData(...) function, which will crash if the buffersize exceeds the initial maximum allocated size.
 */
-(void)updateBuffer:(MYFLT *)buffer
     withBufferSize:(UInt32)bufferSize;
@end

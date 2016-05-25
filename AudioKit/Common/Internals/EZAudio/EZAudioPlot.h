//
//  EZAudioPlot.h
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

#import <QuartzCore/QuartzCore.h>
#import "EZPlot.h"
#import "EZAudioDisplayLink.h"

@class EZAudio;

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

/**
 The default value used for the maximum rolling history buffer length of any EZAudioPlot.
 @deprecated This constant is deprecated starting in version 0.2.0.
 @note Please use EZAudioPlotDefaultMaxHistoryBufferLength instead.
 */
FOUNDATION_EXPORT UInt32 const kEZAudioPlotMaxHistoryBufferLength __attribute__((deprecated));

/**
 The default value used for the default rolling history buffer length of any EZAudioPlot.
 @deprecated This constant is deprecated starting in version 0.2.0.
 @note Please use EZAudioPlotDefaultHistoryBufferLength instead.
 */
FOUNDATION_EXPORT UInt32 const kEZAudioPlotDefaultHistoryBufferLength __attribute__((deprecated));

/**
 The default value used for the default rolling history buffer length of any EZAudioPlot.
 */
FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultHistoryBufferLength;

/**
 The default value used for the maximum rolling history buffer length of any EZAudioPlot.
 */
FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultMaxHistoryBufferLength;

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlotWaveformLayer
//------------------------------------------------------------------------------

/**
 The EZAudioPlotWaveformLayer is a lightweight subclass of the CAShapeLayer that allows implicit animations on the `path` key.
 */
@interface EZAudioPlotWaveformLayer : CAShapeLayer
@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlot
//------------------------------------------------------------------------------

/**
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. 
 
 The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    
 * Buffer (`EZPlotTypeBuffer`) - A plot that only consists of the current buffer and buffer size from the last call to `updateBuffer:withBufferSize:`. This looks similar to the default openFrameworks input audio example.
 * Rolling (`EZPlotTypeRolling`) - A plot that consists of a rolling history of values averaged from each buffer. This is the traditional waveform look.
 
 #Parent Methods and Properties#
 
 See EZPlot for full API methods and properties (colors, plot type, update function)
 
 */
@interface EZAudioPlot : EZPlot

/**
 A BOOL that allows optimizing the audio plot's drawing for real-time displays. Since the update function may be updating the plot's data very quickly (over 60 frames per second) this property will throttle the drawing calls to be 60 frames per second (or whatever the screen rate is). Specifically, it disables implicit path change animations on the `waveformLayer` and sets up a display link to render 60 fps (audio updating the plot at 44.1 kHz causes it to re-render 86 fps - far greater than what is needed for a visual display).
 */
@property (nonatomic, assign) BOOL shouldOptimizeForRealtimePlot;

//------------------------------------------------------------------------------

/**
 A BOOL indicating whether the plot should center itself vertically.
 */
@property (nonatomic, assign) BOOL shouldCenterYAxis;

//------------------------------------------------------------------------------

/**
 An EZAudioPlotWaveformLayer that is used to render the actual waveform. By switching the drawing code to Core Animation layers in version 0.2.0 most work, specifically the compositing step, is now done on the GPU. Hence, multiple EZAudioPlot instances can be used simultaneously with very low CPU overhead so these are now practical for table and collection views.
 */
@property (nonatomic, strong) EZAudioPlotWaveformLayer *waveformLayer;

//------------------------------------------------------------------------------
#pragma mark - Adjust Resolution
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Adjusting The Resolution
///-----------------------------------------------------------

/**
 Sets the length of the rolling history buffer (i.e. the number of points in the rolling plot's buffer). Can grow or shrink the display up to the maximum size specified by the `maximumRollingHistoryLength` method. Will return the actual set value, which will be either the given value if smaller than the `maximumRollingHistoryLength` or `maximumRollingHistoryLength` if a larger value is attempted to be set.
 @param  historyLength The new length of the rolling history buffer.
 @return The new value equal to the historyLength or the `maximumRollingHistoryLength`.
 */
-(int)setRollingHistoryLength:(int)historyLength;

//------------------------------------------------------------------------------

/**
 Provides the length of the rolling history buffer (i.e. the number of points in the rolling plot's buffer).
 *  @return An int representing the length of the rolling history buffer
 */
-(int)rollingHistoryLength;

//------------------------------------------------------------------------------
#pragma mark - Subclass Methods
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Subclass Methods
///-----------------------------------------------------------

/**
 Main method that handles converting the points created from the `updatedBuffer:withBufferSize:` method into a CGPathRef to store in the `waveformLayer`. In this method you can create any path you'd like using the point array (for instance, maybe mapping the points to a circle instead of the standard 2D plane).
 @param points     An array of CGPoint structures, with the x values ranging from 0 - (pointCount - 1) and y values containing the last audio data's buffer.
 @param pointCount A UInt32 of the length of the point array.
 @param rect       An EZRect (CGRect on iOS or NSRect on OSX) that the path should be created relative to.
 @return A CGPathRef that is the path you'd like to store on the `waveformLayer` to visualize the audio data.
 */
- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(UInt32)pointCount
                           inRect:(EZRect)rect;

//------------------------------------------------------------------------------

/**
 Provides the default length of the rolling history buffer when the plot is initialized. Default is `EZAudioPlotDefaultHistoryBufferLength` constant.
 @return An int describing the initial length of the rolling history buffer.
 */
- (int)defaultRollingHistoryLength;

//------------------------------------------------------------------------------

/**
 Called after the view has been created. Subclasses should use to add any additional methods needed instead of overriding the init methods.
 */
- (void)setupPlot;

//------------------------------------------------------------------------------

/**
 Provides the default number of points that will be used to initialize the graph's points data structure that holds. Essentially the plot starts off as a flat line of this many points. Default is 100.
 @return An int describing the initial number of points the plot should have when flat lined.
 */
- (int)initialPointCount;

//------------------------------------------------------------------------------

/**
 Provides the default maximum rolling history length - that is, the maximum amount of points the `setRollingHistoryLength:` method may be set to. If a length higher than this is set then the plot will likely crash because the appropriate resources are only allocated once during the plot's initialization step. Defualt is `EZAudioPlotDefaultMaxHistoryBufferLength` constant.
 @return An int describing the maximum length of the absolute rolling history buffer.
 */
- (int)maximumRollingHistoryLength;

//------------------------------------------------------------------------------

/**
 Method to cause the waveform layer's path to get recreated and redrawn on screen using the last buffer of data provided. This is the equivalent to the drawRect: method used to normally subclass a view's drawing. This normally don't need to be overrode though - a better approach would be to override the `createPathWithPoints:pointCount:inRect:` method.
 */
- (void)redraw;

//------------------------------------------------------------------------------

/**
 Main method used to copy the sample data from the source buffer and update the
 plot. Subclasses can overwrite this method for custom behavior.
 @param data   A float array of the sample data. Subclasses should copy this data to a separate array to avoid threading issues.
 @param length The length of the float array as an int.
 */
-(void)setSampleData:(float *)data length:(int)length;

//------------------------------------------------------------------------------

/**
 Changes the waveform color, but does not overwrite the original color.
 @param color UIColor to change the waveform to
 */
- (void)updateColor:(id)color;

//------------------------------------------------------------------------------

@end

@interface EZAudioPlot () <EZAudioDisplayLinkDelegate>
@property (nonatomic, strong) EZAudioDisplayLink *displayLink;
@property (nonatomic, assign) EZPlotHistoryInfo  *historyInfo;
@property (nonatomic, assign) CGPoint            *points;
@property (nonatomic, assign) UInt32              pointCount;
@property (nonatomic, assign) bool                fadeout;
#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIColor            *originalColor;
#elif TARGET_OS_MAC
@property (nonatomic, strong) NSColor            *originalColor;
#endif
@end
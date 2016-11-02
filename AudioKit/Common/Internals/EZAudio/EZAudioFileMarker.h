//
//  EZAudioFileMarker.h
//
//  Created by Ryan Francesconi on 10/29/16.
//
//  A simple Swift friendly wrapper around the following C struct:
//  see: https://developer.apple.com/reference/audiotoolbox/audiofilemarker
//  Used in EZAudioFile.markers

#import <Foundation/Foundation.h>

@interface EZAudioFileMarker : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSNumber *framePosition;
@property (nonatomic, strong) NSNumber *markerID;
@property (nonatomic, strong) NSNumber *type;

@end

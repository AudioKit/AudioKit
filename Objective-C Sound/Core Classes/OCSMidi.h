//
//  OCSMidi.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol OCSMidiListener <NSObject>

-(void)noteOn:(int)note velocity:(int)velocity;
-(void)noteOff:(int)note velocity:(int)velocity;
-(void)controller:(int)controller changedToValue:(int)value;

@end


@interface OCSMidi : NSObject {
    NSMutableSet *listeners;
}
@property (nonatomic, strong) NSMutableArray *listeners;

-(void)addListener:(id<OCSMidiListener>)listener;

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

@end

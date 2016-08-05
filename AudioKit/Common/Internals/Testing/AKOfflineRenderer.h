//
//  AKOfflineRenderer.h
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

@interface AKOfflineRenderer: NSObject
@property(strong, nonatomic) AVAudioEngine *engine;
- (instancetype)initWithEngine:(AVAudioEngine *)injun;
- (void)render:(int)samples;
@end

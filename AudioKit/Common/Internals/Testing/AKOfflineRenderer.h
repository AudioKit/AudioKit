//
//  AKOfflineRenderer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2017 AudioKit. All rights reserved.
//

@interface AKOfflineRenderer: NSObject
@property(strong, nonatomic) AVAudioEngine *engine;
- (instancetype)initWithEngine:(AVAudioEngine *)injun;
- (void)render:(int)samples;
@end

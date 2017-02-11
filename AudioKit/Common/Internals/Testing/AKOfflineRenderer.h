//
//  AKOfflineRenderer.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

@interface AKOfflineRenderer: NSObject
@property(strong, nonatomic) AVAudioEngine *engine;
- (instancetype)initWithEngine:(AVAudioEngine *)injun;
- (void)render:(int)samples;
@end

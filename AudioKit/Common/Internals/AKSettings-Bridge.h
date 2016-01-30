//
//  AKSettings-Bridge.h
//  AudioKit
//
//  Created by Stéphane Peter on 1/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#ifndef AKSettings_Bridge_h
#define AKSettings_Bridge_h

double  _AKSettings_sampleRate(void);
short   _AKSettings_numberOfChannels(void);
int     _AKSettings_audioInputEnabled(void);
int     _AKSettings_playbackWhileMuted(void);

#endif /* AKSettings_Bridge_h */

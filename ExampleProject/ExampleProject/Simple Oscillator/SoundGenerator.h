//  SoundGenerator.h

#import <UIKit/UIKit.h>
#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDOscillator.h"
#import "CSDParamArray.h"
#import "CSDReverb.h"
#import "CSDOutputStereo.h"

@interface SoundGenerator : CSDInstrument 
    
-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end

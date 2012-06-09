//  SoundGenerator.h

#import <UIKit/UIKit.h>
#import "CSDManager.h"
#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDParam.h"
#import "CSDParamArray.h"
#import "CSDOutputStereo.h"
#import "CSDReverb.h"

#import "CSDOscillator.h"

@interface SoundGenerator : CSDInstrument 
    
-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch;

@end

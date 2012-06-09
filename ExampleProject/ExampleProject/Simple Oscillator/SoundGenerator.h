//  SoundGenerator.h

#import <UIKit/UIKit.h>
#import "CSDManager.h"
#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDParam.h"
#import "CSDParamArray.h"
#import "CSDOutputMono.h"

#import "CSDOscillator.h"

@interface SoundGenerator : CSDInstrument {
    CSDOscillator * myOscillator;
}


-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch;

@end

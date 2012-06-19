//  CSDManager.h

#import <Foundation/Foundation.h>

#import "CsoundObj.h"
#import "CSDConstants.h"
#import "CSDInstrument.h"
#import "CSDOrchestra.h"

//#import "CSDContinuousManager.h"

@interface CSDManager : NSObject <CsoundObjCompletionListener> {
    //TODO: odbfs, sr stuff
    BOOL isRunning;
    NSString * options;
    int sampleRate;
    int samplesPerControlPeriod;
    float zeroDBFullScaleValue;
    NSString * myCSDFile;
    NSString * templateCSDFileContents;

    //CSDContinuousManager * myContinuousManager;
    
    CsoundObj * csound;

}
//@property (nonatomic, strong) NSString * options;
@property (readonly) BOOL isRunning;
//@property (nonatomic, strong) CSDContinuousManager * myContinuousManager;

+(CSDManager *) sharedCSDManager;
-(void)runCSDFile:(NSString *)filename;
-(void)runOrchestra:(CSDOrchestra *)orch;
-(void)stop;
-(void)playNote:(NSString *)note OnInstrument:(CSDInstrument *)instrument;

-(void)updateValueCacheWithContinuousParams:(CSDOrchestra *)orch;

//Other Potential problems
//-(void)mute;
//-(void)pause;
@end

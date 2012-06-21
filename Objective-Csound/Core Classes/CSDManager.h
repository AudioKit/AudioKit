//  CSDManager.h

#import <Foundation/Foundation.h>

#import "CsoundObj.h"
#import "CSDConstants.h"
#import "CSDInstrument.h"
#import "CSDOrchestra.h"

//#import "CSDPropertyManager.h"

@interface CSDManager : NSObject <CsoundObjCompletionListener> {
    //TODO: odbfs, sr stuff
    BOOL isRunning;
    NSString * options;
    int sampleRate;
    int samplesPerControlPeriod;
    float zeroDBFullScaleValue;
    NSString * myCSDFile;
    NSString * templateCSDFileContents;

    //CSDPropertyManager * myPropertyManager;
    
    CsoundObj * csound;

}
//@property (nonatomic, strong) NSString * options;
@property (readonly) BOOL isRunning;
//@property (nonatomic, strong) CSDPropertyManager * myPropertyManager;

+(CSDManager *) sharedCSDManager;
-(void)runCSDFile:(NSString *)filename;
-(void)runOrchestra:(CSDOrchestra *)orch;
-(void)stop;
-(void)playNote:(NSString *)note OnInstrument:(CSDInstrument *)instrument;

-(void)updateValueCacheWithProperties:(CSDOrchestra *)orch;

//Other Potential problems
//-(void)mute;
//-(void)pause;
@end

//  CSDManager.h

#import <Foundation/Foundation.h>

#import "CsoundObj.h"
#import "CSDConstants.h"
#import "CSDInstrument.h"
#import "CSDOrchestra.h"

@interface CSDManager : NSObject <CsoundObjCompletionListener> {
    //TODO: odbfs, sr stuff
    BOOL isRunning;
    NSString * options;
    int sampleRate;
    int samplesPerControlPeriod;
    float zeroDBFullScaleValue;
    NSString * myCSDFile;
    NSString * templateCSDFileContents;
    
    CsoundObj * csound;
}
//@property (nonatomic, strong) NSString * options;
@property (readonly) BOOL isRunning;

+(CSDManager *) sharedCSDManager;
-(void)runCSDFile:(NSString *)filename;
-(void)runOrchestra:(CSDOrchestra *)orch;
-(void)stop;
-(void)playNote:(NSString *)note OnInstrument:(CSDInstrument *)instrument;

//Other Potential problems
//-(void)mute;
//-(void)pause;
@end

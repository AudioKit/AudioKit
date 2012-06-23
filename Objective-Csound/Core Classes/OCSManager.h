//
//  OCSManager.h
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CsoundObj.h"
#import "OCSInstrument.h"
#import "OCSOrchestra.h"

//#import "OCSPropertyManager.h"

@interface OCSManager : NSObject <CsoundObjCompletionListener> {
    //TODO: odbfs, sr stuff
    BOOL isRunning;
    NSString *options;
    int sampleRate;
    int samplesPerControlPeriod;
    float zeroDBFullScaleValue;
    NSString *myCSDFile;
    NSString *templateCSDFileContents;

    //OCSPropertyManager *myPropertyManager;
    
    CsoundObj *csound;

}
//@property (nonatomic, strong) NSString *options;
@property (readonly) BOOL isRunning;
//@property (nonatomic, strong) OCSPropertyManager *myPropertyManager;

+ (OCSManager *) sharedOCSManager;
- (void)runCSDFile:(NSString *)filename;
- (void)runOrchestra:(OCSOrchestra *)orch;
- (void)stop;
- (void)playNote:(NSString *)note OnInstrument:(OCSInstrument *)instrument;

- (void)updateValueCacheWithProperties:(OCSOrchestra *)orch;

//Other Potential problems
//- (void)mute;
//- (void)pause;
@end

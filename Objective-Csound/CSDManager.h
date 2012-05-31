//  CSDManager.h

#import <Foundation/Foundation.h>

#import "CsoundObj.h"
#import "CSDOrchestra.h"

@interface CSDManager : NSObject {
    BOOL isRunning;
    CsoundObj * csound;
}
@property (nonatomic, strong) NSString * options;
@property (readonly) BOOL isRunning;

+(CSDManager *) sharedCSDManager;
-(void)runCSDFile:(NSString *)filename;
-(void)runOrchestra:(CSDOrchestra *)orch;
-(void)stop;

//Other Potential problems
//-(void)mute;
//-(void)pause;
@end

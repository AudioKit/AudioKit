// CSDOrchestra.h
//
// CSDOrchestra is a collection of instruments.  
//
// TODO: 
// * Differentiate between regular instruments and global instruments

#import <Foundation/Foundation.h>
#import "CSDConstants.h"
@class CSDInstrument;

@interface CSDOrchestra : NSObject 
@property (nonatomic, strong) NSMutableArray * instruments;
-(void) addInstrument:(CSDInstrument *) instrument;
-(NSString *) instrumentsForCsd;
@end

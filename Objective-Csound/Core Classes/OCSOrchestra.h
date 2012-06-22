// OCSOrchestra.h
//
// OCSOrchestra is a collection of instruments.  
//
// TODO: 
// * Differentiate between regular instruments and global instruments

#import <Foundation/Foundation.h>
#import "OCSConstants.h"
@class OCSInstrument;

@interface OCSOrchestra : NSObject 
@property (nonatomic, strong) NSMutableArray * instruments;
-(void) addInstrument:(OCSInstrument *) instrument;
-(NSString *) instrumentsForCsd;
@end

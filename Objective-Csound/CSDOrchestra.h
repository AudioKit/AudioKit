// CSDOrchestra.h
//
// CSDOrchestra is a collection of instruments.  
//
// TODO: 
// * Differentiate between regular instruments and global instruments

#import <Foundation/Foundation.h>

@class CSDInstrument;
@class CSDFunctionStatement;

@interface CSDOrchestra : NSObject 
@property (nonatomic, strong) NSMutableArray * instruments;
-(int) addInstrument:(CSDInstrument *) instrument;
@end

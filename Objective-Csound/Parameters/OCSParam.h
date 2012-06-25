//
//  OCSParam.h
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

/** OCS Parameters are arguments to Csound opcodes.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 OCSParam, it is at audio rate.  OCSParamControl and OCSParamConstant should be used for
 slower rate variables. */

@interface OCSParam : NSObject
{
    NSString *type; 
    NSString *parameterString;
    int _myID;
}
@property (nonatomic, strong) NSString *parameterString;

- (id)initWithString:(NSString *)aString;
+ (id)paramWithString:(NSString *)aString;

- (id)initWithExpression:(NSString *)aExpression;
+ (id)paramWithFormat:(NSString *)format, ...;
+ (void) resetID;
@end

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import <AVFoundation/AVFoundation.h>

@interface AUParameter(Ext)

+(_Nonnull instancetype)parameterWithIdentifier:(NSString * _Nonnull)identifier
                                           name:(NSString * _Nonnull)name
                                        address:(AUParameterAddress)address
                                            min:(AUValue)min
                                            max:(AUValue)max
                                           unit:(AudioUnitParameterUnit)unit
                                          flags:(AudioUnitParameterOptions)flags;

+(_Nonnull instancetype)parameterWithIdentifier:(NSString * _Nonnull)identifier
                                           name:(NSString * _Nonnull)name
                                        address:(AUParameterAddress)address
                                            min:(AUValue)min
                                            max:(AUValue)max
                                           unit:(AudioUnitParameterUnit)unit;
@end

@interface AUParameterTree(Ext)
+(_Nonnull instancetype)treeWithChildren:(NSArray<AUParameter *> * _Nonnull)children;
@end

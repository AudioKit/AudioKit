//
//  AKTableGenerator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKTableGenerator : NSObject

/// Generation Routine Number
- (int)generationRoutineNumber;

/// Parameters for the generator
/// @param size The final size of the table, useful for scaling
- (NSArray *)parametersWithSize:(int)size;

@end

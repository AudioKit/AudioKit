/* 
 
 CsoundVirtualKeyboard.m:
 
 Copyright (C) 2011 Steven Yi
 
 This file is part of Csound iOS Examples.
 
 The Csound for iOS Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.   
 
 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 
 */

#import "CsoundVirtualKeyboard.h"

static const int kTotalNumKeys = 25;

@interface CsoundVirtualKeyboard()

- (BOOL)isWhiteKey:(int)key;

@end

@implementation CsoundVirtualKeyboard

@synthesize keyboardDelegate = mKeyboardDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		for (int i = 1; i < kTotalNumKeys; i++) {
			keyDown[i] = NO;
		}
		
		lastWidth = -1.0f;
		currentTouches = [[NSMutableSet alloc] init];
		self.multipleTouchEnabled = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		for (int i = 1; i < kTotalNumKeys; i++) {
			keyDown[i] = NO;
		}
		
		lastWidth = -1.0f;
		currentTouches = [[NSMutableSet alloc] init];
		self.multipleTouchEnabled = YES;
	}
	return self;
}

- (BOOL)isWhiteKey:(int)key {
	switch (key % 12) {
		case 0:
		case 2:
		case 4:
		case 5:
		case 7:
		case 9:
		case 11:
			return YES;
	}
	
	return NO;
}

-(void)updateKeyRects {
	
	if (lastWidth == self.bounds.size.width) {
		return;
	}
	
	lastWidth = self.bounds.size.width;
	
	CGFloat whiteKeyHeight = self.bounds.size.height;
	CGFloat blackKeyHeight = whiteKeyHeight * .625;
	
	CGFloat whiteKeyWidth = self.bounds.size.width / 15.0f;
	CGFloat blackKeyWidth = whiteKeyWidth * .8333333f;
	
	CGFloat leftKeyBound = whiteKeyWidth - (blackKeyWidth / 2.0f);
	
	int lastWhiteKey = 0;
	
	keyRects[0] = CGRectMake(0, 0, whiteKeyWidth, whiteKeyHeight);
	
	for (int i = 1; i < kTotalNumKeys; i++) {
		
		if (![self isWhiteKey:i]) {				
			keyRects[i] = CGRectMake((lastWhiteKey * whiteKeyWidth) + leftKeyBound, 0, blackKeyWidth, blackKeyHeight);
		} else {
			lastWhiteKey++;
			keyRects[i] = CGRectMake(lastWhiteKey * whiteKeyWidth, 0, whiteKeyWidth, whiteKeyHeight);
		}
		
	}
	
}

-(int)getKeyboardKey:(CGPoint)point {
	
	int keyNum = -1;
	
	for(int i = 0; i < kTotalNumKeys; i++) {
		if (CGRectContainsPoint(keyRects[i], point)) {
			keyNum = i;
			if (![self isWhiteKey:i]) {
				break;
			}
		}
	}
	
	return keyNum;
}

- (void)updateKeyStates {
	
	[self updateKeyRects];
    
	NSArray* touches = [currentTouches allObjects];
	int count = [touches count];
    
	int currentKeyState[kTotalNumKeys];
	
	for (int i = 0; i < kTotalNumKeys; i++) {
		currentKeyState[i] = NO;
	}
	
	for (int i = 0; i < count; i++) {
		UITouch* touch = [touches objectAtIndex:i];
		CGPoint point = [touch locationInView:self];
		int index = [self getKeyboardKey:point];
		
		if(index != -1) {
			currentKeyState[index] = YES; 
		}
	}
	
	BOOL keysUpdated = NO;
	
	for (int i = 0; i < kTotalNumKeys; i++) {
		if (keyDown[i] != currentKeyState[i]) {
			keysUpdated = YES;
			BOOL keyDownState = currentKeyState[i];
			
			keyDown[i] = keyDownState;
			
			if (mKeyboardDelegate != nil) {
				if (keyDownState) {
					[mKeyboardDelegate keyDown:self keyNum:i];
				} else {
					[mKeyboardDelegate keyUp:self keyNum:i];
				}
			}
		}
	}
	
	if (keysUpdated) {
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}

#pragma mark Touch Handling Code

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch* touch in touches) {
		[currentTouches addObject:touch];
	}
	[self updateKeyStates];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self updateKeyStates];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch* touch in touches) {
		[currentTouches removeObject:touch];
	}
	[self updateKeyStates];	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch* touch in touches) {
		[currentTouches removeObject:touch];
	}
	[self updateKeyStates];
	
}


#pragma mark Drawing Code


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	
	// Get the context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat whiteKeyHeight = rect.size.height;
	CGFloat blackKeyHeight = (int)(rect.size.height * .625);
	//CGFloat whiteKeyWidth = rect.size.width / 52.0f;
	CGFloat whiteKeyWidth = rect.size.width / 15.0f;
	CGFloat blackKeyWidth = whiteKeyWidth * .8333333;
	CGFloat blackKeyOffset = blackKeyWidth / 2;
	
	float runningX = 0;
	int yval = 0;
	
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, self.bounds);
	
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextStrokeRect(context, self.bounds);
	
	int lineHeight = whiteKeyHeight - 1;
    
	// Draw White Keys
	for (int i = 0; i < kTotalNumKeys; i++) {
		if ([self isWhiteKey:i]) {
			int newX = (int) (runningX + 0.5);
			
			if (keyDown[i]) {
				int newW = (int) ((runningX + whiteKeyWidth + 0.5) - newX);
				
				CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
				CGContextFillRect(context, CGRectMake(newX, yval, newW, whiteKeyHeight - 1));
                
			}
			
			runningX += whiteKeyWidth;
			
			CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
			CGContextStrokeRect(context, CGRectMake(newX, yval, newX, lineHeight));
		}
	}
	
	runningX = 0.0f;
	
	// Draw Black Keys
	for (int i = 0; i < kTotalNumKeys; i++) {
		if ([self isWhiteKey:i]) {
			runningX += whiteKeyWidth;
		} else {
			if (keyDown[i]) {
				CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
			} else {
				CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
			}			
			
			CGContextFillRect(context, CGRectMake((int)(runningX - blackKeyOffset), yval, (int)blackKeyWidth, blackKeyHeight));
            
			CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
			CGContextStrokeRect(context, CGRectMake((int) (runningX - blackKeyOffset), yval, (int)blackKeyWidth, blackKeyHeight));
		}
	}
	
}


@end

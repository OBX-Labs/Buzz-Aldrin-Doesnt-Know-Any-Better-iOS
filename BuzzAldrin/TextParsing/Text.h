//
//  Text.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentence.h"
#import "Font.h"

@interface TextClass : NSObject
{
    //sentence array
    NSMutableArray *theSentenceObjects;
    //current sentence
	Sentence *currentSentence;
	
    //autoplay order
    int autoplayID;
    NSMutableArray *autoplayOrder;
    
    //is this first touch
	bool initialTouch;
}

//init
- (id)initWithText:(NSString *)theText withFont:(Font *)theFont andScreenSize:(CGSize)size;

//setters
- (void) setOutlinedFont:(Font *)theFont;

//getters
- (void) getAutoplayID:(int)currSentenceID;

//focus
- (void) setFocusForCoordinates:(CGPoint)coordinates;
- (void) setFocusNext;
- (void) giveFocusFor:(int)sentenceID and:(int)wordID;
- (void) setAutoplayFocus;

//touches
- (void) setPositionWithCoordinates:(CGPoint)coordinates;
- (void) stopTargetMove;

//draw
- (void) drawText;

@end

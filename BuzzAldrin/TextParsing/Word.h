//
//  Word.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Font.h"

@interface Word : NSObject
{
    //string
	NSString *currentWord;
	
    //positions
    CGPoint currentPosition;
	CGPoint initialPosition;
	CGPoint targetPosition;
	float zPos;
    float yRot;
    
    //fonts
	Font *defaultFont;
	Font *outlinedFont;
	
    //color values
	float targetColorVal[4];
	float focusColorVal[4];
	float defaultColorVal[4];
	float outlineFadedVal[4];
	
	float targetColor[4];
	float defaultFontColor[4];
	float outlineFontColor[4];
	float fadeSpeed[4];
	
    //3d points in 2d space arrays
	GLfloat modelview[16];
	GLfloat projection[16];
	
    //velocity
	float velocityX;
	float velocityY;
    
    //speeds
    float speed;
    float defaultSpeed;
    float focusSpeed;
    float draggingSpeed;
    //rot
    float rotateForwardSpeed;
    float rotateBackwardSpeed;
    
    //radius
    float radius;
    float defaultRadius;
    float focusRadius;
    float draggingRadius;
    
    //dimensions
	float wordWidth;
	float wordHeight;
    
    //current state
	bool isOutlined;
	bool isFocus;
	bool isTarget;
    bool isAutoplay;
    
    //targetPositions    
	float targetX;
	float targetY;
	float targetZPos;
	float defaultZPos;
	float zOffset;
    
    float friction;
}

@property (nonatomic, retain) NSString *currentWord;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) float wordWidth;
@property (nonatomic) float wordHeight;
@property (nonatomic) bool isAutoplay;

//init
- (id) initWithWord:(NSString *)theWord isAutoplay:(BOOL)autoplay withFont:(Font *)theFont;

//setters
- (void) setPosition:(CGPoint)point;
- (void) setTarget:(BOOL)isTargeted;
- (void) setWanderSpeed:(float)theSpeed andRadius:(float)theRadius;
- (void) smoothFriction;
- (void) wander;

- (void) setColorForFocus:(BOOL)focus andTarget:(BOOL)target;
- (void) setOutlinedFont:(Font *)theFont;
- (void) setTargetPosition:(CGPoint)pos;
- (void) stopTargetMove;

- (void) fadeTo:(float *)targetClr forFontColor:(float *)fontColor withSpeed:(float)fadingSpeed;
- (void) changeColorForCurrentFont:(float *)currentColor andTarget:(float *)targetClr withSpeed:(float)fadingSpeed;

- (void) targetFocus;
- (void) focus;
- (void) unfocus;

- (void) bringToFront;
- (void) sendToBack;
- (void) rotateTarget:(BOOL)direction;

- (CGPoint) screenXYWithX:(float)x Y:(float)y andZ:(float)z;

//getters
- (CGRect) getRect;

//draw
- (void) drawStringIsFocus:(BOOL)focus andTarget:(BOOL)target;









@end

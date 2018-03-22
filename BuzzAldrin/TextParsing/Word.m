//
//  Word.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Word.h"
#import "OKPoEMMProperties.h"

@implementation Word
@synthesize currentWord, currentPosition, wordWidth, wordHeight, isAutoplay;

- (id)initWithWord:(NSString *)theWord isAutoplay:(BOOL)autoplay withFont:(Font *)theFont
{    
	self = [self init];
	if (self != nil)
	{
		//string
        currentWord = [[NSString alloc] initWithString:theWord];
        
        //fonts
        defaultFont = theFont;
        
        NSArray* targetColorAr = [OKPoEMMProperties objectForKey:TextFocusedColor]; //DRAGGING
        NSArray* focusColorAr = [OKPoEMMProperties objectForKey:TextForegroundColor]; //FOCUS - FOREGROUND
        NSArray* defaultColorAr = [OKPoEMMProperties objectForKey:TextBackgroundColor]; //BACK
        NSArray* outlineFadedColorAr = [OKPoEMMProperties objectForKey:TextOutlineFadedColor]; //OUTLINE

        //color values
        targetColorVal[0] = [[targetColorAr objectAtIndex:0] floatValue];
		targetColorVal[1] = [[targetColorAr objectAtIndex:1] floatValue];
		targetColorVal[2] = [[targetColorAr objectAtIndex:2] floatValue];
		targetColorVal[3] = [[targetColorAr objectAtIndex:3] floatValue];
		
		focusColorVal[0] = [[focusColorAr objectAtIndex:0] floatValue];
		focusColorVal[1] = [[focusColorAr objectAtIndex:1] floatValue];
		focusColorVal[2] = [[focusColorAr objectAtIndex:2] floatValue];
		focusColorVal[3] = [[focusColorAr objectAtIndex:3] floatValue];
		
		defaultColorVal[0] = [[defaultColorAr objectAtIndex:0] floatValue];
		defaultColorVal[1] = [[defaultColorAr objectAtIndex:1] floatValue];
		defaultColorVal[2] = [[defaultColorAr objectAtIndex:2] floatValue];
		defaultColorVal[3] = [[defaultColorAr objectAtIndex:3] floatValue];
                
		outlineFadedVal[0] = [[outlineFadedColorAr objectAtIndex:0] floatValue];
		outlineFadedVal[1] = [[outlineFadedColorAr objectAtIndex:1] floatValue];
		outlineFadedVal[2] = [[outlineFadedColorAr objectAtIndex:2] floatValue];
		outlineFadedVal[3] = [[outlineFadedColorAr objectAtIndex:3] floatValue];
		
		//color calculators
		defaultFontColor[0] = defaultColorVal[0];
		defaultFontColor[1] = defaultColorVal[1];
		defaultFontColor[2] = defaultColorVal[2];
		defaultFontColor[3] = defaultColorVal[3];
		
		outlineFontColor[0] = defaultColorVal[0];
		outlineFontColor[1] = defaultColorVal[1];
		outlineFontColor[2] = defaultColorVal[2];
		outlineFontColor[3] = defaultColorVal[3];
		
		targetColor[0] = 0.0f;
		targetColor[1] = 0.0f;
		targetColor[2] = 0.0f;
		targetColor[3] = 0.0f;
                
        ///////////////
        
        //speeds
        defaultSpeed = [[OKPoEMMProperties objectForKey:TextWanderBackgroundSpeed] floatValue]; //0.05  max 2.0 min 0.0005
        focusSpeed = [[OKPoEMMProperties objectForKey:TextWanderFocusSpeed] floatValue]; //0.0375  max 2.0 min 0.0005
        draggingSpeed = [[OKPoEMMProperties objectForKey:TextWanderDraggingSpeed] floatValue];
        
        //////////////////////
        
        //rot
        rotateForwardSpeed = 30.0f;
        rotateBackwardSpeed = 45.0f;
        
        //radius
        defaultRadius = [[OKPoEMMProperties objectForKey:TextWanderBackgroundRadius] floatValue];
        focusRadius = [[OKPoEMMProperties objectForKey:TextWanderFocusRadius] floatValue];
        draggingRadius = [[OKPoEMMProperties objectForKey:TextWanderDraggingRadius] floatValue];
        
        //dimensions
        wordWidth = [defaultFont getWidthForString:currentWord];
        wordHeight = [defaultFont getHeightForString:currentWord];
        
        //current state
        isOutlined = NO;
        isFocus = NO;
        isTarget = NO;
        isAutoplay = autoplay;
        
        //targetPositions    
        targetZPos = [[OKPoEMMProperties objectForKey:TextForegroundPosition] floatValue];
        defaultZPos = [[OKPoEMMProperties objectForKey:TextBackgroundPosition] floatValue];
        zOffset = defaultZPos-targetZPos;
        
        //positions
        zPos = defaultZPos;
        yRot = 0.0f;
        
        friction = [[OKPoEMMProperties objectForKey:TextWanderFriction] floatValue];
	}
	return self;
     
}

#pragma mark setters
- (void) setPosition:(CGPoint)point
{
    //initial position (always set back to this point)
	initialPosition = CGPointMake(point.x, point.y);
	//current position (position that is updated)
	currentPosition = initialPosition;
	
    //set target
	[self setTarget:isTarget];
}

//set target when finger is being dragged
- (void) setTargetPosition:(CGPoint)pos
{
    //new target position
	targetPosition = CGPointMake(pos.x, pos.y);
	isTarget = YES;
    //set target
	[self setTarget:isTarget];
    //set dragging speed
    [self setWanderSpeed:draggingSpeed andRadius:draggingRadius];
    friction = 0.94;
}

//stop target move (when dragging stopped)
- (void) stopTargetMove
{	
    //is target (since its dragged)
	isTarget = NO;
    //set target
	[self setTarget:isTarget];
    //set to normal speed
    [self setWanderSpeed:focusSpeed andRadius:focusRadius];
    friction = 0.87;
}

- (void) smoothFriction
{
    float diff;
    float delta;
    float direction;
    
    float smooth = 0.98 - friction;
    if(smooth < 0)
		smooth *= -1;
	    
	//friction
	diff = 0.98 - smooth;
	if(diff != 0)
	{
		delta = smooth * (1.0/10.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			friction = smooth;
		else
			friction += (delta * direction);
	}
}

//set target position (whether target or focus or default)
- (void) setTarget:(BOOL)isTargeted
{	
	float angle = (((arc4random() % 101)/100.0f) * (M_PI*2));
	
    //if is target
	if(isTargeted)
	{
		targetX = (targetPosition.x - cosf(angle) * radius);
		targetY = (targetPosition.y - sinf(angle) * radius);
	}
	else
	{
		targetX = (initialPosition.x - cosf(angle) * radius);
		targetY = (initialPosition.y - sinf(angle) * radius);
	}
}

//set current wander speed
- (void) setWanderSpeed:(float)theSpeed andRadius:(float)theRadius
{
	speed = theSpeed;
	radius = theRadius;
}

//wander (moves the words)
- (void) wander
{
	//get distance to target
	float dx = targetX - currentPosition.x;
	float dy = targetY - currentPosition.y;		
	float d = sqrt(pow(dx, 2) + pow(dy, 2));
	
	if (d > 10)
	{
		dx *= (1/d) * speed; //get acceleration
		dy *= (1/d) * speed;
		velocityX += dx;  //apply acceleration
		velocityY += dy;
		velocityX *= friction; //friction
		velocityY *= friction;
		currentPosition.x += velocityX; //apply velocity
		currentPosition.y += velocityY;
	}
	else
	{
		[self setTarget:isTarget];
	}
    
    [self smoothFriction];
}

#pragma mark getters
//get word position (rect)
- (CGRect) getRect;
{	
	glPushMatrix();
	                  
	glGetFloatv(GL_MODELVIEW_MATRIX, modelview);        // Retrieve The Modelview Matrix
	
	glPopMatrix();
	
	glGetFloatv(GL_PROJECTION_MATRIX, projection);    // Retrieve The Projection Matrix
			
	//top right corner
	CGPoint topRight = [self screenXYWithX:(currentPosition.x + wordWidth) Y:(currentPosition.y + wordHeight) andZ:-zPos];
		
	//bottom left corner
	CGPoint bottomLeft = [self screenXYWithX:currentPosition.x Y:currentPosition.y andZ:-zPos];
	
	float width = topRight.x - bottomLeft.x;
	float height = topRight.y - bottomLeft.y;
	
	return CGRectMake(bottomLeft.x, bottomLeft.y, width, height);
}

//calculate XYZ in 2D from 3D
- (CGPoint) screenXYWithX:(float)x Y:(float)y andZ:(float)z
{
	float ax = ((modelview[0] * x) + (modelview[4] * y) + (modelview[8] * z) + modelview[12]);
	float ay = ((modelview[1] * x) + (modelview[5] * y) + (modelview[9] * z) + modelview[13]);
	float az = ((modelview[2] * x) + (modelview[6] * y) + (modelview[10] * z) + modelview[14]);
	float aw = ((modelview[3] * x) + (modelview[7] * y) + (modelview[11] * z) + modelview[15]);
	
	float ox = ((projection[0] * ax) + (projection[4] * ay) + (projection[8] * az) + (projection[12] * aw));
	float oy = ((projection[1] * ax) + (projection[5] * ay) + (projection[9] * az) + (projection[13] * aw));
	float ow = ((projection[3] * ax) + (projection[7] * ay) + (projection[11] * az) + (projection[15] * aw));
	
	if(ow != 0)
		ox /= ow;
	
	if(ow != 0)
		oy /= ow;
	
    //VICTOR - PROPER SCREEN BOUNDS
	return CGPointMake(([UIScreen mainScreen].bounds.size.width * (1 + ox) / 2.0f), ([UIScreen mainScreen].bounds.size.height * (1 + oy) / 2.0f));
}

//bring to front
- (void) bringToFront
{
    //set zPos
	zPos -= (defaultZPos - targetZPos)/rotateForwardSpeed;
	//rotate (yes = is coming to front)
    [self rotateTarget:YES];
}

//rotate the target
- (void) rotateTarget:(BOOL)direction
{    
	float rotAttenuator = wordWidth <= 50 ? 2 : 2 + (wordWidth-50)/250;
	float rotAngle = (sinf((zPos - targetZPos)/zOffset * (M_PI*2))/rotAttenuator) * 100;
	
    //set yRot
	yRot = direction ? rotAngle : -rotAngle;
}

//bring to back
- (void) sendToBack
{
    //set zPos
	zPos += (defaultZPos - targetZPos)/rotateBackwardSpeed;
    //rotate (no = is going to back)
    [self rotateTarget:NO];
}

//focus the target (word that was tapped)
- (void) targetFocus
{	
	if(zPos > targetZPos)
		[self bringToFront];
    else //Qucik and dirty fix to get yRot back to 0.0
        yRot = 0.0;
}

//focus the focus line
- (void) focus
{		
	if(zPos < defaultZPos)
		[self sendToBack];
    else //Qucik and dirty fix to get yRot back to 0.0
        yRot = 0.0;
    
	[self setWanderSpeed:focusSpeed andRadius:focusRadius];
}

//unfocus all the lines
- (void) unfocus
{
    if(zPos < defaultZPos)
        [self sendToBack];
    else
        yRot = 0.0;
    
	[self setWanderSpeed:defaultSpeed andRadius:defaultRadius];
}

//calculate the fading color speed/values
- (void) fadeTo:(float *)targetClr forFontColor:(float *)fontColor withSpeed:(float)fadingSpeed
{	
	if(targetColor[0] == targetClr[0] && targetColor[1] == targetClr[1] && targetColor[2] == targetClr[2] && targetColor[3] == targetClr[3])
		return;
		
	//set target color
	targetColor[0] = targetClr[0];
	targetColor[1] = targetClr[1];
	targetColor[2] = targetClr[2];
	targetColor[3] = targetClr[3];
	
	fadeSpeed[0] = (targetColor[0] - fontColor[0])*fadingSpeed;
	if(fadeSpeed[0] < 0)
		fadeSpeed[0] *= -1;	
	
	fadeSpeed[1] = (targetColor[1] - fontColor[1])*fadingSpeed;
	if(fadeSpeed[1] < 0)
		fadeSpeed[1] *= -1;	
	
	fadeSpeed[2] = (targetColor[2] - fontColor[2])*fadingSpeed;
	if(fadeSpeed[2] < 0)
		fadeSpeed[2] *= -1;	
	
	fadeSpeed[3] = (targetColor[3] - fontColor[3])*fadingSpeed;
	if(fadeSpeed[3] < 0)
		fadeSpeed[3] *= -1;
}

//change color when needed
- (void) changeColorForCurrentFont:(float *)currentColor andTarget:(float *)targetClr withSpeed:(float)fadingSpeed
{
	float diff;
    float delta;
    float direction;
	
	[self fadeTo:targetClr forFontColor:currentColor withSpeed:fadingSpeed];
    	
	//Red
	diff = targetColor[0] - currentColor[0];
	if(diff != 0)
	{
		delta = fadeSpeed[0] * (1.0/30.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			currentColor[0] = targetColor[0];
		else
			currentColor[0] += (delta * direction);
	}
	
	//green
	diff = targetColor[1] - currentColor[1];
	if(diff != 0)
	{
		delta = fadeSpeed[1] * (1.0/30.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			currentColor[1] = targetColor[1];
		else
			currentColor[1] += (delta * direction);
	}
	
	//blue
	diff = targetColor[2] - currentColor[2];
	if(diff != 0)
	{
		delta = fadeSpeed[2] * (1.0/30.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			currentColor[2] = targetColor[2];
		else
			currentColor[2] += (delta * direction);
	}
	
	//alpha
	diff = targetColor[3] - currentColor[3];
	if(diff != 0)
	{
		delta = fadeSpeed[3] * (1.0/30.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			currentColor[3] = targetColor[3];
		else
			currentColor[3] += (delta * direction);
	}
}

//set color depending on state
- (void) setColorForFocus:(BOOL)focus andTarget:(BOOL)target
{
    //if is focused and target
	if(focus && target)
	{
		[self changeColorForCurrentFont:defaultFontColor andTarget:targetColorVal withSpeed:1];
		[self targetFocus];
		
		isOutlined = YES;
		isFocus = YES;
		
		//reset outline color
		outlineFontColor[0] = defaultColorVal[0];
		outlineFontColor[1] = defaultColorVal[1];
		outlineFontColor[2] = defaultColorVal[2];
		outlineFontColor[3] = defaultColorVal[3];
	}
    //is is focus but not target
	else if(focus && !target)
	{
		[self changeColorForCurrentFont:defaultFontColor andTarget:focusColorVal withSpeed:1];
		[self focus];
		
		isFocus = YES;
        isTarget = NO;
        isOutlined = NO;
	}
    //else...
	else
	{
		[self changeColorForCurrentFont:defaultFontColor andTarget:defaultColorVal withSpeed:1];
		[self unfocus];
		
		isFocus = NO;
	}
}

//set outlined font
- (void) setOutlinedFont:(Font *)theFont
{
	outlinedFont = theFont;
}

#pragma mark draw
//draw string
- (void) drawStringIsFocus:(BOOL)focus andTarget:(BOOL)target
{
    //set color depending on state
	[self setColorForFocus:focus andTarget:target];
    //draw color on font
	[defaultFont setColourFilterRed:defaultFontColor[0] green:defaultFontColor[1] blue:defaultFontColor[2] alpha:defaultFontColor[3]];
    //draw string
	[defaultFont drawStringAt:currentPosition withZValue:zPos andYRot:yRot text:currentWord isFocused:focus];
    
    //if is outline draw font over...
	if(isOutlined && !focus && !target)
	{
		[self changeColorForCurrentFont:outlineFontColor andTarget:outlineFadedVal withSpeed:0.1];

		[outlinedFont setColourFilterRed:outlineFontColor[0] green:outlineFontColor[1] blue:outlineFontColor[2] alpha:outlineFontColor[3]];
		[outlinedFont drawStringAt:currentPosition withZValue:zPos andYRot:yRot text:currentWord isFocused:focus];
		
		if(outlineFontColor[3] <= 0.0)
			isOutlined = NO;
	}
    
	[self wander];
}

#pragma mark dealloc
- (void)dealloc
{
	[super dealloc];
}

@end

//
//  InfoLandscapeController.m
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-26.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import "InfoLandscapeController.h"
//#import "KnowKnowTMProperties.h"
#import "InfoController.h"

@implementation InfoLandscapeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //save the layer origin for dragging and bouncing later
    layerOrigin = subview.frame.origin.x;
    
    //save the view's frame
    width = [self view].frame.size.width;
    height = [self view].frame.size.height;
}

- (void) showView { [self showView:0]; }
- (void) showView:(float)delay
{
    //if we are already sliding then, do nothing
    if (sliding) return;
    
    //show
    sliding = true;
    
    //show the view
    [[self view] setHidden:NO];
    
    //place the subview at the right place
    CGRect subviewFrame = [self subview].frame;
    subviewFrame.origin.x = width;
    [self subview].frame = subviewFrame;
    
    //animate view
    [self animateToView:delay];
}

- (void) animateToView:(float)delay
{
    //animate
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self view].alpha = 1;
    
    CGRect subviewFrame = [self subview].frame;
    subviewFrame.origin.x = width - subviewFrame.size.width;
    [self subview].frame = subviewFrame;
    
    [UIView commitAnimations];
}

- (void) hideView:(float)duration
{
    [super hideView:duration];
    
    //if duration is zero, don't need to animate
    if (duration == 0) {
        [self view].alpha = 0;
        
        CGRect subviewFrame = [self subview].frame;
        subviewFrame.origin.x = width;
        [self subview].frame = subviewFrame;

        [self animationDidStop:@"hide" finished:0 context:nil];
        
        return;
    }
    
    //fade out
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self view].alpha = 0;
    
    CGRect subviewFrame = [self subview].frame;
    subviewFrame.origin.x = width;
    [self subview].frame = subviewFrame;
    
    [UIView commitAnimations];
}

- (void) animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    if ([animationID isEqualToString:@"hide"]) {
        //hide
        [[self view] setHidden:YES];
        
        //flag sliding done
        sliding = NO;
        
        //tell the superController we are hidden
        [self.superController viewDidHide];        
    }
    else if ([animationID isEqualToString:@"show"]) {
        //flag sliding done
        sliding = NO;
    }
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //if we are swiping, do nothing
    if (swiping) return;
    
	//if something is selected in the webview we don't want to move it
	//because we might be moving the selection handles
	NSString *selection = [self.webview stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
	if ([selection length] != 0) return;
    
    //start checking for a swipe
	swiping = false;
	swipeLastPt = swipeStart = [[touches anyObject] locationInView:self.view];
	swipeLockTime = [[NSDate date] timeIntervalSince1970] + SWIPE_LOCK_TIME;
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	//get the point
	CGPoint pt = [[touches anyObject] locationInView:self.view];
	
	//variables to calculate view motion
	float layerDiff = 0;
	float swipeDiff = 0;
	float delta;
	
    //drag the view up to a certain limit
    swipeDiff = pt.x-swipeStart.x;
    layerDiff = abs(subview.frame.origin.x - layerOrigin);
    
	//lock the swipe if we moved far away from the touch began or
	//if we moved fast after the first touch
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	if (!swiping && (abs(swipeDiff) > 20) && (now < swipeLockTime))
		swiping = YES;
	
	//if swiping is not locked then do nothing
	if (!swiping) return;
	
	//calculate how much to move by
	delta = (log(VIEW_BOUNCE+1)-log(layerDiff+1))*2;
    
	//apply the move
	if ((abs(swipeDiff) > 4) && (layerDiff < VIEW_BOUNCE))  {
        
        CGRect subviewFrame = subview.frame;
        subviewFrame.origin.x = subview.frame.origin.x + (swipeDiff > 0 ? delta : -delta);
        subview.frame = subviewFrame;
        
		swipeLastPt = pt;
	}
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (!swiping) return;
    
    //end swipe
    [self endSwipe:[[touches anyObject] locationInView:self.view]];
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (!swiping) return;
    
    //end swipe
    [self endSwipe:[[touches anyObject] locationInView:self.view]];
}

- (void) endSwipe
{
	//if we are not swiping then nothing to end
	if (!swiping) return;
	
	//end the swipe so that it hides the info view
    [self endSwipe:CGPointMake(swipeStart.x, swipeStart.y+SWIPE_LENGTH+1)];
}

- (void) endSwipe:(CGPoint)location
{
	//if we are not swiping then nothing to do
	if (!swiping) return;
    
    //reset swipe
	swiping = false;	
    
	//if we swiped in the outward direction based
	//on orientation then we can close the view
    if (location.x-swipeStart.x > SWIPE_LENGTH)
     [self hideView];
    else
     [self animateToView:0];
}

@end

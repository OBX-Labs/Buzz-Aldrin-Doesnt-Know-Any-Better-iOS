//
//  EAGLView.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"
#import "Font.h"

@class BuzzAldrinAppDelegate;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    id <ESRenderer> renderer;

    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
	
	//Text object
	TextClass *currentText;
    
	//Font objects current (default) / outline (outline target)
	Font *currentFont;
	Font *outlineFont;
	//frame rate (should be removed for final)
//	UILabel *lbl_frameRate;
	//autoplay timer
	NSTimer *autoplayTimer;
    
    bool initialTouch;
    
    //swipe parameters
    NSTimeInterval touchBeganTime; //when the last touch began
	CGPoint swipeStart;
    
    //settings
    //bool bExhibition;
    //bool bGuide;

}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) id displayLink;
@property (nonatomic, assign) NSTimer *animationTimer;
//@property (nonatomic) bool bExhibition;
@property (nonatomic) bool bGuide;


+ (EAGLView*) sharedInstance;

- (id) initWithFrame:(CGRect)aFrame multisampling:(BOOL)canMultisample andSamples:(int)aSamples;

- (void) setupFont;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

//- (void)getFrameRate:(float)withInterval;

- (void) setAutoplayTimer;
- (void) autoplay;

- (UIImage*) screenCapture;

// InfoView
- (void) infoViewWillAppear;
- (void) infoViewWillDisappear;

@end

//
//  InfoController.h
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-24.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "InfoPortraitController.h"
#import "InfoLandscapeController.h"
#import <MessageUI/MessageUI.h>

//possible actions from info view
typedef enum {
    kNone,
    kShare,
    kEmail,
    kShowList
} ActionType;


@interface InfoController : UIViewController <MFMailComposeViewControllerDelegate> {
    //parent controller
    UIViewController* parentController;
    
    //main view container
	UIView* containerView;    
    
    //visibility and state
	BOOL visible;
	BOOL visibleBeforeRotate;
	BOOL shownFirstInfo;
    NSTimeInterval rotateDuration;
    ActionType actionOnClosed;
    id actionOnClosedData;
	
	//auto-hide timer for iPhone/iPod
    NSTimer* autohideTimer;
    NSTimer* autoshowTimer;
    
    //subcontrollers
    //InfoPortraitController* portraitController;
    InfoLandscapeController* landscapeController;
}

@property (nonatomic, retain) UIViewController* parentController;
@property (nonatomic, retain) UIView *containerView;
//@property (nonatomic, retain) InfoPortraitController *portraitController;
@property (nonatomic, retain) InfoLandscapeController *landscapeController;
@property (nonatomic, getter=isVisible) BOOL visible;    
@property (nonatomic, copy) id actionOnClosedData;

- (id)init:(UIViewController*)parent;

- (void) toggleView; //toggle the view (show/hide)
- (void) showFirstView:(NSTimer*)timer; //autoshow view (timer selector)
- (void) showView; //show the view
- (void) showView:(float)delay; //show the view after a delay
- (void) hideView:(NSTimer*)timer; //autohide view (timer selector)
- (void) hideView; //hide the view
- (void) hideViewWithAction:(ActionType)action; //hide the view and then execute action
- (void) hideViewWithAction:(ActionType)action andData:(id)data; //hide the view and then execute action
- (void) viewDidHide; //callback when a view is done hiding

- (BOOL) isSliding; //check if the info view for the current orientation is sliding

- (void) endSwipe; //ends a swipe started in touchesBegan

- (void) showTextList; //show text list

@end

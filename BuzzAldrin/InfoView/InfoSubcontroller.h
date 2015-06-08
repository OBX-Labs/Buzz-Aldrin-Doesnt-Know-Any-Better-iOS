//
//  InfoSubcontroller.h
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-24.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


#define SWIPE_LENGTH 50
#define SWIPE_LOCK_TIME 0.5
#define VIEW_BOUNCE 100

@class InfoController;

@interface InfoSubcontroller : UIViewController <UIWebViewDelegate> {
    //parent controller
    InfoController* superController;
    
    //subviews
    IBOutlet UIView* subview;
    
	//swipe parameters
    BOOL sliding;    
	BOOL swiping;
	CGPoint swipeStart;
	CGPoint swipeLastPt;
	NSTimeInterval swipeLockTime;   
    int layerOrigin;

    //webview
    UIWebView* webview;
    
    //buttons
    UIButton* poemsBtn;
    UIButton* shareBtn;
    
    //window dimensions
    int width;
    int height;
}

@property (nonatomic, retain) IBOutlet UIView *subview;
@property (nonatomic, retain) InfoController *superController;
@property (nonatomic) BOOL swiping;
@property (nonatomic) BOOL sliding;
@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) IBOutlet UIButton *poemsBtn;
@property (nonatomic, retain) IBOutlet UIButton *shareBtn;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(InfoController*)parentOrNil;

- (void) hideView; //hide the view
- (void) hideView:(float)duration;

- (IBAction)doPoemsButton;
- (IBAction)doShareButton;

//enable/disable scrolling of webview
- (void) setScrollEnabled:(BOOL)enabled;

@end


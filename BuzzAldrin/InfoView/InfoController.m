//
//  InfoController.m
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-24.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import "InfoController.h"
#import "KnowProperties.h"
#import "OKClearView.h"
#import "TextsNavigationController.h"
#import "TextsViewController.h"
//#import "BuzzAldrinAppDelegate.h"

static BOOL autoShow = NO;

@implementation InfoController

@synthesize parentController;
@synthesize containerView;
//@synthesize portraitController;
@synthesize landscapeController;
@synthesize visible;
@synthesize actionOnClosedData;

- (id)init:(UIViewController*)parent {
    self = [super init];
    if (self) {
        //set parent
        self.parentController = parent;
        
        //init portrait
        //self.portraitController = [[InfoPortraitController alloc] initWithNibName:@"InfoPortrait"
        //                                                              bundle:[NSBundle mainBundle]
        //                                                              parent:self];
        
        //init landscape
        self.landscapeController = [[[InfoLandscapeController alloc] initWithNibName:@"InfoLandscape"
                                                                       bundle:[NSBundle mainBundle]
                                                                       parent:self] autorelease];
        
        //default visibility and states
        visible = NO;
        visibleBeforeRotate = NO;
        rotateDuration = 0;
        
        //show the info layer only on iPad
        //shownFirstInfo = ![[KnowKnowTMProperties sharedInstance] wasPushed] ? NO : YES;
        bool bExhibition = [[NSUserDefaults standardUserDefaults] boolForKey:@"exhibition_preference"];
        bool bGuide = [[NSUserDefaults standardUserDefaults] boolForKey:@"guide_preference"];
        
        shownFirstInfo = (!bExhibition && !bGuide ? NO : YES);
        autohideTimer = nil;
        
        //set default action to none when the info view is closed
        actionOnClosed = kNone;
    }
    return self;
}

- (void)loadView {
    //get screen bounds
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    //init the clear view
    self.view = [[[OKClearView alloc] initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingNone;
	self.view.autoresizesSubviews = NO;
	self.view.multipleTouchEnabled = NO;    
    
    //add subviews
    [self.view addSubview:landscapeController.view];
//    [self.view addSubview:portraitController.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    //hide subview by default
//	[portraitController hideView:0];
    [landscapeController hideView:0];
    
    //if the info was never shown then show it
    if (!shownFirstInfo && autoShow) {
        
        //create auto-show timer for iPhone/iPod
        autoshowTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showFirstView:) userInfo:nil repeats:NO];

    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    //[parentController release];
    [containerView release];
//	[portraitController release];
	[landscapeController release];
    [actionOnClosedData release];
    [autohideTimer release];
    [autoshowTimer release];
    [super dealloc];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return  (/*(interfaceOrientation == UIInterfaceOrientationPortrait) ||
             (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ||*/
             (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
             (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //flag as rotating
    rotateDuration = duration;
    
	//keep track of view's visibility before rotating
	//to pop it back out after it rotated
	visibleBeforeRotate = [self isVisible];
	
	//remove it from the superview
	//this is only to remove the ugly black corner effect
	//we can't remove it from the superview when a modal view is
	//active because it won't receive the rotation events pass the first one
    if (visibleBeforeRotate || [self modalViewController] == nil) {
        //hide the view
        [self hideView];    

        //detach
        [self.view removeFromSuperview];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //if the info was never shown, then show it
    if (!shownFirstInfo) {
        
        //create auto-hide timer for iPhone/iPod
        if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
            autohideTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideView:) userInfo:nil repeats:NO];
     
        //show it
        [self showView:rotateDuration];
     
        visibleBeforeRotate = NO; //reset flag
        shownFirstInfo = YES;     //set that we have shown the first info view
    }
	//if the view was visible before rotating, show it
    else if (visibleBeforeRotate) {
       
		//show it
        [self showView:rotateDuration];
        
		visibleBeforeRotate = NO; //reset flag
	}
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	//skip touches if the view is not visible or sliding
	if ([self isSliding] || ![self isVisible]) return;
	
    //if the info view is touched and the auto hide timer is valid
    //then we want to cancel it
    if (autohideTimer != nil) {
        [autohideTimer invalidate];
        autohideTimer = nil;
    }
    
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController touchesBegan:touches withEvent:event];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController touchesMoved:touches withEvent:event];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController touchesMoved:touches withEvent:event];    
} 

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController touchesEnded:touches withEvent:event];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController touchesEnded:touches withEvent:event];        
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController touchesCancelled:touches withEvent:event];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController touchesCancelled:touches withEvent:event];    
}

- (void) endSwipe
{
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController endSwipe];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController endSwipe];      
}

- (void) toggleView
{
    //hide or show
	if ([self isVisible])
		[self hideView];
	else
		[self showView];
}

- (void) showFirstView:(NSTimer*)timer
{
    //if it's already been shown, do nothing
    if (shownFirstInfo) return;
    
    //set the auto hide timer
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
        autohideTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideView:) userInfo:nil repeats:NO];
        
    //show it
    [self showView:rotateDuration];
    
    //clear timer
    [autoshowTimer invalidate];
    autoshowTimer = nil;
}

- (void) showView { [self showView:rotateDuration]; }
- (void) showView:(float)delay
{   
	//if the view isn't attached to the superview
    //then we need to attach it
	if (self.view.superview == nil) {
        //reattach the view
        [self.containerView addSubview:[self view]];
	}
	
	//flag as sliding and visible
	visible = YES;
	
    //pass it down to the subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController showView:delay];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController showView:delay];
    
    //reset rotate duration
    rotateDuration = 0;
}

- (void) hideView:(NSTimer*)timer
{
    //if it's visible, hide it, and clear timer
    if ([self isVisible]) [self hideView];
    [autohideTimer invalidate];
    autohideTimer = nil;
}
- (void) hideView { [self hideViewWithAction:kNone]; }
- (void) hideViewWithAction:(ActionType)action { [self hideViewWithAction:action andData:nil]; }
- (void) hideViewWithAction:(ActionType)action andData:(id)data
{
    //pass it down to subcontrollers
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [portraitController hideView];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        [landscapeController hideView];
    
    //keep track of action
    actionOnClosed = action;
    self.actionOnClosedData = data;
}

- (void)viewDidHide
{
    //set as not visible
    visible = NO;

    //check if we have anything to do
    if (actionOnClosed == kNone) return;
    
    //execute closing action
    if (actionOnClosed == kShowList) {
        [self showTextList];
    } else if (actionOnClosed == kEmail) {        
        //create the main controller
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        controller.modalPresentationStyle = UIModalPresentationPageSheet;
        [[controller navigationBar] setTintColor:[UIColor blackColor]];
        
        //get the path
        NSString* path = (NSString*)actionOnClosedData;
        
        //get the email address
        int qmarkIndex = [path rangeOfString:@"?"].location;
        NSString* email = qmarkIndex == NSNotFound ? path : [path substringToIndex:qmarkIndex];
        
        //look if the link specifies a subject or body
        NSString* subject = @"";
        NSString* body = @"";
        if (qmarkIndex != NSNotFound) {
            path = [path substringFromIndex:qmarkIndex+1];
            NSRange subjMark = [path rangeOfString:@"subject=" options:NSCaseInsensitiveSearch];
            if (subjMark.location != NSNotFound) {
                int subjStart = subjMark.location+subjMark.length;
                NSRange ampMark = [path rangeOfString:@"&"
                                              options:NSCaseInsensitiveSearch
                                                range:NSMakeRange(subjStart, path.length - subjStart)];
                subject = [path substringWithRange:(ampMark.location == NSNotFound ?
                                                    NSMakeRange(subjStart, path.length - subjStart) :
                                                    NSMakeRange(subjStart, ampMark.location - subjStart))];
                subject = [subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            NSRange bodyMark = [path rangeOfString:@"body=" options:NSCaseInsensitiveSearch];
            if (bodyMark.location != NSNotFound) {
                int bodyStart = bodyMark.location+bodyMark.length;
                NSRange ampMark = [path rangeOfString:@"&"
                                              options:NSCaseInsensitiveSearch
                                                range:NSMakeRange(bodyStart, path.length - bodyStart)];
                body = [path substringWithRange:(ampMark.location == NSNotFound ?
                                                 NSMakeRange(bodyStart, path.length - bodyStart) :
                                                 NSMakeRange(bodyStart, ampMark.location - bodyStart))];
                body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }				
        }
        
        //set the values and present the controller
        [controller setToRecipients:[NSArray arrayWithObject:email]];
        [controller setSubject:subject];
        [controller setMessageBody:body isHTML:YES];
        //[self presentModalViewController:controller animated:YES];
        [parentController presentModalViewController:controller animated:YES];
        [controller release];
    }
    
    //reset action
    actionOnClosed = kNone;
}

- (BOOL)isSliding
{
    //check if the current subview is sliding
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        return [portraitController sliding];
    else */if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        return [landscapeController sliding];
    
    //should never reach this
    return NO;
}

- (void) showTextList
{
    // Show the text list
	TextsViewController* rootCtrl = [[TextsViewController alloc] init];
	TextsNavigationController* navCtrl = [[TextsNavigationController alloc] initWithRootViewController:rootCtrl];
	[parentController presentModalViewController:navCtrl animated:YES];
	[rootCtrl release];
	[navCtrl release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	//manage the model mail composer
	[self becomeFirstResponder];
	//[self dismissModalViewControllerAnimated:YES];
    [parentController dismissModalViewControllerAnimated:YES];
}

@end

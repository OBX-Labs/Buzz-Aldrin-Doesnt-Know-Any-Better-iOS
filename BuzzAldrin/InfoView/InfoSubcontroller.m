//
//  InfoSubcontroller.m
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-24.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import "InfoSubcontroller.h"
#import "KnowProperties.h"
#import "InfoController.h"

@implementation InfoSubcontroller

@synthesize subview;
@synthesize superController;
@synthesize swiping;
@synthesize sliding;
@synthesize webview;
@synthesize poemsBtn;
@synthesize shareBtn;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(InfoController*)parentOrNil{
    //check if the device is an iPad to load the correct nib
    if (nibNameOrNil != nil && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) nibNameOrNil = [NSString stringWithFormat:@"%@%@", nibNameOrNil, @"-iPad"];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.superController = parentOrNil;
        self.sliding = NO; 
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //clear background (for some reason loading the html unclears it)
    webview.backgroundColor = [UIColor clearColor];
	webview.opaque = NO;
    webview.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
    [self setScrollEnabled:NO];
    
    // Do any additional setup after loading the view from its nib.
    NSString *html = nil;
    
    //set correct html based on device
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        html = @"<html><head><title>Know v. 2</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
        "<style type=\"text/css\">"
        "* { margin: 0; padding: 0; -webkit-user-select: none; -webkit-touch-callout: none; }"
        "html, body { font-family: Helvetica; font-size: 12px; background-color:transparent; }"
        "p { margin-bottom: 10px; }"
        "a { color: #f79910; }"
        "</style>"
        "</head>"
        "<body>"
        "<p>Buzz Aldrin Doesn’t Know Any Better was a poem about crazy talking with a street-person outside a pawn shop on a sunny San Francisco afternoon. Version 2, called Know, expands on the original with a set of new poems by guest writers. Lewis & Nadeau commissioned five poets to create a text that responded thematically and formally to the visual, interactive and dynamic constraints created for the original.</p>"
        "<p>Know for the iPad/iPhone/iPod Touch is the second in a series of P.o.E.M.M.s (Poem for Excitable [Mobile] Media) created specifically for reading via touch interaction. <a href=\"http://itunes.apple.com/app/speak/id406078727\">Speak</a>, <a href=\"http://www.poemm.net/smooth\">Bastard</a>, and <a href=\"http://itunes.apple.com/app/migration/id464900068\">Migration</a> are the other three.</p>"
        "<p>To find out more about the P.o.E.M.M.s, please visit <a href=\"http://www.poemm.net\">www.poemm.net</a>, send an <a href=\"mailto:apps@jasonlewis.org\">email</a>, or look for the #poemm Twitter tag.</p>"
        "<p>Version 2.0.1<br />Programming by <a href=\"http://www.christiangratton.com\">Christian Gratton</a><br />and <a href=\"http://wyldco.com\">Bruno Nadeau</a>, from original code by Nadeau<br />based on the <a href=\"http://www.nexttext.net\">NextText</a> architecture<br />2007 - 2012 © Jason Edward Lewis<br />texts © their respective authors</p>"
        "</body></html>";  
    }
    else {
        html = @"<html><head><title>Migration</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
        "<style type=\"text/css\">"
        "* { margin: 0; padding: 0; -webkit-user-select: none; -webkit-touch-callout: none; }"
        "html, body { font-family: Helvetica; font-size: 12px; background-color:transparent; }"
        "p { margin-bottom: 10px; }"
        "a { color: #f79910; }"
        "</style>"
        "</head>"
        "<body>"
        "<p>Buzz Aldrin Doesn’t Know Any Better is a poem about crazy talking with a street-person outside a pawn shop on a sunny San Francisco afternoon. For version 2, called Know, Lewis & Nadeau commissioned five poets to create texts that respond thematically and formally to the visual, interactive and dynamic constraints created for the original. Know is part of The P.o.E.M.M. Cycle along with <a href=\"http://itunes.apple.com/app/speak/id406078727\">Speak</a>, <a href=\"http://www.poemm.net/smooth\">Bastard</a>, and <a href=\"http://itunes.apple.com/app/migration/id464900068\">Migration</a>. More info: <a href=\"http://www.poemm.net\">www.poemm.net</a> / <a href=\"mailto:apps@jasonlewis.org\">email</a> / #poemm Twitter tag.</p>"
        "<p>Version 2.0.1<br />Code: <a href=\"http://www.christiangratton.com\">C Gratton</a> and <a href=\"http://wyldco.com\">B Nadeau</a><br />2007 - 2012 © Jason Edward Lewis<br />texts © their respective authors</p>"       
        "</body></html>";
    }
     
    //load html
    [webview loadHTMLString:html baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    subview = nil;
    webview = nil;
    poemsBtn = nil;
    shareBtn = nil;
    superController = nil;
}

- (void)dealloc {
    [webview release];
    [poemsBtn release];
    [shareBtn release];
	[subview release];
	[superController release];
    [super dealloc];
}

- (void)hideView {
    //hide view with default duration
    [self hideView:0.3];
}

- (void)hideView:(float)duration {
    //if it's already hidden, do nothing
    if ([[self view] isHidden]) return;
    
    //if we are swiping, do nothing
    if (swiping) return;
    
    //if we are already sliding then, do nothing
    if (sliding) return;
    
    //show
    sliding = true;  
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return  (/*(interfaceOrientation == UIInterfaceOrientationPortrait) ||
             (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ||*/
             (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
             (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (IBAction) doPoemsButton {
	//if we are already sliding then let it finish first
    if (sliding) return;
    
    //hide the info view first, only if iPad
    [superController hideViewWithAction:kShowList];
}

- (IBAction) doShareButton {
	//if we are already sliding then let it finish first
    if (sliding) return;
    
    //hide the info view first, only if iPad
    [superController hideViewWithAction:kShare];
}

- (void)setScrollEnabled:(BOOL)enabled
{
	//disable scrolling
	for (id view in webview.subviews)
		if ([[view class] isSubclassOfClass: [UIScrollView class]])
			[((UIScrollView *)view) setScrollEnabled:NO];
}

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	//catch a click on a link in the webview to open it at the right place
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL* url = [request URL];
		
		//if the click was on an email
		//then open the mail application inside the app
		//parse the value in the link and pass then to the mail composer
		if ([[url scheme] hasPrefix:@"mailto"]) {
			//if we are already sliding then let it finish first
			if (sliding) return NO;
			
			//check if we can send mail
			//if not then we open the link outside which will go
			//to the email setup screen
			if ([MFMailComposeViewController canSendMail] == NO) {
				[[UIApplication sharedApplication] openURL:[request URL]];
				return NO;
			}
			
            //get the path
			NSString* path = [[url absoluteString] substringFromIndex:7];
            
			//hide the info view first, only if iPad
            [superController hideViewWithAction:kEmail andData:path];
		}
		//if the click is on a standard url, then open it in safari
		else {
			[[UIApplication sharedApplication] openURL:[request URL]];
		}
		return NO;
	}
	
	return YES;
}

@end

//
//  BuzzAldrinAppDelegate.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 11-06-07.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "BuzzAldrinAppDelegate.h"
#import "EAGLView.h"

#import "TestFlight.h"
#import "OKPoEMM.h"
#import "OKPreloader.h"
#import "OKTextManager.h"
#import "OKAppProperties.h"
#import "OKPoEMMProperties.h"
#import "OKInfoViewProperties.h"
#import "Appirater.h"

#define IS_IPAD_2 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) // Or more
#define IS_IPHONE_5 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define SHOULD_MULTISAMPLE (IS_IPAD_2 || IS_IPHONE_5)

@implementation BuzzAldrinAppDelegate

@synthesize window, poemm, eaglView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
    /*
    //check if we run the app for the first time or not
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kNOT_FIRST_LAUNCH"]) {
        NSLog(@"fresh install = %d", (int)[self checkForFreshInstall]);
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAPPLICATION_LAUNCHING_FIRST_TIME"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAPPLICATION_LAUNCHING_FIRST_TIME"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
     */

    //TestFlight
    //[TestFlight takeOff:@"0802e903-2d17-4948-8282-2e22d44933b4"];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"fLaunch"])
    {
        [self setDefaultValues];
    }
    
    //In case a new bundle version installed, we clear the cache. This will make the app download the texts/fonts/etc.
    if([self checkBundleVersion])
        [OKTextManager clearCache];
    
    // Register for notifications only is user has agreed
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if([prefs objectForKey:@"pushNotification"])
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    //[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    //[UAirship takeOff:takeOffOptions];
    
    //Init Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Get Screen Bounds
    CGRect sBounds = [[UIScreen mainScreen] bounds];
    CGRect sFrame = CGRectMake(sBounds.origin.x, sBounds.origin.y, sBounds.size.width, sBounds.size.height); // Invert height and width to componsate for portrait launch (these values will be set to determine behaviors/dimensions in EAGLView)
    
    // Set app properties
    [OKAppProperties initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"OKAppProperties.plist"] andOptions:launchOptions];
    [OKPoEMMProperties initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"OKPoEMMProperties.plist"]];
    
    // Load texts
    BOOL canLoad = YES;
    // Get the id of the last text the user read
    NSString *textKey = [[NSUserDefaults standardUserDefaults] stringForKey:Text];
    NSString *appName = [OKAppProperties objectForKey:@"Name"];
    
    NSString *master = [NSString stringWithFormat:@"net.obxlabs.%@.jlewis.%@", appName, appName];
    if(textKey != nil)
    {
        //save default key, just in case
        NSString* defaultTextKey = [[OKTextManager sharedInstance] getDefaultPackage];
        
        // Fixes the bug where net.obxlabs.Know.jlewis.Know is replaced by net.obxlabs.Know.jlewis.67 when list is downloaded
        // but no poem is selected. This finds the default poem and returns the right key.
        if([textKey isEqualToString:master])
            textKey = [[OKTextManager sharedInstance] getDefaultPackage];
        
        //load the text
        if (![[OKTextManager sharedInstance] loadTextFromPackage:textKey atIndex:0])
        {
            // try loading custom text
            if(![[OKTextManager sharedInstance] loadCustomTextFromPackage:textKey])
            {
                if(![[OKTextManager sharedInstance] loadTextFromPackage:defaultTextKey atIndex:0])
                {
                    NSLog(@"Error: could not load any text for package %@ and default package %@. Clearing cache and starting from new.", textKey, defaultTextKey);
                    
                    // Deletes existing file (last hope)
                    [OKTextManager clearCache];
                    
                    // Load new
                    if(![[OKTextManager sharedInstance] loadTextFromPackage:@"net.obxlabs.Know.jlewis.Know" atIndex:0])
                    {
                        // Epic fail
                        NSLog(@"Error: Epic fail.");
                        canLoad = NO;
                    }
                }
            }
        }
    }
    else
    {
        // Set default text
        if(![[OKTextManager sharedInstance] loadTextFromPackage:master atIndex:0])
        {
            NSLog(@"Error: could not load default package. Probably missing some objects (fonts).");
        }
    }

    // Show the preloader
    OKPreloader *preloader = [[OKPreloader alloc] initWithFrame:sFrame forApp:self loadOnAppear:canLoad];
    
    // If we can't load a text, show a warning to the user
    if(!canLoad)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System Error" message:@"It would appear that all app files were corrupted. Please delete and re-install the app and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
    // Add to window
    [self.window setRootViewController:preloader];
    [self.window makeKeyAndVisible];

    //device can't sleep (since we begin)
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //remove any existing badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    return YES;
}

//checkBundleVersion. Returns YES if new version, else return no.
- (BOOL) checkBundleVersion {
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *prevVersion = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"prevVersion"];
    
    //NSLog(@"Current version : %@ Previous version: %@", currentVersion, prevVersion);
    if (prevVersion == nil) {
        // Starting up for first time with NO pre-existing installs (e.g., fresh
        // install of some version)
        [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:@"prevVersion"];
        // Save changes to disk
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    //else if ([prevVersion intValue] < [currentVersion intValue]) {
    else if (![prevVersion isEqualToString:currentVersion]) {
        // Starting up for first time with this version of the app. This
        // means a different version of the app was alread installed once
        // and started.
        [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:@"prevVersion"];
        // Save changes to disk
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}



- (void) setDefaultValues
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"exhibition_preference"];
    /* There seems to be an issue with the Bundle Version being 3.0.10 instead of 2.0.0 so I set the default value instead of getting the current one
     [[NSUserDefaults standardUserDefaults] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version_preference"];
     */
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"guide_preference"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fLaunch"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadOKPoEMMInFrame:(CGRect)frame
{
    // Initialize EAGLView (OpenGL)
    eaglView = [[EAGLView alloc] initWithFrame:frame multisampling:SHOULD_MULTISAMPLE andSamples:2];
    
    // Initilaize OKPoEMM (EAGLView, OKInfoView, OKRegistration... wrapper)
    self.poemm = [[OKPoEMM alloc] initWithFrame:frame EAGLView:eaglView isExhibition:[[NSUserDefaults standardUserDefaults] boolForKey:@"exhibition_preference"]];
     [self.window setRootViewController:self.poemm];
    
    //Start EAGLView animation
    if(eaglView) [eaglView startAnimation];
    
    // Asked for performance version
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"guide_preference"]) {
        [self.poemm promptForPerformance];
    } else {
        // If ever performance was disabled, make sure we leave the current state of exhibition
        [self.poemm setisExhibition:[[NSUserDefaults standardUserDefaults] boolForKey:@"exhibition_preference"]];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPerformance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    //Appirater after eaglview is started and a few seconds after to let everything get in motion
    [self performSelector:@selector(manageAppirater) withObject:nil afterDelay:10.0f];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    //[[UAirship shared] registerDeviceToken:deviceToken];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
   
     [eaglView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Application Did Become Active");


    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //remove any existing badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // Asked for performance version
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"guide_preference"]) {
        [self.poemm promptForPerformance];
    } else {
        // If ever performance was disabled, make sure we leave the current state of exhibition
        [self.poemm setisExhibition:[[NSUserDefaults standardUserDefaults] boolForKey:@"exhibition_preference"]];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPerformance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [eaglView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [eaglView stopAnimation];
    
    //UrbanAirship
    //[UAirship land];
    
    //device can sleep (since we leave)
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)dealloc
{
    [window release];
    [eaglView release];   
    
    [super dealloc];
}

#pragma mark - Appirate

- (void) manageAppirater
{
    [Appirater appLaunched:YES];
    [Appirater setDelegate:self];
    [Appirater setLeavesAppToRate:YES]; // Just too hard on the memory
    [Appirater setAppId:@"446777294"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:5];
}

-(void)appiraterDidDisplayAlert:(Appirater *)appirater
{
    [eaglView stopAnimation];
}

-(void)appiraterDidDeclineToRate:(Appirater *)appirater
{
    [eaglView startAnimation];
}

-(void)appiraterDidOptToRate:(Appirater *)appirater
{
    [eaglView stopAnimation];
}

-(void)appiraterDidOptToRemindLater:(Appirater *)appirater
{
    [eaglView startAnimation];
}

-(void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated
{
    [eaglView stopAnimation];
}

-(void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated
{
    [eaglView startAnimation];
}



@end

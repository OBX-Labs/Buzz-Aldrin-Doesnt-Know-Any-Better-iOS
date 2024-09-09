//
//  BuzzAldrinAppDelegate.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 11-06-07.
//  Modified by Muhammad Shahrom Ali on 07-23-2024
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <OBXKit/AppDelegate.h>
#import <OBXKit/EAGLView.h>

#import <ObxKit/OKPoEMM.h>
#import <ObxKit/OKPreloader.h>
#import <ObxKit/OKTextManager.h>
#import <ObxKit/OKAppProperties.h>
#import <ObxKit/OKPoEMMProperties.h>
#import <ObxKit/OKInfoViewProperties.h>

#import <UserNotifications/UNUserNotificationCenter.h>

#define IS_IPAD_2 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) // Or more
#define IS_IPHONE_5 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define SHOULD_MULTISAMPLE (IS_IPAD_2 || IS_IPHONE_5)

@implementation AppDelegate

@synthesize window, poemm, eaglView;

#pragma mark LifecycleEvents

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self prepareAppWithOptions: launchOptions];
    
    BOOL canLoad = [self loadText];
    
    // Add preloader to window and show
    OKPreloader *preloader = [[OKPreloader alloc] initWithFrame:[[UIScreen mainScreen] bounds] forApp:self loadOnAppear:canLoad];
    [self.window setRootViewController:preloader];
    [self.window makeKeyAndVisible];

	[UIApplication sharedApplication].idleTimerDisabled = YES; //device mustn't sleep
    [[UNUserNotificationCenter currentNotificationCenter] setBadgeCount:0 withCompletionHandler: NULL];//remove any existing badge
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
   
    [eaglView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application Did Become Active");


    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //remove any existing badge
    [[UNUserNotificationCenter currentNotificationCenter] setBadgeCount:0 withCompletionHandler: NULL];
    
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

- (void)applicationWillTerminate:(UIApplication *)application {
    [eaglView stopAnimation];
    
    //device can sleep (since we leave)
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark helpers

- (void) prepareAppWithOptions: (NSDictionary *)launchOptions {
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"fLaunch"])
    {
        [self setDefaultValues];
    }
    
    //In case a new bundle version installed, we clear the cache. This will make the app download the texts/fonts/etc.
    if([self checkBundleVersion])
        [OKTextManager clearCache];
    
    // Set app properties
    [OKAppProperties initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"OKAppProperties.plist"] andOptions:launchOptions];
    [OKPoEMMProperties initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"OKPoEMMProperties.plist"]];
    
    //Init Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (BOOL) loadText {
    BOOL canLoad = YES;
    // Get the id of the last text the user read
    NSString *textKey = [[NSUserDefaults standardUserDefaults] stringForKey:Text];
    NSString *appName = [OKAppProperties objectForKey:@"Name"];
    
    NSString *master = [NSString stringWithFormat:@"net.obxlabs.%@.jlewis.%@", appName, appName];
    if(textKey != nil) {
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
            canLoad = NO;
        }
    }
    
    if(!canLoad)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System Error" message:@"App files were corrupted. Please re-install the app." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
    return canLoad;

}


#pragma mark ClassMethods

//checkBundleVersion. Returns YES if new version, else return no.
- (BOOL) checkBundleVersion {
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *prevVersion = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"prevVersion"];
    
    //NSLog(@"Current version : %@ Previous version: %@", currentVersion, prevVersion);
    if (prevVersion == nil) {
        // Starting up for first time with NO pre-existing installs
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

- (void) setDefaultValues {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"exhibition_preference"];
    /* There seems to be an issue with the Bundle Version being 3.0.10 instead of 2.0.0 so I set the default value instead of getting the current one
     [[NSUserDefaults standardUserDefaults] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version_preference"];
     */
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"guide_preference"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fLaunch"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) loadOKPoEMMInFrame:(CGRect)frame {
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

}


- (void)dealloc {
    [window release];
    [eaglView release];   
    
    [super dealloc];
}


@end

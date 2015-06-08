//
//  BuzzAldrinAppDelegate.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 11-06-07.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appirater.h"
//#import "UAirship.h"

@class EAGLView;
@class TextManager;
@class OKPoEMM;

@interface BuzzAldrinAppDelegate : UIResponder <UIApplicationDelegate, AppiraterDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) OKPoEMM *poemm;
@property (nonatomic, strong) EAGLView *eaglView;

- (void) setDefaultValues;
- (void) loadOKPoEMMInFrame:(CGRect)frame;
- (void) checkAppirater;
- (BOOL) checkBundleVersion;

@end

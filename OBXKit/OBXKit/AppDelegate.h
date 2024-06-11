//
//  AppDelegate.h
//  OBXKit
//
//  Created by Muhammad Shahrom Ali on 2024-06-11.
//

#import <UIKit/UIKit.h>

@class EAGLView;
@class TextManager;
@class OKPoEMM;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) OKPoEMM *poemm;
@property (nonatomic, strong) EAGLView *eaglView;

- (void) setDefaultValues;
- (void) loadOKPoEMMInFrame:(CGRect)frame;
- (BOOL) checkBundleVersion;

@end

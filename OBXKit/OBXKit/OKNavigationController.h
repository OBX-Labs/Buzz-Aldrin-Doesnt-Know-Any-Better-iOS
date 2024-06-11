//
//  OKNavigationController.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKNavigationController : UINavigationController
{
    UIViewController *parent;
    UIViewController *root;
    UIPopoverController *po;
}

- (id) initWithRootViewController:(UIViewController*)aRoot andParent:(UIViewController*)aParent;
- (void) dismiss;
- (UIViewController*) getParentViewController;

@end

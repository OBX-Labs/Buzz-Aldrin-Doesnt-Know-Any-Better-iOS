//
//  OKShare.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "OKShareButtonProtocol.h"

@class OKInfoView;
@class OKShareButton;
@class OKShareScrollView;

@interface OKShare : UIViewController <OKShareButtonProtocol>
{
    OKInfoView *display;
    
    OKShareButton *facebook;
    OKShareButton *twitter;
    OKShareButton *mail;
    
    OKShareScrollView *scrollView;
    
    UIView *center;
    
    NSArray *imageNames;
}

- (id) initForIPadWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;
- (id) initForIPhoneWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;
- (void) setDisplayViewController:(OKInfoView*)aDisplay;

@end

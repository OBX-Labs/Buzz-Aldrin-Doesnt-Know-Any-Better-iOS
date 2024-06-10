//
//  OKMoreAppsItem.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OKMoreAppsItem : UIView
{
    UIButton *icon;
    NSURL *url;
}

- (id) initAtPosition:(CGPoint)position withTitle:(NSString *)title andImage:(UIImage *)image;
- (void) setURL:(NSString*)aURL;

@end

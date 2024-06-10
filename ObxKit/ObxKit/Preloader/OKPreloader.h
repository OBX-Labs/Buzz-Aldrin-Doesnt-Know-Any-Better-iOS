//
//  OKPreloader.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuzzAldrinAppDelegate;

@interface OKPreloader : UIViewController
{
    CGRect frame;
    BuzzAldrinAppDelegate *delegate;
    BOOL loadOnAppear;
}

- (id) initWithFrame:(CGRect)aFrame forApp:(BuzzAldrinAppDelegate*)aDelegate loadOnAppear:(BOOL)flag;

@end

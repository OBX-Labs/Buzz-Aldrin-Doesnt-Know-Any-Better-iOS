//
//  OKPreloader.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-11.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
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

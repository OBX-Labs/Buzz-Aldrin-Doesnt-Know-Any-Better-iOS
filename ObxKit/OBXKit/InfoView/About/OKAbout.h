//
//  OKAbout.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class OKInfoView;

@interface OKAbout : UIViewController
{
    // ScrollView
    UIScrollView *scrollView;
    
    // LimitedEdition text
    UILabel *limitedEdition;
}

- (id) initWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;

@end

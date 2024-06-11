//
//  OKShareButton.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OKShareButtonProtocol.h"

@interface OKShareButton : UIView
{
    UIButton *icon;
    UILabel *title;
    OKShareButtonType type;
}

@property (nonatomic, setter = setDelegate:) id<OKShareButtonProtocol> delegate;

- (id) initWithFrame:(CGRect)frame forType:(OKShareButtonType)aType;

@end

//
//  OKShareButtonProtocol.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    OKShareButtonTypeFacebook,
    OKShareButtonTypeTwitter,
    OKShareButtonTypeMail,
} OKShareButtonType;

@protocol OKShareButtonProtocol <NSObject>

@required
- (void) shareWithType:(OKShareButtonType)type;

@end

//
//  OKShareItem.m
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import "OKShareItem.h"
#import "OKImageManipulator.h"

static float PADDING = 5.0f;

@implementation OKShareItem

- (id) initWithFrame:(CGRect)aFrame andImage:(UIImage*)aImage
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, self.frame.size.width - (PADDING * 2.0f), self.frame.size.height - (PADDING * 2.0f))];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:[OKImageManipulator imageWithImage:aImage resizeToScale:CGSizeMake(self.frame.size.width - (PADDING * 2.0f), self.frame.size.height - (PADDING * 2.0f))]];
        
        [self addSubview:imageView];
        
        // Applies shadow
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowOpacity:0.75f];
        [self.layer setShadowRadius:2.5f];
        [self.layer setShouldRasterize:YES];
    }
    return self;
}

@end

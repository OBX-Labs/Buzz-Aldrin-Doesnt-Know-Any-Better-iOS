//
//  OKShareScrollView.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKShareItem;

typedef enum
{
    ContentScrollDirectionVertical,
    ContentScrollDirectionHorizontal,
} ContentScrollDirection;

@interface OKShareScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *pages;
    CGSize pageSize;
    
    ContentScrollDirection contentScrollDirection;
    
    CGPoint lastContentOffset;
}

- (id) initWithFrame:(CGRect)frame andPageSize:(CGSize)size;
- (void) setPages:(NSArray*)aPages forScrollingDirection:(ContentScrollDirection)aContentScrollDirection;
- (int) currentPage;

@end

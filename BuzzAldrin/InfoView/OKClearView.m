//
//  OKClearView.m
//  ObxKit
//
//  Created by Bruno Nadeau on 11-04-06.
//  Copyright 2011 Obx Labs. All rights reserved.
//

#import "OKClearView.h"


@implementation OKClearView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //return true only if the point is within the frame of one
    //of this view's subviews. this way the clear areas should
    //not trigger touch events
    NSArray *subviews = [self subviews];
    int subviewCount = [subviews count];
    UIView* subview;
    for (int subviewIndex = 0; subviewIndex < subviewCount; subviewIndex++) {
        subview = [subviews objectAtIndex:subviewIndex];
        //if ( CGRectContainsPoint([subview frame], point) )
        if ([subview alpha] > 0 && ![subview isHidden]) {
            if ([subview isKindOfClass:[OKClearView class]]) {
                return [subview pointInside:point withEvent:event];
            } else if (CGRectContainsPoint([subview frame], point)) {
                return TRUE;
            }
        }
    }
    return FALSE;
}

- (void)dealloc
{
    [super dealloc];
}

@end

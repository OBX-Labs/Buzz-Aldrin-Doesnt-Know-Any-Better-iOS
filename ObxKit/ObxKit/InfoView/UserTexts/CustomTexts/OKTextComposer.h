//
//  OKTextComposer.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKTextComposer : UIViewController <UITextViewDelegate, UIScrollViewDelegate>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Composing view
    UITextView *composer;
    
    // Composer line counter
    UIScrollView *lineCounters;
    NSMutableArray *lineCountersAr;
    // Composer character per line counter
    UIScrollView *characterCounters;
    NSMutableArray *characterCountersAr;
    // Counter toggle;
    NSTimer *counterToggle;
    BOOL countersVisible;
    // Publish button
    UIBarButtonItem *publish;
}

- (id) initWithTitle:(NSString*)aTitle;
- (id) initWithTitle:(NSString*)aTitle andText:(NSString*)aText;

@end

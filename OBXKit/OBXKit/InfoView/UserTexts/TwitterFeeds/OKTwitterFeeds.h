//
//  OKTwitterFeeds.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OKTwitterProtocol.h"

@interface OKTwitterFeeds : UITableViewController <UITextFieldDelegate, OKTwitterProtocol>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Rows
    NSMutableArray *rows;
    NSIndexPath *sRow;
    
    // Invisible overlay (for DSActivityView)
    UIView *overlay;
    
    // Current feed
    NSString *cFeed;
    
    // Button
    UIBarButtonItem *search;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle;

@end

//
//  OKCustomTexts.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKCustomTexts : UITableViewController <UITextFieldDelegate>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Rows
    NSMutableArray *rows;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle;

@end

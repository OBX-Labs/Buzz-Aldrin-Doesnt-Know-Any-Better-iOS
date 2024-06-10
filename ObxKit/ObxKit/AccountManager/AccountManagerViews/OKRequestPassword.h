//
//  OKRequestPassword.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKInfoView.h"

@class OKInfoView;
@class OKRegistration;

@interface OKRequestPassword : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    // TableView Sections
    NSMutableArray *sections;
    
    // Validation errors
    NSMutableArray *validationErrors;
    
    // First Responders
    NSMutableArray *firstResponders;
    
    // Display ViewController
    OKInfoView *display;
    
    // Account type
    OKAccountType accountType;
    
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Row Switcher
    NSIndexPath *sRow;
}

- (id) initWithTitle:(NSString*)aTitle style:(UITableViewStyle)aStyle forType:(OKAccountType)aType;
- (void) setDisplayViewController:(OKInfoView*)aDisplay;

@end

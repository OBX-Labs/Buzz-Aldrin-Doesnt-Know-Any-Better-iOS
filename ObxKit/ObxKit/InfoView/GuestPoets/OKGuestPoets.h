//
//  OKGuestPoets.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OKGuestPoets : UITableViewController <NSURLConnectionDelegate>
{
    // Table View Headers (prevents lags if initialized and stored one)
    NSMutableArray *headers;
    NSMutableArray *authors;
    NSMutableDictionary *packages;
    
    // Invisible overlay (for DSActivityView)
    UIView *overlay;
    
    // Row
    NSIndexPath *sRow;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle icon:(UIImage *)aIcon;

- (BOOL) hasConnection;
- (void) updateTexts:(UIRefreshControl*)refresh;
- (void) updateTexts;
- (void) loadNewTextForPackage:(NSString*)aPackage;

@end

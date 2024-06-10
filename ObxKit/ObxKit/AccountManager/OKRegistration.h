//
//  OKRegistration.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OKInfoView.h"

@interface OKRegistration : NSObject <NSURLConnectionDelegate>
{
    NSArray *trustedHosts;
    
    BOOL didCancel;
    
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

+ (OKRegistration*) sharedInstance;

- (void) setTrustedHost:(NSArray*)aTrustedHosts;

- (void) registerUser:(NSDictionary*)aDict forType:(OKAccountType)aType;
- (void) signIn:(NSDictionary*)aDict forType:(OKAccountType)aType;
- (void) requestPassword:(NSDictionary*)aDict forType:(OKAccountType)aType;
- (void) resetPassword:(NSDictionary*)aDict forType:(OKAccountType)aType;

- (void) registerVersion:(NSString*)aVersion;

- (void) sendRequestToURL:(NSURL*)aURL withData:(NSData*)aData;
- (void) cancel;

- (BOOL) checkNetworkStatus;

@end

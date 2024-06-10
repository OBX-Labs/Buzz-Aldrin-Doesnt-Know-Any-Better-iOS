//
//  OKTwitter.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "OKTwitterProtocol.h"

typedef enum
{
    OKTextCapitalizationTypeNone,
    OKTextCapitalizationTypeWords,
    OKTextCapitalizationTypeSentences,
    OKTextCapitalizationTypeAllCharacters,
} OKTextCapitalizationType;

@interface OKTwitter : NSObject

@property (nonatomic, setter = setDelegate:) id<OKTwitterProtocol> delegate;
@property (nonatomic, setter = setTextCapitalizationType:) OKTextCapitalizationType capitalizationType;

+ (OKTwitter*) sharedInstance;

- (void) search:(NSString*)aQuery maxResults:(int)aMaxResults language:(NSString*)aLanguage;
- (void) timeline:(NSString*)aUser maxResults:(int)aMaxResults;

@end

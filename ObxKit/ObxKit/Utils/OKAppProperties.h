//
//  OKAppProperties.h
//  ObxKit
//  Created by Muhammad Shahrom Ali on 2024-06-10.
//  Programmed by Christian Gratton on 2013-02-04.
//  Copyright (c) 2024 Obx Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKAppProperties : NSObject

@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, getter = isiPad) BOOL iPad;
@property (nonatomic, getter = isiPhone568h) BOOL iPhone568h;
@property (nonatomic, getter = wasPushed) BOOL pushed;
@property (nonatomic) float scale;
@property (nonatomic) BOOL supportsRetinaFonts;

+ (OKAppProperties*) sharedInstance;

// Init the properties with a plist
+ (void) initWithContentsOfFile:(NSString*)aPath andOptions:(NSDictionary*)aOptions;

// Retreive a property value from a singleton
+ (id) objectForKey:(id)aKey;
+ (void) setObject:(id)aObject forKey:(id)aKey;

// Check if the os is above or equal to the passed version
+ (BOOL) isOSGreaterOrEqualThan:(NSString*)aOS;

// Check if the app is running on the iPad
+ (BOOL) isiPad;

// Check if the app is running on a 5 inch screen device (568h)
+ (BOOL) isiPhone568h;

// Check if the app is running on a device with retina display
+ (BOOL) isRetina;

// Check if the app supports @2x fonts
+ (BOOL) doesSupportsRetinaFonts;

+ (NSString*) deviceType;

- (void) listAvailableFonts;

+ (void) listProperties;

@end

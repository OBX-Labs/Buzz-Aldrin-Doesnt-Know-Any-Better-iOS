//
//  main.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 11-06-07.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OBXKit/AppDelegate.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));

    [pool release];
    return retVal;
}

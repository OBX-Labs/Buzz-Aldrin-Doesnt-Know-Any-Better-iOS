//
//  ESRenderer.h
//  OBXKit
//  Created by Christian Gratton on 10-12-02.
//  Recreated by Muhammad Shahrom Ali on 2024-06-11.
//  Copyright (c) 2024 Obx Labs. All rights reserved.

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import "TextClass.h"

@protocol ESRenderer <NSObject>

- (void)render;
- (void) setFrame:(CGRect)aFrame;

- (void)render:(TextClass *)theText;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
-(UIImage *) glToUIImage;
- (void) resetOpenGL;

@end

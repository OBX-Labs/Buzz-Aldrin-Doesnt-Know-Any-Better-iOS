//
//  ESRenderer.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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

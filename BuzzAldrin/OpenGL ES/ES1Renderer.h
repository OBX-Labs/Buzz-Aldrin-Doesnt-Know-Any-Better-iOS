//
//  ES1Renderer.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextClass.h"

@interface ES1Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	bool glInitialised;
    
    //window frame
    CGRect windowFrame;
}

- (void)render;
- (void) setFrame:(CGRect)aFrame;

- (void)render:(TextClass *)theText;

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

- (void) initOpenGL;
- (void) initFog;
- (void) resetOpenGL;

@end

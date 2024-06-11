//
//  ES1Renderer.m
//  OBXKit
//  Created by Christian Gratton on 10-12-02.
//  Recreated by Muhammad Shahrom Ali on 2024-06-11.
//  Copyright (c) 2024 Obx Labs. All rights reserved.

#import "ES1Renderer.h"
#import "OKPoEMMProperties.h"

@implementation ES1Renderer

// Create an OpenGL ES 1.1 context
- (id)init
{
    self = [super init];
    if (self)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }

        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
    }

    return self;
}

- (void) setFrame:(CGRect)aFrame
{
    windowFrame = aFrame;
}

- (void)initOpenGL
{
    //near and far plane
    GLfloat zNear = 300;
    GLfloat zFar = 1000;
    
    //rad theta for field of view Y
    GLfloat radtheta = 2.0 * atan2(windowFrame.size.height/2, zNear);
    
    //fovY/aspect ratio
    GLfloat fovY = (100.0 * radtheta) / M_PI;
    GLfloat aspect = windowFrame.size.width/windowFrame.size.height;
    
    //calculate the x and y min/max
    GLfloat ymax = zNear * tan(fovY * M_PI / 360.0);
    GLfloat ymin = -ymax;
    GLfloat xmin = ymin * aspect;
    GLfloat xmax = ymax * aspect;
        
    //set the view port/projection mode
    glViewport(0, 0, windowFrame.size.width, windowFrame.size.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    //frustrum and translate to center
    glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
    glTranslatef(-(windowFrame.size.width/2), -(windowFrame.size.height/2), 0);

    glMatrixMode(GL_MODELVIEW);
        
    // Save the current matrix to the stack
    glPushMatrix();
    
    //initialize opengl states
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_DST);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    NSArray* bgColor = [OKPoEMMProperties objectForKey:BgColor];
    
    //color values
    glClearColor([[bgColor objectAtIndex:0] floatValue], [[bgColor objectAtIndex:1] floatValue], [[bgColor objectAtIndex:2] floatValue], [[bgColor objectAtIndex:3] floatValue]);
    
    //glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        
    //init the fog
    if([[OKPoEMMProperties objectForKey:Fog] boolValue])
        [self initFog];
    
    //set opengl initialized
    glInitialised = YES;
}

- (void) initFog
{
    //fog color
    NSArray* fogColorAr = [OKPoEMMProperties objectForKey:FogColor];
    float fogColor[] = { [[fogColorAr objectAtIndex:0] floatValue], [[fogColorAr objectAtIndex:1] floatValue], [[fogColorAr objectAtIndex:2] floatValue], [[fogColorAr objectAtIndex:3] floatValue] };
    
    glEnable(GL_FOG);
    glClearDepthf(1.0f);                    //Depth Buffer Setup
    glEnable(GL_DEPTH_TEST);              // Enables Depth Testing
    glDepthFunc(GL_ALWAYS);               // The Type Of Depth Testing To Do
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);    // Really Nice Perspective Calculations
    glEnable(GL_TEXTURE_2D);
    glFogf(GL_FOG_MODE, GL_LINEAR);
    glFogf(GL_FOG_DENSITY, 0.35f); //0.35f
    glHint(GL_FOG_HINT, GL_FASTEST);
    glFogfv(GL_FOG_COLOR, fogColor);
    glFogf(GL_FOG_START, [[OKPoEMMProperties objectForKey:FogStartPositon] floatValue]); //900.0f
    glFogf(GL_FOG_END, [[OKPoEMMProperties objectForKey:FogEndPosition] floatValue]); //500.0f
     
}

- (void) resetOpenGL
{
    glInitialised = NO;
}

- (void)render
{
    // Replace the implementation of this method to do your own custom drawing
    
    if(!glInitialised)
    {
        [self initOpenGL];
    }
    // Replace the implementation of this method to do your own custom drawing
    
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    //draw scene
    glClear(GL_COLOR_BUFFER_BIT);
        
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

//grabs screenshot of canvas and returns an image
-(UIImage *) glToUIImage
{
    int width = windowFrame.size.width * [[UIScreen mainScreen] scale];
    int height = windowFrame.size.height * [[UIScreen mainScreen] scale];
    
    NSInteger myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x < width * 4; x++)
        {
            buffer2[((height - 1) - y) * width * 4 + x] = buffer[y * 4 * width + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

//render text
- (void)render:(TextClass *)theText
{
    if(!glInitialised)
    {
        [self initOpenGL];
    }
        
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);

    //draw scene
    glDepthMask (GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //draws the text
    [theText drawText];
    
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
     
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}

@end

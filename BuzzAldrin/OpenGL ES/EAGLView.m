//
//  EAGLView.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EAGLView.h"
#import "ES1Renderer.h"
#import "BuzzAldrinAppDelegate.h"
#import "BuzzAldrinAppDelegate.h"
#import "OKPoEMMProperties.h"
#import "OKTextManager.h"

#define SWIPE_LENGTH 50
#define SWIPE_MAX_TIME 0.5

static EAGLView *sharedInstance;

@interface EAGLView ()
@property (nonatomic, getter=isAnimating) BOOL animating;

@end

@implementation EAGLView

@synthesize animating, animationFrameInterval, displayLink, animationTimer, bGuide;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
+ (EAGLView*) sharedInstance
{
    @synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [[EAGLView alloc] init];
	}
	return sharedInstance;
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithFrame:(CGRect)aFrame multisampling:(BOOL)canMultisample andSamples:(int)aSamples
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]]; // sets the scale based on the device
        
        renderer = [[ES1Renderer alloc] init];
        [renderer setFrame:self.frame];

		if (!renderer)
		{
			[self release];
			return nil;
		}
        
        NSLog(@"Window aFrame: %f %f ", aFrame.size.width, aFrame.size.height);
        
        [self setupFont];
        
        //start autoplay timer
        [self setAutoplayTimer];

        //bExhibition = [[NSUserDefaults standardUserDefaults] boolForKey:@"exhibition_preference"];
        //bGuide = [[NSUserDefaults standardUserDefaults] boolForKey:@"guide_preference"];
        
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 2; //max out at 30 FPS (since iPad 2 is just too fast...)
        displayLink = nil;
        animationTimer = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
        
        // Add NSNotificationCenter observers for OKInfoView
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoViewWillAppear) name:@"OKInfoViewWillAppear" object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoViewWillDisappear) name:@"OKInfoViewWillDisappear" object:self.window];
	}
    return self;
}

- (void) setupFont
{    
    //RENDERER
    [renderer resetOpenGL];
    
    //TEXT    
    NSString *textPath = [OKTextManager textPathForFile:[OKPoEMMProperties objectForKey:TextFile] inPackage:[OKPoEMMProperties objectForKey:Text]];
    NSMutableString *textFromFile = [NSMutableString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
    
    //NSLog(@"textFromFile1 is: %@", textFromFile);
    
    //replace \r with \n (return line)
    [textFromFile replaceOccurrencesOfString:@"\r" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [textFromFile length])];

    //then we replace the \n\n by a single \n (in case in original text there was \r\n or \n\r for each line)
    [textFromFile replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [textFromFile length])];
    
    //NSLog(@"textFromFile2 is: %@", textFromFile);
    
    //replace – (charID 8211) with - (charID 45)
    [textFromFile replaceOccurrencesOfString:@"–" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [textFromFile length])];
    
    //FONT
    NSString *fontFilePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontFile] ofType:nil ];
    NSString *fontImagePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontFile] ofType:@"png" ];
    
    NSString *fontOutlineFilePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontOutlineFile] ofType:nil ];
    NSString *fontOutlineImagePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontOutlineFile] ofType:@"png" ];
        
    CGSize displaySize;
    GLfloat scale = [[OKPoEMMProperties objectForKey:@"FontScale"] floatValue]/100; //since it's % value on PoEMMaker

    if ([OKAppProperties isiPad])
        displaySize = CGSizeMake(775, 700);
    else
        displaySize = CGSizeMake(370, 290);
    
    if([OKAppProperties isRetina])
        scale *= 0.5;
    else
        scale *= 1.0; //max 2.5 min 0.15
    
    NSArray* color = [OKPoEMMProperties objectForKey:TextBackgroundColor];
    
    /*
     // Only initializes the font if it has changed.
     if(font && ![font.name isEqualToString:fontName]) [font release];
     
     // Text font
     if(!font) {
     font  = [[OKTessFont alloc] initWithControlFile:fontName scale:1.0 filter:GL_LINEAR];
     [font setColourFilterRed:0.0 green:0.0 blue:0.0 alpha:0.0];
     }
     if(text) [text release];
     if(white) [white release];
     white = [[White alloc] initWithFont:font text:text andBounds:self.frame];
     */

    //set default font (files name/color)
    if(currentFont) {
        currentFont = nil;
        [currentFont release];
    }
    currentFont = [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:scale filter:GL_LINEAR];
    [currentFont setColourFilterRed:[[color objectAtIndex:0] floatValue]
                              green:[[color objectAtIndex:1] floatValue]
                               blue:[[color objectAtIndex:2] floatValue]
                              alpha:[[color objectAtIndex:3] floatValue]];
    
    //set outline font (files name/color)
    if(outlineFont) {
        outlineFont = nil;
        [outlineFont release];
    }
    outlineFont	= [[Font alloc] initWithFontImageNamed:fontOutlineImagePath controlFile:fontOutlineFilePath scale:scale filter:GL_LINEAR];
    [outlineFont setColourFilterRed:[[color objectAtIndex:0] floatValue]
                              green:[[color objectAtIndex:1] floatValue]
                               blue:[[color objectAtIndex:2] floatValue]
                              alpha:[[color objectAtIndex:3] floatValue]];
    
    //replace unknown characters (for debug)
//    NSMutableArray *uChar = [[NSMutableArray alloc] init];
//    NSArray *avChar = [currentFont getAvailChars];
        
//    for(int i = 0; i < [textFromFile length]; i++)
//    {
//        NSString *aChar = [NSString stringWithFormat: @"%C", [textFromFile characterAtIndex:i]];
//        NSString *aCharId = [NSString stringWithFormat: @"%i", [textFromFile characterAtIndex:i]];
//                
//        if(![avChar containsObject:aCharId] && ![uChar containsObject:aChar])
//        {
//            [uChar addObject:aChar];
//        }
//    }
//    
//    for(int j = 0; j < [uChar count]; j++)
//    {
//        if(![[uChar objectAtIndex:j] isEqualToString:@"\n"])
//            [textFromFile replaceOccurrencesOfString:[uChar objectAtIndex:j] withString:@"?" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [textFromFile length])];
//    }
//    
//    [uChar release];
  
    //start parsing the text and set the outline font.
    if(currentText) {
        currentText = nil;
        [currentText release];
    }
    currentText = [[TextClass alloc] initWithText:textFromFile withFont:currentFont andScreenSize:displaySize];
    [currentText setOutlinedFont:outlineFont];
    
}

- (UIImage*)screenCapture
{
    //grab screen for screen shot
    return [renderer glToUIImage];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:self];
        
    //then move words
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPerformance"])
        [currentText setFocusNext];
    else{
        [currentText setFocusForCoordinates:CGPointMake(touchLocation.x, self.frame.size.height-touchLocation.y)];
    }
    
    [currentText setPositionWithCoordinates:CGPointMake(touchLocation.x, self.frame.size.height-touchLocation.y)];
                          
    //swipe start location
    swipeStart = [[touches anyObject] locationInView:self];
             
    //save the touch start time to detect swipe
    touchBeganTime = touch.timestamp;

    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint moveLocation = [touch locationInView:self];
        
    [currentText setPositionWithCoordinates:CGPointMake(moveLocation.x, self.frame.size.height-moveLocation.y)];
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //we stoped moving/touching stop moving action and reset autoplay
    [currentText stopTargetMove];
     
	[self setAutoplayTimer];
	
    [super touchesEnded:touches withEvent:event];
    
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //we cancelled moving/touching stop moving action and reset autoplay
    [currentText stopTargetMove];
	[self setAutoplayTimer];
}

- (void) setAutoplayTimer
{
    //if timer is valid stop it and set it to null
	if([autoplayTimer isValid])
	{
		[autoplayTimer invalidate];
		autoplayTimer = nil;
	}
	
    //start timer again
	autoplayTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(autoplay) userInfo:nil repeats:YES];
}

- (void) autoplay
{
    //each time the timer is triggered set the appropriate sentence in focus
	[currentText setAutoplayFocus];
}

- (void) infoViewWillAppear {
    [self stopAnimation]; }
- (void) infoViewWillDisappear{
    [self startAnimation];
    }

- (void)drawView:(id)sender
{
//	NSDate *startDate = [NSDate date];
	
    //bGuide = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPerformance"];
    
	//rendering etc in here
	[renderer render:currentText];
		
	//[self getFrameRate:[[NSDate date] timeIntervalSinceDate:startDate]];
}

//- (void)getFrameRate:(float)withInterval
//{	
//	lbl_frameRate.text = [NSString stringWithFormat:@"%.1f", 60-(withInterval*1000)];	
//}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];

        self.animating = TRUE;
    }
    
    //bGuide = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPerformance"];

}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            self.displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            self.animationTimer = nil;
        }

        self.animating = FALSE;
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)dealloc
{
    [renderer release];
    [displayLink release];
	[currentText release];
	[currentFont release];
    [outlineFont release];
	
    [super dealloc];
}

@end

//
//  Sentence.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sentence.h"


@implementation Sentence
@synthesize theWordObjects;

- (id)initWithSentence:(NSString *)theSentence withFont:(Font *)theFont
{
	self = [self init];
	if (self != nil)
	{
        //split the line on space
		theWordObjects = [[NSMutableArray alloc] init];
		NSArray *theWords = [theSentence componentsSeparatedByString:@" "];
        
		for(int i = 0; i < [theWords count]; i++)
		{
			//find the autoplay word and create it
			NSRange range = [[theWords objectAtIndex:i] rangeOfString:@"*"];
			if (range.location != NSNotFound)
				currentWord = [[Word alloc] initWithWord:[[theWords objectAtIndex:i] stringByReplacingOccurrencesOfString:@"*" withString:@""] isAutoplay:YES withFont:theFont];
            //else
			else
				currentWord = [[Word alloc] initWithWord:[theWords objectAtIndex:i] isAutoplay:NO withFont:theFont];
			
            //create instance of word
			[theWordObjects addObject:currentWord];
			[currentWord release];
		}
	}
	return self;
}

//set outline font
- (void) setOutlinedFont:(Font *)theFont
{
	for(Word *words in theWordObjects)
	{
		[words setOutlinedFont:theFont];
	}
}

#pragma mark setters
//set position
- (void) setXWithWidht:(float)screenWidth andYOffset:(float)offsetY withFont:(Font *)theFont
{
	int i = 0;
	
	for(Word *words in theWordObjects)
	{
		float widthDivision = screenWidth/[theWordObjects count];
		
		float halfWordWidth = [theFont getWidthForString:words.currentWord]/2;
		float halfScreenWidthOffset = ([UIScreen mainScreen].bounds.size.height - screenWidth)/2;
		float xPos = ((i * widthDivision) + (widthDivision/2));
		float offsetX = halfScreenWidthOffset + (xPos - halfWordWidth);	
		
		//randomize the height between -30 and 30
		int randomHeight = ((arc4random() % 60) - 30);
		
		[words setPosition:CGPointMake(offsetX, (offsetY + randomHeight))];
		
		i++;
	}
}

#pragma mark dealloc
- (void)dealloc
{
	[theWordObjects release];
	[super dealloc];
}

@end

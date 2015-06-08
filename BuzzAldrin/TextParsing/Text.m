//
//  Text.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Text.h"

@implementation TextClass

//init
- (id)initWithText:(NSString *)theText withFont:(Font *)theFont andScreenSize:(CGSize)size
{
	self = [self init];
	if (self != nil)
	{
        //create a sentence object array
        theSentenceObjects = [[NSMutableArray alloc] init];
        
        //split sentences on return line
		NSArray *theSentences = [theText componentsSeparatedByString:@"\n"];
		        
        //get height of sentence
		float heightDivision = size.height/[theSentences count];
			
		for(int i = 0; i < [theSentences count]; i++)
		{
            //create sentence
			currentSentence = [[Sentence alloc] initWithSentence:[theSentences objectAtIndex:i] withFont:theFont];

            //calculate size and position
			float halfWordHeight = [theFont getHeightForString:[theSentences objectAtIndex:i]]/2;
			float halfScreenHeightOffset = ([UIScreen mainScreen].bounds.size.width - size.height)/2;
            
			float yPos = ((i * heightDivision) + (heightDivision/2));
			float offsetY = ([UIScreen mainScreen].bounds.size.width - halfScreenHeightOffset) - (yPos + halfWordHeight);			
			
            //set position
			[currentSentence setXWithWidht:size.width andYOffset:offsetY withFont:theFont];
			
			//create sentence object
			[theSentenceObjects addObject:currentSentence];
			[currentSentence release];
		}
        
        //autoplay order
        autoplayOrder = [[NSMutableArray alloc] initWithArray:theSentenceObjects];
        autoplayID = 0;
	}
	return self;    
}

#pragma mark setters
//set outlined font
- (void) setOutlinedFont:(Font *)theFont
{
	for(Sentence *sentence in theSentenceObjects)
	{
		[sentence setOutlinedFont:theFont];
	}
}

#pragma mark focus
//get word at position XY
- (void) setFocusForCoordinates:(CGPoint)coordinates
{
    int sentenceID = -1;
    int wordID = -1;
    int sentenceCounter = 0;
    
    BOOL didTouch = NO;
    
    for(Sentence *sentence in theSentenceObjects)
    {
        int wordCounter = 0;
        for(Word *words in sentence.theWordObjects)
        {
            if(CGRectContainsPoint([words getRect], coordinates))
            {
                didTouch = YES;
                wordID = wordCounter;
            }
            
            wordCounter++;
        }
        
        if(didTouch)
        {
            sentenceID = sentenceCounter;
            didTouch = NO;
        }
        
        sentenceCounter++;
    }
    
    if(sentenceID != -1)
    {
        initialTouch = YES;
        //update autoplay order
        [self getAutoplayID:sentenceID];
        //set focus to touched word/sentence
        [self giveFocusFor:sentenceID and:wordID];
    }
}

- (void) setFocusNext {
    initialTouch = YES;
    
    if (autoplayID == -1) {
        autoplayID++;
        //reset initialtouch because that's how the
        //rendering knows if a line is in focus or not
        initialTouch = NO;
        return;
    }
    
    Sentence *autoSentence = [autoplayOrder objectAtIndex:autoplayID];
    
    int sentenceCounter = 0;
    for(Sentence *sentences in theSentenceObjects)
    {
        if(sentences == autoSentence)
        {
            int wordCounter = 0;
            for(Word *words in sentences.theWordObjects)
            {
                if(words.isAutoplay)
                {
                    [self giveFocusFor:sentenceCounter and:wordCounter];
                    break;
                }
                wordCounter++;
            }
            break;
        }
        sentenceCounter++;
    }
    
    if(autoplayID < ([autoplayOrder count] - 1))
        autoplayID++;
    else
        autoplayID = -1; //set to -1 to skip one line at the end
}

//give focus to object X
- (void) giveFocusFor:(int)sentenceID and:(int)wordID;
{
	[theSentenceObjects addObject:[theSentenceObjects objectAtIndex:sentenceID]];
	[theSentenceObjects removeObjectAtIndex:sentenceID];
	
	Sentence *currSentence = [theSentenceObjects objectAtIndex:[theSentenceObjects count] - 1];
	[currSentence.theWordObjects addObject:[currSentence.theWordObjects objectAtIndex:wordID]];
	[currSentence.theWordObjects removeObjectAtIndex:wordID];
}

//set autoplay focus
- (void) setAutoplayFocus
{	
	initialTouch = YES;

    //make sure that autoplay sentence ID wasn't
    //set to -1 because of the reading guide
    if (autoplayID == -1)
        autoplayID++;
        
	Sentence *autoSentence = [autoplayOrder objectAtIndex:autoplayID];
    
    int sentenceCounter = 0;
    for(Sentence *sentences in theSentenceObjects)
    {
        if(sentences == autoSentence)
        {
            int wordCounter = 0;
            for(Word *words in sentences.theWordObjects)
            {
                if(words.isAutoplay)
                {
                    [self giveFocusFor:sentenceCounter and:wordCounter];
                    break;
                }
                wordCounter++;
            }
            break;
        }
        sentenceCounter++;
    }
    
    if(autoplayID < ([autoplayOrder count] - 1))
        autoplayID++;
    else
        autoplayID = 0;
}

//update autoplay order
- (void) getAutoplayID:(int)currSentenceID
{
    Sentence *prevSentence = [theSentenceObjects objectAtIndex:currSentenceID];
    
    int sentenceCounter = 0;
    for(Sentence *sentences in autoplayOrder)
    {
        if(sentences == prevSentence)
        {
            if(sentenceCounter < ([autoplayOrder count] - 1))
                autoplayID = (sentenceCounter + 1);
            else
                autoplayID = 0;
            
            break;
        }
        sentenceCounter++;
    }
}

#pragma mark touches
//set the target for dragged word
- (void) setPositionWithCoordinates:(CGPoint)coordinates
{
	int sentenceCounter = 0;
	for(Sentence *sentence in theSentenceObjects)
	{
		int wordCounter = 0;
		for(Word *words in sentence.theWordObjects)
		{
			if(sentenceCounter == [theSentenceObjects count] - 1 && initialTouch)
			{
				if(wordCounter == [sentence.theWordObjects count] - 1)
					[words setTargetPosition:CGPointMake(coordinates.x - (words.wordWidth/2), coordinates.y - (words.wordHeight/2))];
			}
			wordCounter++;
		}
		sentenceCounter++;
	}
}

//stop target move (when dragging stopped)
- (void) stopTargetMove
{
	int sentenceCounter = 0;
	for(Sentence *sentence in theSentenceObjects)
	{
		int wordCounter = 0;
		for(Word *words in sentence.theWordObjects)
		{
            //if word in focus (initial touch) and is focus stop moving (dragging)
			if(sentenceCounter == [theSentenceObjects count] - 1 && initialTouch)
			{
				if(wordCounter == [sentence.theWordObjects count] - 1)
					[words stopTargetMove];
			}
			
			wordCounter++;
		}
		sentenceCounter++;
	}
}

#pragma mark draw
//draw the text
- (void) drawText
{
    //loop through all sentences/words and draw each word depending on value
	int sentenceCounter = 0;
	for(Sentence *sentence in theSentenceObjects)
	{
		int wordCounter = 0;
		for(Word *words in sentence.theWordObjects)
		{
            //if word in focus (initial touch) then draw focus line and target word
			if(sentenceCounter == [theSentenceObjects count] - 1 && initialTouch)
			{
                //last word is word in focus
				if(wordCounter == [sentence.theWordObjects count] - 1)
					[words drawStringIsFocus:YES andTarget:YES];
				else 
					[words drawStringIsFocus:YES andTarget:NO];
			}
            //else draw normal
			else
				[words drawStringIsFocus:NO andTarget:NO];
			
			wordCounter++;
		}
		
		sentenceCounter++;
	}
}

#pragma mark dealloc
- (void)dealloc
{
	[theSentenceObjects release];
	[super dealloc];
}

@end

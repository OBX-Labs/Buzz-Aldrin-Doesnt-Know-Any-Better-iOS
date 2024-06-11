//
//  Sentence.h
//  OBXKit
//  Created by Christian Gratton on 10-12-02.
//  Recreated by Muhammad Shahrom Ali on 2024-06-11.
//

#import <Foundation/Foundation.h>
#import "Word.h"
#import "Font.h"

@interface Sentence : NSObject
{
    //word array
    NSMutableArray *theWordObjects;
    //current word
    Word *currentWord;
}

@property (nonatomic, retain) NSMutableArray *theWordObjects;

//init
- (id)initWithSentence:(NSString *)theSentence withFont:(Font *)theFont;

//font
- (void) setOutlinedFont:(Font *)theFont;

//setters
- (void) setXWithWidht:(float)screenWidth andYOffset:(float)offsetY withFont:(Font *)theFont;


@end

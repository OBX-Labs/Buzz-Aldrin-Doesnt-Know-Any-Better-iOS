//
//  Font.h
//  OBXKit
//  Created by Christian Gratton on 10-12-02.
//  Recreated by Muhammad Shahrom Ali on 2024-06-11.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "CharDef.h"

@interface Font : NSObject
{
    // The image which contains the bitmap font
    Image        *image;
    // The characters building up the font
    CharDef        *charsArray[256];
    // The height of a line
    GLuint        lineHeight;
    // Colour Filter = Red, Green, Blue, Alpha
    float        colourFilter[4];
    // The scale to be used when rendering the font
    float        scale;
    float        rotation;
    int commonHeight;
    // Vertex arrays
    Quad2 *texCoords;
    Quad2 *vertices;
    GLushort *indices;
    
    NSMutableArray *availChars;
}

@property(nonatomic, assign)float scale;
@property(nonatomic, assign)float rotation;

- (id)initWithFontImageNamed:(NSString*)fontImage controlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter;
- (void)drawStringAt:(CGPoint)point withZValue:(float)zPos andYRot:(float)yRot text:(NSString*)text isFocused:(BOOL)isFocused;
- (float)getWidthForString:(NSString*)string;
- (float)getHeightForString:(NSString*)string;
- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void)setScale:(float)newScale;
- (void)setRotation:(float)newRotation;
- (NSMutableArray*) getAvailChars;

@end

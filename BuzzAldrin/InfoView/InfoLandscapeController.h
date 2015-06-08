//
//  InfoLandscapeController.h
//  KnowKnowTM
//
//  Created by Bruno Nadeau on 11-08-26.
//  Copyright (c) 2011 Wyld Collective Ltd. All rights reserved.
//

#import "InfoSubcontroller.h"

@interface InfoLandscapeController : InfoSubcontroller

- (void) showView;
- (void) showView:(float)delay; //show the view
- (void) animateToView:(float)delay;
- (void) animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;

- (void) endSwipe;
- (void) endSwipe:(CGPoint)location;

@end

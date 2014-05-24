//
//  Grid.h
//  GameOfLife
//
//  Created by 靖 陈 on 5/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Grid : CCSprite

@property NSInteger generation;
@property NSInteger totalAlive;

- (void)evolveStep;
- (void)countNeighbors;
- (void)updateCreatures;

@end

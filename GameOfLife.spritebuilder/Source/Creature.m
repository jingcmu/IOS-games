//
//  Creature.m
//  GameOfLife
//
//  Created by 靖 陈 on 5/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Creature.h"

@implementation Creature

- (id)initCreature
{
    self = [super initWithImageNamed:@"GameOfLifeAssets/Assets/bubble.png"];
    
    if(self){
        self.isAlive = false;
    }
    
    return self;
}

- (void)setIsAlive:(BOOL)newState {
    _isAlive = newState;
    self.visible = _isAlive;
}

@end

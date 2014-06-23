//
//  Seal.m
//  PeevedPenguins
//
//  Created by Jing on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

//-(id)init {
//    self = [super init];
//    
//    if (self) {
//        CCLOG(@"Seal created");
//    }
//    
//    return self;
//}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}



@end

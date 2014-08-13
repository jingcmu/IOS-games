//
//  GamLayer.h
//  DoodleDrop
//
//  Created by Jing on 7/2/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"

@interface GamLayer : CCLayer {
    CCSprite *player;
    CMMotionManager *cmManager;
    CGPoint playerVelocity;
    
    NSMutableArray *bullets;
    float bulletMoveDuration;
    int numbulletMoved;
    
    int score;
    BOOL isCollision;
    BOOL isRestart;
    int level;
    //label for score
    CCNode < CCLabelProtocol > *label;
    CCNode < CCLabelProtocol > *scoreLabel;
    
    SneakyButton *pauseButton;
    SneakyButton *restartButton;
    int HealthPoint;
    BOOL labelScale;
}

+(id) scene;

typedef enum
{
    GameSceneLayerTagGame = 1,
    GameSceneLayerTagInput,
} GameSceneLayerTag;

@end

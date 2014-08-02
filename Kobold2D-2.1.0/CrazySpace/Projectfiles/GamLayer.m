//
//  GamLayer.m
//  CrazySpace
//
//  Created by Jing on 7/2/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "GamLayer.h"
#import "SimpleAudioEngine.h"

@implementation GamLayer

+(id) scene
{
    CCScene *scene = [CCScene node]; //Create a scene
    CCLayer *layer = [GamLayer node]; //Create a layer
    [scene addChild:layer]; //add layer to the scene
    return scene;
}

-(id) init
{
    if((self = [super init]))
    {
        CCLOG(@"%@ : %@", NSStringFromSelector(_cmd), self);
        
#if KK_PLATFORM_IOS
		// set iPad version to use standard resolution images for iPad 1 & 2 and Retina images for iPad 3
		[[CCFileUtils sharedFileUtils] setiPadSuffix:@""];					// Default on iPad is "" (empty string)
		[[CCFileUtils sharedFileUtils] setiPadRetinaDisplaySuffix:@"-hd"];	// Default on iPad RetinaDisplay is "-ipadhd"

#endif
        
        //add Button
        [self addPauseButton];
        [self addRestartButton];
        
        level = 1;
        isRestart = false;
        self.isAccessibilityElement = YES;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        //float imageHeight = player.texture.contentSize.height;
        
        HealthPoint = 3;
        
        for(int i=0; i<HealthPoint; i++)
        {
            CCSprite *planet = [CCSprite spriteWithFile:@"planet.png"];
            CGSize size = planet.texture.contentSize;
            planet.position = CGPointMake(screenSize.width - size.width * 0.5f - size.width * i * 1.2f, screenSize.height - size.height);
            
            //add sprite planet to current layer
            [self addChild:planet z:0 tag:4+i];
        }
        
        CCSprite *background = [CCSprite spriteWithFile:@"space.png"];
        [self addChild:background z:-100];
        background.position = CGPointMake(screenSize.width/2, screenSize.height/2);
        
        player = [CCSprite spriteWithFile:@"planet.png"];
        [self addChild:player z:0 tag:1];
        
        player.position = CGPointMake(screenSize.width/2, screenSize.height/2); //place player to the middle of the screen
        
        //schedules the -(void)update:(ccTime)delta method to be called every frame
        [self scheduleUpdate];
        
        //Init bullets(which are suns)
        [self initbullets];
        
        //create the label for score
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:48];
        //add label to the top middle of the screen
        scoreLabel.position = CGPointMake(screenSize.width/2, screenSize.height);
        
        //change the anchorPoint for score label
        scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
        
        //add label to current layer, set z to -1
        [self addChild:scoreLabel z:-1];
        
        //play background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"blues.mp3" loop:YES];
        [[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
        
        //set a seed for the random generator
		//srandom((unsigned int)time(NULL));
        
        //first enter GameOver scene
        bulletMoveDuration = 4.0f;
        isCollision = true;
        [self stopAndShowMessage:@"CrazySpace.." withLevel:@"Touch to play Level-1"];
		//[self showGameOver];
    }
    
    return self;
}

-(void) addPauseButton
{
    float buttonRadius = 80;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *pause_idle = [CCSprite spriteWithFile:@"pause.png"];
    CCSprite *pause_press = [CCSprite spriteWithFile:@"continue.png"];
    
    pauseButton = [[SneakyButton alloc] initWithRect:CGRectZero];
    pauseButton.radius = buttonRadius;
    
    SneakyButtonSkinnedBase *skinPauseButton = [[SneakyButtonSkinnedBase alloc] init];
    skinPauseButton.button = pauseButton;
    skinPauseButton.defaultSprite = pause_idle;
    skinPauseButton.pressSprite = pause_press;
    
    skinPauseButton.position = CGPointMake(screenSize.width - buttonRadius*1.2, buttonRadius/2 );
    [self addChild:skinPauseButton];
}

-(void) addRestartButton
{
    float buttonRadius = 80;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *restart_idle = [CCSprite spriteWithFile:@"stop.png"];
    CCSprite *restart_press = [CCSprite spriteWithFile:@"stop.png"];
    
    restartButton = [[SneakyButton alloc] initWithRect:CGRectZero];
    restartButton.radius = buttonRadius;
    
    SneakyButtonSkinnedBase *skinRestartButton = [[SneakyButtonSkinnedBase alloc] init];
    skinRestartButton.button = restartButton;
    skinRestartButton.defaultSprite = restart_idle;
    skinRestartButton.pressSprite = restart_press;
    
    skinRestartButton.position = CGPointMake(screenSize.width - buttonRadius/2, buttonRadius/2);
    [self addChild:skinRestartButton];
}

-(void) dealloc
{
    CCLOG(@"%@ : %@", NSStringFromSelector(_cmd), self);
}

-(void)update:(ccTime)delta
{
    //keep adding up the playerVelocity to the player's position
    CGPoint pos = player.position;
    pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;

    //the player should also be stoped from going outside the screen
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float imageWidthHalved = player.texture.contentSize.width * 0.5f;
    float imageHeightHalved = player.texture.contentSize.height * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float bottomBorderLimit = imageHeightHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    float topBorderLimit = screenSize.height - imageHeightHalved;
    
    //preventing the player sprite from moving outside the screen
    if(pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        playerVelocity.x = 0;
    }
    else if(pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        playerVelocity.x = 0;
    }
    
    if(pos.y < bottomBorderLimit)
    {
        pos.y = bottomBorderLimit;
        playerVelocity.y = 0;
    }
    else if(pos.y > topBorderLimit)
    {
        pos.y = topBorderLimit;
        playerVelocity.y = 0;
    }

    
    //assigning the modified position back
    player.position = pos;
    [self checkForCollision];
    if([CCDirector sharedDirector].totalFrames % 60 == 0)
    {
        score += 1;
    }
    [scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
    
    //pause or restart
    if(pauseButton.active)
    {
        CCLOG(@"pause!!");
        [self stopAndShowMessage:@"Paused!" withLevel:@"Touch to continue"];
    }
    if(restartButton.active)
    {
        CCLOG(@"restart!!");
        isCollision = true;
        isRestart = true;
        [self stopAndShowMessage:@"Stoped!" withLevel:@"Touch to restart"];
    }
}

-(void) onEnter
{
    [super onEnter];
    // forbid screen to close
	[self setScreenSaverEnabled:NO];
    
    cmManager = [[CMMotionManager alloc]init];
    if (!cmManager.accelerometerAvailable) {
        NSLog(@"CMMotionManager unavailable");
    }
    cmManager.accelerometerUpdateInterval = 0.1f;
    [cmManager startAccelerometerUpdates];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateAcceleration:) userInfo:nil repeats:YES];
    [timer fire];
}

-(void)updateAcceleration:(id)userInfo
{
    CMAccelerometerData *accelData = cmManager.accelerometerData;
    double x = accelData.acceleration.x;
    double y = accelData.acceleration.y + 0.5;
    
    printf("x = %f\n", x);
    printf("y = %f\n", y);
    
    
//    double z = accelData.acceleration.z;
    
    //control the change rate of the speed（lower = quicker to change direction）
    float deceleration = 0.3f;
    //sensitivity（higher = more sensitive）
    float sensitivity = 14.0f;
    //highest speed
    float maxVelocity = 200;
    
    playerVelocity.x = playerVelocity.x * deceleration + x * sensitivity;
    playerVelocity.y = playerVelocity.y * deceleration + y * sensitivity;
    
    if(playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if(playerVelocity.x < 0 - maxVelocity)
    {
        playerVelocity.x = 0 - maxVelocity;
    }
    
    if(playerVelocity.y > maxVelocity)
    {
        playerVelocity.y = maxVelocity;
    }
    else if(playerVelocity.y < 0 - maxVelocity)
    {
        playerVelocity.y = 0 - maxVelocity;
    }
}

-(void) initbullets
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    //temporary sprite used to get the size
    CCSprite *tempbullet = [CCSprite spriteWithFile:@"bullet.png"];
    
    //get the width of the sprite
    float imageWidth = tempbullet.texture.contentSize.width;
    
    //calculate how many sprite is needed
    int numbullets = screenSize.width / imageWidth;
    
    //allocate sprites
    bullets = [NSMutableArray arrayWithCapacity:numbullets];
    for(int i=0; i<numbullets; i++)
    {
        CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
        //add sprite to current layer
        [self addChild:bullet z:0 tag:2];
        
        //add the sprite to the array
        [bullets addObject:bullet];
    }
    
    //reset sprite
    [self resetbullets];
}

-(void) resetbullets
{
    CGSize screenSize =[CCDirector sharedDirector].winSize;
    
    //get an arbitery sprite to get the size
    CCSprite *tempbullet =[bullets lastObject];
    CGSize size = tempbullet.texture.contentSize;
    int numbullets = [bullets count];
    
    for(int i=0; i<numbullets; i++)
    {
        //place the sprite to the position outside the screen
        CCSprite *bullet = [bullets objectAtIndex:i];
        bullet.position = CGPointMake(size.width * i + size.width * 0.5f, screenSize.height + size.height);
        
        [bullet stopAllActions];
    }
    
    //call bulletUpdate every 0.7 seconds
    [self schedule:@selector(bulletsUpdate:) interval:(0.7f/level)];
    
    //reset the counter for the moving sprite
    numbulletMoved = 0;
}

-(void) bulletsUpdate:(ccTime)delta
{
    if(score == 15 && level == 1)  //level-2
    {
        bulletMoveDuration = 2.0f;
        level++;
        [self stopAndShowMessage:@"Win!" withLevel:@"Touch to play Level-2"];
    }
    else if(score == 30 && level == 2) //level-3
    {
        bulletMoveDuration = 1.5f;
        level++;
        [self stopAndShowMessage:@"Win!" withLevel:@"Touch to play Level-3"];
    }
    else if(score == 45 && level == 3) //level-4
    {
        bulletMoveDuration = 4.0f;
        level++;
        [self stopAndShowMessage:@"Win!" withLevel:@"Touch to play Level-4"];
    }
    else if(score == 60 && level == 4) //level-5
    {
        bulletMoveDuration = 2.0f;
        level++;
        [self stopAndShowMessage:@"Win!" withLevel:@"Touch to play Level-5"];
    }
    //get an arbitery still sprite
    for(int i=0; i<10; i++)
    {
        int randombulletIndex = CCRANDOM_0_1() * bullets.count;
        CCSprite *bullet = [bullets objectAtIndex:randombulletIndex];
        
        //judge whether it is still
        if(bullet.numberOfRunningActions == 0)
        {
            //move the sprite
            [self runbulletMoveSequence:bullet];
            break;
        }
    }

}

-(void) runbulletMoveSequence:(CCSprite *)bullet
{
    // the count increase for the moving sprite
    numbulletMoved++;
    
    // move to the position that below the screen
    CGPoint belowScreenPosition = CGPointMake(bullet.position.x, -bullet.texture.contentSize.height);
    // MoveTo action
    CCMoveTo *move = [CCMoveTo actionWithDuration:bulletMoveDuration position:belowScreenPosition];
    // CallBlock action
    CCCallBlock *callDidDrop = [CCCallBlock actionWithBlock:^void(){
        CGPoint pos = bullet.position;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        pos.y = screenSize.height + bullet.texture.contentSize.height;
        bullet.position = pos;
    }];
    
    CCSequence *sequence = [CCSequence actions:move, callDidDrop, nil];
    [bullet runAction:sequence];
}

-(void) checkForCollision
{
    // assume all sprites are square
    float playerImageSize = player.texture.contentSize.width;
    CCSprite *bullet = [bullets lastObject];
    float bulletImageSize = bullet.texture.contentSize.width;
    float playerCollisionRadius = playerImageSize * 0.4f;
    float bulletCollisionRadius = bulletImageSize * 0.4f;
    
    // This collision distance will roughly equal the image shapes
    float maxCollisionDistance = playerCollisionRadius + bulletCollisionRadius;
    
    int numbullets = bullets.count;
    isCollision = false;
    for(int i=0; i<numbullets; i++)
    {
        bullet = [bullets objectAtIndex:i];
        
        if(bullet.numberOfRunningActions == 0)
        {
            // if the sprite is still, continue
            continue;
        }
        
        //cacl the distance between player and other bsprites
        float actualDistance = ccpDistance(player.position, bullet.position);
        
        //crash detect
        if(actualDistance < maxCollisionDistance)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
            
            isCollision = true;            
            
            //game over if HP is 0
            if(HealthPoint == 0)
            {
                isRestart = true;
                bulletMoveDuration = 4.0f;
                [self stopAndShowMessage:@"CrazySpace!" withLevel:@"Touch to play Level-1"];
            }
            else
            {
                HealthPoint--;
                [self stopAndShowMessage:@"You died!" withLevel:@"Touch to continue!"];
            }
            break;
        }
    }
}

-(void) resetGame
{
    // forbid the screen to be closed
	[self setScreenSaverEnabled:NO];
    self.touchEnabled = NO;
    
    level = 1;
    
    // remove game over label & touch to continue label
    [self removeChildByTag:100 cleanup:YES];
    [self removeChildByTag:101 cleanup:YES];
    for(int i=0; i<HealthPoint+1; i++)
    {
        [self removeChildByTag:4+i cleanup:YES];
    }
    [self resetbullets];
    [self scheduleUpdate];
    score = 0;
    [scoreLabel setString:@"0"];
}

-(void) pauseGame
{
    // forbid the screen to be closed
	[self setScreenSaverEnabled:NO];
    self.touchEnabled = NO;
    
    // remove game over label & touch to continue label
	[self removeChildByTag:100 cleanup:YES];
	[self removeChildByTag:101 cleanup:YES];
    for(int i=0; i<HealthPoint+1; i++)
    {
        [self removeChildByTag:4+i cleanup:YES];
    }
    
    [self resetbullets];
    [self scheduleUpdate];
}

#pragma mark Reset Game
// forbid the screen to be closed
-(void) setScreenSaverEnabled:(bool)enabled
{
#if KK_PLATFORM_IOS
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
#endif
}

-(void) runbulletWiggleSequence:(CCSprite*)bullet
{
	// Do something icky with the bullets ...
	CCScaleTo* scaleUp = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:1.05f];
	CCEaseBackInOut* easeUp = [CCEaseBackInOut actionWithAction:scaleUp];
	CCScaleTo* scaleDown = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:0.95f];
	CCEaseBackInOut* easeDown = [CCEaseBackInOut actionWithAction:scaleDown];
	CCSequence* scaleSequence = [CCSequence actions:easeUp, easeDown, nil];
	CCRepeatForever* repeatScale = [CCRepeatForever actionWithAction:scaleSequence];
	[bullet runAction:repeatScale];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isCollision && isRestart)
    {
        [self resetGame];
        isRestart = false;
        HealthPoint = 3;
    }
    else
    {
        [self pauseGame];
    }
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    for(int i=0; i<HealthPoint; i++)
    {
        CCSprite *planet = [CCSprite spriteWithFile:@"planet.png"];
        CGSize size = planet.texture.contentSize;
        planet.position = CGPointMake(screenSize.width - size.width * 0.5f - size.width * i * 1.2f, screenSize.height - size.height);
        
        //add sprite to current layer
        [self addChild:planet z:0 tag:4+i];
    }
}

-(void) stopAndShowMessage:(NSString *)message withLevel:(NSString *)level
{
    // Re-enable screensaver, to prevent battery drain in case the user puts the device aside without turning it off.
	[self setScreenSaverEnabled:YES];
    self.touchEnabled = YES;
	
	// have everything stop
	for (CCNode* node in self.children)
	{
		[node stopAllActions];
	}
	
	// I do want the bullets to keep wiggling so I simply restart this here
	for (CCSprite* bullet in bullets)
	{
		[self runbulletWiggleSequence:bullet];
	}
	
	// stop the scheduled selectors
	[self unscheduleAllSelectors];
	
	// add the labels shown during game over
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCLabelTTF* gameOver = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:60];
	gameOver.position = CGPointMake(screenSize.width / 2, screenSize.height / 3);
	[self addChild:gameOver z:100 tag:100];
	
	// game over label runs 3 different actions at the same time to create the combined effect
	// 1) color tinting
	CCTintTo* tint1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:0];
	CCTintTo* tint2 = [CCTintTo actionWithDuration:2 red:255 green:255 blue:0];
	CCTintTo* tint3 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:0];
	CCTintTo* tint4 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:255];
	CCTintTo* tint5 = [CCTintTo actionWithDuration:2 red:0 green:0 blue:255];
	CCTintTo* tint6 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	CCSequence* tintSequence = [CCSequence actions:tint1, tint2, tint3, tint4, tint5, tint6, nil];
	CCRepeatForever* repeatTint = [CCRepeatForever actionWithAction:tintSequence];
	[gameOver runAction:repeatTint];
	
	// 2) rotation with ease
	CCRotateTo* rotate1 = [CCRotateTo actionWithDuration:2 angle:3];
	CCEaseBounceInOut* bounce1 = [CCEaseBounceInOut actionWithAction:rotate1];
	CCRotateTo* rotate2 = [CCRotateTo actionWithDuration:2 angle:-3];
	CCEaseBounceInOut* bounce2 = [CCEaseBounceInOut actionWithAction:rotate2];
	CCSequence* rotateSequence = [CCSequence actions:bounce1, bounce2, nil];
	CCRepeatForever* repeatBounce = [CCRepeatForever actionWithAction:rotateSequence];
	[gameOver runAction:repeatBounce];
	
	// 3) jumping
	CCJumpBy* jump = [CCJumpBy actionWithDuration:3 position:CGPointZero height:screenSize.height / 3 jumps:1];
	CCRepeatForever* repeatJump = [CCRepeatForever actionWithAction:jump];
	[gameOver runAction:repeatJump];
	
	// touch to continue label
	CCLabelTTF* touch = [CCLabelTTF labelWithString:level fontName:@"Arial" fontSize:24];
	touch.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
	[self addChild:touch z:100 tag:101];
	
	// did you try turning it off and on again?
	CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
	CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
	[touch runAction:repeatBlink];
}

@end

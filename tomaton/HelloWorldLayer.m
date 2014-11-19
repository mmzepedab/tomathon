//
//  HelloWorldLayer.m
//  tomaton
//
//  Created by Mario Zepeda on 11/12/14.
//  Copyright mmzepedab 2014. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "SimpleAudioEngine.h"
#import "CDAudioManager.h"
#import "CocosDenshion.h"

#import "IntroLayer.h"


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer ()
{
    BOOL tomatoMoving;
    NSMutableArray *_tomatoes;
    int _tag;
    
    //Basket
    CCSprite *_basket;
    ccColor3B _oldBasketColor;
    CGPoint po;
    CGFloat poMinX;
    CGFloat poMaxX;
    
    //HUD
    int _score;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_scoreLabelStroke;
    int _livesLeft;
    CCLabelTTF *_livesLeftLabel;
    CCMenu *_pauseMenu;
    
    BOOL _isGameActive;
    BOOL _isGamePaused;
    
    //TERMOMETER
    CCSprite *_termometerLine;
    
    //COMBO
    int _comboPoints;
    BOOL _isComboActive;
    CCSprite *_windmill;
    CDLongAudioSource *rightChannel;
}

//@property (nonatomic, strong) CCSprite *tomato;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) CCAction *moveAction;

@end


// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
        //Configure Game

        self.touchEnabled = TRUE;
        _tomatoes = [[NSMutableArray alloc]init];
        _score = 0;
        _livesLeft = 3;
        _isGameActive = true;
        _isGamePaused = FALSE;
        
        _isComboActive = FALSE;
        _comboPoints = 0;
        
        [self schedule:@selector(gameLogic:) interval:1];
        [self schedule:@selector(update:)];
        [self addBackground];
        [self addHUD];
        [self addBasket];
        [[CDAudioManager sharedManager] setMode:kAMM_MediaPlayback];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgMusic.mp3"];
        
        rightChannel = [[CDAudioManager sharedManager] audioSourceForChannel:kASC_Right];
        [rightChannel load:@"comboBGMusic.mp3"];
    }
	return self;
}


- (void)update:(ccTime)dt {
    if (_isGameActive) {
    
        if(!_isGamePaused){
            for (int i=0;i<[_tomatoes count]; i++) {
                CCSprite *tomato = [_tomatoes objectAtIndex:i];
                int tomateTag = tomato.tag;
                CGRect tempBoundingBox = CGRectInset(_basket.boundingBox, _basket.boundingBox.size.width / 3, _basket.boundingBox.size.height / 2);
                if (CGRectIntersectsRect(tempBoundingBox, tomato.boundingBox)) {
                    int points;
                    if(tomateTag == 1){
                        points = 1;
                    }else if(tomateTag == 2){
                        points = 3;
                    }

                    
                    [tomato removeFromParentAndCleanup:YES];
                    [tomato stopAllActions];
                    [_tomatoes removeObjectAtIndex:i];
                    [self onScore:points];
                }
            }
        }
        
    }else{
            [self unschedule:@selector(update:)];
    }
    
}

-(void)addHUD{
    
    NSLog(@"WTF");
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    message = [NSString stringWithFormat:@"%d",_score];
    
    //CCLabel* myLabel = [CCLabel labelWithString:@"Some Text" fontName:@"M04_FATAL FURY" fontSize:18];

    _scoreLabel = [CCLabelTTF labelWithString:message fontName:@"M04_FATAL FURY" fontSize:30];
    _scoreLabelStroke = [CCLabelTTF labelWithString:message fontName:@"M04_FATAL FURY BLACK" fontSize:30];
    _scoreLabel.position = ccp(winSize.width / 2,winSize.height - _scoreLabel.contentSize.height );
    _scoreLabelStroke.position = _scoreLabel.position;
    //_scoreLabel.color = ccc3(0, 0, 0);
    //_scoreLabelStroke.color = ccc3(255, 255, 255);
    [_scoreLabel enableStrokeWithColor:ccc3(255, 255, 255) size:0.001f updateImage:YES];
    //[_scoreLabelStroke enableStrokeWithColor:ccc3(0, 0, 0) size:0.001f updateImage:YES];

    
    NSString *livesLeftText;
    livesLeftText = [NSString stringWithFormat:@"%d",_livesLeft];
    _livesLeftLabel = [CCLabelTTF labelWithString:livesLeftText fontName:@"M04_FATAL FURY BLACK" fontSize:20];
    _livesLeftLabel.position = ccp( _livesLeftLabel.contentSize.width + 25, winSize.height - _livesLeftLabel.contentSize.height - 5 );
    
    CCSprite *heart = [CCSprite spriteWithFile:@"heart.png"];
    heart.position = _livesLeftLabel.position;
    
    //[CCMenuItemFont setFontName:@"M04_FATAL FURY BLACK"];
    //[CCMenuItemFont setFontSize:20];
    CCMenuItemFont *pause = [CCMenuItemFont itemWithString:@"||"
                            target:self
                          selector:@selector(onPausePressed)];
    pause.color = ccWHITE;
    
    
    CCMenuItemImage *pauseButton = [CCMenuItemImage itemWithNormalImage:@"pauseButton.png" selectedImage:@"pauseButton.png" target:self selector:@selector(onPausePressed)];


    _pauseMenu = [CCMenu menuWithItems: pauseButton,  nil];
    _pauseMenu.position = ccp(winSize.width - pause.contentSize.width / 2 - 25, winSize.height - pause.contentSize.height / 2 - 5);
    [self addChild: _pauseMenu];
    
    [self addChild:_scoreLabel];
    [self addChild:_scoreLabelStroke];
    [self addChild:heart];
    [self addChild:_livesLeftLabel];
    
    
    //ADD TERMOMETER
    CCSprite *termometerBack = [CCSprite spriteWithFile:@"termometerBack.png"];
    termometerBack.position = ccp(_pauseMenu.position.x ,  _pauseMenu.position.y - termometerBack.contentSize.height);
    [self addChild:termometerBack];
    
    CGSize lineSize = CGSizeMake(8, 0);// IT TAKES 120 to fill the termometer
    _termometerLine = [self blankSpriteWithSize:lineSize];
    _termometerLine.anchorPoint = ccp(0.5f, 0.0f);
    _termometerLine.position = ccp(termometerBack.position.x, termometerBack.position.y - termometerBack.contentSize.height / 2  + 49);
    _termometerLine.color = ccc3(192, 35, 9);
    //_termometerLine.color = ccBLACK;
    [self addChild:_termometerLine];
    
    CCSprite *termometerFront = [CCSprite spriteWithFile:@"termometerFront.png"];
    termometerFront.position = termometerBack.position;
    [self addChild:termometerFront];
    
    CCSprite *feverText = [CCSprite spriteWithFile:@"feverText.png"];
    feverText.position = ccp(termometerBack.position.x - feverText.contentSize.width / 2 ,  termometerBack.position.y + 20);
    [self addChild:feverText];
    //END ADD TERMOMETER
    

}

- (CCSprite*)blankSpriteWithSize:(CGSize)size
{
    CCSprite *sprite = [CCSprite node];
    GLubyte *buffer = malloc(sizeof(GLubyte)*4);
    for (int i=0;i<4;i++) {buffer[i]=255;}
    CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:size];
    [sprite setTexture:tex];
    [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
    free(buffer);
    return sprite;
}

-(void)onPausePressed{
    //_termometerLine.scaleY =  400 / _termometerLine.contentSize.height ;
    
    NSLog(@"paused");
    if(_isGamePaused){
        _isGamePaused = FALSE;
        [[CCDirector sharedDirector] resume];
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    }else{
        _isGamePaused = TRUE;
        [[CCDirector sharedDirector] pause];
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
    
}

-(void)addBasket{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    //BASKET
    _basket = [[CCSprite alloc] initWithFile:@"basket.png"];
    _basket.position = ccp(winSize.width / 2, _basket.contentSize.height / 2);
    [self addChild:_basket];
    
    _oldBasketColor = _basket.color;
    
    po = ccp(-999, -999);
    poMinX = _basket.boundingBox.size.width * 0.5;
    poMaxX = winSize.width - _basket.boundingBox.size.width * 0.5;
}

-(void)addBackground{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
    bg.position = ccp(winSize.width / 2, winSize.height / 2);
    [self addChild:bg z:-2];
    
    

    
    //int interval = (arc4random() % 5);
}

-(void)updateLives{
    if (_isComboActive) {
        return;
    }
    
    _livesLeft--;
    if (_livesLeft <= 0 && _isGameActive) {
        _livesLeft = 0;
        //[[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
        
        [self gameOver];
        
    }
    
    
    if (_livesLeft < 0){
        _livesLeft = 0;
    }
    [_livesLeftLabel setString:[NSString stringWithFormat:@"%d",_livesLeft]];
    

}

-(void)gameOver{
    _isGameActive = FALSE;
    
    [self removeChild:_pauseMenu cleanup:YES];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [self unschedule:@selector(gameLogic:)];
    [self unschedule:@selector(update:)];
    
    
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCMenuItemImage *startButton = [CCMenuItemImage itemWithNormalImage:@"playButton.png" selectedImage:@"playButton.png" target:self selector:@selector(startGame:)];
    CCMenuItemImage *exitButton = [CCMenuItemImage itemWithNormalImage:@"exitButton.png" selectedImage:@"exitButton.png" target:self selector:@selector(exitGame:)];
    
    startButton.position = ccp(startButton.contentSize.width / 2 + 10,0);
    exitButton.position = ccp(- exitButton.contentSize.width / 2 - 10,0);
    
    CCMenu *menu = [CCMenu menuWithItems: startButton, exitButton, nil];
    [self addChild: menu];
    
    CCSprite *gameOverSprite = [CCSprite spriteWithFile:@"gameOver.png"];
    gameOverSprite.position = ccp(winSize.width / 2, menu.position.y + gameOverSprite.contentSize.height /2 + startButton.contentSize.height / 2 + 10);
    [self addChild:gameOverSprite];
    
    
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];

    if (highScore) {
        if (highScore < _score) {
            highScore = _score;
            [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"HighScore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        highScore = _score;
        [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"HighScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    

    
    NSString *message;
    message = [NSString stringWithFormat:@"Score %d",_score];
    
    CCLabelTTF *myScore = [CCLabelTTF labelWithString:message fontName:@"M04_FATAL FURY" fontSize:30];
    CCLabelTTF *myScoreStroke = [CCLabelTTF labelWithString:message fontName:@"M04_FATAL FURY BLACK" fontSize:30];
    myScore.position = ccp(winSize.width / 2, winSize.height/2 - myScore.contentSize.height / 2 - startButton.contentSize.height / 2 - 10 );
    myScoreStroke.position = myScore.position;
    [myScore enableStrokeWithColor:ccc3(0, 0, 0) size:0.001f updateImage:YES];
    [self addChild:myScore];
    [self addChild:myScoreStroke];
    
    NSString *messageHighScore;
    messageHighScore = [NSString stringWithFormat:@"Best  %d",highScore];
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:messageHighScore fontName:@"M04_FATAL FURY" fontSize:30];
    CCLabelTTF *highScoreStrokeLabel = [CCLabelTTF labelWithString:messageHighScore fontName:@"M04_FATAL FURY BLACK" fontSize:30];
    highScoreLabel.position = ccp(winSize.width / 2, myScore.position.y - myScore.contentSize.height / 2 - highScoreLabel.contentSize.height / 2 - 10 );
    highScoreStrokeLabel.position = highScoreLabel.position;
    highScoreStrokeLabel.color = ccc3(255, 255, 0);
    [highScoreLabel enableStrokeWithColor:ccc3(0, 0, 0) size:0.001f updateImage:YES];
    [self addChild:highScoreLabel];
    [self addChild:highScoreStrokeLabel];
    
    
    NSLog(@"GameOver");
    
    //ADD TO TOTAL TOMATOES
    NSInteger oldTomatoes = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalTomatoes"];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"totalTomatoes"];
    //[[NSUserDefaults standardUserDefaults] synchronize];

    
    NSInteger newTomatoes = oldTomatoes + _score;
    [[NSUserDefaults standardUserDefaults] setInteger:newTomatoes forKey:@"totalTomatoes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //return;

}


- (void) startGame: (id) sender
{
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"menuClick.mp3"];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void) exitGame: (id) sender
{
    
    NSString *description = [NSString stringWithFormat:@"He logrado conseguir %d tomates. Este es mi nuevo Record puedes superarlo?.",_score];
    
    //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Tomathon NUEVO RECORD", @"name",
                                   @"TOMATHON", @"caption",
                                   description, @"description",
                                   @"the-tomathon.appspot.com", @"link",
                                   @"http://the-tomathon.appspot.com/images/highScore.png", @"picture",
                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error.description);
                              }
                          }];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"menuClick.mp3"];
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}

-(void)onScore:(int)points{
    NSLog(@"Score");
    _basket.rotation = 0;
    id rotateleft = [CCRotateBy actionWithDuration:0.1 angle:-10];
    id rotateright = [CCRotateBy actionWithDuration:0.1 angle:10];
    CCSequence *spawnAction = [CCSequence actions:
                                 [CCTintTo actionWithDuration:0.1 red:255.0f green:255.0f blue:0.0f],
                               
                                  rotateleft,
                                  rotateright,
                                 nil];
    
    CCSpawn *sequenceAction = [CCSequence actions:
                               [CCTintTo actionWithDuration:0.1 red:_oldBasketColor.r green:_oldBasketColor.g blue:_oldBasketColor.b],
                               nil];
    
    [_basket runAction:[CCSequence actions: spawnAction, sequenceAction, nil]];
    
    
    
    [self updateScoreBy:points];
    [self popScore: _basket.position By:points];
    
    if (_comboPoints >= 19) {
        _comboPoints = 0;
        _isComboActive = TRUE;
        [self activateCombo];
    }
    
    if(points == 1){
        if (!_isComboActive) {
            _comboPoints = _comboPoints + 1;
            [_termometerLine setTextureRect:CGRectMake(0, 0, _termometerLine.contentSize.width, _termometerLine.contentSize.height + 6)];
        }
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3"];
    }else if (points == 3){
        if (!_isComboActive) {
            _comboPoints = _comboPoints + 3;
            [_termometerLine setTextureRect:CGRectMake(0, 0, _termometerLine.contentSize.width, _termometerLine.contentSize.height + 18)];
        }
        [[SimpleAudioEngine sharedEngine] playEffect:@"goldenClick.wav"];
    }
    
    
}

-(void)activateCombo{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    //[[SimpleAudioEngine sharedEngine] playEffect:@"comboBGMusic.mp3"];
    [rightChannel play];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"comboBGMusic.mp3"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _windmill = [CCSprite spriteWithFile:@"bonusBG.png"];
    _windmill.position = CGPointMake(winSize.width / 2, winSize.height /2);
    //windmill.scale = 0.55f;
    [self addChild:_windmill z:-1];
    [_windmill runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5.0 angle:360]]];
    
    
    //float delay = 1.0; // Number of seconds between each call of myTimedMethod:
    //[[CCTimer alloc] initWithTarget:self selector:@selector(stopCombo) interval:delay];
    [self unschedule:@selector(gameLogic:)];
    [self schedule:@selector(gameLogic:) interval:0.1f];
    
    [self schedule:@selector(stopCombo) interval:10.0f];
}

-(void)stopCombo{
    
    //[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [rightChannel stop];
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    [self unschedule:@selector(stopCombo)];
    [self unschedule:@selector(gameLogic:)];
    [self schedule:@selector(gameLogic:) interval:1.0f];
    [self removeChild:_windmill cleanup:YES];
    [_termometerLine setTextureRect:CGRectMake(0, 0, _termometerLine.contentSize.width, 0)];
    
    [self schedule:@selector(stopComboDelay) interval:4.0f];
    
}

-(void)stopComboDelay{
    _isComboActive = false;
    [self unschedule:@selector(stopComboDelay)];
}


-(void)popScore: (CGPoint)position By: (int)points{
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    
    CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"plus%d.png", points]];
    sprite.position = position;
    
    [self addChild:sprite];
    
    id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(sprite.position.x, winSize.height / 2)];
    id scaleAction = [CCScaleTo actionWithDuration:1 scaleX:3.0f scaleY:3.0f];
    id fadeAction = [CCFadeTo actionWithDuration:1 opacity:0];
    CCCallBlockN * actionsDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    CCSpawn *spawnAction = [CCSpawn actions: moveAction,scaleAction, fadeAction, nil];
    
    
    [sprite runAction:[CCSequence actions:spawnAction, actionsDone, nil]];

}

-(void)updateScoreBy: (int)points {
    _score = _score + points;
    [_scoreLabel setString:[NSString stringWithFormat:@"%d",_score]];
    [_scoreLabelStroke setString:[NSString stringWithFormat:@"%d",_score]];

}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isGameActive) {
        UITouch *touch = [touches anyObject];
        CGPoint poNow = [touch locationInView:[touch view]];
        poNow = [[CCDirector sharedDirector] convertToGL:poNow];
        
        if (CGRectContainsPoint(_basket.boundingBox, poNow))
        {
            printf("*** ccTouchesBegan (x:%f, y:%f)\n", poNow.x, poNow.y);
            po = poNow;
        }
    }
   
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isGameActive) {
        UITouch *touch = [touches anyObject];
        CGPoint poNow = [touch locationInView:[touch view]];
        poNow = [[CCDirector sharedDirector] convertToGL:poNow];
        
        if (po.x >= 0)
        {
            CGFloat x = _basket.position.x + poNow.x - po.x;
            
            if (x < poMinX) x = poMinX;
            if (x > poMaxX) x = poMaxX;
            
            _basket.position = ccp(x, _basket.position.y);
            po = poNow;
            
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (po.x >= 0)
    {
        printf("ccTouchesEnded:\n\n");
        po = ccp(-999, -999);
    }
}


- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    
    NSLog([NSString stringWithFormat:@"Cuenta: %d", [_tomatoes count]]);

    for (int i=0;i<[_tomatoes count]; i++) {
        CCSprite *tomato = [_tomatoes objectAtIndex:i];
        if (CGRectContainsPoint( tomato.boundingBox     , touchLocation)) {
            NSLog(@"Tocado");
            
            [tomato removeFromParentAndCleanup:YES];
            [_tomatoes removeObject:tomato];
            i--;
        }
    }
    
}

-(void)gameLogic:(ccTime)dt {
    if(!_isGamePaused){
        int lowerBound = 0;
        int upperBound = 10;
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        
        if (rndValue == 1) {
            [self addGoldenTomato];
        }else{
            [self addTomato];
        }
    }
    
}


-(void)addGoldenTomato{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    CCSprite *tomato = [CCSprite spriteWithFile:@"goldTomatoe.png"];
    int minX = tomato.contentSize.width / 2;
    int maxX = winSize.width - tomato.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    tomato.position = ccp(actualX, winSize.height + tomato.contentSize.height / 2);
    
    
    tomato.tag = 2;
    [_tomatoes addObject:tomato];
    [self addChild:tomato];
    
    // Determine speed of the tomato
    int minDuration = 1.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, tomato.contentSize.height / 2)];
    id ease = [CCEaseIn actionWithAction:actionMove rate:2];
    id loseLife = [CCCallFuncND actionWithTarget:self selector:@selector(addSplashTomatoWith:data:) data:actualX];
    id rotateAction = [CCRotateBy actionWithDuration:actualDuration angle:90];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    
    id spawAction = [CCSpawn actions:actionMove, rotateAction, ease, nil]; //[aSprite runAction:spawAction];
    //[_tomato runAction:spawAction];
    //[_tomato runAction:[CCSequence actions:actionMove, rotateAction, actionMoveDone, action3, nil]];
    [tomato runAction:[CCSequence actions: spawAction, actionMoveDone, loseLife, nil]];
    
}

-(void)addTomato{
    
    
    //NSLog(rndValue);
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    //CREATE SPRITESHEET
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimTomato.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimTomato.png"];
    [self addChild:spriteSheet];
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=2; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"tomato%d.png",i]]];
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.50f];
    CCSprite *tomato;
    tomato = [CCSprite spriteWithSpriteFrameName:@"tomato1.png"];
    
    int minX = tomato.contentSize.width / 2;
    int maxX = winSize.width - tomato.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    tomato.position = ccp(actualX, winSize.height + tomato.contentSize.height / 2);
    self.walkAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:walkAnim]];
    [tomato runAction:self.walkAction];
    
    tomato.tag = 1;
    [_tomatoes addObject:tomato];
    [spriteSheet addChild:tomato];
    
    
    // Determine speed of the tomato
    int minDuration = 1.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, tomato.contentSize.height / 2)];
    id ease = [CCEaseIn actionWithAction:actionMove rate:2];
    id loseLife = [CCCallFuncND actionWithTarget:self selector:@selector(addSplashTomatoWith:data:) data:actualX];
    id rotateAction = [CCRotateBy actionWithDuration:actualDuration angle:90];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    
    id spawAction = [CCSpawn actions:actionMove, rotateAction, ease, nil]; //[aSprite runAction:spawAction];
    //[_tomato runAction:spawAction];
    //[_tomato runAction:[CCSequence actions:actionMove, rotateAction, actionMoveDone, action3, nil]];
    [tomato runAction:[CCSequence actions: spawAction, actionMoveDone, loseLife, nil]];
    
    //_tag = _tag + 1;
}

-(void)addSplashTomatoWith:(id)sender data:(void *)data{
    //NSLog(@"Test");

    if (!_isComboActive) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        _comboPoints = 0;
        [_termometerLine setTextureRect:CGRectMake(0, 0, _termometerLine.contentSize.width, 0)];
    }
    
    
    if(_livesLeft < 1 && _isGameActive){
        [self gameOver];
    }
    
    [self updateLives];
    
    //PLAY SPLASH EFFECT
    [[SimpleAudioEngine sharedEngine] playEffect:@"splash.mp3"];
    
    
    int actualX = data;
   /*
    CCSprite *splashTomato =  [CCSprite spriteWithFile:@"splashTomato.png"];
    splashTomato.position = ccp(actualX, splashTomato.contentSize.height / 2);
    [self addChild:splashTomato];
    */
    
    
    CCSprite *splashTomato;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimSplash.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimSplash.png"];
    [self addChild:spriteSheet];
    NSMutableArray *splashAnimFrames = [NSMutableArray array];
    for (int i=1; i<=3; i++) {
        [splashAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"splash%d.png",i]]];
    }
    CCAnimation *splashAnim =  [CCAnimation animationWithSpriteFrames:splashAnimFrames delay:0.01f];
    //CCAnimation *splashAnim =  [CCAnimation animationWithSpriteFrames:splashAnimFrames];
    
    splashTomato = [CCSprite spriteWithSpriteFrameName:@"splash1.png"];
    splashTomato.position = ccp(actualX, splashTomato.contentSize.height / 2);
    [splashTomato runAction:[CCAnimate actionWithAnimation:splashAnim]];
    [spriteSheet addChild:splashTomato];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [splashTomato removeFromParentAndCleanup:YES];
        }];
        
        id dissapearAction = [CCSequence actions:
                              [CCBlink actionWithDuration:1.0f blinks:4],
                              [CCFadeOut actionWithDuration:0.5],
                              actionMoveDone,
                              nil];
        [splashTomato runAction:dissapearAction];
        //[splashTomato removeFromParentAndCleanup:YES];
    });
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}



@end

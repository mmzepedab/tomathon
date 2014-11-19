//
//  HelloWorldLayer.h
//  tomaton
//
//  Created by Mario Zepeda on 11/12/14.
//  Copyright mmzepedab 2014. All rights reserved.
//


#import <GameKit/GameKit.h>

#import <FacebookSDK/FacebookSDK.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

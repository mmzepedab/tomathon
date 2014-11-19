//
//  IntroLayer.h
//  tomaton
//
//  Created by Mario Zepeda on 11/12/14.
//  Copyright mmzepedab 2014. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import <FacebookSDK/FacebookSDK.h>


// HelloWorldLayer
@interface IntroLayer : CCLayer <FBLoginViewDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property (strong, nonatomic) FBProfilePictureView *profilePictureView;


@end

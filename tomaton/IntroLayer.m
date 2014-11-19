//
//  IntroLayer.m
//  tomaton
//
//  Created by Mario Zepeda on 11/12/14.
//  Copyright mmzepedab 2014. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "HelloWorldLayer.h"

#import "HelloWorldLayer.h"

#import "SimpleAudioEngine.h"
#import "CDAudioManager.h"
#import "CocosDenshion.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer{
    FBLoginView *_loginView;
    
}

@synthesize profilePictureView;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {

        

        
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        //_loginView = [[FBLoginView alloc] init];
        _loginView =
        [[FBLoginView alloc] initWithReadPermissions:
         @[@"public_profile", @"email", @"user_friends", @"publish_actions"]];
        
        
        _loginView.frame =  CGRectMake(size.width / 2, size.height / 2, 200.0f, 50.0f);
        _loginView.layer.anchorPoint = CGPointMake(1, 1);
        _loginView.delegate = self;
        
        [[[CCDirector sharedDirector] view]addSubview:_loginView];
        
        
        //profilePictureView = [FBProfilePictureView alloc]ini FBProfilePictureView
        
        [self addBackground];
        
        NSInteger totalTomatoes = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalTomatoes"];
        
        if (!totalTomatoes) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"totalTomatoes"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            totalTomatoes = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalTomatoes"];
        }
        
        
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencySymbol:@""];
        [numberFormatter setMaximumFractionDigits:0];
        NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInt: totalTomatoes]];
        
		CCLabelTTF *title = [CCLabelTTF labelWithString:numberAsString fontName:@"M04_FATAL FURY" fontSize:30];
        CCLabelTTF *myScoreStroke = [CCLabelTTF labelWithString:numberAsString fontName:@"M04_FATAL FURY BLACK" fontSize:30];
        title.position =  ccp(size.width / 2 , size.height / 2  - 150 - title.contentSize.height / 2);
        myScoreStroke.position = title.position;
        [title enableStrokeWithColor:ccc3(0, 0, 0) size:0.001f updateImage:YES];
        [self addChild: title];
        [self addChild:myScoreStroke];
        
        CCMenuItemImage *startButton = [CCMenuItemImage itemWithNormalImage:@"playButton.png" selectedImage:@"playButton.png" target:self selector:@selector(startGame:)];
        
        
        //[startButton setAnchorPoint:ccp(2,2)];
        //[startButton2 setAnchorPoint:ccp(2,2)];
        
        CCMenu *menu = [CCMenu menuWithItems: startButton, nil];
        menu.position = ccp(size.width/2, _loginView.layer.position.y + startButton.contentSize.height / 2 + 10);
        [self addChild: menu];
        
        
        CCSprite *tomathonLogo = [CCSprite spriteWithFile:@"tomathonLogo.png"];
        tomathonLogo.position = ccp(size.width/ 2, size.height - tomathonLogo.contentSize.height / 2 - 10);
        [self addChild:tomathonLogo];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"splash.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"click.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"goldenClick.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"menuClick.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"comboBGMusic.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bgMusic.mp3"];
        //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"comboBGMusic.mp3"];

		// add the label as a child to this Layer
		//[self addChild: background];
	}
	
	return self;
}

-(void)addBackground{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *bg = [CCSprite spriteWithFile:@"menuBG.png"];
    bg.position = ccp(winSize.width / 2, winSize.height / 2);
    [self addChild:bg];
    
    //int interval = (arc4random() % 5);
}

-(void) onEnter
{
	[super onEnter];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] ]];
}

- (void) startGame: (id) sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"menuClick.mp3"];
    
    [_loginView removeFromSuperview];
    
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    CGSize size = [[CCDirector sharedDirector] winSize];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.id]   ];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *newImage = [self roundCorneredImage:image radius:image.size.height /2 ];
    CCTexture2D *texture = [[CCTexture2D  alloc] initWithCGImage:newImage.CGImage resolutionType:kCCResolutioniPhone5 ];
    
    CCSprite *imagen = [CCSprite spriteWithTexture:texture];
    imagen.position = ccp(size.width/2, size.height/2 - 90);
    imagen.scale = 0.4f;
    
    [self addChild:imagen];
    
    
    //self.nameLabel.text = user.name;
    NSLog(@"Si entro papi");
}

- (UIImage*) roundCorneredImage: (UIImage*) orig radius:(CGFloat) r {
    UIGraphicsBeginImageContextWithOptions(orig.size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, orig.size}
                                cornerRadius:r] addClip];
    [orig drawInRect:(CGRect){CGPointZero, orig.size}];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
@end

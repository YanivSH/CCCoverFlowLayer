//
//  HelloWorldLayer.m
//  CCCoverFlowLayer
//
//  Created by Yaniv Marshaly on 7/28/13.
//  Copyright Sketch Heroes LTD. 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCCoverFlowLayer.h"
#import "CCCircularSelector.h"

#import "CCCoverFlowSprite.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer () <CCCoverFlowLayerDelegate,CCCoverFlowLayerDataSource>

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
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
        NSMutableArray * items = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            [items addObject:[CCSprite spriteWithFile:@"Icon.png"]];
        }
        //CCCircularSelector * layer = [[CCCircularSelector alloc]initWithChoices:items];
        
        CCCoverFlowLayer * coverlayer = [[CCCoverFlowLayer alloc]init];
        
        coverlayer.dataSource = self;
        coverlayer.delegate = self;
        
		//layer.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        
        coverlayer.position = ccp(0, 0);
        coverlayer.anchorPoint = ccp(0, 0);
		// add the Layer as a child to this Layer
	//	[self addChild: layer];
        [self addChild: coverlayer];
		

	}
	return self;
}

// on "dealloc" you need to release all your retained objects

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
#pragma mark -CCCoverFlowLayerDataSource
-(NSUInteger)numberOfItems:(CCCoverFlowLayer *)layer
{
    return 1;
}
-(CCNode*)coverFlow:(CCCoverFlowLayer *)layer nodeForItemAtIndex:(NSUInteger)index
{
    
    CCCoverFlowSprite * sprite = (CCCoverFlowSprite *)[layer reuseSpriteForIndex:index];
    if (sprite == nil) {
        sprite = [[CCCoverFlowSprite alloc]initWithFile:@"Icon.png"];
    }
    return sprite;
}
#pragma mark - CCCoverFlowLayerDelegate
-(void)coverFlow:(CCCoverFlowLayer *)layer didSelectItemAtIndex:(NSUInteger)index
{
    
}
@end

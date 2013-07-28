//
//  CCCoverFlowLayer.h
//  CCCoverFlowLayer
//
//  Created by Yaniv Marshaly on 7/28/13.
//  Copyright (c) 2013 Sketch Heroes LTD. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"


@class CCCoverFlowLayer;

@protocol CCCoverFlowLayerDataSource <NSObject>

@required

-(NSUInteger)numberOfItems:(CCCoverFlowLayer*)layer;

-(CCSprite*)coverFlow:(CCCoverFlowLayer*)layer nodeForItemAtIndex:(NSUInteger)index;

@end

@protocol CCCoverFlowLayerDelegate <NSObject>

@optional
-(void)coverFlow:(CCCoverFlowLayer*)layer didSelectItemAtIndex:(NSUInteger)index;

@end


@interface CCCoverFlowLayer : CCLayerColor
{

@private
    // Current state support
	double _offset;
	
	NSTimer *_timer;
	double _startTime;
	double _startOff;
	double _startPos;
	double _startSpeed;
	double _runDelta;
	BOOL _touchFlag;
	CGPoint _startTouch;
	
	double _lastPos;

}

@property (weak,nonatomic) id<CCCoverFlowLayerDataSource> dataSource;

@property (weak,nonatomic) id<CCCoverFlowLayerDelegate> delegate;


-(CCSprite*)reuseSpriteForIndex:(NSUInteger)index;

-(void)reloadData;

@end

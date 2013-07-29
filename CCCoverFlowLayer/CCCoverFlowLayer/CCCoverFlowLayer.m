//
//  CCCoverFlowLayer.m
//  CCCoverFlowLayer
//
//  Created by Yaniv Marshaly on 7/28/13.
//  Copyright (c) 2013 Sketch Heroes LTD. All rights reserved.
//


#define TEXTURESIZE			256		// width and height of texture; power of 2, 256 max
#define MAXTILES			48		// maximum allocated 256x256 tiles in cache
#define VISTILES			6		// # tiles left and right of center tile visible on screen

/*
 *	Parameters to tweak layout and animation behaviors
 */

#define SPREADIMAGE			0.1		// spread between images (screen measured from -1 to 1)
#define FLANKSPREAD			0.4		// flank spread out; this is how much an image moves way from center
#define FRICTION			10.0	// friction
#define MAXSPEED			10.0	// throttle speed to this value

#import "CCCoverFlowLayer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CCCoverFlowLayer.h"
@implementation CCCoverFlowLayer{
    
    CCRenderTexture * _renderTexure;
    
    NSDictionary * _reusableNodes;
    
    BOOL _shouldDraw;
    
    float x ;
}

-(id)initWithColor:(ccColor4B)color
{
    self = [super initWithColor:color];
    if (self) {
        [self commonInit];
    }
    return self;
}
-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h
{
    self = [super initWithColor:color width:w height:h];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark -
-(void)commonInit
{
    self.touchEnabled = YES;
    _offset = 0;
    
    x = 0;
//    _renderTexure = [[CCRenderTexture alloc]initWithWidth:self.contentSize.width height:self.contentSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
//    _renderTexure.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
//    _renderTexure.anchorPoint = ccp(0, 0);
//    
//    [self addChild:_renderTexure];
    
    [self unscheduleAllSelectors];
    [self scheduleUpdate];
    
    
}

-(NSUInteger)numberOfNodes
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItems:)]) {
        return [self.dataSource numberOfItems:self];
    }
    return 0;
}
-(CCSprite*)getNodeAtIndex:(NSUInteger)index
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(coverFlow:nodeForItemAtIndex:)]) {
        
        
        CCSprite * node = [self.dataSource coverFlow:self nodeForItemAtIndex:index];
        
        if (![self.children containsObject:node]) {
            [self addChild:node z:1 tag:index];


        }
        
        return node;
    }
    return nil;
}
#pragma mark -
-(void)reloadData
{
   
}
-(CCSprite*)reuseSpriteForIndex:(NSUInteger)index
{
    return (CCSprite*)[self getChildByTag:index];
}
#pragma mark -
-(void)onEnter
{
    [super onEnter];
    [self drawOnDemand];

    [[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
    
//    CCSprite * node = [self getNodeAtIndex:0];
//    node.scale = 5.0f;
//    [node runAction:[CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:-70 angleX:0 deltaAngleX:0]];

}
-(void)onExit
{
    [[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
    [super onExit];
}

#pragma mark -
-(void)draw
{
   
}
-(void)update:(ccTime)delta
{
   
}
#pragma mark -
-(void)drawOnDemand
{
    int i,len = [self numberOfNodes];
	int mid = (int)floor(_offset + 0.5);
	int iStartPos = mid - VISTILES;
	if (iStartPos<0) {
		iStartPos=0;
	}
	for (i = iStartPos; i < mid; ++i) {
        [self drawNodeAtIndex:i andOffset:i-_offset];

        
	}
	
	int iEndPos=mid + VISTILES;
	if (iEndPos >= len) {
		iEndPos = len-1;
	}
	for (i = iEndPos; i >= mid; --i) {
        [self drawNodeAtIndex:i andOffset:i-_offset];
	}
}
-(void)drawNodeAtIndex:(NSUInteger)index andOffset:(NSInteger)offset
{
    CCSprite * node = [self getNodeAtIndex:index];

    GLfloat m[16];
	memset(m,0,sizeof(m));
	m[10] = 1;
	m[15] = 1;
	m[0] = 1;
	m[5] = 1;
	double trans = offset * SPREADIMAGE;
	
	double f = offset * FLANKSPREAD;
	if (f < -FLANKSPREAD) {
		f = -FLANKSPREAD;
	} else if (f > FLANKSPREAD) {
		f = FLANKSPREAD;
	}
	m[3] = -f;
	m[0] = 1-fabs(f);
	double sc = 0.45 * (1 - fabs(f));
	trans += f * 1;
	CGPoint center =  ccp(self.contentSize.width/2,self.contentSize.height/2);
    center.x += trans * 100; 

    NSLog(@"trans = %lf sc = %lf",trans,sc);
   // [node.camera setCenterX:trans*100 centerY:0 centerZ:10];
    node.position = center;
    
}
#pragma mark - Animation
/************************************************************************/
/*																		*/
/*	Animation															*/
/*																		*/
/************************************************************************/

- (void)updateAnimationAtTime:(double)elapsed
{
	int max = [self numberOfNodes] - 1;
	
	if (elapsed > _runDelta) elapsed = _runDelta;
	double delta = fabs(_startSpeed) * elapsed - FRICTION * elapsed * elapsed / 2;
	if (_startSpeed < 0) delta = -delta;
	_offset = _startOff + delta;
	
	if (_offset > max) _offset = max;
	if (_offset < 0) _offset = 0;
	
	[self drawOnDemand];
}

- (void)endAnimation
{
	if (_timer) {
		int max = [self numberOfNodes] - 1;
		_offset = floor(_offset + 0.5);
		if (_offset > max) _offset = max;
		if (_offset < 0) _offset = 0;
		[self draw];
		
		[_timer invalidate];
		_timer = nil;
	}
}

- (void)driveAnimation
{
	double elapsed = CACurrentMediaTime() - _startTime;
	if (elapsed >= _runDelta) {
		[self endAnimation];
	} else {
		[self updateAnimationAtTime:elapsed];
	}
}

- (void)startAnimation:(double)speed
{
	if (_timer) [self endAnimation];
	
	
	
	NSLog(@"speed: %lf",speed);
	double delta = speed * speed / (FRICTION * 2);
	if (speed < 0) delta = -delta;
	double nearest = _startOff + delta;
	nearest = floor(nearest + 0.5);
	_startSpeed = sqrt(fabs(nearest - _startOff) * FRICTION * 2);
	if (nearest < _startOff) _startSpeed = -_startSpeed;
	
	_runDelta = fabs(_startSpeed / FRICTION);
	_startTime = CACurrentMediaTime();
	
	NSLog(@"startSpeed: %lf",_startSpeed);
	NSLog(@"runDelta: %lf",_runDelta);
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                             target:self
                                           selector:@selector(driveAnimation)
                                           userInfo:nil
                                            repeats:YES];
}
#pragma mark - touches
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *t = [touches anyObject];
	CGPoint where = [[CCDirector sharedDirector] convertToGL:[t locationInView:t.view]];
	_startPos = (where.x / self.contentSize.width) * 10 - 5;
	_startOff = _offset;
	
	_touchFlag = YES;
	_startTouch = where;
	
	_startTime = CACurrentMediaTime();
	_lastPos = _startPos;

   // [self endAnimation];
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *t = [touches anyObject];
	CGPoint where = [[CCDirector sharedDirector] convertToGL:[t locationInView:t.view]];
	double pos = (where.x / self.contentSize.width) * 10 - 5;
    
	if (_touchFlag) {
		// determine if the user is dragging or not
		int dx = fabs(where.x - _startTouch.x);
		int dy = fabs(where.y - _startTouch.y);
		if ((dx < 3) && (dy < 3)) return;
		_touchFlag = NO;
	}
	
	int max = [self numberOfNodes]-1;
	
	_offset = _startOff + (_startPos - pos);
	if (_offset > max) _offset = max;
	if (_offset < 0) _offset = 0;
	//[self drawOnDemand];
	
	double time = CACurrentMediaTime();
	if (time - _startTime > 0.2) {
		_startTime = time;
		_lastPos = pos;
	}

    CCSprite * node = [self getNodeAtIndex:0];
    
    
    for( UITouch *touch in touches ) {
        CGPoint touchLocation = [touch locationInView: [touch view]];
        CGPoint prevLocation = [touch previousLocationInView: [touch view]];
        
        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
        
        CGPoint diff = ccpSub(touchLocation,prevLocation);
       // [node setPosition: ccpAdd(node.position, diff)];
        
        // Get the camera's current values.
        float centerX, centerY, centerZ;
        float eyeX, eyeY, eyeZ;
        [node.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
        [node.camera eyeX:&eyeX eyeY:&eyeY eyeZ:&eyeZ];
        
        // Increment panning value based on current zoom factor.
        diff.x = 2 * diff.x * (1+(eyeZ/832));
        diff.y = 2 * diff.y * (1+(eyeZ/832));
        
        // Round values to avoid subpixeling.
        int newX = centerX-round(diff.x);
        int newY = centerY-round(diff.y);

        float angle = CC_RADIANS_TO_DEGREES(atan2(node.position.y - touchLocation.y, node.position.x - touchLocation.x));
        
        angle += 90;
        angle *= -1;
        
       
        if (fabs(angle) > 70) {
            return;
        }
        // NSLog(@"%f",angle);
//
       // [node setScaleX:angle];
        // Set values.
        //[node.camera setCenterX:angle centerY:0 centerZ:10];
        
        [node.camera setEyeX:angle eyeY:0 eyeZ:10];
    }
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *t = [touches anyObject];
	CGPoint where = [[CCDirector sharedDirector] convertToGL:[t locationInView:t.view]];
	double pos = (where.x / self.contentSize.width) * 10 - 5;
	
	if (_touchFlag == YES) {
//		// Touched location; only accept on touching inner 256x256 area
//		r.origin.x += (r.size.width - 256)/2;
//		r.origin.y += (r.size.height - 256)/2;
//		r.size.width = 256;
//		r.size.height = 256;
//		
//		if (CGRectContainsPoint(r, where)) {
//			[self touchAtIndex:(int)floor(offset + 0.01)];	// make sure .99 is 1
//		}
	} else {
		// Start animation to nearest
		_startOff += (_startPos - pos);
		_offset = _startOff;

		double time = CACurrentMediaTime();
		double speed = (_lastPos - pos)/(time - _startTime);
        NSLog(@"speed = %f",speed);
		if (speed > MAXSPEED) speed = MAXSPEED;
		if (speed < -MAXSPEED) speed = -MAXSPEED;
		
       		//[self startAnimation:speed];
	}

}
-(void)touchMoved
{
    
}


@end

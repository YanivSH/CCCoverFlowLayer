//
//  CCCoverFlowSprite.m
//  CCCoverFlowLayer
//
//  Created by Yaniv Marshaly on 7/28/13.
//  Copyright (c) 2013 Sketch Heroes LTD. All rights reserved.
//

#import "CCCoverFlowSprite.h"

@implementation CCCoverFlowSprite


-(id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if (self) {
        
    }
    return self;
}

- (CGAffineTransform)nodeToParentTransform
{
    if ( _isTransformDirty ) {
        // Translate values
        float x = _position.x;
        float y = _position.y;
        
        if ( _ignoreAnchorPointForPosition ) {
            x += _anchorPointInPoints.x;
            y += _anchorPointInPoints.y;
        }
        
        _transform = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(_skewY)),
                                           tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1.0f,
                                           x, y );
        // Rotation values
        float c = 1, s = 0;
        if( self.rotation ) {
            float radians = -CC_DEGREES_TO_RADIANS(self.rotation);
            c = cosf(radians);
            s = sinf(radians);
        }
        
        CGAffineTransform rotMatrix = CGAffineTransformMake( c * _scaleX,  s * _scaleX,
                                                            -s * _scaleY, c * _scaleY,
                                                            0.0f, 0.0f );
        _transform = CGAffineTransformConcat(rotMatrix, _transform);
        
        // adjust anchor point
        if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
            _transform = CGAffineTransformTranslate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y);
        
        _isTransformDirty = NO;
    }
    return _transform;
}
@end

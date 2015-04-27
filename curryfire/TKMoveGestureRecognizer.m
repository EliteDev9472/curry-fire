//
//  TKMoveViewGestureRecognizer.m
//  Created by Devin Ross on 4/16/15.
//
/*
 
 curryfire || https://github.com/devinross/curry-fire
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKMoveGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "ShortHand.h"

@interface TKMoveGestureRecognizer ()

@property (nonatomic,assign) BOOL moving;
@property (nonatomic,assign) CGPoint startPoint;

@end

@implementation TKMoveGestureRecognizer

#pragma mark Init & Friends
+ (instancetype) gestureWithDirection:(TKMoveGestureDirection)direction movableView:(UIView*)movableView{
    return [[TKMoveGestureRecognizer alloc] initWithDirection:direction movableView:movableView];
}
+ (instancetype) gestureWithDirection:(TKMoveGestureDirection)direction movableView:(UIView*)movableView locations:(NSArray*)locations{
    return [[TKMoveGestureRecognizer alloc] initWithDirection:direction movableView:movableView locations:locations];
}
+ (instancetype) gestureWithDirection:(TKMoveGestureDirection)direction movableView:(UIView *)movableView locations:(NSArray*)locations moveHandler:(void (^)(TKMoveGestureRecognizer *gesture, CGPoint position,CGPoint location ))block{
    return [[TKMoveGestureRecognizer alloc] initWithDirection:direction movableView:movableView locations:locations moveHandler:block];
}

- (instancetype) initWithDirection:(TKMoveGestureDirection)direction movableView:(UIView*)movableView{
    self = [self initWithDirection:direction movableView:movableView locations:nil moveHandler:nil];
    return self;
}
- (instancetype) initWithDirection:(TKMoveGestureDirection)direction movableView:(UIView *)movableView locations:(NSArray*)locations{
    self = [self initWithDirection:direction movableView:movableView locations:locations moveHandler:nil];
    return self;
}
- (instancetype) initWithTarget:(id)target action:(SEL)action{
    if(!(self=[super initWithTarget:target action:action])) return nil;
    
    _direction = TKMoveGestureDirectionXY;
    [self addTarget:self action:@selector(pan:)];
    self.velocityDamping = 20;
    
    return self;
}
- (instancetype) initWithDirection:(TKMoveGestureDirection)direction movableView:(UIView *)movableView locations:(NSArray*)locations moveHandler:(void (^)(TKMoveGestureRecognizer *gesture, CGPoint position, CGPoint location ))block{
    self = [self initWithTarget:nil action:nil];
    
    _direction = direction;
    self.locations = locations;
    self.moveHandler = block;
    self.movableView = movableView;
    
    return self;
    
}



- (CGPoint) closestPointToLocation:(CGPoint)projectedPoint currentPoint:(CGPoint)currentPoint{
    
    CGFloat minDistance = 100000000;
    CGPoint retPoint = CGPointZero;
    
    if(self.direction == TKMoveGestureDirectionXY){
        for(NSValue *endValue in self.locations){
            CGPoint locationPoint = [endValue CGPointValue];
            CGFloat dis = CGPointGetDistance(projectedPoint, locationPoint);
            if(dis < minDistance){
                retPoint = locationPoint;
                minDistance = dis;
            }
        }
        return retPoint;
    }

    
    if(self.direction == TKMoveGestureDirectionY){
        for(NSNumber *number in self.locations){
            CGPoint locationPoint = CGPointMake(currentPoint.x, number.doubleValue);
            CGFloat dis = CGPointGetDistance(projectedPoint, locationPoint);
            if(dis < minDistance){
                retPoint = locationPoint;
                minDistance = dis;
            }
        }
        return retPoint;
    }

    

    for(NSNumber *number in self.locations){
        CGPoint locationPoint = CGPointMake(number.doubleValue,currentPoint.y);
        CGFloat dis = CGPointGetDistance(projectedPoint, locationPoint);
        if(dis < minDistance){
            retPoint = locationPoint;
            minDistance = dis;
        }
    }
    return retPoint;
    
    
}

- (void) pan:(UIPanGestureRecognizer*)gesture{
    
    CGPoint velocity = [self velocityInView:self.view];
    UIView *panView = self.movableView;
    if(self.state == UIGestureRecognizerStateBegan){
        self.startPoint = panView.center;
        [panView.layer pop_removeAnimationForKey:@"pop"];
    }
    
    CGPoint p = self.startPoint;
    
    if(self.direction == TKMoveGestureDirectionXY || self.direction == TKMoveGestureDirectionX)
        p.x += [self translationInView:self.view].x;
    if(self.direction == TKMoveGestureDirectionXY || self.direction == TKMoveGestureDirectionY)
        p.y += [self translationInView:self.view].y;

    
    CGPoint blockPoint = p;
    
    if(self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged){
        
        panView.center = p;

        
    }else if(self.state == UIGestureRecognizerStateEnded || self.state == UIGestureRecognizerStateCancelled){
        


        CGFloat projectedX = p.x + velocity.x / self.velocityDamping;
        CGFloat projectedY = p.y + velocity.y / self.velocityDamping;
        CGPoint projectedPoint = CGPointMake(projectedX, projectedY);
        


        
        blockPoint = [self closestPointToLocation:projectedPoint currentPoint:p];
        
        
        if(self.direction == TKMoveGestureDirectionX){
            self.snapBackAnimation.fromValue = @(p.x);
            self.snapBackAnimation.toValue = @(blockPoint.x);
            self.snapBackAnimation.velocity = @(velocity.x);
        }else if(self.direction == TKMoveGestureDirectionY){
            self.snapBackAnimation.fromValue = @(p.y);
            self.snapBackAnimation.toValue = @(blockPoint.y);
            self.snapBackAnimation.velocity = @(velocity.y);
        }else{
            self.snapBackAnimation.fromValue = NSCGPoint(p);
            self.snapBackAnimation.toValue = NSCGPoint(blockPoint);
            self.snapBackAnimation.velocity = NSCGPoint(velocity);
        }
        

        [panView.layer pop_addAnimation:self.snapBackAnimation forKey:@"pop"];
        
    }
    
    CGPoint minPoint = [self minimumLocation];
    CGPoint maxPoint = [self maximumLocation];
    CGPoint perc = CGPointMake((p.x - minPoint.x) / (maxPoint.x - minPoint.x), (p.y - minPoint.y) / (maxPoint.y - minPoint.y));
    
    if(self.moveHandler)
        self.moveHandler(self,perc,blockPoint);
    

}

- (CGPoint) minimumLocation{
    
    if(self.direction == TKMoveGestureDirectionX){
        
        return CGPointMake([[self.locations valueForKeyPath:@"@min.self"] doubleValue], self.movableView.center.y);

    }else if(self.direction == TKMoveGestureDirectionY){
        
        return CGPointMake(self.movableView.center.y, [[self.locations valueForKeyPath:@"@min.self"] doubleValue]);


    }
    
    
    NSArray *sortedArray = [self.locations sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGPoint p1 = [obj1 CGPointValue];
        CGPoint p2 = [obj2 CGPointValue];
        if (p1.x == p2.x) return p1.y < p2.y;
        return p1.x < p2.x;
    }];
    
    return [sortedArray.firstObject CGPointValue];
        

    
    
}
- (CGPoint) maximumLocation{
    
    
    
    if(self.direction == TKMoveGestureDirectionX){
        
        return CGPointMake([[self.locations valueForKeyPath:@"@max.self"] doubleValue], self.movableView.center.y);
        
    }else if(self.direction == TKMoveGestureDirectionY){
        
        return CGPointMake(self.movableView.center.y, [[self.locations valueForKeyPath:@"@max.self"] doubleValue]);
        
        
    }
    
    
    NSArray *sortedArray = [self.locations sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGPoint p1 = [obj1 CGPointValue];
        CGPoint p2 = [obj2 CGPointValue];
        if (p1.x == p2.x) return p1.y < p2.y;
        return p1.x < p2.x;
    }];
    
    return [sortedArray.lastObject CGPointValue];
    
}

- (void) moveToPoint:(CGPoint)point{
    
    UIView *panView = self.movableView;
    CGPoint blockPoint = panView.center;
    
    if(self.direction == TKMoveGestureDirectionXY || self.direction == TKMoveGestureDirectionX)
        blockPoint.x = point.x;
    if(self.direction == TKMoveGestureDirectionXY || self.direction == TKMoveGestureDirectionY)
        blockPoint.y = point.y;
    
    if(self.direction == TKMoveGestureDirectionX){
        self.snapBackAnimation.toValue = @(blockPoint.x);
    }else if(self.direction == TKMoveGestureDirectionY){
        self.snapBackAnimation.toValue = @(blockPoint.y);
    }else{
        self.snapBackAnimation.toValue = NSCGPoint(blockPoint);
    }
    
    [panView.layer pop_addAnimation:self.snapBackAnimation forKey:@"pop"];
    
    
    CGPoint minPoint = [self minimumLocation];
    CGPoint maxPoint = [self maximumLocation];
    CGPoint perc = CGPointMake((blockPoint.x - minPoint.x) / (maxPoint.x - minPoint.x), (blockPoint.y - minPoint.y) / (maxPoint.y - minPoint.y));
    
    if(self.moveHandler)
        self.moveHandler(nil,perc,blockPoint);

}


#pragma mark UITouchMoved
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if ([self state] == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
        self.moving = NO;
    }
    
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];

    if ([self state] == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
    } else {
        [self setState:UIGestureRecognizerStateChanged];
    }
    
    self.moving = YES;
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self setState:UIGestureRecognizerStateEnded];
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self setState:UIGestureRecognizerStateCancelled];
}


#pragma mark Properties
- (NSString*) popAnimationPropertyName{
    if(self.direction == TKMoveGestureDirectionX)
        return kPOPLayerPositionX;
    else if(self.direction == TKMoveGestureDirectionY)
        return kPOPLayerPositionY;
    return kPOPLayerPosition;
}
- (POPSpringAnimation*) snapBackAnimation{
    if(_snapBackAnimation) return _snapBackAnimation;
    _snapBackAnimation = [POPSpringAnimation animationWithPropertyNamed:self.popAnimationPropertyName];
    _snapBackAnimation.springBounciness = 1.5;
    _snapBackAnimation.springSpeed = 2;
    _snapBackAnimation.removedOnCompletion = NO;
    return _snapBackAnimation;
}

@end
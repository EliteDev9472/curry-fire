//
//  UIView+Material.m
//  Created by Devin Ross on 4/10/15.
//
/*
 
 curry || https://github.com/devinross/curry
 
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

#import "UIView+Material.h"
@import curry;

@implementation UIView (Material)

#pragma mark Material Like Animations
- (void) fireMaterialTouchDiskAtPoint:(CGPoint)point{
    
    UIView *disk = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    disk.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    disk.layer.cornerRadius = CGRectGetWidth(disk.frame)/2;
    disk.center = point;
    [self addSubview:disk];
    
    [UIView animateWithDuration:0.5 animations:^{
        disk.transform = CGAffineTransformMakeScale(10, 10);
        disk.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    } completion:^(BOOL finished) {
        
        [disk removeFromSuperview];
    }];
    
}
- (void) materialTransitionWithSubview:(UIView*)subview atPoint:(CGPoint)point changes:(void (^)(void))changes completion:(void (^)(BOOL finished))completion{
    [self materialTransitionWithSubview:subview expandCircle:YES atPoint:point duration:1 changes:changes completion:completion];
    return;
}
- (void) materialTransitionWithSubview:(UIView*)subview expandCircle:(BOOL)expandCircle atPoint:(CGPoint)point duration:(CFTimeInterval)duration changes:(void (^)(void))changes completion:(void (^)(BOOL finished))completion{
    
    UIImage *snapshotImage = [subview snapshotImageAfterScreenUpdates:NO];
    
    UIImageView *snapshotView = [[UIImageView alloc] initWithFrame:subview.frame];
    snapshotView.image = snapshotImage;
    [self addSubview:snapshotView];
    
    if(changes) changes();
    
    NSInteger size = 10;
    NSInteger expandScale = MAX(CGRectGetWidth(subview.frame),CGRectGetHeight(subview.frame)) / size;
    expandScale *= 2;
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [snapshotView removeFromSuperview];
            if(completion) completion(YES);
        }];
        
        CATransform3D endTransform = expandCircle ? CATransform3DMakeScale(expandScale, expandScale, 1) : CATransform3DIdentity;
        CATransform3D startTransform = expandCircle ? CATransform3DIdentity : CATransform3DMakeScale(expandScale, expandScale, 1);
        
        
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        shapeMask.frame = CGRectMake(point.x-size/2, point.y-size/2, size, size);
        shapeMask.fillColor = [UIColor redColor].CGColor;
        
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)];
        
        
        if(expandCircle)
            [path appendPath:[UIBezierPath bezierPathWithRect:CGRectInset(shapeMask.bounds, -500, -500)]];
        shapeMask.path = path.CGPath;
        snapshotView.layer.mask = shapeMask;
        shapeMask.fillRule = kCAFillRuleEvenOdd;
        
        shapeMask.transform = startTransform;
        
        
        CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"transform"];
        anime.fromValue = [NSValue valueWithCATransform3D:shapeMask.transform];
        anime.toValue = [NSValue valueWithCATransform3D:endTransform];
        anime.duration = duration;
        [shapeMask addAnimation:anime forKey:@"material"];
        shapeMask.transform = endTransform;
        
    } [CATransaction commit];
    
}


@end

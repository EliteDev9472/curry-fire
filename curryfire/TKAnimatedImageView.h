//
//  TKAnimatedImageView.h
//  Created by Devin Ross on 5/21/15.
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

@import UIKit;
@import curry;

/** `TKAnimatedImageView` is a reimplementation of UIImageView animated images with better access to the current frame in the animation sequence. */
@interface TKAnimatedImageView : UIImageView

- (void) playAnimationWithImages:(NSArray*)images duration:(NSTimeInterval)duration withCompletionBlock:(void (^)(BOOL finished))finished;

- (void) playAnimationWithImages:(NSArray*)images duration:(NSTimeInterval)duration repeatCount:(NSUInteger)repeatCount withCompletionBlock:(void (^)(BOOL finished))finished;

- (void) stopAnimating;

@property (nonatomic,readonly) UIImage *currentImage;
@property (nonatomic,readonly) NSInteger currentFrame;

@end

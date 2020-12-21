#import <UIKit/UIKit.h>

@interface UIView (Fade)
- (void)fadeInWithDuration:(double)duration;
- (void)fadeOutWithDuration:(double)duration;
@end

@interface PassthroughView : UIView
@end
#import "UIView+Extensions.h"

@implementation PassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    for (UIView *view in self.subviews) {
        if (!view.hidden && view.isUserInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }

    return NO;

}

@end

@implementation UIView (Fade)

- (void)fadeInWithDuration:(double)duration {
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    }];
}

- (void)fadeOutWithDuration:(double)duration {
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion: ^(BOOL finished) {
        self.hidden = finished;
    }];
}

@end
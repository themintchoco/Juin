#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaRemote/MediaRemote.h>
#import <CoreText/CoreText.h>
#import "MarqueeLabel.h"
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;

BOOL firstTimeLoaded = NO;
UIImageView* backgroundArtwork;
UIVisualEffectView* blurView;
UIBlurEffect* blur;
UIImage* currentArtwork;
UIView* juinView;
UIView* backgroundGradient;
UIButton* sourceButton;
UIButton* playPauseButton;
UIButton* rewindButton;
UIButton* skipButton;
UILabel* artistLabel;
UILabel* songLabel;
UIView* gestureView;
UITapGestureRecognizer* tap;
UISwipeGestureRecognizer* leftSwipe;
UISwipeGestureRecognizer* rightSwipe;

extern BOOL enabled;

// background
BOOL backgroundArtworkSwitch = YES;
BOOL addBlurSwitch = NO;
NSString* blurModeValue = @"2";
NSString* blurAmountValue = @"1.0";

// gestures
BOOL leftSwipeSwitch = YES;
BOOL rightSwipeSwitch = YES;

// miscellaneous
NSString* offsetValue = @"24";

@interface CSCoverSheetViewController : UIViewController
@end

@interface CSCoverSheetView : UIView
- (void)rewindSong;
- (void)skipSong;
- (void)pausePlaySong;
- (void)hideJuinView;
- (void)handleSwipe:(UISwipeGestureRecognizer *)sender;
@end

@interface MediaControlsTimeControl : UIControl
- (id)_viewControllerForAncestor;
@end

@interface MRPlatterViewController : UIViewController
@property(assign, nonatomic)id delegate;
@end

@interface CSMediaControlsViewController : UIViewController
@end

@interface CSAdjunctItemView : UIView
@end

@interface CSNotificationAdjunctListViewController : UIViewController
@end

@interface CSQuickActionsButton : UIControl
- (void)receiveFadeNotification:(NSNotification *)notification;
@end

@interface CSPageControl : UIPageControl
- (void)receiveFadeNotification:(NSNotification *)notification;
@end

@interface SBUILegibilityLabel : UILabel
@end

@interface SBUICallToActionLabel : UILabel
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (void)setNowPlayingInfo:(id)arg1;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)changeTrack:(int)arg1 eventSource:(long long)arg2;
- (BOOL)togglePlayPauseForEventSource:(long long)arg1;
@end
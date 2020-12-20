#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaRemote/MediaRemote.h>
#import <CoreText/CoreText.h>
#import "MarqueeLabel.h"

UIImageView* backgroundArtwork;
UIImage* currentArtwork;
UIView* juinView;
UIView* backgroundGradient;
UIButton* sourceButton;
UIButton* playPauseButton;
UIButton* rewindButton;
UIButton* skipButton;
UILabel* artistLabel;
UILabel* songLabel;

BOOL firstTimeLoaded = NO;

@interface CSCoverSheetViewController : UIViewController
@end

@interface CSCoverSheetView : UIView
- (void)rewindSong;
- (void)skipSong;
- (void)pausePlaySong;
- (void)hideJuinView;
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
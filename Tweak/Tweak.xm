#import "Juin.h"

BOOL enabled;

MediaControlsTimeControl* timeSlider;

%group Juin

%hook CSCoverSheetViewController

- (void)viewDidLoad { // add background artwork

	%orig;

	if (backgroundArtworkSwitch) {
		if (!backgroundArtwork) backgroundArtwork = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
		[backgroundArtwork setContentMode:UIViewContentModeScaleAspectFill];
		[backgroundArtwork setHidden:YES];
		[[self view] insertSubview:backgroundArtwork atIndex:0];

		if (addBlurSwitch && !blur) {
			if (!blur) {
				if ([blurModeValue intValue] == 0)
					blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
				else if ([blurModeValue intValue] == 1)
					blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
				else if ([blurModeValue intValue] == 2)
					blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
				blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
				[blurView setFrame:[backgroundArtwork bounds]];
				[blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
				[blurView setClipsToBounds:YES];
				[blurView setAlpha:[blurAmountValue doubleValue]];
				[backgroundArtwork addSubview:blurView];
			}
		}
	}

}

%end

%hook CSCoverSheetView

- (void)didMoveToWindow { // add juin

	%orig;

	if (firstTimeLoaded) return;
	firstTimeLoaded = YES;

	// load cirlularspui-book font
	NSData* inData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/PreferenceBundles/JuinPrefs.bundle/CircularSpUI-Book.otf"]];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);

	// load cirlularspui-bold font
	NSData* inData2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/PreferenceBundles/JuinPrefs.bundle/CircularSpUI-Bold.otf"]];
    CFErrorRef error2;
    CGDataProviderRef provider2 = CGDataProviderCreateWithCFData((CFDataRef)inData2);
    CGFontRef font2 = CGFontCreateWithDataProvider(provider2);
    if (!CTFontManagerRegisterGraphicsFont(font2, &error2)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error2);
        CFRelease(errorDescription);
    }
    CFRelease(font2);
    CFRelease(provider2);


	// juin view
	if (!juinView) juinView = [[UIView alloc] initWithFrame:[self bounds]];
	[juinView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[juinView setHidden:YES];
	[self addSubview:juinView];


	// gradient
	if (!backgroundGradient) backgroundGradient = [[UIView alloc] initWithFrame:[juinView bounds]];
	if (!gradient) gradient = [CAGradientLayer layer];
	[gradient setFrame:[backgroundGradient bounds]];
	[gradient setColors:@[(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor]]];
	[[backgroundGradient layer] insertSublayer:gradient atIndex:0];
	[juinView addSubview:backgroundGradient];


	// source button
	if (!sourceButton) sourceButton = [[UIButton alloc] init];
	[[sourceButton titleLabel] setFont:[UIFont fontWithName:@"CircularSpUI-Book" size:10]];
	[sourceButton setTintColor:[UIColor whiteColor]];
	[sourceButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	if (showDeviceNameSwitch) [sourceButton setTitle:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] name]] forState:UIControlStateNormal];
	else [sourceButton setTitle:@"" forState:UIControlStateNormal];

	[sourceButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sourceButton.widthAnchor constraintEqualToConstant:juinView.bounds.size.width].active = YES;
    [sourceButton.heightAnchor constraintEqualToConstant:24].active = YES;
    if (![sourceButton isDescendantOfView:juinView]) [juinView addSubview:sourceButton];
    [sourceButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [sourceButton.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-[offsetValue intValue]].active = YES;


	// play/pause button
	if (!playPauseButton) playPauseButton = [[UIButton alloc] init];
	[playPauseButton addTarget:self action:@selector(pausePlaySong) forControlEvents:UIControlEventTouchUpInside];
	[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/paused.png"] forState:UIControlStateNormal];

	[playPauseButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [playPauseButton.widthAnchor constraintEqualToConstant:72].active = YES;
    [playPauseButton.heightAnchor constraintEqualToConstant:72].active = YES;
    if (![playPauseButton isDescendantOfView:juinView]) [juinView addSubview:playPauseButton];
    [playPauseButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [playPauseButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;


	// rewind button
	if (!rewindButton) rewindButton = [[UIButton alloc] init];
	[rewindButton addTarget:self action:@selector(rewindSong) forControlEvents:UIControlEventTouchUpInside];
	[rewindButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/rewind.png"] forState:UIControlStateNormal];
	[rewindButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

	[rewindButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rewindButton.widthAnchor constraintEqualToConstant:34].active = YES;
    [rewindButton.heightAnchor constraintEqualToConstant:34].active = YES;
    if (![rewindButton isDescendantOfView:juinView]) [juinView addSubview:rewindButton];
    [rewindButton.centerXAnchor constraintEqualToAnchor:playPauseButton.leftAnchor constant:-60].active = YES;
    [rewindButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;


	// skip button
	if (!skipButton) skipButton = [[UIButton alloc] init];
	[skipButton addTarget:self action:@selector(skipSong) forControlEvents:UIControlEventTouchUpInside];
	[skipButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/skip.png"] forState:UIControlStateNormal];
	[skipButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

	[skipButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [skipButton.widthAnchor constraintEqualToConstant:34].active = YES;
    [skipButton.heightAnchor constraintEqualToConstant:34].active = YES;
    if (![skipButton isDescendantOfView:juinView]) [juinView addSubview:skipButton];
    [skipButton.centerXAnchor constraintEqualToAnchor:playPauseButton.rightAnchor constant:60].active = YES;
    [skipButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;


	// artist label
	if (!artistLabel) artistLabel = [[UILabel alloc] init];
	[artistLabel setText:@"Far Places"];
	[artistLabel setTextColor:[UIColor colorWithRed: 0.60 green: 0.60 blue: 0.60 alpha: 1.00]];
	[artistLabel setFont:[UIFont fontWithName:@"CircularSpUI-Bold" size:22]];
	[artistLabel setTextAlignment:NSTextAlignmentCenter];

	[artistLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [artistLabel.widthAnchor constraintEqualToConstant:279].active = YES;
    [artistLabel.heightAnchor constraintEqualToConstant:31].active = YES;
    if (![artistLabel isDescendantOfView:juinView]) [juinView addSubview:artistLabel];
    [artistLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [artistLabel.centerYAnchor constraintEqualToAnchor:playPauseButton.topAnchor constant:-60].active = YES;


	// song label
	if (!songLabel) songLabel = [[MarqueeLabel alloc] init];
	[songLabel setText:@"In My Head"];
	[songLabel setTextColor:[UIColor whiteColor]];
	[songLabel setFont:[UIFont fontWithName:@"CircularSpUI-Bold" size:36]];
	[songLabel setTextAlignment:NSTextAlignmentCenter];

	[songLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [songLabel.widthAnchor constraintEqualToConstant:279].active = YES;
    [songLabel.heightAnchor constraintEqualToConstant:51].active = YES;
    if (![songLabel isDescendantOfView:juinView]) [juinView addSubview:songLabel];
    [songLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [songLabel.centerYAnchor constraintEqualToAnchor:artistLabel.topAnchor constant:-24].active = YES;


	// gesture view
	if (!gestureView) gestureView = [[UIView alloc] initWithFrame:CGRectMake(juinView.bounds.origin.x, juinView.bounds.origin.y, juinView.bounds.size.width, juinView.bounds.size.height / 1.3 - [offsetValue intValue])];
	[gestureView setBackgroundColor:[UIColor clearColor]];
	[juinView addSubview:gestureView];

	
	// tap gesture
	if (!tap) tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideJuinView)];
	[tap setNumberOfTapsRequired:1];
	[tap setNumberOfTouchesRequired:1];
	[gestureView addGestureRecognizer:tap];


	// swipe gestures
	if (leftSwipeSwitch) {
		if (!leftSwipe) leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
		[leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
		[gestureView addGestureRecognizer:leftSwipe];
	}

	if (rightSwipeSwitch) {
		if (!rightSwipe) rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
		[rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
		[gestureView addGestureRecognizer:rightSwipe];
	}

}

- (void)layoutSubviews { // add time slider

	%orig;

	[timeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [timeSlider.widthAnchor constraintEqualToConstant:juinView.bounds.size.width -32].active = YES;
    [timeSlider.heightAnchor constraintEqualToConstant:49].active = YES;
    [juinView addSubview:timeSlider];
    [timeSlider.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [timeSlider.centerYAnchor constraintEqualToAnchor:playPauseButton.topAnchor constant:-24].active = YES;

}

%new
- (void)rewindSong { // rewind song

	[[%c(SBMediaController) sharedInstance] changeTrack:-1 eventSource:0];

}

%new
- (void)skipSong { // skip song

	[[%c(SBMediaController) sharedInstance] changeTrack:1 eventSource:0];

}

%new
- (void)pausePlaySong { // pause/play song

	[[%c(SBMediaController) sharedInstance] togglePlayPauseForEventSource:0];
	
	if ([[%c(SBMediaController) sharedInstance] isPlaying])
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/playing.png"] forState:UIControlStateNormal];
	else
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/paused.png"] forState:UIControlStateNormal];

}

%new
- (void)hideJuinView { // hide juin on tap

	if ([juinView isHidden]) return;
	if (![[%c(SBMediaController) sharedInstance] isPlaying] && ![[%c(SBMediaController) sharedInstance] isPaused]) return;

	[UIView transitionWithView:juinView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[juinView setHidden:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"juinUnhideElements" object:nil];
	} completion:nil];

}

%new
- (void)handleSwipe:(UISwipeGestureRecognizer *)sender { // rewind/skip song based on swipe direction

	if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
		[self skipSong];
	else if (sender.direction == UISwipeGestureRecognizerDirectionRight)
		[self rewindSong];

}

%end

%hook NCNotificationListView

- (void)touchesBegan:(id)arg1 withEvent:(id)arg2 { // unhide juin on tap

	%orig;

	if (![juinView isHidden]) return;
	if (![[%c(SBMediaController) sharedInstance] isPlaying] && ![[%c(SBMediaController) sharedInstance] isPaused]) return;

	[UIView transitionWithView:juinView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[juinView setHidden:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"juinHideElements" object:nil];
	} completion:nil];

}

%end

%hook MediaControlsTimeControl

- (void)layoutSubviews { // get a time slider instance

	%orig;

	MRPlatterViewController* controller = (MRPlatterViewController *)[self _viewControllerForAncestor];
  	if ([controller respondsToSelector:@selector(delegate)] && [[controller delegate] isKindOfClass:%c(CSMediaControlsViewController)])
    	timeSlider = self;

}

%end

%hook CSAdjunctItemView

- (void)_updateSizeToMimic { // hide original player

	%orig;

	[self.heightAnchor constraintEqualToConstant:0].active = true;
	[self setHidden:YES];

}

%end

%hook CSNotificationAdjunctListViewController

- (void)viewDidLoad { // make the time slider bright

	%orig;

    [self setOverrideUserInterfaceStyle:2];

}

%end

%end

%group JuinHiding

%hook CSQuickActionsButton

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveFadeNotification:(NSNotification *)notification { // hide or unhide quick action buttons

	if ([notification.name isEqual:@"juinHideElements"]) {
		[UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:0.0];
		} completion:nil];
	} else if ([notification.name isEqual:@"juinUnhideElements"]) {
		[UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:1.0];
		} completion:nil];
	}

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSTeachableMomentsContainerView

- (void)_layoutCallToActionLabel { // hide unlock text on homebar devices when playing
	
	%orig;

	SBUILegibilityLabel* label = MSHookIvar<SBUILegibilityLabel *>(self, "_callToActionLabel");

	if ([juinView isHidden]) {
		[label setHidden:NO];
		return;
	}

	[label setHidden:YES];	

}

%end

%hook SBUICallToActionLabel

- (void)didMoveToWindow { // hide unlock text on home button devices when playing

	%orig;

	if ([juinView isHidden]) {
		[self setHidden:NO];
		return;
	}

	[self setHidden:YES];

}

- (void)_updateLabelTextWithLanguage:(id)arg1 { // hide unlock text on home button devices when playing

	%orig;

	if ([juinView isHidden]) {
		[self setHidden:NO];
		return;
	}

	[self setHidden:YES];

}

%end

%end

%group JuinData

%hook SBMediaController

- (void)setNowPlayingInfo:(id)arg1 { // set now playing info

    %orig;

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        if (information) {
            NSDictionary* dict = (__bridge NSDictionary *)information;

            if (dict) {
				currentArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]]; // get artwork
				[songLabel setText:[NSString stringWithFormat:@"%@ ", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle]]]; // set song title
				[artistLabel setText:[NSString stringWithFormat:@"%@ ", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist]]]; // set artist name

				// set artwork
                if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
					[UIView transitionWithView:backgroundArtwork duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
						[backgroundArtwork setImage:currentArtwork];
					} completion:nil];
				}
				
				// unhide juin
				[backgroundArtwork setHidden:NO];
                [juinView setHidden:NO];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"juinHideElements" object:nil];
            }
        } else { // hide juin if not playing
			[backgroundArtwork setHidden:YES];
            [juinView setHidden:YES];

			[[NSNotificationCenter defaultCenter] postNotificationName:@"juinUnhideElements" object:nil];
        }
  	});
    
}

- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 { // get play/pause state change

    %orig;

	if ([self isPlaying])
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/playing.png"] forState:UIControlStateNormal];
	else
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/JuinPrefs.bundle/paused.png"] forState:UIControlStateNormal];

}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 { // reload data after a respring

    %orig;

    [[%c(SBMediaController) sharedInstance] setNowPlayingInfo:0];
    
}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.juinpreferences"];

	[preferences registerBool:&enabled default:nil forKey:@"Enabled"];

	// background artwork
	[preferences registerBool:&backgroundArtworkSwitch default:YES forKey:@"backgroundArtwork"];
	[preferences registerBool:&addBlurSwitch default:NO forKey:@"addBlur"];
	[preferences registerObject:&blurModeValue default:@"2" forKey:@"blurMode"];
	[preferences registerObject:&blurAmountValue default:@"1.0" forKey:@"blurAmount"];

	// gestures
	[preferences registerBool:&leftSwipeSwitch default:YES forKey:@"leftSwipe"];
	[preferences registerBool:&rightSwipeSwitch default:YES forKey:@"rightSwipe"];

	// miscellaneous
	[preferences registerObject:&offsetValue default:@"24" forKey:@"offset"];
	[preferences registerBool:&showDeviceNameSwitch default:YES forKey:@"showDeviceName"];
	
	if (enabled) {
		%init(Juin);
		%init(JuinData);
		%init(JuinHiding);
	}

}
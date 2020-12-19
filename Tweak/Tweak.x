#import "Juin.h"

MediaControlsTimeControl* timeSlider;

%group Juin

%hook CSCoverSheetViewController

- (void)viewDidLoad { // add background artwork

	%orig;

	if (!backgroundArtwork) {
		backgroundArtwork = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
		[backgroundArtwork setContentMode:UIViewContentModeScaleAspectFill];
		[backgroundArtwork setHidden:YES];
		[[self view] insertSubview:backgroundArtwork atIndex:0];
	}

}

%end

%hook CSCoverSheetView

- (void)didMoveToWindow { // add juin

	%orig;

	if (firstTimeLoaded) return;
	firstTimeLoaded = YES;

	// load cirlularspui-book font
	NSData* inData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Juin/CircularSpUI-Book.otf"]];
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
	NSData* inData2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Juin/CircularSpUI-Bold.otf"]];
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
	juinView = [[UIView alloc] initWithFrame:[self bounds]];
	[self addSubview:juinView];


	// gradient
	backgroundGradient = [[UIView alloc] initWithFrame:[juinView bounds]];
	CAGradientLayer* gradient = [CAGradientLayer layer];
	[gradient setFrame:[backgroundGradient bounds]];
	[gradient setColors:@[(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor]]];
	[backgroundGradient setHidden:YES];
	[[backgroundGradient layer] insertSublayer:gradient atIndex:0];
	[juinView addSubview:backgroundGradient];


	// source button
	sourceButton = [[UIButton alloc] init];
	[[sourceButton titleLabel] setFont:[UIFont fontWithName:@"CircularSpUI-Book" size:10]];
	[sourceButton setTintColor:[UIColor colorWithRed: 0.11 green: 0.73 blue: 0.33 alpha: 1.00]];
	[sourceButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	[sourceButton setTitle:[[NSString stringWithFormat:@"Aurora"] uppercaseString] forState:UIControlStateNormal];
	// [sourceButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/listeningOnAnotherDevice.png"] forState:UIControlStateNormal];
	[sourceButton setHidden:YES];

	[sourceButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sourceButton.widthAnchor constraintEqualToConstant:juinView.bounds.size.width].active = YES;
    [sourceButton.heightAnchor constraintEqualToConstant:24].active = YES;
    if (![sourceButton isDescendantOfView:juinView]) [juinView addSubview:sourceButton];
    [sourceButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [sourceButton.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-24].active = YES;


	// play/pause button
	playPauseButton = [[UIButton alloc] init];
	[playPauseButton addTarget:self action:@selector(pausePlaySong) forControlEvents:UIControlEventTouchDown];
	[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/paused.png"] forState:UIControlStateNormal];
	[playPauseButton setHidden:YES];

	[playPauseButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [playPauseButton.widthAnchor constraintEqualToConstant:72].active = YES;
    [playPauseButton.heightAnchor constraintEqualToConstant:72].active = YES;
    if (![playPauseButton isDescendantOfView:juinView]) [juinView addSubview:playPauseButton];
    [playPauseButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [playPauseButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;


	// rewind button
	rewindButton = [[UIButton alloc] init];
	[rewindButton addTarget:self action:@selector(rewindSong) forControlEvents:UIControlEventTouchDown];
	[rewindButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/rewind.png"] forState:UIControlStateNormal];
	[rewindButton setHidden:YES];

	[rewindButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rewindButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [rewindButton.heightAnchor constraintEqualToConstant:24].active = YES;
    if (![rewindButton isDescendantOfView:juinView]) [juinView addSubview:rewindButton];
    [rewindButton.centerXAnchor constraintEqualToAnchor:playPauseButton.leftAnchor constant:-60].active = YES;
    [rewindButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;


	// skip button
	skipButton = [[UIButton alloc] init];
	[skipButton addTarget:self action:@selector(skipSong) forControlEvents:UIControlEventTouchDown];
	[skipButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/skip.png"] forState:UIControlStateNormal];
	[skipButton setHidden:YES];

	[skipButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [skipButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [skipButton.heightAnchor constraintEqualToConstant:24].active = YES;
    if (![skipButton isDescendantOfView:juinView]) [juinView addSubview:skipButton];
    [skipButton.centerXAnchor constraintEqualToAnchor:playPauseButton.rightAnchor constant:60].active = YES;
    [skipButton.centerYAnchor constraintEqualToAnchor:sourceButton.topAnchor constant:-50].active = YES;

	// artist label
	artistLabel = [[UILabel alloc] init];
	[artistLabel setText:@"Far Places"];
	[artistLabel setTextColor:[UIColor colorWithRed: 0.60 green: 0.60 blue: 0.60 alpha: 1.00]];
	[artistLabel setFont:[UIFont fontWithName:@"CircularSpUI-Bold" size:22]];
	[artistLabel setTextAlignment:NSTextAlignmentCenter];
	[artistLabel setNumberOfLines:2];
	[artistLabel setHidden:YES];

	[artistLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [artistLabel.widthAnchor constraintEqualToConstant:279].active = YES;
    [artistLabel.heightAnchor constraintEqualToConstant:31].active = YES;
    if (![artistLabel isDescendantOfView:juinView]) [juinView addSubview:artistLabel];
    [artistLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [artistLabel.centerYAnchor constraintEqualToAnchor:playPauseButton.topAnchor constant:-60].active = YES;

	// song label
	songLabel = [[UILabel alloc] init];
	[songLabel setText:@"In My Head"];
	[songLabel setTextColor:[UIColor whiteColor]];
	[songLabel setFont:[UIFont fontWithName:@"CircularSpUI-Bold" size:36]];
	[songLabel setTextAlignment:NSTextAlignmentCenter];
	[songLabel setNumberOfLines:3];
	[songLabel setHidden:YES];

	[songLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [songLabel.widthAnchor constraintEqualToConstant:279].active = YES;
    [songLabel.heightAnchor constraintEqualToConstant:160].active = YES;
    if (![songLabel isDescendantOfView:juinView]) [juinView addSubview:songLabel];
    [songLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [songLabel.centerYAnchor constraintEqualToAnchor:artistLabel.topAnchor constant:-24].active = YES;

	
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideJuinView)];
	[tap setNumberOfTapsRequired:1];
	[tap setNumberOfTouchesRequired:1];

	[self addGestureRecognizer:tap];

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
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/playing.png"] forState:UIControlStateNormal];
	else
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/paused.png"] forState:UIControlStateNormal];

}

%new
- (void)hideJuinView {

	if (![juinView isHidden]) {
		[UIView transitionWithView:juinView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			[juinView setHidden:YES];
		} completion:^(BOOL finished) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"juinUnhideElements" object:nil];
		}];
	} else {
		[UIView transitionWithView:juinView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			[juinView setHidden:NO];
		} completion:^(BOOL finished) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"juinHideElements" object:nil];
		}];
	}

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
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:0.0];
		} completion:nil];
	} else if ([notification.name isEqual:@"juinUnhideElements"]) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:1.0];
		} completion:nil];
	}

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSHomeAffordanceView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveFadeNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"juinHideElements"]) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:0.0];
		} completion:nil];
	} else if ([notification.name isEqual:@"juinUnhideElements"]) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:1.0];
		} completion:nil];
	}

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSPageControl

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFadeNotification:) name:@"juinUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveFadeNotification:(NSNotification *)notification { // hide or unhide page dots

	if ([notification.name isEqual:@"juinHideElements"]) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:0.0];
		} completion:nil];
	} else if ([notification.name isEqual:@"juinUnhideElements"]) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setAlpha:1.0];
		} completion:nil];
	}

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

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

                if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) // set artwork
					[backgroundArtwork setImage:currentArtwork];
				
				// unhide elements
                [backgroundArtwork setHidden:NO];
				[backgroundGradient setHidden:NO];
				[sourceButton setHidden:NO];
				[playPauseButton setHidden:NO];
				[rewindButton setHidden:NO];
				[skipButton setHidden:NO];
				[artistLabel setHidden:NO];
				[songLabel setHidden:NO];
				[timeSlider setHidden:NO];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"juinHideElements" object:nil];
            }
        } else { // hide everything if not playing
            [backgroundArtwork setHidden:YES];
			[backgroundGradient setHidden:YES];
			[sourceButton setHidden:YES];
			[playPauseButton setHidden:YES];
			[rewindButton setHidden:YES];
			[skipButton setHidden:YES];
			[artistLabel setHidden:YES];
			[songLabel setHidden:YES];
			[timeSlider setHidden:YES];

			[[NSNotificationCenter defaultCenter] postNotificationName:@"juinUnhideElements" object:nil];
        }
  	});
    
}

- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 { // get play/pause event

    %orig;

	if ([self isPlaying])
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/playing.png"] forState:UIControlStateNormal];
	else
		[playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Juin/paused.png"] forState:UIControlStateNormal];

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

	%init(Juin);
	%init(JuinData);
	%init(JuinHiding);

}
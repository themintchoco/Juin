#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>

@interface JUNAppearanceSettings : HBAppearanceSettings
@end

@interface JUNContributorsSubPrefsListController : HBListController
@property(nonatomic, retain)UILabel* titleLabel;
@end
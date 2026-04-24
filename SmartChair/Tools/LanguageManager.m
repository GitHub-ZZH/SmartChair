//
//  LanguageManager.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/13.
//

#import "LanguageManager.h"

@implementation LanguageManager

+ (instancetype)shared {
    static LanguageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LanguageManager alloc] init];
    });
    return manager;
}

- (NSString *)getLanguage
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
    return language;
}

- (void)setLanguage:(NSString *)language {
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"appLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)localizedString:(NSString *)key {

    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];

    NSBundle *bundle = [NSBundle bundleWithPath:path];

    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

@end

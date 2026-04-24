//
//  LanguageManager.h
//  SmartChair
//
//  Created by 张志恒 on 2026/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define Localized(key) [[LanguageManager shared] localizedString:key]

@interface LanguageManager : NSObject

+ (instancetype)shared;
- (NSString *)getLanguage;
- (void)setLanguage:(NSString *)language;
- (NSString *)localizedString:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

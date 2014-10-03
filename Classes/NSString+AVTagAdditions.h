//
//  NSString+AVTagAdditions.h
//  AVTagTextField
//
//  Created by Arseniy Vershinin on 9/16/13.
//

#import <Foundation/Foundation.h>

@interface NSString(AVTagAdditions)

+ (NSRegularExpression *)endOfStringTagRegex;

- (NSRange)wholeStringRange;
- (NSString *)stringWithCheckingResult:(NSTextCheckingResult *)result;
- (NSDictionary *)endOfStringTag;
- (NSArray *)hashTags;
- (NSArray *)tags;

@end

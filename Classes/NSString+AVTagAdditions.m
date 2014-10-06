//
//  NSString+AVTagAdditions.m
//  AVTagTextField
//
//  Created by Arseniy Vershinin on 9/16/13.
//

#import "NSString+AVTagAdditions.h"

@implementation NSString (AVTagAdditions)

- (NSRange)wholeStringRange{
    return NSMakeRange(0, self.length);
}

- (NSString *)stringWithCheckingResult:(NSTextCheckingResult *)result{
    return [self substringWithRange:NSMakeRange(result.range.location+1, result.range.length-1)];
}

+ (NSRegularExpression *)endOfStringTagRegex{
    return [NSRegularExpression
            regularExpressionWithPattern:@"(@|#)(\\w+)$"
            options:NSRegularExpressionCaseInsensitive
            error:nil];
}

- (NSDictionary *)endOfStringTag{
    NSRegularExpression *regex = [NSString endOfStringTagRegex];
    NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if(result) {
		NSString *tagType = [self substringWithRange:NSMakeRange(result.range.location, 1)];
		NSString *match = [self substringWithRange:NSMakeRange(result.range.location+1, result.range.length-1)];
	
		return @{
				 @"type":tagType,
				 @"tag":match
				 };
    }
    return nil;
}

- (NSArray *)searchForOccurrencesOf:(NSString *)item{
    NSMutableArray *results = [NSMutableArray array];
    if(self) {
        //TODO: exclude # with a regex
		NSString *regexStr = [NSString stringWithFormat:@"%@(\\w+)", item];
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexStr
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
        
        [regex enumerateMatchesInString:self
                                options:0
                                  range:NSMakeRange(0, [self length])
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                 
                                 NSString *match = [self substringWithRange:NSMakeRange(result.range.location+1, result.range.length-1)];
                                 if(match) {
                                     [results addObject:match];
                                 }
                             }];
        
    }
    return results;
}

- (NSArray *)hashTags {
	return [self searchForOccurrencesOf:@"#"];
}

- (NSArray *)tags {
	return [self searchForOccurrencesOf:@"@"];
}

@end

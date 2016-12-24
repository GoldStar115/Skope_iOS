//
//  NSString+Utilities.h
//  N&M
//
//  Created by Nguyen Truong Luu on 7/10/14.
//  Copyright (c) 2014 ___NTL___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)
+ (NSString *)abbreviateNumber:(NSInteger)num;
- (NSString *)trim;
- (NSUInteger)numberOfOccurrencesOfString:(NSString *)needle inString:(NSString *)haystack;
- (BOOL)startsWith:(NSString *)string;
- (BOOL)contains:(NSString*)string;
- (BOOL)containsOnlyLetters;
- (BOOL)containsOnlyNumbers;
- (BOOL)containsOnlyNumbersAndLetters;
- (NSString*)safeSubstringToIndex:(NSUInteger)index;
- (NSString*)stringByRemovingPrefix:(NSString*)prefix;
- (NSString*)stringByRemovingPrefixes:(NSArray*)prefixes;
- (BOOL)hasPrefixes:(NSArray*)prefixes;
- (BOOL)isEqualToOneOf:(NSArray*)strings;
@end

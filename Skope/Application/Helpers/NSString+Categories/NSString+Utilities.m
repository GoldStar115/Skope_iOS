//
//  NSString+Utilities.m
//  N&M
//
//  Created by Nguyen Truong Luu on 7/10/14.
//  Copyright (c) 2014 ___NTL___. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (NSString *) trim
{
    return  [self stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceCharacterSet]];
}

- (NSUInteger)numberOfOccurrencesOfString:(NSString *)needle inString:(NSString *)haystack
{
    NSUInteger numberOfMatches = 0;
    if (needle && needle.length > 0) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:needle options:NSRegularExpressionCaseInsensitive error:&error];
        numberOfMatches = [regex numberOfMatchesInString:haystack options:0 range:NSMakeRange(0, [haystack length])];
    }
    return numberOfMatches;
}

- (BOOL)startsWith:(NSString *)string
{
    if ([self length] >= [string length] && [[self substringToIndex:[string length]] isEqualToString:string])
        return YES;
    return NO;
}

- (BOOL)contains:(NSString*)string
{
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)containsOnlyLetters
{
    NSCharacterSet *blockedCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

- (BOOL)containsOnlyNumbers
{
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbers].location == NSNotFound);
}

- (BOOL)containsOnlyNumbersAndLetters
{
    NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

- (NSString*)safeSubstringToIndex:(NSUInteger)index
{
    if(index >= self.length)
        index = self.length - 1;
    return [self substringToIndex:index];
}

- (NSString*)stringByRemovingPrefix:(NSString*)prefix
{
    NSRange range = [self rangeOfString:prefix];
    if(range.location == 0) {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

- (NSString*)stringByRemovingPrefixes:(NSArray*)prefixes
{
    for(NSString *prefix in prefixes) {
        NSRange range = [self rangeOfString:prefix];
        if(range.location == 0) {
            return [self stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    return self;
}

- (BOOL)hasPrefixes:(NSArray*)prefixes
{
    for(NSString *prefix in prefixes) {
        if([self hasPrefix:prefix])
            return YES;
    }
    return NO;
}

- (BOOL)isEqualToOneOf:(NSArray*)strings
{
    for(NSString *string in strings) {
        if([self isEqualToString:string]) {
            return YES;
        }
    }
    return NO;
}

+(NSString *)abbreviateNumber:(NSInteger)num {
    
    /*
     
     [NSString abbreviateNumber:987] ---> 987
     [NSString abbreviateNumber:1200] ---> 1.2K
     [NSString abbreviateNumber:12000] ----> 12K
     [NSString abbreviateNumber:120000] ----> 120K
     [NSString abbreviateNumber:1200000] ---> 1.2M
     [NSString abbreviateNumber:1340] ---> 1.3K
     [NSString abbreviateNumber:132456] ----> 132.5K
     
     */
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [NSString floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

+ (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end

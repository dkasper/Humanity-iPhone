#import "NSStringAdditions.h"

#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Additions)
- (BOOL) isCaseInsensitiveEqualToString:(NSString *) string {
	return ([self caseInsensitiveCompare:string] == NSOrderedSame);
}

- (BOOL) _hasCaseInsensitiveSearchInString:(NSString *) string options:(NSStringCompareOptions) options {
	return [self rangeOfString:string options:options | NSCaseInsensitiveSearch range:NSMakeRange(0, self.length)].location != NSNotFound;
}

- (BOOL) hasCaseInsensitiveSubstring:(NSString *) substring {
	return [self _hasCaseInsensitiveSearchInString:substring options:0];
}

- (BOOL) hasCaseInsensitivePrefix:(NSString *) prefix {
	return [self _hasCaseInsensitiveSearchInString:prefix options:NSAnchoredSearch];
}

- (BOOL) hasCaseInsensitiveSuffix:(NSString *) suffix {
	return [self _hasCaseInsensitiveSearchInString:suffix options:NSBackwardsSearch];
}

- (NSString *) stringByCapitalizingString {
	if (!self.length)
		return @"";

	unichar firstCharacter = [self characterAtIndex:0];
	if ((firstCharacter >= 'A' && firstCharacter <= 'Z') || !(firstCharacter >= 'a' && firstCharacter <= 'z'))
		return [[self copy] autorelease];

	firstCharacter -= 32; // a - A in ascii is 32

	if (self.length > 1)
		return [NSString stringWithFormat:@"%C%@", firstCharacter, [self substringFromIndex:1]];
	return [NSString stringWithFormat:@"%C", firstCharacter];
}
@end

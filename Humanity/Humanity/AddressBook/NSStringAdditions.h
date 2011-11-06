@interface NSString (Additions)
- (BOOL) isCaseInsensitiveEqualToString:(NSString *) string;
- (BOOL) hasCaseInsensitiveSubstring:(NSString *) substring;
- (BOOL) hasCaseInsensitivePrefix:(NSString *) prefix;
- (BOOL) hasCaseInsensitiveSuffix:(NSString *) suffix;


- (NSString *) stringByCapitalizingString;
@end

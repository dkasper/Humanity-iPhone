@interface NSString (Additions)
- (BOOL) isCaseInsensitiveEqualToString:(NSString *) string;
- (BOOL) hasCaseInsensitiveSubstring:(NSString *) substring;
- (BOOL) hasCaseInsensitivePrefix:(NSString *) prefix;
- (BOOL) hasCaseInsensitiveSuffix:(NSString *) suffix;

- (NSString *) stringByRemovingCharactersInSet:(NSCharacterSet *) set;

- (NSString *) stringByCapitalizingString;

- (NSString *) stringByEncodingToPercentEscapeString;

- (NSString *) stringByDecodingFromPercentEscapeString; 
@end

#import "ABMultiValueAdditions.h"
#import <Foundation/Foundation.h>

NSDictionary *ABMultiValueDictionaryRepresentationForKeys(ABMultiValueRef multiValueRepresentation, NSDictionary *keys) {
	if (!multiValueRepresentation)
		return nil;

	CFIndex count = ABMultiValueGetCount(multiValueRepresentation);
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
	for (CFIndex i = 0; i < count; i++) {
		CFStringRef type = ABMultiValueCopyLabelAtIndex(multiValueRepresentation, i);
		CFStringRef value = ABMultiValueCopyValueAtIndex(multiValueRepresentation, i);

		if (!value && !type)
			continue;

		if (!value) {
			CFRelease(type);
			continue;
		}

		if (!type) {
			CFRelease(value);
			continue;
		}

		for (id key in keys) {
			if ([(id)type isEqualToString:key]) {
				[dictionary setObject:(id)value forKey:[keys objectForKey:key]];
				break;
			}
		}

		CFRelease(type);
		CFRelease(value);
	}
	
	return [dictionary autorelease];
}

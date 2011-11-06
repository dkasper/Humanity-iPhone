#import "SCAddressBook.h"
#import "JSONKit.h"
#import <AddressBook/AddressBook.h>
#import <Foundation/Foundation.h>
#import "ABMultiValueAdditions.h"


@interface SCAddressBook (Private)
- (NSArray *) _sortUserDictsByAddressBookSettings:(NSArray *) userDicts;
@end




@implementation SCAddressBook

@synthesize sortOrder = _sortOrder;
- (id) init {
	if (!(self = [super init]))
		return nil;

	_addressBookRef = ABAddressBookCreate();
    _sortOrder = ABPersonGetSortOrdering();
	return self;
}

+ (SCAddressBook *) sharedAddressBook {
	static BOOL creatingSharedInstance = NO;
	static SCAddressBook *sharedAddressBook = nil;

	if (!creatingSharedInstance && !sharedAddressBook) {
		creatingSharedInstance = YES;
		sharedAddressBook = [[[self class] alloc] init];
	}

	return sharedAddressBook;
}

- (NSArray *) groupsForPeople:(NSArray *) people {
    NSString *prevName = nil;
    NSMutableArray *groups = [NSMutableArray array];
	NSMutableDictionary *numericGroup = nil;
	
    for (NSDictionary *person in people) {
        NSString *sortName = nil;
        if (_sortOrder == kABPersonSortByFirstName) {
            sortName = [[person objectForKey:@"name"] objectForKey:@"first"];
            if (!sortName) sortName = [[person objectForKey:@"name"] objectForKey:@"last"];
        } else {
            sortName = [[person objectForKey:@"name"] objectForKey:@"last"];
            if (!sortName) sortName = [[person objectForKey:@"name"] objectForKey:@"first"];    
        }
		
		if (!sortName) continue;
		
		BOOL sortIsAlpha = ([[NSCharacterSet letterCharacterSet] characterIsMember:[sortName characterAtIndex:0]]);		
		BOOL prevIsAlpha = prevName.length && ([[NSCharacterSet letterCharacterSet] characterIsMember:[prevName characterAtIndex:0]]);
		
        if (!prevName.length || (![[sortName substringToIndex:1] isCaseInsensitiveEqualToString:[prevName substringToIndex:1]] && (sortIsAlpha || prevIsAlpha))) {
            [groups addObject:[NSMutableArray array]];
			if (!sortIsAlpha) {
				numericGroup = [[groups objectAtIndex:groups.count -1] retain];		
			}
        }
        [[groups objectAtIndex:groups.count -1] addObject:person];
        prevName = sortName;     
    }        
	
	/*
	 Move numeric group to end (as in the contacts app)
	 */
	if (numericGroup) {
		[groups removeObject:numericGroup];
		[groups addObject:numericGroup];
		[numericGroup release];
	}
	return groups;    
}  


- (NSArray *) people:(NSArray *) people filteredWithString:(NSString *) searchTerm {
	NSMutableArray *newPeople = [NSMutableArray array];
	for (NSDictionary *person in  people) {
		NSString *fn = [[person objectForKey:@"name"] objectForKey:@"first"];
		NSString *ln = [[person objectForKey:@"name"] objectForKey:@"last"];
		NSString *fullName;
		if (fn && ln) {
			fullName = [NSString stringWithFormat:@"%@ %@", fn, ln];
		} else if (fn) {
			fullName = fn;
		} else if (ln) {
			fullName = ln;
		} else {
			continue;  
		}
		
		if ([fn hasCaseInsensitivePrefix:searchTerm] || [ln hasCaseInsensitivePrefix:searchTerm] || [fullName hasCaseInsensitivePrefix:searchTerm]) { 
			[newPeople addObject:person];
		} 		
	}
	return newPeople;
}

- (NSArray *) peopleWithProperty:(ABPropertyID) property {
    static NSMutableDictionary *peoples = nil;
	static dispatch_once_t pred;
	dispatch_once(&pred, ^{
        peoples = [[NSMutableDictionary alloc] init];
    }); 
    
    NSNumber *propertyNum = [NSNumber numberWithInt:property];
    if ([peoples objectForKey:propertyNum]) return [peoples objectForKey:propertyNum]; 
    
    NSMutableArray *newPeople = [NSMutableArray array];
    
    for (NSDictionary *dict in [self people]) {
        if (property == kABPersonPhoneProperty) {
            if ([dict objectForKey:@"phone_number"]) {
				[newPeople addObject:dict];
			}
		} else if (property == kABPersonEmailProperty) {
            if ([dict objectForKey:@"email"]) {
				[newPeople addObject:dict];
			}
		} else if (property == kABPersonNoProperty) {	
		    //do not add
		} else{
			[newPeople addObject:dict];
        }        
    }
     
    [peoples setObject:newPeople forKey:propertyNum];
    return [peoples objectForKey:propertyNum];
}

    
#pragma mark -
- (NSArray *) people {
    static dispatch_once_t pred;
    static NSArray *sortedPeople = nil;
    
	dispatch_once(&pred, ^{
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
		NSUInteger numberOfPeople = CFArrayGetCount(allPeople);
		NSMutableDictionary *people = [[NSMutableDictionary alloc] initWithCapacity:numberOfPeople];
		// Shared keys for getting data
		NSMutableDictionary *keys = [[NSMutableDictionary alloc] initWithCapacity:7];
		[keys setObject:@"home" forKey:(id)kABHomeLabel];
		[keys setObject:@"work" forKey:(id)kABWorkLabel];
		[keys setObject:@"other" forKey:(id)kABOtherLabel];
		[keys setObject:@"mobile" forKey:(id)kABPersonPhoneMobileLabel];
		[keys setObject:@"iphone" forKey:(id)kABPersonPhoneIPhoneLabel];
		[keys setObject:@"main" forKey:(id)kABPersonPhoneMainLabel];

		for (NSUInteger i = 0; i < numberOfPeople; i++) {
			ABPerson record = CFArrayGetValueAtIndex(allPeople, i);
			CFStringRef firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
			CFStringRef lastName = ABRecordCopyValue(record, kABPersonLastNameProperty);

			if (!firstName && !lastName)
				continue;

			//CFStringRef middleName = ABRecordCopyValue(record, kABPersonMiddleNameProperty);

			// Name
			NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithCapacity:3];
			NSMutableDictionary *names = [[NSMutableDictionary alloc] initWithCapacity:2];
            NSMutableString *personKey = [[NSMutableString alloc] init]; 
			if (firstName) {
				if (CFStringGetLength(firstName)) {
					[names setObject:(id)firstName forKey:@"first"];
                    [personKey appendString:(NSString *)firstName];
				}
				CFRelease(firstName);
			}
            
			if (lastName) {
				if (CFStringGetLength(lastName)) {
					[names setObject:(id)lastName forKey:@"last"];
				    [personKey appendString:(NSString *)lastName];
				}
				CFRelease(lastName);
			}

			if ([names allKeys].count)
				[person setObject:names forKey:@"name"];

			[names release];

			ABMultiValueRef allEmails = ABRecordCopyValue(record, kABPersonEmailProperty);
			if (allEmails) {
				NSDictionary *emails = ABMultiValueDictionaryRepresentationForKeys(allEmails, keys);

				CFRelease(allEmails);
                
				if ([emails allKeys].count) {
					[person setObject:emails forKey:@"email"];
				}
			}
            
			ABMultiValueRef allPhoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
			if (allPhoneNumbers) {
				// phone numbers
				NSDictionary *phoneNumbers = ABMultiValueDictionaryRepresentationForKeys(allPhoneNumbers, keys);
				if ([phoneNumbers allKeys].count)
					[person setObject:phoneNumbers forKey:@"phone_number"];

				CFRelease(allPhoneNumbers);
			}

			// All together now
			if ([person allKeys].count) {
                [people setObject:person forKey:personKey];
            }
				//[people addObject:person];

			[person release];
			[personKey release];
		}
		[keys release];
		CFRelease(allPeople);
        sortedPeople = [[self _sortUserDictsByAddressBookSettings:[people allValues]] retain];
        [people release];
	});
    
	return sortedPeople;
} 

- (void) JSONRepresentationInbackground {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self JSONRepresentation];
    });
}

- (NSString *) JSONRepresentation {
	static dispatch_once_t pred;
	static NSString *JSONRepresentation = nil;
	dispatch_once(&pred, ^{
        JSONRepresentation = [[[self people] JSONString] copy];
	});
	return JSONRepresentation;
}

#pragma mark -


- (NSComparisonResult) comparePrimary1:(NSString *) primary1 secondary1:(NSString *) secondary1 primary2:(NSString *) primary2 secondary2:(NSString *) secondary2 {
    NSString *s1 = primary1;
    if (!s1.length) s1 = secondary1;
    
    NSString *s2 = primary2;
    if (!s2.length) s2 = secondary2;
    
    NSComparisonResult result = [s1 localizedCaseInsensitiveCompare:s2];
	if (result != NSOrderedSame)
		return result;
	
	if (secondary1.length) 
        s1 = secondary1;
        
    if (secondary2.length) 
        s2 = secondary2;
    
    return [s1 localizedCaseInsensitiveCompare:s2];    
} 

    
- (NSArray *) _sortUserDictsByAddressBookSettings:(NSArray *) userDicts {
	return [userDicts sortedArrayUsingComparator:^(id first, id second) {
        NSString *f1 = [[first objectForKey:@"name"] objectForKey:@"first"];
        NSString *f2 = [[second objectForKey:@"name"] objectForKey:@"first"];
        NSString *l1 = [[first objectForKey:@"name"] objectForKey:@"last"];
        NSString *l2 = [[second objectForKey:@"name"] objectForKey:@"last"];
        
	    if (_sortOrder == kABPersonSortByFirstName)
            return [self comparePrimary1:f1 secondary1:l1 primary2:f2 secondary2:l2];
        return [self comparePrimary1:l1 secondary1:f1 primary2:l2 secondary2:f2];   
	}];
}

- (NSComparisonResult) compareFirst1:(NSString *) first1 last1:(NSString *) last1 first2:(NSString *) first2 last2:(NSString *) last2 {
    if (_sortOrder == kABPersonSortByFirstName)
        return [self comparePrimary1:first1 secondary1:last1 primary2:first2 secondary2:last2];
        
    return [self comparePrimary1:last1 secondary1:first1 primary2:last2 secondary2:first2];    
}

@end

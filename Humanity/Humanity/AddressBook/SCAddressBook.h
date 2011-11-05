#import <AddressBook/AddressBook.h>
#import "NSStringAdditions.h"

/*Redefine the nackname property to mean none*/
#define kABPersonNoProperty kABPersonNicknameProperty

typedef ABRecordRef ABPerson;


@interface SCAddressBook : NSObject {
@private
	ABAddressBookRef _addressBookRef;
    ABPersonSortOrdering _sortOrder; 
}

+ (SCAddressBook *) sharedAddressBook;
- (NSArray *) people;
- (NSArray *) peopleWithProperty:(ABPropertyID) property;
- (NSArray *) people:(NSArray *) people filteredWithString:(NSString *) searchTerm;
- (NSString *) JSONRepresentation;
- (void) JSONRepresentationInbackground;

- (NSComparisonResult) compareFirst1:(NSString *) first1 last1:(NSString *) last1 first2:(NSString *) first2 last2:(NSString *) last2;
@property (readonly) ABPersonSortOrdering sortOrder;
@end

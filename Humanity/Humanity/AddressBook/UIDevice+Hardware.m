/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>

#import "UIDevice+Hardware.h"

@implementation UIDevice (Hardware)

/*
 Platforms
 
 iFPGA ->		??

 iPhone1,1 ->	iPhone 1G
 iPhone1,2 ->	iPhone 3G
 iPhone2,1 ->	iPhone 3GS
 iPhone3,1 ->	iPhone 4/AT&T
 iPhone3,2 ->	iPhone 4/Other Carrier?
 iPhone3,3 ->	iPhone 4/Other Carrier?
 iPhone4,1 ->	??iPhone 5

 iPod1,1   -> iPod touch 1G 
 iPod2,1   -> iPod touch 2G 
 iPod2,2   -> ??iPod touch 2.5G
 iPod3,1   -> iPod touch 3G
 iPod4,1   -> iPod touch 4G
 iPod5,1   -> ??iPod touch 5G
 
 iPad1,1   -> iPad 1G, WiFi
 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
 iPad2,1   -> iPad 2G (iProd 2,1)
 
 AppleTV2,1 -> AppleTV 2

 i386, x86_64 -> iPhone Simulator
*/


#pragma mark sysctlbyname utils

- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
	sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
	char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

- (NSString *) platform
{
	return [self getSysInfoByName:"hw.machine"];
}

#pragma mark platform type and name utils

- (NSUInteger) platformType
{
	NSString *platform = [self platform];
	// if ([platform isEqualToString:@"XX"])			return UIDeviceUnknown;

	if ([platform isEqualToString:@"iFPGA"])		return UIDeviceIFPGA;

	if ([platform isEqualToString:@"iPhone1,1"])	return UIDevice1GiPhone;
	if ([platform isEqualToString:@"iPhone1,2"])	return UIDevice3GiPhone;
	if ([platform hasPrefix:@"iPhone2"])			return UIDevice3GSiPhone;
	if ([platform hasPrefix:@"iPhone3"])			return UIDevice4iPhone;
	if ([platform hasPrefix:@"iPhone4"])			return UIDevice5iPhone;

	if ([platform isEqualToString:@"iPod1,1"])		return UIDevice1GiPod;
	if ([platform isEqualToString:@"iPod2,1"])		return UIDevice2GiPod;
	if ([platform isEqualToString:@"iPod3,1"])		return UIDevice3GiPod;
	if ([platform isEqualToString:@"iPod4,1"])		return UIDevice4GiPod;

	if ([platform isEqualToString:@"iPad1,1"])		return UIDevice1GiPad;
	if ([platform hasPrefix:@"iPad2"])		return UIDevice2GiPad;

	if ([platform isEqualToString:@"AppleTV2,1"])	return UIDeviceAppleTV2;

	/*
	 MISSING A SOLUTION HERE TO DATE TO DIFFERENTIATE iPAD and iPAD 3G.... SORRY!
	 */

	if ([platform hasPrefix:@"iPhone"]) return UIDeviceUnknowniPhone;
	if ([platform hasPrefix:@"iPod"])	return UIDeviceUnknowniPod;
	if ([platform hasPrefix:@"iPad"])	return UIDeviceUnknowniPad;

	if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) // thanks Jordan Breeding
	{
		if ([[UIScreen mainScreen] bounds].size.width < 768)
			return UIDeviceiPhoneSimulatoriPhone;
		else 
			return UIDeviceiPhoneSimulatoriPad;

		return UIDeviceiPhoneSimulator;
	}
	return UIDeviceUnknown;
}

- (NSString *) platformString
{
	switch ([self platformType])
	{
		case UIDevice1GiPhone:				return IPHONE_1G_NAMESTRING;
		case UIDevice3GiPhone:				return IPHONE_3G_NAMESTRING;
		case UIDevice3GSiPhone:				return IPHONE_3GS_NAMESTRING;
		case UIDevice4iPhone:				return IPHONE_4_NAMESTRING;
		case UIDevice5iPhone:				return IPHONE_5_NAMESTRING;
		case UIDeviceUnknowniPhone:			return IPHONE_UNKNOWN_NAMESTRING;

		case UIDevice1GiPod:				return IPOD_1G_NAMESTRING;
		case UIDevice2GiPod:				return IPOD_2G_NAMESTRING;
		case UIDevice3GiPod:				return IPOD_3G_NAMESTRING;
		case UIDevice4GiPod:				return IPOD_4G_NAMESTRING;
		case UIDeviceUnknowniPod:			return IPOD_UNKNOWN_NAMESTRING;

		case UIDevice1GiPad:				return IPAD_1G_NAMESTRING;
		case UIDevice2GiPad:				return IPAD_2G_NAMESTRING;

		case UIDeviceAppleTV2:				return APPLETV_2G_NAMESTRING;

		case UIDeviceiPhoneSimulator:		return IPHONE_SIMULATOR_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPad:	return IPHONE_SIMULATOR_IPAD_NAMESTRING;

		case UIDeviceIFPGA:					return IFPGA_NAMESTRING;

		default:							return IPOD_FAMILY_UNKNOWN_DEVICE;
	}
}
@end

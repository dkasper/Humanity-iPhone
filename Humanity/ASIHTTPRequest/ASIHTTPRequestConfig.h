//
//  ASIHTTPRequestConfig.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 14/12/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//


// ======
// Debug output configuration options
// ======

#define ASIDEBUG 0

// When set to 1 ASIHTTPRequests will print information about what a request is doing
#ifndef DEBUG_REQUEST_STATUS
	#if ASIDEBUG
		#define DEBUG_REQUEST_STATUS 1
	#endif
#endif

// When set to 1, ASIFormDataRequests will print information about the request body to the console
#ifndef DEBUG_FORM_DATA_REQUEST
	#if ASIDEBUG
		#define DEBUG_FORM_DATA_REQUEST 1
	#endif
#endif

// When set to 1, ASIHTTPRequests will print information about bandwidth throttling to the console
#ifndef DEBUG_THROTTLING
	#if ASIDEBUG
		#define DEBUG_THROTTLING 1
	#endif
#endif

// When set to 1, ASIHTTPRequests will print information about persistent connections to the console
#ifndef DEBUG_PERSISTENT_CONNECTIONS
	#if ASIDEBUG
		#define DEBUG_PERSISTENT_CONNECTIONS 1
	#endif
#endif

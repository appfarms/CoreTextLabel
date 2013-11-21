//
//  AFMacros.h
//  AFMacros
//
//  Created by Daniel Kuhnke on 12.08.13.
//  Copyright (c) 2013 appfarms GmbH & Co. KG. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2013 appfarms GmbH & Co. KG
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Directories
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_CACHE_DIR
#define AF_CACHE_DIR      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#endif

#ifndef AF_DOCUMENTS_DIR
#define AF_DOCUMENTS_DIR  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// NSLocalizedString
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_LOCALIZE
#define AF_LOCALIZE(__NSSTRING) NSLocalizedString(__NSSTRING, __NSSTRING);
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// UUID
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_UUID
#define AF_UUID AF_NSUUIDString()
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// NSLocale
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_PREFERRED_LANGUAGE_IDENTIFIER
#define AF_PREFERRED_LANGUAGE_IDENTIFIER [[NSLocale preferredLanguages] objectAtIndex:0]
#endif

#ifndef AF_PREFERRED_LANGUAGE_CODE
#define AF_PREFERRED_LANGUAGE_CODE [[NSLocale componentsFromLocaleIdentifier:AF_PREFERRED_LANGUAGE_IDENTIFIER] objectForKey:NSLocaleLanguageCode]
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// NSLog
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef ZLog
#define ZLog(fmt, ...) NSLog((@"%s (%d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// NSManagedObject
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_MOC
#define AF_MOC ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(managedObjectContext)] ? (NSManagedObjectContext *)[[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)] : nil)
#endif

#ifndef AF_SAVEMOC
#define AF_SAVEMOC(__OBJECT) { NSError *_error = nil; if(AF_VALID(__OBJECT, NSManagedObjectContext)){ [__OBJECT save:&_error]; } if(AF_VALID(_error, NSError)) { NSLog(@"%s Error '%@'", __PRETTY_FUNCTION__ _error); } }
#endif

#ifndef AF_SAVEMAINMOC
#define AF_SAVEMAINMOC() { NSError *_error = nil; [AF_MOC save:&_error]; if(AF_VALID(_error, NSError)) { NSLog(@"%s Error '%@'", __PRETTY_FUNCTION__ _error); } }
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Validation
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_EMPTY
#define AF_EMPTY(__OBJECT) ((nil == __OBJECT) ? YES : ((nil != __OBJECT && [__OBJECT respondsToSelector:@selector(count)]) ? ([__OBJECT performSelector:@selector(count)] <= 0) : ((nil != __OBJECT && [__OBJECT respondsToSelector:@selector(length)]) ? ([__OBJECT performSelector:@selector(length)] <= 0) : NO)))
#endif

#ifndef AF_NOTEMPTY
#define AF_NOTEMPTY(__OBJECT) (EMPTY(__OBJECT) == NO)
#endif

#ifndef AF_VALID
#define AF_VALID(__OBJECT, __CLASSNAME) (nil != __OBJECT && [__OBJECT isKindOfClass:[__CLASSNAME class]])
#endif

#ifndef AF_VALID_EMPTY
#define AF_VALID_EMPTY(__OBJECT, __CLASSNAME) (AF_VALID(__OBJECT, __CLASSNAME) == YES && AF_EMPTY(__OBJECT) == YES)
#endif

#ifndef AF_VALID_NOTEMPTY
#define AF_VALID_NOTEMPTY(__OBJECT, __CLASSNAME) (AF_VALID(__OBJECT, __CLASSNAME) == YES && AF_EMPTY(__OBJECT) == NO)
#endif

#ifndef AF_RADIANS
#define AF_RADIANS(__FLOAT) ((__FLOAT * M_PI) / 180.0)
#endif

#ifndef AF_ARRAY_INDEX_EXISTS
#define AF_ARRAY_INDEX_EXISTS(__ARRAY, __INDEX) (AF_VALID(__ARRAY, NSArray) && __INDEX >= 0 && __INDEX < [(NSArray *)__ARRAY count])
#endif

#ifndef AF_ARRAY_OBJECT_AT_INDEX
#define AF_ARRAY_OBJECT_AT_INDEX(__ARRAY, __INDEX) (AF_ARRAY_INDEX_EXISTS(__ARRAY, __INDEX) ? [__ARRAY objectAtIndex:__INDEX] : nil)
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// App Version / Info Plist
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_BUNDLE_SHORT_VERSION_STRING
#define AF_BUNDLE_SHORT_VERSION_STRING [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#endif

#ifndef AF_BUNDLE_VERSION_STRING
#define AF_BUNDLE_VERSION_STRING [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#endif

#ifndef AF_BUNDLE_VERSION_VALUE
#define AF_BUNDLE_VERSION_VALUE [AF_BUNDLE_VERSION_STRING intValue]
#endif

#ifndef AF_APP_VERSION_STRING
#define AF_APP_VERSION_STRING   [NSString stringWithFormat:@"%@ (%@)", AF_BUNDLE_SHORT_VERSION_STRING, AF_BUNDLE_VERSION_STRING]
#endif

#ifndef AF_BUNDLE_IDENTIFIER
#define AF_BUNDLE_IDENTIFIER (NSString *)([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"])
#endif

#ifndef AF_DEVICE_MACHINE_NAME
#define AF_DEVICE_MACHINE_NAME (NSString *)(AF_NSStringMachineNameFromCurrentDevice())
#endif

#ifndef AF_DEVICE_SYSTEM_VERSION
#define AF_DEVICE_SYSTEM_VERSION [[UIDevice currentDevice] systemVersion]
#endif

#ifndef AF_SCREEN_SCALE
#define AF_SCREEN_SCALE ([[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")] ? [[UIScreen mainScreen] scale] : 1.f)
#endif

#ifndef AF_DEBUG_APP_CONFIG_STRING
#define AF_DEBUG_APP_CONFIG_STRING [NSString stringWithFormat:@"App Version: '%@' System Version: '%@' Machine Name '%@' Bundle Identifier: '%@'", AF_APP_VERSION_STRING, AF_DEVICE_SYSTEM_VERSION, AF_DEVICE_MACHINE_NAME, AF_BUNDLE_IDENTIFIER]
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// NSDate + NSDateFormatter
//
///////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef AF_DATE_FORMATTER_STRING_UTC
#define AF_DATE_FORMATTER_STRING_UTC @"yyyy-MM-dd HH:mm:ss z"
#endif

#ifndef AF_DATE_FORMATTER_STRING_ZULU
#define AF_DATE_FORMATTER_STRING_ZULU @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Helper Methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////


NSString * AF_NSStringByEncodingData(NSData * data);
NSString * AF_NSStringMachineNameFromCurrentDevice();
NSString * AF_NSUUIDCreateString();
NSString * AF_NSUUIDString();

NSDate * AF_NSDateFromStringWithFormat(NSString * dateString, NSString * formatString);
NSDate * AF_NSDateFromUTCString(NSString * dateString);
NSDate * AF_NSDateFromZULUString(NSString * dateString);


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// UIColor
//
///////////////////////////////////////////////////////////////////////////////////////////////////


UIColor * AF_UIColorWithHexString(NSString * string);
UIColor * AF_UIColorWithRGBString(NSString * string);

#ifndef AF_COLOR_HEX
#define AF_COLOR_HEX(__STRING) AF_UIColorWithHexString(__STRING)
#endif

#ifndef AF_COLOR_RGB
#define AF_COLOR_RGB(__STRING) AF_UIColorWithRGBString(__STRING)
#endif
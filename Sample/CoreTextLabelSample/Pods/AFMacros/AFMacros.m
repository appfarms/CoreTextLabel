//
//  AFMacros.m
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

#import "AFMacros.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#pragma mark - NSString

NSString * AF_NSStringByEncodingData(NSData * dataObject)
{
    if (AF_VALID(dataObject, NSData))
    {
        const uint8_t * input  = (uint8_t *)dataObject.bytes;
        NSInteger       length = dataObject.length;
        
        static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        
        NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
        uint8_t *output = (uint8_t *)data.mutableBytes;
        
        for (NSInteger i = 0; i < length; i += 3) {
            NSInteger value = 0;
            for (NSInteger j = i; j < (i + 3); j++) {
                value <<= 8;
                
                if (j < length) {
                    value |= (0xFF & input[j]);
                }
            }
            
            NSInteger index = (i / 3) * 4;
            output[index + 0] =                    table[(value >> 18) & 0x3F];
            output[index + 1] =                    table[(value >> 12) & 0x3F];
            output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
            output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
        }
        
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    return nil;
}

NSString * AF_NSStringMachineNameFromCurrentDevice ()
{
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    
    // Done with this
    free(name);
    
    return machine;
}

NSString * AF_NSUUIDCreateString()
{
    NSString  * uuidString = nil;
    CFUUIDRef   uuid       = CFUUIDCreate(NULL);
    
    if (uuid)
    {
        uuidString = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    return uuidString;
}

NSString * AF_NSUUIDString()
{
    NSString * key  = @"AF_UUID_String";
    NSString * uuid = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (AF_VALID_NOTEMPTY(uuid, NSString) == NO)
    {
        uuid = AF_NSUUIDCreateString();
        [[NSUserDefaults standardUserDefaults] setObject:uuid
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uuid;
}

#pragma mark - NSDate

NSDate * AF_NSDateFromStringWithFormat(NSString * dateString, NSString * formatString)
{
    if (AF_VALID_NOTEMPTY(dateString, NSString) && AF_VALID_NOTEMPTY(formatString, NSString))
    {
        NSDateFormatter * formatter = [NSDateFormatter new];
        [formatter setDateFormat:formatString];
        return [formatter dateFromString:dateString];
    }
    
    return nil;
}

NSDate * AF_NSDateFromUTCString(NSString * dateString)
{
    return AF_NSDateFromStringWithFormat(dateString, AF_DATE_FORMATTER_STRING_UTC);
}

NSDate * AF_NSDateFromZULUString(NSString * dateString)
{
    return AF_NSDateFromStringWithFormat(dateString, AF_DATE_FORMATTER_STRING_ZULU);
}

#pragma mark - UIColor

UIColor * AF_UIColorWithHexString(NSString * string)
{
    if (AF_VALID_NOTEMPTY(string, NSString))
    {
        NSString *cString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6)
        {
            return nil;
        }
        
        // strip "0X" if it appears
        if ([cString hasPrefix:@"0X"])
        {
            cString = [cString substringFromIndex:2];
        }
        // strip "#" if it appears
        else if ([cString hasPrefix:@"#"])
        {
            cString = [cString substringFromIndex:1];
        }
        
        if ([cString length] != 6)
        {
            return nil;
        }
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.f)
                               green:((float) g / 255.f)
                                blue:((float) b / 255.f)
                               alpha:1.f];
    }
    
    return nil;
}

UIColor * AF_UIColorWithRGBString(NSString * string)
{
    if (AF_VALID_NOTEMPTY(string, NSString))
    {
        NSArray * values = [string componentsSeparatedByString:@","];
        if (AF_VALID(values, NSArray) && values.count > 2)
        {
            return [UIColor colorWithRed:[values[0] floatValue]/255.f
                                   green:[values[1] floatValue]/255.f
                                    blue:[values[2] floatValue]/255.f
                                   alpha:1.f];
        }
    }
    
    return nil;
}


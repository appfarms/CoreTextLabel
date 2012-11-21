//
//  CoreTextLabel.m
//  CoreTextLabel
//
//  Created by Daniel Kuhnke on 19.11.12.
//  Copyright (c) 2012 Daniel Kuhnke appfarms GmbH & Co. KG (http://www.appfarms.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to
//  do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "CoreTextLabel.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#import "RegexKitLite.h"

#define CORE_TEXT_SUPPORTED() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)

@interface CoreTextLabel()

@property (nonatomic, retain) CATextLayer * attributedTextLayer;

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html parentTag:(NSString *)parentTag;

@end

@implementation CoreTextLabel

@synthesize string              = _string;

@synthesize font                = _font;
@synthesize boldFont            = _boldFont;
@synthesize italicFont          = _italicFont;
@synthesize boldItalicFont      = _boldItalicFont;

@synthesize textColor           = _textColor;
@synthesize boldTextColor       = _boldTextColor;
@synthesize italicTextColor     = _italicTextColor;
@synthesize boldItalicTextColor = _boldItalicTextColor;

@synthesize defaultFontSize     = _defaultFontSize;

- (id) initWithFrame:(CGRect)frame
{
    if (CORE_TEXT_SUPPORTED() == NO)
	{
		return nil;
	}
    
	self = [super initWithFrame:frame];
    
	if (self)
	{
        [self setContentMode:UIViewContentModeRedraw];
		self.backgroundColor = [UIColor clearColor];
        _defaultFontSize     = 18.f;
	}
    
	return self;
}

#pragma mark - Getter

- (UIFont *) font
{
    if (!_font)
    {
        self.font = [UIFont systemFontOfSize:self.defaultFontSize];
    }
    
    return _font;
}

- (UIFont *) boldFont
{
    if (!_boldFont)
    {
        self.boldFont = [UIFont boldSystemFontOfSize:self.defaultFontSize];
    }
    
    return _boldFont;
}

- (UIFont *) italicFont
{
    if (!_italicFont)
    {
        self.italicFont = [UIFont italicSystemFontOfSize:self.defaultFontSize];
    }
    
    return _italicFont;
}

- (UIFont *) boldItalicFont
{
    if (!_boldItalicFont)
    {
        self.boldItalicFont = [UIFont italicSystemFontOfSize:self.defaultFontSize];
    }
    
    return _boldItalicFont;
}

- (UIColor *) textColor
{
    if (!_textColor)
    {
        self.textColor = [UIColor blackColor];
    }
    
    return _textColor;
}

- (UIColor *) boldTextColor
{
    if (!_boldTextColor)
    {
        self.boldTextColor = self.textColor;
    }
    
    return _boldTextColor;
}

- (UIColor *) italicTextColor
{
    if (!_italicTextColor)
    {
        self.italicTextColor = self.textColor;
    }
    
    return _italicTextColor;
}


- (UIColor *) boldItalicTextColor
{
    if (!_boldItalicTextColor)
    {
        self.boldItalicTextColor = self.textColor;
    }
    
    return _boldItalicTextColor;
}

#pragma mark - Layout

- (void) sizeToFit
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 9000);
    
    CTFramesetterRef framesetter     = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
    CFRange          fullStringRange = CFRangeMake(0, self.string.string.length);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, self.bounds);
    CTFrameRef aFrame = CTFramesetterCreateFrame(framesetter, fullStringRange, framePath, NULL);
    
    CFArrayRef lines = CTFrameGetLines(aFrame);
    CFIndex    count = CFArrayGetCount(lines);
    
    // Limit lines if self.numberOfLines != 0
    if (self.numberOfLines != 0 && count > self.numberOfLines)
    {
        count = self.numberOfLines;
    }
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(aFrame, CFRangeMake(0, count), origins);
    
    CGFloat ascent, descent, leading, width;
    CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, count-1);
    width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, ceilf(self.bounds.size.height - origins[count-1].y + descent));
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Fetch the context
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
    CFRange fullStringRange = CFRangeMake(0, self.string.string.length);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, rect);
    CTFrameRef aFrame = CTFramesetterCreateFrame(framesetter, fullStringRange, framePath, NULL);
    
    CFArrayRef lines = CTFrameGetLines(aFrame);
    CFIndex    count = CFArrayGetCount(lines);
    
    // Limit lines if self.numberOfLines != 0
    if (self.numberOfLines != 0 && count > self.numberOfLines)
    {
        count = self.numberOfLines;
    }
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(aFrame, CFRangeMake(0, count), origins); // Fill origins[] buffer.
    
    // Draw every line but the last one
    for (CFIndex i = 0; i < count-1; i++)
    {
        CGContextSetTextPosition(context, origins[i].x, origins[i].y);
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
        CTLineDraw(line, context);
    }
    
    // Truncate the last line before drawing it
    CGPoint lastOrigin = origins[count-1];
    CTLineRef lastLine = CFArrayGetValueAtIndex(lines, count-1);
    
    // Truncation token is a CTLineRef itself
    NSRange effectiveRange = NSMakeRange(0, 0);
    CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), (__bridge CFDictionaryRef)([self.string attributesAtIndex:0 effectiveRange:&effectiveRange]));
    CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
    CFRelease(truncationString);
    
    // Range to cover everything from the start of lastLine to the end of the string
    CFRange rng = CFRangeMake(CTLineGetStringRange(lastLine).location, 0);
    rng.length = CFAttributedStringGetLength((__bridge CFAttributedStringRef)self.string) - rng.location;
    
    // Substring with that range
    NSAttributedString * longString = [self.string attributedSubstringFromRange:NSMakeRange(rng.location, rng.length)];
    
    // Line for that string
    CTLineRef longLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)longString);
    
    CTLineRef truncated = CTLineCreateTruncatedLine(longLine, rect.size.width, kCTLineTruncationEnd, truncationToken);
    CFRelease(longLine);
    CFRelease(truncationToken);
    
    // If 'truncated' is NULL, then no truncation was required to fit it
    if (truncated == NULL)
        truncated = (CTLineRef)CFRetain(lastLine);
    
    // Draw new line at the same offset as the non-truncated version
    CGContextSetTextPosition(context, lastOrigin.x, lastOrigin.y);
    CTLineDraw(truncated, context);
    CFRelease(truncated);
}

#pragma mark - HTML

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html
{
	return [self attributedStringByHTML:html parentTag:nil];
}

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html parentTag:(NSString *)parentTag
{
	CTFontRef  parentFont  = CTFontCreateFromUIFont(self.font);
    CGColorRef parentColor = self.textColor.CGColor;
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)parentFont,  (id)kCTFontAttributeName,
                                        (__bridge id)parentColor, (id)kCTForegroundColorAttributeName,
                                        nil];
    
	if (!html)
	{
		return [[NSMutableAttributedString alloc] initWithString:@""
                                                      attributes:attributes];
	}
    
	NSString * newLinePlaceHolder = @"{BR}";
    
	// Fix newlines
	html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	html = [html stringByReplacingOccurrencesOfRegex:@"<p[^>]*>" withString:@""];
	html = [html stringByReplacingOccurrencesOfString:@"</p>" withString:newLinePlaceHolder];
	html = [html stringByReplacingOccurrencesOfRegex:@"<br[^>]*>" withString:newLinePlaceHolder];
    
	NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:html
                                                                                    attributes:attributes];
    
	if (parentTag)
	{
		if ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"])
		{
			parentFont  = CTFontCreateFromUIFont(self.boldFont);
            parentColor = self.boldTextColor.CGColor;
		}
		if ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"])
		{
			parentFont  = CTFontCreateFromUIFont(self.italicFont);
            parentColor = self.italicTextColor.CGColor;
		}
	}
    
	NSRange tagRange = [attrString.string rangeOfRegex:@"<[^/>]+>"];
    
	do
	{
		if (tagRange.location != NSNotFound)
		{
			// Prepare tag
			NSString * searchTag = [attrString.string substringWithRange:tagRange];
			searchTag            = [searchTag stringByReplacingOccurrencesOfString:@"<" withString:@""];
			searchTag            = [searchTag stringByReplacingOccurrencesOfString:@">" withString:@""];
            
			// Remove attributes from tag
			if ([searchTag rangeOfRegex:@" "].location != NSNotFound)
			{
				NSInteger location = [searchTag rangeOfRegex:@" "].location;
				searchTag          = [searchTag stringByReplacingCharactersInRange:NSMakeRange(location, [searchTag length]-location) withString:@""];
			}
            
			NSString * regString = [NSString stringWithFormat:@"<%@[^>]*>(.*?)</%@>", searchTag, searchTag];
			NSRange    match     = [attrString.string rangeOfRegex:regString];
            
			if (match.location != NSNotFound)
			{
				NSString * innerString = [attrString.string substringWithRange:match];
				innerString            = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"<%@[^>]*>", searchTag] withString:@""];
				innerString            = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"</%@>", searchTag] withString:@""];
                
				CTFontRef  matchFont  = parentFont;
                CGColorRef matchColor = parentColor;
                
				if ([searchTag isEqualToString:@"b"] || [searchTag isEqualToString:@"strong"])
				{
					matchFont  = CTFontCreateFromUIFont(self.boldFont);
                    matchColor = self.boldTextColor.CGColor;
                    
					if (parentTag && ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"]))
					{
						matchFont  = CTFontCreateFromUIFont(self.boldItalicFont);
                        matchColor = self.boldItalicTextColor.CGColor;
					}
				}
				if ([searchTag isEqualToString:@"i"] || [searchTag isEqualToString:@"em"])
				{
					matchFont  = CTFontCreateFromUIFont(self.italicFont);
                    matchColor = self.italicTextColor.CGColor;
                    
					if (parentTag && ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"]))
					{
						matchFont  = CTFontCreateFromUIFont(self.boldItalicFont);
                        matchColor = self.boldItalicTextColor.CGColor;
					}
				}
                
                [attributes setValue:(__bridge id)matchFont
                              forKey:(id)kCTFontAttributeName];
                
                [attributes setValue:(__bridge id)matchColor
                              forKey:(id)kCTForegroundColorAttributeName];
                
				NSMutableAttributedString * innerAttrString = [[NSMutableAttributedString alloc] initWithString:innerString attributes:attributes];
                
				NSRange innerMatch = [innerAttrString.string rangeOfRegex:@"<[^/>]+>(.*?)</[^>]+>"];
				if (innerMatch.location != NSNotFound)
				{
					NSString * nestedInnerString = [innerAttrString.string substringWithRange:innerMatch];
                    
					NSAttributedString * nestedAttrString = [self attributedStringByHTML:nestedInnerString
                                                                               parentTag:searchTag];
                    
					[innerAttrString replaceCharactersInRange:innerMatch withAttributedString:nestedAttrString];
				}
                
				[attrString replaceCharactersInRange:match
                                withAttributedString:innerAttrString];
			}
			else
            {
				NSLog(@"NOT found: regString:%@ match(%i,%i) %@", regString, match.location, match.length, attrString.string);
			}
            
			tagRange = [attrString.string rangeOfRegex:@"<[^>]+>"];
		}
        
	}
	while (tagRange.location != NSNotFound);
    
	NSRange newLinePlaceholder = [attrString.string rangeOfString:newLinePlaceHolder];
    
    [attributes setValue:self.font forKey:(id)kCTFontAttributeName];
    
	do
	{
		if (newLinePlaceholder.location != NSNotFound)
		{
			NSAttributedString * newLine = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
            
			[attrString replaceCharactersInRange:newLinePlaceholder withAttributedString:newLine];
		}
		newLinePlaceholder = [attrString.string rangeOfString:newLinePlaceHolder];
		
	}
	while (newLinePlaceholder.location != NSNotFound);
    
	return attrString;
}

CTFontRef CTFontCreateFromUIFont(UIFont * font)
{
    return CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                font.pointSize,
                                NULL);
}

@end

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
@synthesize numberOfLines       = _numberOfLines;
@synthesize lineSpacing         = _lineSpacing;
@synthesize numberOfColumns     = _numberOfColumns;
@synthesize columnMargin        = _columnMargin;
@synthesize textAlignment       = _textAlignment;

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    
	if (self)
	{
        [self setupInitDefaults];
	}
    
	return self;
}

- (id) init
{
	self = [super init];
    
	if (self)
	{
        [self setupInitDefaults];
	}
    
	return self;
}

- (void) setupInitDefaults
{
    // Force redraw on layout or frame changes
    [self setContentMode:UIViewContentModeRedraw];
    
    // Set default background color to clear
    self.backgroundColor = [UIColor clearColor];
    
    _defaultFontSize     = 18.f;
    _lineSpacing         = 0.f;
    _textAlignment       = NSTextAlignmentLeft;
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
    CFRange          fullStringRange = CFRangeMake(0, self.string.length);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, self.bounds);
    CTFrameRef aFrame = CTFramesetterCreateFrame(framesetter, fullStringRange, framePath, NULL);
    
    if (!aFrame)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0.f);
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(aFrame);
    CFIndex    count = CFArrayGetCount(lines);
    
    // Limit lines if self.numberOfLines != 0
    if (self.numberOfLines != 0 && count > self.numberOfLines)
    {
        count = self.numberOfLines;
    }
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(aFrame, CFRangeMake(0, count), origins);
    
    CGFloat height = 0.f;
    
    if (count-1 >= 0)
    {
        CGFloat ascent, descent, leading, width;
        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, count-1);
        width          = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        height         = ceilf(self.bounds.size.height - origins[count-1].y + descent);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //NSLog(@"drawRect rect => %@", NSStringFromCGRect(rect));
    
    // Fetch the context
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
    CFRange fullStringRange = CFRangeMake(0, self.string.length);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, rect);
    CTFrameRef aFrame = CTFramesetterCreateFrame(framesetter, fullStringRange, framePath, NULL);
    
    if (!aFrame)
    {
        return;
    }
    
    // Draw columns
    CFArrayRef columnPaths = [self columnPaths];
    CFIndex    pathCount   = CFArrayGetCount(columnPaths);
    
    CFIndex startIndex = 0;
    
    int column;
    for (column = 0; column < pathCount; column++)
    {
        CGRect columnFrame = CGRectFromString([[self columnFrames] objectAtIndex:column]);
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
        
        // Create a frame for this column and draw it.
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
        
        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex    count = CFArrayGetCount(lines);
        
        CGPoint origins[count];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins); // Fill origins[] buffer.
        
        // Draw every line but the last one (in last column)
        int total = (column == pathCount-1) ? count-1 : count;
        for (CFIndex i = 0; i < total; i++)
        {
            CGPoint point = CGPointMake(origins[i].x + columnFrame.origin.x, origins[i].y);
            CGContextSetTextPosition(context, point.x, point.y);
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
            CTLineDraw(line, context);
        }
        
        // Draw last (truncated) line for last column
        if (column == pathCount-1 && total < count)
        {
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
            
            CTLineRef truncated = CTLineCreateTruncatedLine(longLine, columnFrame.size.width, kCTLineTruncationEnd, truncationToken);
            CFRelease(longLine);
            CFRelease(truncationToken);
            
            // If 'truncated' is NULL, then no truncation was required to fit it
            if (truncated == NULL)
                truncated = (CTLineRef)CFRetain(lastLine);
            
            // Draw new line at the same offset as the non-truncated version
            CGContextSetTextPosition(context, lastOrigin.x+columnFrame.origin.x, lastOrigin.y);
            CTLineDraw(truncated, context);
            CFRelease(truncated);
        }
        
        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
    }
    CFRelease(columnPaths);
}

- (CFArrayRef) columnPaths
{
    NSArray        * frames = [self columnFrames];
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, frames.count, &kCFTypeArrayCallBacks);
    int               column;
    
    for (column = 0; column < frames.count; column++)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectFromString([frames objectAtIndex:column]));
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    
    return array;
}

- (NSArray *) columnFrames
{
    CGRect bounds          = self.bounds;
    int    numberOfColumns = MAX(self.numberOfColumns, 1);
    int    column;
    
    CGRect columnRects[numberOfColumns];
    
    // Start by setting the first column to cover the entire view.
    columnRects[0] = bounds;
    
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(bounds) / numberOfColumns;
    for (column = 0; column < numberOfColumns - 1; column++)
    {
        CGRectDivide(columnRects[column], &columnRects[column],&columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    // Add column margin
    if (numberOfColumns > 1)
    {
        for (column = 0; column < numberOfColumns; column++)
        {
            columnRects[column] = CGRectInset(columnRects[column], _columnMargin, 0.f);
        }
    }
    
    // Create an array of layout paths, one for each column.
    NSMutableArray * array = [NSMutableArray new];
    for (column = 0; column < numberOfColumns; column++)
    {
        [array addObject:NSStringFromCGRect(columnRects[column])];
    }
    
    return array;
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
    
    if (_lineSpacing < 0.f)
    {
        _lineSpacing = 0.f;
    }
    
    CTTextAlignment textAlignment = CTTextAlignmentFromNSTextAlignment(_textAlignment);
    
    CTParagraphStyleSetting setting[2] =
    {
        {
            kCTParagraphStyleSpecifierMinimumLineSpacing,
            sizeof(CGFloat),
            &_lineSpacing
        },
        {
            kCTParagraphStyleSpecifierAlignment,
            sizeof(CTTextAlignment),
            &textAlignment
        }
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, 2);
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)parentFont,  (id)kCTFontAttributeName,
                                        (__bridge id)parentColor, (id)kCTForegroundColorAttributeName,
                                        (__bridge id)paragraphStyle, (id)kCTParagraphStyleAttributeName,
                                        nil];
    
	if (html == nil || [html isKindOfClass:[NSString class]] == NO)
	{
		return [[NSMutableAttributedString alloc] initWithString:@""
                                                      attributes:attributes];
	}

    // Remove "self closing" tags
    html = [html stringByReplacingOccurrencesOfRegex:@"(<[a-zA-Z]+)([^>]+)(/>)"
                                          withString:@""];
    
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
    
    [attributes setValue:(__bridge id)(CTFontCreateFromUIFont(self.font))
                  forKey:(id)kCTFontAttributeName];
    
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

CTTextAlignment CTTextAlignmentFromNSTextAlignment(NSTextAlignment textAlignment)
{
    switch (textAlignment)
    {
        case NSTextAlignmentRight:
            return kCTTextAlignmentRight;
            break;
            
        case NSTextAlignmentJustified:
            return kCTTextAlignmentJustified;
            break;
            
        case NSTextAlignmentCenter:
            return kCTTextAlignmentCenter;
            break;
            
        case NSTextAlignmentNatural:
            return kCTTextAlignmentNatural;
            break;
            
        case NSTextAlignmentLeft:
        default:
            return kCTTextAlignmentLeft;
            break;
    }
}

@end

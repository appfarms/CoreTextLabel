//
//  CoreTextLabel.m
//  CoreTextLabel
//
//  Created by Daniel Kuhnke on 19.11.12.
//  Copyright (c) 2014 Daniel Kuhnke appfarms GmbH & Co. KG (http://www.appfarms.com/)
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
#import <AFMacros/AFMacros.h>
#import <RegexKitLite/RegexKitLite.h>
#import <NSString-HTML/NSString+HTML.h>

#define CORE_TEXT_SUPPORTED() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)

NSString * CoreTextLabelBlockKeyLinkPressed = @"CoreTextLabelBlockKeyLinkPressed";

@interface CoreTextLabel()

@property (nonatomic, retain) CATextLayer               * attributedTextLayer;
@property (nonatomic, assign) CTFramesetterRef            framesetter;
@property (nonatomic, retain) NSMutableAttributedString * framesetterString;
@property (nonatomic, retain) NSMutableArray            * linkArray;
@property (nonatomic, retain) NSMutableDictionary       * blocks;
@property (nonatomic, retain) NSTextCheckingResult      * activeLink;

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

- (id) init
{
    self = [super init];

    if (self)
    {
        [self setupInitDefaults];
    }

    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        [self setupInitDefaults];
    }

    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        [self setupInitDefaults];
    }

    return self;
}

- (void) setupInitDefaults
{
    self.linkArray = [NSMutableArray array];

    // Force redraw on layout or frame changes
    [self setContentMode:UIViewContentModeRedraw];

    // Set default background color to clear
    self.backgroundColor = [UIColor clearColor];

    _defaultFontSize     = 18.f;
    _lineSpacing         = 0.f;
    _textAlignment       = NSTextAlignmentLeft;
    _textIsTruncated     = NO;
}

- (void) dealloc
{
    if (_framesetter)
    {
        CFRelease(_framesetter);
        _framesetter = nil;
    }
}

#pragma mark - Setter

- (void) setString:(NSMutableAttributedString *)string
{
    @synchronized(_string)
    {
        _string = string;
        [self setNeedsDisplay];
    }
}

- (void) setHtml:(NSString *)html
{
    @synchronized(_html)
    {
        _html = html;
        [self setString:[self attributedStringByHTML:html]];
    }
}

- (void) setText:(NSString *)text
{
    @synchronized(_text)
    {
        _text = text;
        [self setString: [[NSMutableAttributedString alloc] initWithString:text
                                                                attributes:self.defaultAttributedStringAttributes]];
    }
}

- (void) setLinkPressedBlock:(void (^)(NSTextCheckingResult * textCheckingResult))linkPressedBlock
{
    if (linkPressedBlock)
    {
        if (AF_VALID(self.blocks, NSMutableDictionary) == NO)
        {
            self.blocks = [NSMutableDictionary dictionary];
        }

        self.blocks[CoreTextLabelBlockKeyLinkPressed] = [linkPressedBlock copy];
    }
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

- (UIFont *) linkFont
{
    if (!_linkFont)
    {
        self.linkFont = [UIFont systemFontOfSize:self.defaultFontSize];
    }

    return _linkFont;
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

- (UIColor *) linkTextColor
{
    if (!_linkTextColor)
    {
        self.linkTextColor = self.textColor;
    }

    return _linkTextColor;
}

- (CTFramesetterRef) framesetter
{
    BOOL stringIsDifferent = (AF_VALID(self.string, NSMutableAttributedString) == YES &&
                              AF_VALID(self.framesetterString, NSMutableAttributedString) == YES &&
                              [self.string isEqualToAttributedString:self.framesetterString] == NO);

    if (!_framesetter || stringIsDifferent == YES)
    {
        if (AF_VALID(self.string, NSMutableAttributedString))
        {
            if (stringIsDifferent && _framesetter)
            {
                CFRelease(_framesetter);
                _framesetter = nil;
            }

            if (self.string)
            {
                _framesetterString = [self.string mutableCopy];
                _framesetter       = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
            }
        }
    }

    return _framesetter;
}

//
// Method `linkAtCharacterIndex:` is original from TTTAttributedLabel.m
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
// https://github.com/mattt/TTTAttributedLabel
//
- (NSTextCheckingResult *) linkAtCharacterIndex:(CFIndex)idx
{
    NSEnumerator *enumerator = [self.linkArray reverseObjectEnumerator];
    NSTextCheckingResult *result = nil;

    while ((result = [enumerator nextObject]))
    {
        if (NSLocationInRange((NSUInteger)idx, result.range))
        {
            return result;
        }
    }

    return nil;
}

//
// Method `characterIndexAtPoint:` is original from TTTAttributedLabel.m
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
// https://github.com/mattt/TTTAttributedLabel
//
- (CFIndex) characterIndexAtPoint:(CGPoint)point
{
    CGRect textRect = self.bounds;

    if (!CGRectContainsPoint(textRect, point))
    {
        return NSNotFound;
    }

    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, self.string.length), path, NULL);
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }

    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }

    NSUInteger idx = NSNotFound;

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);

    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
    {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);

        // Check if we've already passed the line
        if (point.y > yMax)
        {
            break;
        }

        // Check if the point is within this line vertically
        if (point.y >= yMin)
        {
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width)
            {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }

    CFRelease(frame);
    CFRelease(path);

    return idx;
}

#pragma mark - Layout

- (void) sizeToFit
{
    CGRect frame = self.frame;
    frame.size   = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 10000.f)];
    self.frame = frame;
}

- (CGSize) sizeThatFits:(CGSize)size
{
    CGSize calcSize = CGSizeZero;

    if (AF_VALID_NOTEMPTY(self.string, NSMutableAttributedString) == NO || self.string.length == 0 || CGSizeEqualToSize(size, CGSizeZero) || !self.framesetter)
    {
        return calcSize;
    }

    CGRect           bounds          = CGRectMake(0.f, 0.f, size.width, size.height);
    CFRange          fullStringRange = CFRangeMake(0, self.string.length);
    CGMutablePathRef framePath       = CGPathCreateMutable();

    CGPathAddRect(framePath, nil, bounds);
    CTFrameRef aFrame = CTFramesetterCreateFrame(self.framesetter, fullStringRange, framePath, NULL);

    CFRelease(framePath);

    if (!aFrame || aFrame == NULL)
    {
        return calcSize;
    }

    CFArrayRef lines = CTFrameGetLines(aFrame);
    CFRetain(lines);
    CFIndex    count = CFArrayGetCount(lines);

    _textIsTruncated = NO;
    // Limit lines if self.numberOfLines != 0
    if (self.numberOfLines != 0 && count > self.numberOfLines)
    {
        _textIsTruncated = YES;
        count = self.numberOfLines;
    }

    CGPoint origins[count];
    CTFrameGetLineOrigins(aFrame, CFRangeMake(0, count), origins);

    if (aFrame)
    {
        CFRelease(aFrame);
    }

    CGFloat calcHeight = 0.f;
    CGFloat calcWidth  = 0.f;

    if (count > 0)
    {
        for (int lineIndex=0; lineIndex<count; lineIndex++)
        {
            CGFloat ascent, descent, leading, width;

            CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, lineIndex);
            width          = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
            calcHeight     = ceilf(bounds.size.height - origins[lineIndex].y + descent);

            if (width > calcWidth)
            {
                calcWidth = width;
            }
        }
    }

    if (lines)
    {
        CFRelease(lines);
    }

    calcSize.width  = (calcWidth <= size.width)   ? calcWidth  : size.width;
    calcSize.height = (calcHeight <= size.height) ? calcHeight : size.height;

    return calcSize;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];

    if (self.string == nil || [self.string isKindOfClass:[NSMutableAttributedString class]] == NO || self.string.length == 0)
    {
        return;
    }

    // Fetch the context
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CFRange fullStringRange = CFRangeMake(0, self.string.length);

    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, rect);
    CTFrameRef aFrame = CTFramesetterCreateFrame(self.framesetter, fullStringRange, framePath, NULL);

    if (!aFrame)
    {
        CFRelease(framePath);
        return;
    }

    // Draw columns
    CFArrayRef columnPaths = [self columnPaths];
    if (!columnPaths)
    {
        if (aFrame)
        {
            CFRelease(aFrame);
        }
        CFRelease(framePath);
        return;
    }

    CFIndex pathCount  = CFArrayGetCount(columnPaths);
    CFIndex startIndex = 0;

    int column;
    for (column = 0; column < pathCount; column++)
    {
        CGRect columnFrame = CGRectFromString([[self columnFrames] objectAtIndex:column]);
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);

        // Create a frame for this column and draw it.
        CTFrameRef frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(startIndex, 0), path, NULL);

        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex    count = CFArrayGetCount(lines);

        CGPoint origins[count];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins); // Fill origins[] buffer.

        // Draw every line but the last one (in last column)
        NSUInteger total = (column == pathCount-1) ? count-1 : count;
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
            if (truncated == NULL && lastLine)
            {
                truncated = (CTLineRef)CFRetain(lastLine);
            }

            // Draw new line at the same offset as the non-truncated version
            if (truncated)
            {
                CGContextSetTextPosition(context, lastOrigin.x+columnFrame.origin.x, lastOrigin.y);
                CTLineDraw(truncated, context);
                CFRelease(truncated);
            }

            _textIsTruncated = YES;
        }

        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
    }

    CFRelease(framePath);
    CFRelease(columnPaths);
    CFRelease(aFrame);
}

- (CFArrayRef) columnPaths
{
    CFMutableArrayRef   array = nil;
    NSArray           * frames = [self columnFrames];
    if (AF_VALID_NOTEMPTY(frames, NSArray))
    {
        array = CFArrayCreateMutable(kCFAllocatorDefault, frames.count, &kCFTypeArrayCallBacks);
        for (int column = 0; column < frames.count; column++)
        {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, CGRectFromString([frames objectAtIndex:column]));
            CFArrayInsertValueAtIndex(array, column, path);
            CFRelease(path);
        }
    }

    return array;
}

- (NSArray *) columnFrames
{
    CGRect     bounds          = self.bounds;
    NSUInteger numberOfColumns = MAX(self.numberOfColumns, 1);
    NSUInteger column;

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

#pragma mark - UIResponder / Link handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point   = [[touches anyObject] locationInView:self];
    CFIndex idx     = [self characterIndexAtPoint:point];
    self.activeLink = [self linkAtCharacterIndex:idx];

    if (!self.activeLink)
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink)
    {
        CGPoint point   = [[touches anyObject] locationInView:self];
        CFIndex idx     = [self characterIndexAtPoint:point];

        if ([self.activeLink isEqual:[self linkAtCharacterIndex:idx]] == NO)
        {
            self.activeLink = nil;
        }
    }
    else
    {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (AF_VALID(self.activeLink, NSTextCheckingResult) && self.blocks[CoreTextLabelBlockKeyLinkPressed])
    {
        void (^block)(NSTextCheckingResult * textCheckingResult);
        block = self.blocks[CoreTextLabelBlockKeyLinkPressed];
        if (block)
        {
            block(self.activeLink);
        }
    }
}

- (void) addLink:(NSURL*)url atRange:(NSRange)range
{
    [self addLink:url atRange:range inString:self.string];
    [self setNeedsDisplay];
}

- (void) addLink:(NSURL *)url atRange:(NSRange)range inString:(NSMutableAttributedString *)string
{
    if (AF_VALID_NOTEMPTY(string, NSMutableAttributedString) &&
        AF_VALID(url, NSURL) && NSLocationInRange(range.location, NSMakeRange(0, string.length)) &&
        (range.location+range.length) <= string.length &&
        AF_VALID(self.linkFont, UIFont) &&
        AF_VALID(self.linkTextColor, UIColor))
    {
        NSTextCheckingResult * textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:url];

        if (AF_VALID(textCheckingResult, NSTextCheckingResult))
        {
            CTFontRef font = CTFontCreateFromUIFont(self.linkFont);

            [string addAttributes:@{ (id)kCTForegroundColorAttributeName : (__bridge id)self.linkTextColor.CGColor, (id)kCTFontAttributeName : (__bridge id)font }
                            range:textCheckingResult.range];

            CFRelease(font);

            [self.linkArray addObject:textCheckingResult];
        }
    }
}

#pragma mark - HTML

- (NSMutableDictionary *) defaultAttributedStringAttributes
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

    CFRelease(paragraphStyle);
    CFRelease(parentFont);

    return attributes;
}

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html
{
    return [self attributedStringByHTML:[html kv_decodeHTMLCharacterEntities] parentTag:nil];
}

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html parentTag:(NSString *)parentTag
{
    NSString * urlString   = nil;
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

    CFRelease(paragraphStyle);

    if (html == nil || [html isKindOfClass:[NSString class]] == NO)
    {
        CFRelease(parentFont);
        return [[NSMutableAttributedString alloc] initWithString:@""
                                                      attributes:attributes];
    }

    // Fix newlines
    NSString * newLinePlaceHolder       = @"{BR}";
    NSString * doubleNewLinePlaceHolder = [NSString stringWithFormat:@"%@%@", newLinePlaceHolder, newLinePlaceHolder];

    // Replace newlines and global starting or ending p- and div-tags with empty string
    html = [html stringByReplacingOccurrencesOfRegex:@"[\\s]+"
                                          withString:@" "];

    html = [html stringByReplacingOccurrencesOfRegex:@"^<(p|div)[^>]*>"
                                          withString:@""];

    html = [html stringByReplacingOccurrencesOfRegex:@"</(p|div)>$"
                                          withString:@""];

    // Replace tags with newline placeholder
    html = [html stringByReplacingOccurrencesOfRegex:@"(</(p|div)>)([\\s]*)(<(p|div)[^>]*>)"
                                          withString:doubleNewLinePlaceHolder];

    html = [html stringByReplacingOccurrencesOfRegex:@"<(p|div)[^>]*>"
                                          withString:doubleNewLinePlaceHolder];

    html = [html stringByReplacingOccurrencesOfRegex:@"</(p|div)>"
                                          withString:doubleNewLinePlaceHolder];

    html = [html stringByReplacingOccurrencesOfRegex:@"<br[^>]*>"
                                          withString:newLinePlaceHolder];

    // Remove other unsupported tags
    html = [html stringByReplacingOccurrencesOfRegex:@"</?(?!a|b|i|em|strong)\\w+[^>]*>"
                                          withString:@""];

    // Remove spaces at line beginning after newline (that's how HTML would render it)
    html = [html stringByReplacingOccurrencesOfRegex:@"\\{BR\\}\\s*" withString:newLinePlaceHolder];

    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:html
                                                                                    attributes:attributes];

    NSRange newLinePlaceholder = [attrString.string rangeOfString:newLinePlaceHolder];

    CTFontRef attrFont = CTFontCreateFromUIFont(self.font);

    [attributes setValue:(__bridge id)(attrFont)
                  forKey:(id)kCTFontAttributeName];

    CFRelease(attrFont);

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

    if (parentTag)
    {
        if ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"])
        {
            CFRelease(parentFont);
            parentFont  = CTFontCreateFromUIFont(self.boldFont);
            parentColor = self.boldTextColor.CGColor;
        }
        if ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"])
        {
            CFRelease(parentFont);
            parentFont  = CTFontCreateFromUIFont(self.italicFont);
            parentColor = self.italicTextColor.CGColor;
        }
        if ([parentTag isEqualToString:@"a"])
        {
            CFRelease(parentFont);
            parentFont  = CTFontCreateFromUIFont(self.linkFont);
            parentColor = self.linkTextColor.CGColor;
        }
    }

    NSRange tagRange = [attrString.string rangeOfRegex:@"(<)([^>]+)(/>|>)"];

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
                if ([searchTag rangeOfString:@"href="].location != NSNotFound)
                {
                    urlString = [searchTag stringByReplacingOccurrencesOfRegex:@"(.*)(href=\\\")(.+?)(\\\")(.*)"
                                                                    withString:@"$3"];
                }

                NSInteger location = [searchTag rangeOfRegex:@" "].location;
                searchTag          = [searchTag stringByReplacingCharactersInRange:NSMakeRange(location, [searchTag length]-location) withString:@""];
            }

            NSString * regString = [NSString stringWithFormat:@"<%@[^>]*>(.*?)</%@>", searchTag, searchTag];
            NSRange    match     = [attrString.string rangeOfRegex:regString
                                                           options:RKLDotAll|RKLMultiline
                                                           inRange:NSMakeRange(0, attrString.string.length)
                                                           capture:0
                                                             error:nil];

            if (match.location != NSNotFound)
            {
                NSString * innerString = [attrString.string substringWithRange:match];

                innerString            = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"<%@[^>]*>", searchTag]
                                                                               withString:@""];

                innerString            = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"</%@>", searchTag]
                                                                               withString:@""];

                CTFontRef  matchFont  = parentFont;
                CGColorRef matchColor = parentColor;
                CFRetain(matchFont);

                if ([searchTag isEqualToString:@"b"] || [searchTag isEqualToString:@"strong"])
                {
                    CFRelease(matchFont);
                    matchFont  = CTFontCreateFromUIFont(self.boldFont);
                    matchColor = self.boldTextColor.CGColor;

                    if (parentTag && ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"]))
                    {
                        CFRelease(matchFont);
                        matchFont  = CTFontCreateFromUIFont(self.boldItalicFont);
                        matchColor = self.boldItalicTextColor.CGColor;
                    }
                }
                if ([searchTag isEqualToString:@"i"] || [searchTag isEqualToString:@"em"])
                {
                    CFRelease(matchFont);
                    matchFont  = CTFontCreateFromUIFont(self.italicFont);
                    matchColor = self.italicTextColor.CGColor;

                    if (parentTag && ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"]))
                    {
                        CFRelease(matchFont);
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

                if (AF_VALID_NOTEMPTY(urlString, NSString))
                {
                    [self addLink:[NSURL URLWithString:urlString]
                          atRange:NSMakeRange(match.location, innerAttrString.length)
                         inString:attrString];
                    urlString = nil;
                }


                CFRelease(matchFont);
            }
            else
            {
                NSLog(@"NOT found: regString:%@ match(%li,%li) %@", regString, (unsigned long)match.location, (unsigned long)match.length, attrString.string);
                tagRange = NSMakeRange(NSNotFound, 0);
                continue;
            }

            tagRange = [attrString.string rangeOfRegex:@"<[^>]+>"];
        }

    }
    while (tagRange.location != NSNotFound);
    
    CFRelease(parentFont);
    
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

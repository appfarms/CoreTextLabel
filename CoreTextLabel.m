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
#import "RegexKitLite.h"


#define CORE_TEXT_SUPPORTED() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)

@interface CoreTextLabel()

@property (nonatomic, retain) CATextLayer * attributedTextLayer;

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html parentTag:(NSString *)parentTag;

@end

@implementation CoreTextLabel

@synthesize regularFont         = _regularFont;
@synthesize boldFont            = _boldFont;
@synthesize italicFont          = _italicFont;
@synthesize boldItalicFont      = _boldItalicFont;
@synthesize textColor           = _textColor;

@synthesize attributedTextLayer = _attributedTextLayer;
@synthesize attributedString    = _attributedString;

- (id) initWithFrame:(CGRect)frame
{
  if (CORE_TEXT_SUPPORTED() == NO)
	{
		return nil;
	}
	
	self = [super initWithFrame:frame];
    
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		
		_attributedTextLayer               = [CATextLayer new];
		_attributedTextLayer.frame         = self.bounds;
		_attributedTextLayer.contentsScale = [[UIScreen mainScreen] scale];
		
		[self.layer addSublayer:_attributedTextLayer];
    
    self.layer.actions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [NSNull null], @"onOrderIn",
                          [NSNull null], @"onOrderOut",
                          [NSNull null], @"sublayers",
                          [NSNull null], @"contents",
                          [NSNull null], @"bounds",
                          [NSNull null], @"position",
                          nil];
    
    _attributedTextLayer.actions = self.layer.actions;
	}
	
	return self;
}

#pragma mark - Getter

+ (CGFloat) defaultFontSize
{
  return 12.f;
}

- (UIFont *) regularFont
{
  if (!_regularFont)
  {
    self.regularFont = [UIFont systemFontOfSize:[CoreTextLabel defaultFontSize]];
  }
  
  return _regularFont;
}

- (UIFont *) boldFont
{
  if (!_boldFont)
  {
    self.boldFont = [UIFont boldSystemFontOfSize:[CoreTextLabel defaultFontSize]];
  }
  
  return _boldFont;
}

- (UIFont *) italicFont
{
  if (!_italicFont)
  {
    self.italicFont = [UIFont italicSystemFontOfSize:[CoreTextLabel defaultFontSize]];
  }
  
  return _italicFont;
}

- (UIFont *) boldItalicFont
{
  if (!_boldItalicFont)
  {
    self.boldItalicFont = [UIFont italicSystemFontOfSize:[CoreTextLabel defaultFontSize]];
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

#pragma mark - Setter

- (void) setAttributedString:(NSMutableAttributedString *)attributedString
{
	_attributedString           = attributedString;
  _attributedTextLayer.string = _attributedString;
	[self setNeedsLayout];
}

#pragma mark - Layout

- (CGSize)suggestSizeAndFitRange:(CFRange *)range forAttributedString:(NSMutableAttributedString *)attrString usingSize:(CGSize)referenceSize
{
  CTFramesetterRef framesetter   = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
  CGSize           suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
																																								CFRangeMake(0, [attrString length]),
																																								NULL,
																																								referenceSize,
																																								range);
  
  //HACK: There is a bug in Core Text where suggested size is not quite right
  //I'm padding it with half line height to make up for the bug.
  //see the coretext-dev list: http://web.archiveorange.com/archive/v/nagQXwVJ6Gzix0veMh09
  
  CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
  CGFloat ascent, descent, leading;
  CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
  CGFloat lineHeight = ascent + descent + leading;
  suggestedSize.height += lineHeight / 2.f;
  //END HACK
  
  return suggestedSize;
}

- (void) layoutSubviews
{
  [super layoutSubviews];
  _attributedTextLayer.frame   = self.bounds;
  _attributedTextLayer.wrapped = YES;
}

- (void) sizeToFit
{
  CFRange fitRange;
  CGRect  textDisplayRect = CGRectMake(0, 0, self.bounds.size.width, 99999);
  CGSize  recommendedSize = [self suggestSizeAndFitRange:&fitRange
                                     forAttributedString:_attributedString
                                               usingSize:textDisplayRect.size];
  
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, recommendedSize.height);
  
  _attributedTextLayer.frame   = self.bounds;
  _attributedTextLayer.wrapped = YES;
}

#pragma mark - HTML

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html
{
	return [self attributedStringByHTML:html parentTag:nil];
}

- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html parentTag:(NSString *)parentTag
{
  NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.regularFont,       (id)NSFontAttributeName,
                                      self.textColor.CGColor, (id)kCTForegroundColorAttributeName,
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
	
	UIFont * parentFont = self.regularFont;
	
	NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:html
																																									attributes:attributes];
	
	if (parentTag)
	{
		if ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"])
		{
			parentFont = self.boldFont;
		}
		if ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"])
		{
			parentFont = self.italicFont;
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
			
			//NSLog(@"searchTag => %@", searchTag);
			
			NSString * regString = [NSString stringWithFormat:@"<%@[^>]*>(.*?)</%@>", searchTag, searchTag];
			NSRange match = [attrString.string rangeOfRegex:regString];
			
			if (match.location != NSNotFound)
			{
				NSString * innerString = [attrString.string substringWithRange:match];
				innerString = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"<%@[^>]*>", searchTag] withString:@""];
				innerString = [innerString stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"</%@>", searchTag] withString:@""];
				
				//NSLog(@"Found: regString:%@ match(%i,%i) htmlInnerString:%@", regString, match.location, match.length, innerString);
				
				UIFont * matchFont = parentFont;
				
				if ([searchTag isEqualToString:@"b"] || [searchTag isEqualToString:@"strong"])
				{
					matchFont = self.boldFont;
					
					if (parentTag && ([parentTag isEqualToString:@"i"] || [parentTag isEqualToString:@"em"]))
					{
						matchFont = self.boldItalicFont;
					}
				}
				if ([searchTag isEqualToString:@"i"] || [searchTag isEqualToString:@"em"])
				{
					matchFont = self.italicFont;
					
					if (parentTag && ([parentTag isEqualToString:@"b"] || [parentTag isEqualToString:@"strong"]))
					{
						matchFont = self.boldItalicFont;
					}
				}
        
        [attributes setValue:matchFont forKey:(id)kCTFontAttributeName];
				
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
	
  [attributes setValue:self.regularFont forKey:(id)kCTFontAttributeName];
  
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

@end

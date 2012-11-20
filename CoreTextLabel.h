//
//  CoreTextLabel.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface CoreTextLabel : UIView

@property (nonatomic, retain) UIFont                    * font;                /**< Default: [UIFont systemFontOfSize:] */
@property (nonatomic, retain) UIFont                    * boldFont;            /**< Default: [UIFont boldSystemFontOfSize:] */
@property (nonatomic, retain) UIFont                    * italicFont;          /**< Default: [UIFont italicSystemFontOfSize:] */
@property (nonatomic, retain) UIFont                    * boldItalicFont;      /**< Default: [UIFont italicSystemFontOfSize:] */
@property (nonatomic, retain) UIColor                   * textColor;           /**< Default: [UIColor blackColor] */
@property (nonatomic, retain) UIColor                   * boldTextColor;       /**< Default: self.textColor */
@property (nonatomic, retain) UIColor                   * italicTextColor;     /**< Default: self.textColor */
@property (nonatomic, retain) UIColor                   * boldItalicTextColor; /**< Default: self.textColor */
@property (nonatomic, retain) NSMutableAttributedString * attributedString;    /**< Default: nil */
@property (nonatomic, assign) CGFloat                     defaultFontSize;     /**< Default font size used if no fonts defined from outside => 18.f */

/**
 * Create NSMutableAttributedString by HTML string
 *
 * - text will be styled with self.font and self.textColor
 * - </p> and <br /> will be replaced by NEWLINE
 * - <b> and <strong> will be styled with self.boldFont and self.boldTextColor
 * - <i> and <em> will be styled with self.italicFont and self.italicTextColor
 * - <i>/<em> combined with <b>/<strong> will be styled with self.boldItalicFont and self.boldItalicTextColor
 */
- (NSMutableAttributedString *) attributedStringByHTML:(NSString *)html;

@end

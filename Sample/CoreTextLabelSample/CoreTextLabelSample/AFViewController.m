//
//  AFViewController.m
//  CoreTextLabelSample
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

#import "AFViewController.h"
#import "CoreTextLabel.h"

@interface AFViewController ()

@property (nonatomic, retain) CoreTextLabel * label;

@end

@implementation AFViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    if (!_label)
    {
        UIFont   * regularFont         = [UIFont fontWithName:@"Verdana" size:18];
        UIFont   * boldFont            = [UIFont fontWithName:@"Verdana-Bold" size:18];
        UIFont   * italicFont          = [UIFont fontWithName:@"Verdana-Italic" size:18];
        UIFont   * boldItalicFont      = [UIFont fontWithName:@"Verdana-BoldItalic" size:18];
        
        UIColor  * boldTextColor       = [UIColor blueColor];
        UIColor  * boldItalicTextColor = [UIColor redColor];
        UIColor  * italicTextColor     = [UIColor yellowColor];
        
        _label                     = [[CoreTextLabel alloc] initWithFrame:[self labelFrame]];
        _label.defaultFontSize     = 18;
        _label.font                = regularFont;
        _label.boldFont            = boldFont;
        _label.italicFont          = italicFont;
        _label.boldItalicFont      = boldItalicFont;
        _label.boldTextColor       = boldTextColor;
        _label.boldItalicTextColor = boldItalicTextColor;
        _label.italicTextColor     = italicTextColor;
        _label.linkTextColor       = [UIColor purpleColor];
        _label.string              = [_label attributedStringByHTML:[self html]];
        
//        [_label addLink:[NSURL URLWithString:@"adsadasdasdasdd"]
//                atRange:NSMakeRange(20, 100)];
        
        [_label setLinkPressedBlock:^(NSTextCheckingResult *textCheckingResult) {
            NSLog(@"textCheckingResult => %@", textCheckingResult);
        }];
        
        
        [self.view addSubview:_label];
    }
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _label.frame = [self labelFrame];
}

- (CGRect) labelFrame
{
    CGFloat padding = 10.f;
    return CGRectMake(padding, padding, self.view.frame.size.width-padding*2.f, self.view.frame.size.height-padding*2.f);
}

- (NSString *) html
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"html"]
                                     encoding:NSUTF8StringEncoding
                                        error:nil];
}

@end

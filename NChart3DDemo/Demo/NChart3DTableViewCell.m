/**
 * Disclaimer: IMPORTANT:  This Nulana software is supplied to you by Nulana
 * LTD ("Nulana") in consideration of your agreement to the following
 * terms, and your use, installation, modification or redistribution of
 * this Nulana software constitutes acceptance of these terms.  If you do
 * not agree with these terms, please do not use, install, modify or
 * redistribute this Nulana software.
 *
 * In consideration of your agreement to abide by the following terms, and
 * subject to these terms, Nulana grants you a personal, non-exclusive
 * license, under Nulana's copyrights in this original Nulana software (the
 * "Nulana Software"), to use, reproduce, modify and redistribute the Nulana
 * Software, with or without modifications, in source and/or binary forms;
 * provided that if you redistribute the Nulana Software in its entirety and
 * without modifications, you must retain this notice and the following
 * text and disclaimers in all such redistributions of the Nulana Software.
 * Except as expressly stated in this notice, no other rights or licenses, 
 * express or implied, are granted by Nulana herein, including but not limited 
 * to any patent rights that may be infringed by your derivative works or by other
 * works in which the Nulana Software may be incorporated.
 *
 * The Nulana Software is provided by Nulana on an "AS IS" basis.  NULANA
 * MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 * THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE, REGARDING THE NULANA SOFTWARE OR ITS USE AND
 * OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 *
 * IN NO EVENT SHALL NULANA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 * MODIFICATION AND/OR DISTRIBUTION OF THE NULANA SOFTWARE, HOWEVER CAUSED
 * AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 * STRICT LIABILITY OR OTHERWISE, EVEN IF NULANA HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (C) 2015 Nulana LTD. All Rights Reserved.
 */
 

#import "NChart3DTableViewCell.h"


@implementation NChart3DTableViewCell
{
    id  m_target;
    SEL m_action;
}

+ (NChart3DTableViewCell *)cellWithText:(NSString *)text target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    return [[[NChart3DTableViewCell alloc] initWithText:text target:target action:action tag:tag value:value] autorelease];
}

+ (NChart3DTableViewCell *)cellWithText:(NSString *)text subText:(NSString *)subText target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    return [[[NChart3DTableViewCell alloc] initWithText:text subText:subText target:target action:action tag:tag value:value] autorelease];
}

+ (NChart3DTableViewCell *)cellAsDisclosureWithText:(NSString *)text target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    return [[[NChart3DTableViewCell alloc] initAsDisclosureWithText:text target:target action:action tag:tag value:value] autorelease];
}

+ (NChart3DTableViewCell *)cellAsDisclosureWithText:(NSString *)text subText:(NSString *)subText target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    return [[[NChart3DTableViewCell alloc] initAsDisclosureWithText:text subText:subText target:target action:action tag:tag value:value] autorelease];
}

+ (NChart3DTableViewCell *)cellWithText:(NSString *)text image:(UIImage *)image target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    return [[[NChart3DTableViewCell alloc] initWithText:text image:image target:target action:action tag:tag value:value] autorelease];
}

- (id)initWithText:(NSString *)text target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self)
    {
        [self.textLabel setText:text];
        self.tag = tag;
        self.value = value;
        m_target = target;
        m_action = action;
    }
    return self;
}

- (id)initWithText:(NSString *)text subText:(NSString *)subText target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    if (self)
    {
        [self.textLabel setText:text];
        self.detailTextLabel.text = subText;
        self.tag = tag;
        self.value = value;
        m_target = target;
        m_action = action;
    }
    return self;
}

- (id)initAsDisclosureWithText:(NSString *)text target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self)
    {
        [self.textLabel setText:text];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.tag = tag;
        self.value = value;
        m_target = target;
        m_action = action;
    }
    return self;
}

- (id)initAsDisclosureWithText:(NSString *)text subText:(NSString *)subText target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    if (self)
    {
        [self.textLabel setText:text];
        self.detailTextLabel.text = subText;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.tag = tag;
        self.value = value;
        m_target = target;
        m_action = action;
    }
    return self;
}

- (id)initWithText:(NSString *)text image:(UIImage *)image target:(id)target action:(SEL)action tag:(NSInteger)tag value:(int)value
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self)
    {
        [self.textLabel setText:text];
        self.imageView.image = image;
        self.tag = tag;
        self.value = value;
        m_target = target;
        m_action = action;
    }
    return self;
}

- (void)dealloc
{
    self.spinner = nil;
    
    [super dealloc];
}

- (void)performAction
{
    [m_target performSelector:m_action withObject:self];
}

- (BOOL)checked
{
    return self.accessoryType == UITableViewCellAccessoryCheckmark;
}

- (void)setChecked:(BOOL)checked
{
    self.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)showWaiter
{
    if (!self.spinner)
        self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self addSubview:self.spinner];
    self.accessoryView = self.spinner;
    [self.spinner startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

- (void)hideWaiter
{
    [self.spinner stopAnimating];
    self.accessoryView = nil;
}

@end

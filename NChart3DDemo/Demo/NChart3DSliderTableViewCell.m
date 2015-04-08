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
 

#import "NChart3DSliderTableViewCell.h"


@implementation NChart3DSliderTableViewCell
{
    UISlider *m_slider;
}

+ (NChart3DSliderTableViewCell *)cellWithMin:(int)min max:(int)max target:(id)target action:(SEL)action tag:(NSInteger)tag
{
    return [[[NChart3DSliderTableViewCell alloc] initWithMin:min max:max target:target action:action tag:tag] autorelease];
}

- (id)initWithMin:(int)min max:(int)max target:(id)target action:(SEL)action tag:(NSInteger)tag
{
    self = [super initWithText:[NSString stringWithFormat:@"%d", min] target:target action:action tag:tag value:0];
    if (self)
    {
        m_slider = [UISlider new];
        [m_slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [m_slider addTarget:self action:@selector(sliderValueDidEndChanging:) forControlEvents:UIControlEventTouchUpInside];
        [m_slider addTarget:self action:@selector(sliderValueDidEndChanging:) forControlEvents:UIControlEventTouchUpOutside];
        [m_slider addTarget:self action:@selector(sliderValueDidCancelChanging:) forControlEvents:UIControlEventTouchCancel];
        m_slider.minimumValue = min;
        m_slider.maximumValue = max;
        self.accessoryType = UITableViewCellAccessoryNone;
        [self addSubview:m_slider];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc
{
    [m_slider release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    m_slider.frame = CGRectMake(50.0f, roundf((self.bounds.size.height - 27.0f) / 2.0f),
                                self.bounds.size.width - 75.0f, 27.0f);
}

- (int)minValue
{
    return m_slider.minimumValue;
}

- (void)setMinValue:(int)minValue
{
    m_slider.minimumValue = minValue;
}

- (int)maxValue
{
    return m_slider.maximumValue;
}

- (void)setMaxValue:(int)maxValue
{
    m_slider.maximumValue = maxValue;
}

- (int)currentValue
{
    return m_slider.value;
}

- (void)setCurrentValue:(int)currentValue
{
    m_slider.value = currentValue;
    [self sliderValueDidChange:nil];
}

- (void)sliderValueDidChange:(id)dummy
{
    [self.textLabel setText:[NSString stringWithFormat:@"%d", self.currentValue]];
}

- (void)sliderValueDidEndChanging:(id)dummy
{
    m_slider.value = self.currentValue;
    [self sliderValueDidChange:nil];
    [self performAction];
}

- (void)sliderValueDidCancelChanging:(id)dummy
{
    [self performSelectorOnMainThread:@selector(sliderValueDidEndChanging:) withObject:dummy waitUntilDone:NO];
}

@end

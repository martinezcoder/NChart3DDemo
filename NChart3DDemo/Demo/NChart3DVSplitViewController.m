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
 

#import "NChart3DVSplitViewController.h"


@interface NChart3DVSplitView : UIView

- (id)initWithSecondaryView:(UIView *)secondaryView andMainView:(UIView *)mainView;

@property (nonatomic, assign) float secondaryWidth;
@property (nonatomic, assign) BOOL secondaryViewShown;

@end

@implementation NChart3DVSplitView
{
    UIView *m_secondaryView;
    UIView *m_mainView;
    BOOL m_secondaryViewShown;
    BOOL m_secondaryRectSet;
    NSTimeInterval m_animDuration;
}

@synthesize secondaryViewShown = m_secondaryViewShown;

- (id)initWithSecondaryView:(UIView *)secondaryView andMainView:(UIView *)mainView
{
    self = [super init];
    if (self)
    {
        self.secondaryWidth = 320.0f;
        m_secondaryView = [secondaryView retain];
        m_mainView = [mainView retain];
        [self addSubview:m_secondaryView];
        [self addSubview:m_mainView];
        m_secondaryViewShown = !isIPhone();
        
        if (isIPhone())
        {
            /*UISwipeGestureRecognizer *leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(leftSwipe:)] autorelease];
            leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [self addGestureRecognizer:leftSwipeRecognizer];*/
            
            UISwipeGestureRecognizer *rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc]
                                                               initWithTarget:self action:@selector(rightSwipe:)] autorelease];
            rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            [self addGestureRecognizer:rightSwipeRecognizer];
        }
    }
    return self;
}

- (void)dealloc
{
    [m_secondaryView release];
    [m_mainView release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect secondaryRect, mainRect;
    
    if (isIPhone())
        self.secondaryWidth = self.bounds.size.width;
    
    if (m_secondaryViewShown)
    {
        secondaryRect = mainRect = self.bounds;
        secondaryRect.size.width = self.secondaryWidth;
        if (isIPhone())
        {
            mainRect.origin.x = -self.secondaryWidth - 1.0f;
        }
        else
        {
            mainRect.origin.x = self.secondaryWidth + 1.0f;
            mainRect.size.width -= self.secondaryWidth + 1.0f;
        }
        m_secondaryRectSet = YES;
    }
    else
    {
        if (m_secondaryRectSet)
            secondaryRect = m_secondaryView.frame;
        else
        {
            secondaryRect = self.bounds;
            secondaryRect.size.width = self.secondaryWidth;
            m_secondaryRectSet = YES;
        }
        if (isIPhone())
            secondaryRect.origin.x = secondaryRect.size.width;
        else
            secondaryRect.origin.x = -secondaryRect.size.width;
        mainRect = self.bounds;
    }
    
    if (m_animDuration > 0.0f)
    {
        if (m_mainView.frame.size.width < mainRect.size.width)
        {
            [UIView animateWithDuration:m_animDuration
                             animations:^{ m_secondaryView.frame = secondaryRect; m_mainView.frame = mainRect; }];
        }
        else
        {
            CGRect tmpMainRect = m_mainView.frame;
            tmpMainRect.origin.x = mainRect.origin.x;
            [UIView animateWithDuration:m_animDuration
                             animations:^{ m_secondaryView.frame = secondaryRect; m_mainView.frame = tmpMainRect; }
                             completion:^(BOOL finished){ m_mainView.frame = mainRect; }];
        }
        m_animDuration = 0.0f;
    }
    else
    {
        m_secondaryView.frame = secondaryRect;
        m_mainView.frame = mainRect;
    }
}

- (void)setSecondaryViewShown:(BOOL)secondaryViewShown
{
    m_secondaryViewShown = secondaryViewShown;
    m_animDuration = 0.25f;
    [self setNeedsLayout];
}

/*- (void)leftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    if (self.leftViewShown && [recognizer locationInView:self].x < self.leftWidth)
        self.leftViewShown = NO;
}*/

- (void)rightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    if (!(self.secondaryViewShown) && [recognizer locationInView:self].x < self.secondaryWidth)
        self.secondaryViewShown = NO;
}

@end

@implementation NChart3DVSplitViewController
{
    UIViewController *m_secondaryPanel;
    UIViewController *m_mainPanel;
    NChart3DVSplitView *m_view;
}

@synthesize secondaryPanel = m_secondaryPanel;
@synthesize mainPanel = m_mainPanel;

- (id)initWithSecondaryPanel:(UIViewController *)secondaryPanel andMainPanel:(UIViewController *)mainPanel
{
    self = [super init];
    if (self)
    {
        m_secondaryPanel = [secondaryPanel retain];
        m_mainPanel = [mainPanel retain];
    }
    return self;
}

- (void)dealloc
{
    [m_secondaryPanel release];
    [m_mainPanel release];
    [m_view release];
    
    [super dealloc];
}

- (void)loadView
{
    m_view = [[NChart3DVSplitView alloc] initWithSecondaryView:m_secondaryPanel.view andMainView:m_mainPanel.view];
    self.view = m_view;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView setAnimationsEnabled:YES];
}

- (BOOL)isUILocked
{
    return !(self.secondaryPanel.view.userInteractionEnabled);
}

- (void)setIsUILocked:(BOOL)isUILocked
{
    self.secondaryPanel.view.userInteractionEnabled = !isUILocked;
}

- (BOOL)isSettingsPanelShown
{
    return m_view.secondaryViewShown;
}

- (void)setIsSettingsPanelShown:(BOOL)isSettingsPanelShown
{
    m_view.secondaryViewShown = isSettingsPanelShown;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return isIPhone() ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}

@end

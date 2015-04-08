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
 

#import "MultipleViewsViewController.h"


@interface MultipleViewsView : UIView

@property (nonatomic, retain) NChartView *view1;
@property (nonatomic, retain) NChartView *view2;

@end

@implementation MultipleViewsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.view1 = [[[NChartView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.view1];
        self.view2 = [[[NChartView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.view2];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc
{
    self.view1 = nil;
    self.view2 = nil;
    
    [super dealloc];
}

- (void)layoutSubviews
{
    const float mrg = 20.0f; // Magin for iOS' status bar
    
    // Place views side by side in landscape interface orientation and one over another in portrait interface orientation
    if (self.bounds.size.width > self.bounds.size.height)
    {
        CGSize size = CGSizeMake(roundf(self.bounds.size.width / 2.0f), roundf(self.bounds.size.height - mrg));
        self.view1.frame = CGRectMake(0.0f, mrg, size.width, size.height);
        self.view2.frame = CGRectMake(size.width, mrg, size.width, size.height);
    }
    else
    {
        CGSize size = CGSizeMake(self.bounds.size.width, roundf((self.bounds.size.height - mrg) / 2.0f));
        self.view1.frame = CGRectMake(0.0f, mrg, size.width, size.height);
        self.view2.frame = CGRectMake(0.0f, size.height + mrg, size.width, size.height);
    }
}

@end

@implementation MultipleViewsViewController
{
    MultipleViewsView *m_view;
}

- (void)dealloc
{
    [m_view release];
    
    [super dealloc];
}

- (void)loadView
{
    // Create a view with two charts.
    m_view = [[MultipleViewsView alloc] initWithFrame:CGRectZero];
    
    // Paste your license key here.
    m_view.view1.chart.licenseKey = @"T8eJSp1MGDRzfvQqIYhLPpxMYmTP2LEuXo6PUpa2bqpl4yWwFg9ZSJIArbYLGZYyfffCf2CyJmZ6oNs7YKszWHz93UE6xxVeW2UeX6jbSm8VYLg+1wo74s/o/MEAB+02SE8RiAgI3rVbhBOTgoW3KweH3k7T3422KubGBJURv3bHsimpl7jfYYSc+kKq6FXY850todatkDgCJ1BxL8zFMVQ4G0D2EXXS8B7HKKCjG2rglSMOnCJfypYYv/GAFSKOB9RJYZv0uXw3BK0h860eGzX8ktcwJGHl7w7esN08f4YrVhBwXnHvN20Txv9f9IO4RMwYwu4tz+Cz116tHAy/zcLOehrWLUARf6vxDywfxOsjyDkNoZiK3nzsN3OfAwKmcpXZo8EJmZxKc19PuJscLauIiv8upkq/vaI9JGwBs7hvDvt7VR9Vi7eAOCCy3F11nn1CiRjWB/mjiFPHeguqBVmXCopWYjv0P9qgOLuVvJZ70I1iV+YdzHzfM5I5q4eCEXjs1P2iFAChN5+W/RLfUu5uTxLUceD3d0Au7E6lVO7HNduCVn6/6lOsh8J9IrggAjvKLU/jFTL5bFoWtAUNkjkJ9EiDvQQtF3EJ60SgqHzsu4NfF3eXqtXnD6a8uvyqkjQAjTFZ6V6NSWe4orVTzvZR+xUnf5ZUOhJj53OEQfA=";
    // And here.
    m_view.view2.chart.licenseKey = @"T8eJSp1MGDRzfvQqIYhLPpxMYmTP2LEuXo6PUpa2bqpl4yWwFg9ZSJIArbYLGZYyfffCf2CyJmZ6oNs7YKszWHz93UE6xxVeW2UeX6jbSm8VYLg+1wo74s/o/MEAB+02SE8RiAgI3rVbhBOTgoW3KweH3k7T3422KubGBJURv3bHsimpl7jfYYSc+kKq6FXY850todatkDgCJ1BxL8zFMVQ4G0D2EXXS8B7HKKCjG2rglSMOnCJfypYYv/GAFSKOB9RJYZv0uXw3BK0h860eGzX8ktcwJGHl7w7esN08f4YrVhBwXnHvN20Txv9f9IO4RMwYwu4tz+Cz116tHAy/zcLOehrWLUARf6vxDywfxOsjyDkNoZiK3nzsN3OfAwKmcpXZo8EJmZxKc19PuJscLauIiv8upkq/vaI9JGwBs7hvDvt7VR9Vi7eAOCCy3F11nn1CiRjWB/mjiFPHeguqBVmXCopWYjv0P9qgOLuVvJZ70I1iV+YdzHzfM5I5q4eCEXjs1P2iFAChN5+W/RLfUu5uTxLUceD3d0Au7E6lVO7HNduCVn6/6lOsh8J9IrggAjvKLU/jFTL5bFoWtAUNkjkJ9EiDvQQtF3EJ60SgqHzsu4NfF3eXqtXnD6a8uvyqkjQAjTFZ6V6NSWe4orVTzvZR+xUnf5ZUOhJj53OEQfA=";
    
    // Create column series for the first view on the screen.
    NChartColumnSeries *series1 = [[NChartColumnSeries new] autorelease];
    series1.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.38f
                                                                                    green:0.8f
                                                                                     blue:0.91f
                                                                                    alpha:1.0f]];
    series1.tag = 1;
    series1.dataSource = self;
    m_view.view1.chart.shouldAntialias = YES;
    [m_view.view1.chart addSeries:series1];
    [m_view.view1.chart updateData];
    
    // Create area series for the second view in the screen.
    NChartAreaSeries *series2 = [[NChartAreaSeries new] autorelease];
    series2.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.79f
                                                                                    green:0.86f
                                                                                     blue:0.22f
                                                                                    alpha:0.8f]];
    series2.tag = 2;
    series2.dataSource = self;
    m_view.view2.chart.shouldAntialias = YES;
    [m_view.view2.chart addSeries:series2];
    [m_view.view2.chart updateData];
    
    // Set chart view to the controller.
    self.view = m_view;
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    // Create points with some data for the series.
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i <= 10; ++i)
    {
        [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i Y:(rand() % 30) + 1]
                                            forSeries:series]];
    }
    return result;
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    // Get name of the series.
    return [NSString stringWithFormat:@"My series %d", (int)series.tag];
}

@end

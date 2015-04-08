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
 

#import "SecondaryAxisViewController.h"


@implementation SecondaryAxisViewController
{
    NChartView *m_view;
}

- (void)dealloc
{
    [m_view release];
    
    [super dealloc];
}

- (void)loadView
{
    // Create a chart view that will display the chart.
    m_view = [[NChartView alloc] initWithFrame:CGRectZero];
    
    // Paste your license key here.
    m_view.chart.licenseKey = @"T8eJSp1MGDRzfvQqIYhLPpxMYmTP2LEuXo6PUpa2bqpl4yWwFg9ZSJIArbYLGZYyfffCf2CyJmZ6oNs7YKszWHz93UE6xxVeW2UeX6jbSm8VYLg+1wo74s/o/MEAB+02SE8RiAgI3rVbhBOTgoW3KweH3k7T3422KubGBJURv3bHsimpl7jfYYSc+kKq6FXY850todatkDgCJ1BxL8zFMVQ4G0D2EXXS8B7HKKCjG2rglSMOnCJfypYYv/GAFSKOB9RJYZv0uXw3BK0h860eGzX8ktcwJGHl7w7esN08f4YrVhBwXnHvN20Txv9f9IO4RMwYwu4tz+Cz116tHAy/zcLOehrWLUARf6vxDywfxOsjyDkNoZiK3nzsN3OfAwKmcpXZo8EJmZxKc19PuJscLauIiv8upkq/vaI9JGwBs7hvDvt7VR9Vi7eAOCCy3F11nn1CiRjWB/mjiFPHeguqBVmXCopWYjv0P9qgOLuVvJZ70I1iV+YdzHzfM5I5q4eCEXjs1P2iFAChN5+W/RLfUu5uTxLUceD3d0Au7E6lVO7HNduCVn6/6lOsh8J9IrggAjvKLU/jFTL5bFoWtAUNkjkJ9EiDvQQtF3EJ60SgqHzsu4NfF3eXqtXnD6a8uvyqkjQAjTFZ6V6NSWe4orVTzvZR+xUnf5ZUOhJj53OEQfA=";
    
    // Margin to ensure some free space for the iOS status bar.
    m_view.chart.cartesianSystem.margin = NChartMarginMake(10.0f, 10.0f, 10.0f, 20.0f);
    
    // Array of colors for the series.
    CGFloat colors[3][3] =
    {
        { 0.38f, 0.8f, 0.91f },
        { 0.79f, 0.86f, 0.22f },
        { 0.9f, 0.29f, 0.51f }
    };
    
    // Create column series with colors from an array and add them to the chart.
    for (int i = 0; i < 3; ++i)
    {
        NChartColumnSeries *series = [[NChartColumnSeries new] autorelease];
        series.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:colors[i][0]
                                                                                       green:colors[i][1]
                                                                                        blue:colors[i][2]
                                                                                       alpha:1.0f]];
        series.dataSource = self;
        
        // The third series should be hosted on the secondary Y-Axis (so called SY-Axis).
        if (i == 2)
            series.hostsOnSY = YES;
        
        // A tag is used to get data for a particular series in the data source.
        series.tag = i;
        
        [m_view.chart addSeries:series];
    }
    
    // Set data source for the X- and SY-Axis to have custom values on them.
    m_view.chart.cartesianSystem.xAxis.dataSource = self;
    m_view.chart.cartesianSystem.syAxis.dataSource = self;
    
    // Update data in the chart.
    [m_view.chart updateData];
    
    // Set chart view to the controller.
    self.view = m_view;
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    // Create points with some data for the series.
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < 10; ++i)
    {
        // Let series with tag 2 have bigger values than others.
        [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i Y:((rand() % 25) + 1) * (series.tag == 2 ? 2 : 1)]
                                            forSeries:series]];
    }
    return result;
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    // Get name of the series.
    return [NSString stringWithFormat:@"My series %d", (int)series.tag + 1];
}

#pragma mark - NChartValueAxisDataSource

- (NSArray *)valueAxisDataSourceTicksForValueAxis:(NChartValueAxis *)axis
{
    // Choose ticks by the kind of axis.
    switch (axis.kind)
    {
        case NChartValueAxisX:
        {
            // Return 10 ticks for the X-Axis representing, let us say, years.
            NSMutableArray *result = [NSMutableArray array];
            for (int i = 2000; i < 2010; ++i)
                [result addObject:[NSString stringWithFormat:@"%d", i]];
            return result;
        }
            
        default:
            // Other axes have no ticks.
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceMinForValueAxis:(NChartValueAxis *)axis
{
    // Choose min by the kind of axis.
    switch (axis.kind)
    {
        case NChartValueAxisSY:
            // We want SY-Axis to have a custom min value.
            return @1.0f;
            
        default:
            // All other axes should have the min calculated.
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceMaxForValueAxis:(NChartValueAxis *)axis
{
    // Choose max by the kind of axis.
    switch (axis.kind)
    {
        case NChartValueAxisSY:
            // We want SY-Axis to have a custom max value.
            return @56.0f;
            
        default:
            // All other axes should have the max calculated.
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceStepForValueAxis:(NChartValueAxis *)axis
{
    // Choose step by the kind of axis.
    switch (axis.kind)
    {
        case NChartValueAxisSY:
            // We want SY-Axis to have a custom step value.
            return @11.0f;
            
        default:
            // All other axes should have the step calculated.
            return nil;
    }
}

@end

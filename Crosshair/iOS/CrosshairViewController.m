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
 

#import "CrosshairViewController.h"


@implementation CrosshairViewController
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
    
    // Create series that will be displayed on the chart.
    NChartAreaSeries *series = [[NChartAreaSeries new] autorelease];
    
    // Set brush that will fill that series with color.
    series.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.38f green:0.8f blue:0.91f alpha:0.9f]];
    
    // Set data source for the series.
    series.dataSource = self;
    
    // Add series to the chart.
    [m_view.chart addSeries:series];
    
    // Create crosshair.
    NChartCrosshair *cs = [NChartCrosshair crosshair];
    
    // Set color for crosshair's haris.
    [cs.xHair setColor:[UIColor redColor]];
    [cs.yHair setColor:[UIColor blueColor]];
    
    // Set thickness for crosshair's hairs.
    cs.thickness = 2.0f;
    
    // Set value for crosshair. Alternatively it's possible to create crosshair connected to chart point using the method
    // + (NChartCrosshair *)crosshairWithColor:(UIColor *)color thickness:(float)thickness andTargetPoint:(NChartPoint *)targetPoint;
    cs.xHair.value = 5.25;
    cs.yHair.value = 13.0;
    
    // Set crosshair delegate to handle moving.
    cs.delegate = self;
    
    // Set crosshair snapping to X-Axis ticks.
    cs.xHair.snapToMinorTicks = YES;
    cs.xHair.snapToMajorTicks = YES;
    
    // Add tooltip to the hair parallel to Y-Axis.
    cs.xHair.tooltip = [self createTooltip];
    [self updateTooltipText:cs.xHair.tooltip value:cs.xHair.value];
    
    // Add crosshair to the chart's coordinate system.
    [m_view.chart.cartesianSystem addCrosshair:cs];
    
    // Update data in the chart.
    [m_view.chart updateData];
    
    // Set chart view to the controller.
    self.view = m_view;
}

- (NChartTooltip *)createTooltip
{
    NChartTooltip *result = [[NChartTooltip new] autorelease];
    
    result.background = [NChartSolidColorBrush solidColorBrushWithColor:
                         [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    result.background.opacity = 0.9f;
    result.padding = NChartMarginMake(10.0f, 10.0f, 10.0f, 10.0f);
    result.borderColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    result.borderThickness = 1.0f;
    result.font = [UIFont systemFontOfSize:16.0f];
    
    return result;
}

- (void)updateTooltipText:(NChartTooltip *)tooltip value:(double)value
{
    tooltip.text = [NSString stringWithFormat:@"%.2f", value];
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    // Create points with some data for the series.
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i <= 10; ++i)
        [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i Y:(rand() % 30) + 1] forSeries:series]];
    return result;
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    // Get name of the series.
    return @"My series";
}

#pragma mark - NChartCrosshairDelegate

- (void)crosshairDelegateCrosshairDidMove:(NChartCrosshair *)crosshair
{
    [self updateTooltipText:crosshair.xHair.tooltip value:crosshair.xHair.value];
}

- (void)crosshairDelegateCrosshairDidEndMoving:(NChartCrosshair *)crosshair
{
    [self updateTooltipText:crosshair.xHair.tooltip value:crosshair.xHair.value];
}

@end

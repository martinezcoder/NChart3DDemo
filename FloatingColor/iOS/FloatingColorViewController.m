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
 

#import "FloatingColorViewController.h"

#define R 0.38f
#define G 0.8f
#define B 0.91f


@implementation FloatingColorViewController
{
    NChartView *m_view;
    NSTimer *m_timer;
    double m_t;
    double m_length;
}

- (void)dealloc
{
    [m_view release];
    [m_timer invalidate];
    [m_timer release];
    
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
    
    // Create line series that will be displayed on the chart.
    NChartLineSeries *series = [[NChartLineSeries new] autorelease];
    
    // Set brush that will fill that series with color.
    series.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:R green:G blue:B alpha:1.0f]];
    
    // Take control over marker's size.
    m_view.chart.sizeAxis.dataSource = self;
    
    // Set data source for the series.
    series.dataSource = self;
    
    // Switch off the offset on the X-Axis, which is on by default.
    m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
    
    // Add series to the chart.
    [m_view.chart addSeries:series];
    
    // Update data in the chart.
    [m_view.chart updateData];
    
    // Set chart view to the controller.
    self.view = m_view;
    
    // Now simulate some process. Let's assume, the process is associated with parameter m_t, where m_t = 0 means
    // that the process is not even started and m_t = 1 means that the process is ended. We change the color of the line
    // to display the process. For that, we will change m_t from 0 to 1 within, say, 5 sec. To simulate the process we
    // use the simple timer, updating the state every 1/30 sec.
    m_timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES] retain];
}

- (void)timer:(id)dummy
{
    // Update chart data to display process.
    
    if (m_t >= 1.0f)
    {
        // Process ended, stop timer.
        [m_timer invalidate];
        [m_timer release], m_timer = nil;
        
        // Color all the points.
        NSArray *points = ((NChartSeries *)(m_view.chart.series.lastObject)).points;
        for (NSUInteger i = 0, n = points.count; i < n; ++i)
        {
            NChartSolidColorBrush *brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
            ((NChartPoint *)points[i]).currentState.brush = brush;
            ((NChartPoint *)points[i]).currentState.marker.brush = brush;
        }
        
        // Update data in the chart. For that we usr lightweight method that does not relaod data from data source,
        // because we just updated some info in the existing points.
        [m_view.chart updateSeries];
        
        // Exit.
        return;
    }
    
    // The idea of displaying process is to change colors of i-th and (i+1)-th chart points for each m_t and
    // therefore to make the color "float" through the segment.
    
    // Firsly find out the points according to current m_t.
    NChartPointState *s1 = nil, *s2 = nil;
    NSArray *points = ((NChartSeries *)(m_view.chart.series.lastObject)).points;
    double s = m_t * m_length;
    double curLen = 0.0, prevLen = 0.0;
    NSUInteger i, n;
    for (i = 0, n = points.count - 1; i < n; ++i)
    {
        s1 = ((NChartPoint *)points[i]).currentState;
        s2 = ((NChartPoint *)points[i + 1]).currentState;
        prevLen = curLen;
        curLen += hypot(s2.doubleX - s1.doubleX, s2.doubleY - s1.doubleY);
        if (prevLen <= s && curLen >= s)
            break;
    }
    
    // Secondly determine the color for the points to display the process. The color over the line is calculated
    // automatically through the linear interpolation.
    double c = curLen - prevLen;
    if (c > 0.0)
        c = (s - prevLen) / c;
    else
        c = 1.0;
    if (c < 0.5)
    {
        c *= 2.0;
        NChartSolidColorBrush *brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:c + (1.0f - c) * R green:(1.0f - c) * G blue:(1.0f - c) * B alpha:1.0f]];
        s1.brush = brush;
        s1.marker.brush = brush;
    }
    else
    {
        c = (c - 0.5) * 2.0;
        NChartSolidColorBrush *redBrush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
        NChartSolidColorBrush *brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:c + (1.0f - c) * R green:(1.0f - c) * G blue:(1.0f - c) * B alpha:1.0f]];
        s1.brush = redBrush;
        s1.marker.brush = redBrush;
        s2.brush = brush;
        s2.marker.brush = brush;
    }
    
    // All the previous points should be colored.
    for (int j = 0; j < i; ++j)
    {
        NChartSolidColorBrush *brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
        ((NChartPoint *)points[j]).currentState.brush = brush;
        ((NChartPoint *)points[j]).currentState.marker.brush = brush;
    }
    
    // Update data in the chart. For that we usr lightweight method that does not relaod data from data source,
    // because we just updated some info in the existing points.
    [m_view.chart updateSeries];
    
    // Update the virtual process we display.
    m_t += 1.0 / 30.0 / 5.0;
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    // Create points for series as seen on the picture. A bit wired logic: we double the points in the middle of
    // line to have individual segments. This will help us to achieve the effect of floating color. Also we calculate
    // the length of the line.
    NSMutableArray *result = [NSMutableArray array];
    m_length = 0.0;
    for (int i = 1, n = 11; i < n; ++i)
    {
        int value = (rand() % 30) + 1;
        NChartPointState *state = [NChartPointState pointStateAlignedToXWithX:i Y:value];
        
        // Let the line have markers in the points.
        state.marker = [[NChartMarker new] autorelease];
        state.marker.shape = NChartMarkerShapeCircle;
        if (i > 1)
        {
            NChartPointState *prevState = ((NChartPoint *)(result.lastObject)).currentState;
            m_length += hypot(state.doubleX - prevState.doubleX, state.doubleY - prevState.doubleY);
        }
        [result addObject:[NChartPoint pointWithState:state forSeries:series]];
        if (i > 1 && i < n - 1)
        {
            NChartPointState *addlState = [NChartPointState pointStateAlignedToXWithX:i Y:value];
            addlState.marker = [[NChartMarker new] autorelease];
            addlState.marker.shape = NChartMarkerShapeCircle;
            [result addObject:[NChartPoint pointWithState:addlState forSeries:series]];
        }
    }
    return result;
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    // Get name of the series.
    return @"My series";
}

#pragma mark - NChartSizeAxisDataSource

- (float)sizeAxisDataSourceMinSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    // Min size for markers in pixels.
    return 10.0f;
}

- (float)sizeAxisDataSourceMaxSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    // Max size for markers in pixels.
    return 10.0f;
}

@end

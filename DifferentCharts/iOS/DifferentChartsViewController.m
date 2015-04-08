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
 

#import "DifferentChartsViewController.h"


@implementation DifferentChartsViewController
{
    NChartView *m_view;
}

- (void)dealloc
{
    [m_view release];
    self.brushes = nil;
    
    [super dealloc];
}

- (void)loadView
{
    // Create a chart view that will display the chart.
    m_view = [[NChartView alloc] initWithFrame:CGRectZero];
    
    // Paste your license key here.
    m_view.chart.licenseKey = @"T8eJSp1MGDRzfvQqIYhLPpxMYmTP2LEuXo6PUpa2bqpl4yWwFg9ZSJIArbYLGZYyfffCf2CyJmZ6oNs7YKszWHz93UE6xxVeW2UeX6jbSm8VYLg+1wo74s/o/MEAB+02SE8RiAgI3rVbhBOTgoW3KweH3k7T3422KubGBJURv3bHsimpl7jfYYSc+kKq6FXY850todatkDgCJ1BxL8zFMVQ4G0D2EXXS8B7HKKCjG2rglSMOnCJfypYYv/GAFSKOB9RJYZv0uXw3BK0h860eGzX8ktcwJGHl7w7esN08f4YrVhBwXnHvN20Txv9f9IO4RMwYwu4tz+Cz116tHAy/zcLOehrWLUARf6vxDywfxOsjyDkNoZiK3nzsN3OfAwKmcpXZo8EJmZxKc19PuJscLauIiv8upkq/vaI9JGwBs7hvDvt7VR9Vi7eAOCCy3F11nn1CiRjWB/mjiFPHeguqBVmXCopWYjv0P9qgOLuVvJZ70I1iV+YdzHzfM5I5q4eCEXjs1P2iFAChN5+W/RLfUu5uTxLUceD3d0Au7E6lVO7HNduCVn6/6lOsh8J9IrggAjvKLU/jFTL5bFoWtAUNkjkJ9EiDvQQtF3EJ60SgqHzsu4NfF3eXqtXnD6a8uvyqkjQAjTFZ6V6NSWe4orVTzvZR+xUnf5ZUOhJj53OEQfA=";
    
    // Create brushes.
    self.brushes = [NSMutableArray array];
    [self.brushes addObject:[NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.38f green:0.8f blue:0.91f alpha:1.0f]]];
    [self.brushes addObject:[NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.8f green:0.86f blue:0.22f alpha:1.0f]]];
    [self.brushes addObject:[NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:0.9f green:0.29f blue:0.51f alpha:1.0f]]];
    
    // Switch this field to view all types of series.
    self.type = TypeColumn3D;
    
    // Switch on antialiasing.
    m_view.chart.shouldAntialias = YES;
    
    if (self.type >= TypeColumn3D)
    {
        // Switch 3D on.
        m_view.chart.drawIn3D = YES;
        // Margin to ensure some free space for the iOS status bar and Y-axis tick titles.
        m_view.chart.cartesianSystem.margin = NChartMarginMake(50.0f, 50.0f, 10.0f, 20.0f);
        m_view.chart.polarSystem.margin = NChartMarginMake(50.0f, 50.0f, 10.0f, 20.0f);
    }
    else
    {
        // Margin to ensure some free space for the iOS status bar.
        m_view.chart.cartesianSystem.margin = NChartMarginMake(10.0f, 10.0f, 10.0f, 20.0f);
        m_view.chart.polarSystem.margin = NChartMarginMake(10.0f, 10.0f, 10.0f, 20.0f);
    }
    
    // Set data source for the size axis to provide sizes for bubbles.
    m_view.chart.sizeAxis.dataSource = self;
    
    // Create series that will be displayed on the chart.
    [self createSeries];
    
    // Update data in the chart.
    [m_view.chart updateData];
    
    // Set chart view to the controller.
    self.view = m_view;
}

- (void)createSeries
{
    // Create series.
    switch (self.type)
    {
        case TypeColumn2D:
        case TypeColumn3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartColumnSeries *series = [NChartColumnSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartColumnSeriesSettings *settings = [NChartColumnSeriesSettings seriesSettings];
            settings.cylindersResolution = 4;
            settings.shouldSmoothCylinders = NO;
            [m_view.chart addSeriesSettings:settings];
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeColumnCylinder:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartColumnSeries *series = [NChartColumnSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartColumnSeriesSettings *settings = [NChartColumnSeriesSettings seriesSettings];
            settings.cylindersResolution = 20;
            settings.shouldSmoothCylinders = YES;
            [m_view.chart addSeriesSettings:settings];
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeBar2D:
        case TypeBar3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartBarSeries *series = [NChartBarSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartBarSeriesSettings *settings = [NChartBarSeriesSettings seriesSettings];
            settings.cylindersResolution = 4;
            settings.shouldSmoothCylinders = NO;
            [m_view.chart addSeriesSettings:settings];
            m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.yAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeBarCylinder:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartBarSeries *series = [NChartBarSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartBarSeriesSettings *settings = [NChartBarSeriesSettings seriesSettings];
            settings.cylindersResolution = 20;
            settings.shouldSmoothCylinders = YES;
            [m_view.chart addSeriesSettings:settings];
            m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.yAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeArea2D:
        case TypeArea3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartAreaSeries *series = [NChartAreaSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeLine2D:
        case TypeLine3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartLineSeries *series = [NChartLineSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = self.brushes[i];
                series.lineThickness = 3.0f;
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeStep2D:
        case TypeStep3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartStepSeries *series = [NChartStepSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = self.brushes[i];
                series.lineThickness = 3.0f;
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeRibbon:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartRibbonSeries *series = [NChartRibbonSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypePie2D:
        case TypePie3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartPieSeries *series = [NChartPieSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
            settings.holeRatio = 0.0f;
            [m_view.chart addSeriesSettings:settings];
        }
            break;
            
        case TypeDoughnut2D:
        case TypeDoughnut3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartPieSeries *series = [NChartPieSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = (NChartSolidColorBrush *)self.brushes[i];
                [m_view.chart addSeries:series];
            }
            NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
            settings.holeRatio = 0.1f;
            [m_view.chart addSeriesSettings:settings];
        }
            break;
            
        case TypeBubble2D:
        case TypeBubble3D:
        case TypeScatter2D:
        case TypeScatter3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartBubbleSeries *series = [NChartBubbleSeries series];
                series.dataSource = self;
                series.tag = i;
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = NO;
        }
            break;
            
        case TypeSurface:
        {
            NChartSurfaceSeries *series = [NChartSurfaceSeries series];
            series.dataSource = self;
            series.tag = 0;
            [m_view.chart addSeries:series];
            
            m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = NO;
        }
            break;
            
        case TypeCandlestick2D:
        case TypeCandlestick3D:
        {
            NChartCandlestickSeries *series = [NChartCandlestickSeries series];
            series.dataSource = self;
            series.tag = 0;
            series.positiveColor = [UIColor colorWithRed:0.28f green:0.88f blue:0.55f alpha:1.0f];
            series.positiveBorderColor = [UIColor colorWithRed:0.25f green:0.8f blue:0.15f alpha:1.0f];
            series.negativeColor = [UIColor colorWithRed:0.87f green:0.28f blue:0.28f alpha:1.0f];
            series.negativeBorderColor = [UIColor colorWithRed:0.78f green:0.1f blue:0.2f alpha:1.0f];
            series.borderThickness = 3.0f;
            [m_view.chart addSeries:series];
            
            NChartCandlestickSeriesSettings *settings = [NChartCandlestickSeriesSettings seriesSettings];
            settings.cylindersResolution = 20;
            [m_view.chart addSeriesSettings:settings];
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeOHLC2D:
        case TypeOHLC3D:
        {
            NChartOHLCSeries *series = [NChartOHLCSeries series];
            series.dataSource = self;
            series.tag = 0;
            series.positiveColor = [UIColor colorWithRed:0.28f green:0.88f blue:0.55f alpha:1.0f];
            series.negativeColor = [UIColor colorWithRed:0.87f green:0.28f blue:0.28f alpha:1.0f];
            series.borderThickness = 1.0f;
            [m_view.chart addSeries:series];
            
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeBand:
        {
            NChartBandSeries *series = [NChartBandSeries series];
            series.dataSource = self;
            series.tag = 0;
            series.positiveColor = [UIColor colorWithRed:0.41f green:0.67f blue:0.95f alpha:0.8f];
            series.negativeColor = [UIColor colorWithRed:0.77f green:0.94f blue:0.36f alpha:0.8f];
            series.highBorderColor = [UIColor colorWithRed:0.51f green:0.78f blue:1.0f alpha:0.8f];
            series.lowBorderColor = [UIColor colorWithRed:0.89f green:1.0f blue:0.44f alpha:0.8f];
            
            series.borderThickness = 5.0f;
            [m_view.chart addSeries:series];
            
            m_view.chart.cartesianSystem.xAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.yAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.zAxis.hasOffset = YES;
        }
            break;
            
        case TypeSequence:
        {
            for (int i = 0, m = 3; i < m; ++i)
            {
                NChartSequenceSeries *series = [NChartSequenceSeries series];
                series.dataSource = self;
                series.tag = i;
                series.brush = [self.brushes objectAtIndex:i % self.brushes.count];
                [m_view.chart addSeries:series];
            }
            
            m_view.chart.cartesianSystem.xAxis.hasOffset = NO;
            m_view.chart.cartesianSystem.yAxis.hasOffset = YES;
            m_view.chart.cartesianSystem.zAxis.hasOffset = NO;
        }
            break;
            
        case TypeRadar:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartRadarSeries *series = [NChartRadarSeries series];
                series.dataSource = self;
                series.tag = i;
                NChartBrush *brush = [self.brushes objectAtIndex:i % self.brushes.count];
                brush.opacity = 0.8f;
                series.brush = brush;
                [m_view.chart addSeries:series];
            }
        }
            break;
            
        case TypeFunnel2D:
        case TypeFunnel3D:
        {
            for (int i = 0; i < 3; ++i)
            {
                NChartFunnelSeries *series = [NChartFunnelSeries series];
                series.dataSource = self;
                series.tag = i;
                series.bottomRadius = (float)(i + 1) / 5.0f;
                series.topRadius = (float)(i + 2) / 5.0f;
                NChartBrush *brush = [self.brushes objectAtIndex:i % self.brushes.count];
                brush.opacity = 0.8f;
                series.brush = brush;
                [m_view.chart addSeries:series];
            }
            m_view.chart.cartesianSystem.visible = NO;
        }
            break;
            
        case TypeHeatmap:
        {
            NChartHeatmapSeries *series = [NChartHeatmapSeries series];
            series.dataSource = self;
            series.tag = 0;
            
            // Create brush scale.
            // See NChartBrushScale for details.
            series.scale = [NChartBrushScale brushScaleWithBrushes:self.brushes andValues:@[@-0.3, @0.3]];
            
            [m_view.chart addSeries:series];
            m_view.chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
            m_view.chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
        }
            break;
    }
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    // Create points with some data for the series.
    NSMutableArray *result = [NSMutableArray array];
    
    switch (self.type)
    {
        case TypeColumn2D:
            for (int i = 0; i <= 10; ++i)
                [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i Y:(rand() % 30) + 1] forSeries:series]];
            break;
            
        case TypeColumn3D:
        case TypeColumnCylinder:
            for (int i = 0; i <= 4; ++i)
                for (int j = 0; j <= 4; ++j)
                    [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXZWithX:i Y:(rand() % 30) + 1 Z:j] forSeries:series]];
            break;
            
        case TypeBar2D:
            for (int i = 0; i <= 10; ++i)
                [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToYWithX:(rand() % 30) + 1 Y:i] forSeries:series]];
            break;
            
        case TypeBar3D:
        case TypeBarCylinder:
            for (int i = 0; i <= 4; ++i)
                for (int j = 0; j <= 4; ++j)
                    [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToYZWithX:(rand() % 30) + 1 Y:i Z:j] forSeries:series]];
            break;
            
        case TypeArea2D:
        case TypeLine2D:
        case TypeStep2D:
        case TypeRadar:
            for (int i = 0; i <= 10; ++i)
                [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i Y:(rand() % 30) + 1] forSeries:series]];
            break;
            
        case TypeArea3D:
        case TypeLine3D:
        case TypeStep3D:
        case TypeRibbon:
            for (int i = 0; i <= 10; ++i)
                [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXZWithX:i Y:(rand() % 30) + 1 Z:series.tag] forSeries:series]];
            break;
            
        case TypePie2D:
        case TypePie3D:
        case TypeDoughnut2D:
        case TypeDoughnut3D:
            for (int i = 0; i <= 10; ++i)
                [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateWithCircle:i value:(rand() % 30) + 1] forSeries:series]];
            break;
            
        case TypeBubble2D:
        case TypeBubble3D:
        {
            NChartPointState *state = [NChartPointState pointStateWithX:(rand() % 10) + 1
                                                                      Y:(rand() % 10) + 1
                                                                      Z:(rand() % 10) + 1];
            state.marker = [[NChartMarker new] autorelease];
            state.marker.size = (float)(rand() % 1000) / 1000.0f;
            state.marker.brush = (NChartSolidColorBrush *)self.brushes[series.tag];
            if (self.type == TypeBubble2D)
            {
                state.marker.shape = NChartMarkerShapeCircle;
                state.marker.brush.shadingModel = NChartShadingModelPlain;
                state.marker.brush.opacity = 0.8f;
            }
            else
            {
                state.marker.shape = NChartMarkerShapeSphere;
                state.marker.brush.shadingModel = NChartShadingModelPhong;
            }

            [result addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        break;
            
        case TypeScatter2D:
        case TypeScatter3D:
            for (int i = 0; i <= 10; ++i)
            {
                NChartPointState *state = [NChartPointState pointStateWithX:(rand() % 10) + 1
                                                                          Y:(rand() % 10) + 1
                                                                          Z:(rand() % 10) + 1];
                state.marker = [[NChartMarker new] autorelease];
                state.marker.size = 1.0f;
                state.marker.brush = (NChartSolidColorBrush *)self.brushes[series.tag];
                if (self.type == TypeScatter2D)
                {
                    state.marker.shape = NChartMarkerShapeCircle;
                    state.marker.brush.shadingModel = NChartShadingModelPlain;
                    state.marker.brush.opacity = 0.8f;
                }
                else
                {
                    state.marker.shape = NChartMarkerShapeSphere;
                    state.marker.brush.shadingModel = NChartShadingModelPhong;
                }
                
                [result addObject:[NChartPoint pointWithState:state forSeries:series]];
            }
            break;
            
        case TypeSurface:
        {
            double y = 0.0, normalY;
            double x, z;
            float minRed = 36.0 / 255.0, minGreen = 136.0 / 255.0, minBlue = 201.0 / 255.0;
            float maxRed = 122.0 / 255.0, maxGreen = 254.0 / 255.0, maxBlue = 254.0 / 255.0;
            for (int i = 0, n = 20; i < n; ++i)
            {
                for (int j = 0, m = 20; j < m; ++j)
                {
                    x = (double)(i) * 2.0 * M_PI / (double)n;
                    z = (double)(j) * 2.0 * M_PI / (double)m;
                    y = sin(x) * cos(z);

                    NChartPointState *state = [NChartPointState pointStateWithX:i Y:y Z:j];
                    normalY = (y + 1.0) / 2.0;
                    state.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor
                                                                                   colorWithRed:(1.0 - normalY) * minRed + normalY * maxRed
                                                                                   green:(1.0 - normalY) * minGreen + normalY * maxGreen
                                                                                   blue:(1.0 - normalY) * minBlue + normalY * maxBlue
                                                                                   alpha:1.0f]];
                    [result addObject:[NChartPoint pointWithState:state forSeries:series]];
                }
            }
        }
            break;
            
        case TypeCandlestick2D:
        case TypeCandlestick3D:
        case TypeOHLC2D:
        case TypeOHLC3D:
            for (int i = 0; i < 30; ++i)
            {
                double open = 5.0f * sin((float)i * M_PI / 10);
                double close = 5.0f * cos((float)i * M_PI / 10);
                double low = MIN(open, close) - (rand() % 3);
                double high = MAX(open, close) + (rand() % 3);
                [result addObject:[NChartPoint pointWithState:[NChartPointState
                                                               pointStateAlignedToXZWithX:i
                                                               Z:series.tag
                                                               low:low
                                                               open:open
                                                               close:close
                                                               high:high]
                                                    forSeries:series]];
            }
            break;
            
        case TypeBand:
            for (int i = 0; i < 10; ++i)
            {
                double low = rand() % 20;
                double high = rand() % 20;
                [result addObject:[NChartPoint pointWithState:[NChartPointState
                                                               pointStateAlignedToXWithX:i
                                                               low:low
                                                               high:high]
                                                    forSeries:series]];
            }
            break;
            
        case TypeSequence:
            for (int i = 0; i < 30; ++i)
            {
                int y = rand() % 4;
                double open = rand() % 30;
                double close = open + 1.0;
                [result addObject:[NChartPoint pointWithState:[NChartPointState
                                                               pointStateAlignedToYWithY:y
                                                               open:open
                                                               close:close]
                                                    forSeries:series]];
            }
            break;
            
        case TypeFunnel2D:
        case TypeFunnel3D:
            [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateWithX:0 Y:rand() % 30 Z:0]
                                                forSeries:series]];
            break;
            
        case TypeHeatmap:
            for (int i = 0, n = 100; i < n; ++i)
            {
                for (int j = 0, m = 100; j < m; ++j)
                {
                    double x = 1.0 - 2.0 * (double)(i) / (double)(n);
                    double y = 1.0 - 2.0 * (double)(j) / (double)(m);
                    double value = (1.0 - fabs(x * y)) * sin((1.0 - fabs(x * y)) * M_PI * 4.0);
                    [result addObject:[NChartPoint pointWithState:[NChartPointState pointStateWithX:x Y:y Value:value] forSeries:series]];
                }
            }
            break;
    }

    return result;
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    // Get name of the series.
    return [NSString stringWithFormat:NSLocalizedString(@"Series %d", nil), series.tag + 1];
}

#pragma mark - NChartSizeAxisDataSource

- (float)sizeAxisDataSourceMinSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    // Minimal size of bubbles in pixels. The size provided in the chart point is mapped to pixels through this value.
    return 30.0f;
}

- (float)sizeAxisDataSourceMaxSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    // Maximal size of bubbles in pixels. The size provided in the chart point is mapped to pixels through this value.
    return self.type == TypeScatter2D || self.type == TypeScatter3D ? 30.0f : 100.0f;
}

@end

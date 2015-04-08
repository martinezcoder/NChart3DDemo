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
 

#import "NChart3DMainViewController.h"


@implementation NChart3DMainViewController
{
    NChart3DView *m_view;
    NChart3DDataSource *m_dataSource;
    NChart3DDataSourceTypes m_dataSourceType;
    NChart3DAudioCapturer *m_audioCapturer;
    BOOL m_isViewVisible;
    BOOL m_needsUpdate;
    id<NChart3DMainViewControllerDelegate> m_delegate;
    
    NChart3DDataTypes m_types[DataSourceTypesCount];
}

- (id<NChart3DMainViewControllerDelegate>)delegate
{
    return m_delegate;
}

- (void)setDelegate:(id<NChart3DMainViewControllerDelegate>)delegate
{
    m_delegate = delegate;
}

- (id)initWithDefaultType:(NChart3DDataTypes)defaultType
{
    self = [super init];
    if (self)
    {
        UIBarButtonItem *pinItem, *resetItem;
        
        self.title = NSLocalizedString(@"NChart3D", nil);
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            pinItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sidepanel.png"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(pinSettings:)] autorelease];
            resetItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reset.png"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(resetTransformations:)] autorelease];
            
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        }
        else
        {
            pinItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil)
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(pinSettings:)] autorelease];
            resetItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil)
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(resetTransformations:)] autorelease];
        }
        
        if (isIPhone())
        {
            [self.navigationItem setLeftBarButtonItems:@[resetItem]];
            [self.navigationItem setRightBarButtonItems:@[pinItem]];
        }
        else
        {
            [self.navigationItem setLeftBarButtonItems:@[pinItem]];
            [self.navigationItem setRightBarButtonItems:@[resetItem]];
        }
        
        m_audioCapturer = [NChart3DAudioCapturer new];
        if (![m_audioCapturer initDevice])
            [m_audioCapturer release], m_audioCapturer = nil;
        
        if (m_audioCapturer)
            m_audioCapturer.spectrumSize = m_audioCapturer.sampleRate * 30 / 4000;
    }
    return self;
}

- (void)dealloc
{
    [m_view release];
    [m_dataSource release];
    [m_audioCapturer release];
    
    [super dealloc];
}

- (void)loadView
{
    m_view = [[NChart3DView alloc] initWithFrame:CGRectZero];
    
    // Paste your license key here.
    m_view.chart.licenseKey = @"T8eJSp1MGDRzfvQqIYhLPpxMYmTP2LEuXo6PUpa2bqpl4yWwFg9ZSJIArbYLGZYyfffCf2CyJmZ6oNs7YKszWHz93UE6xxVeW2UeX6jbSm8VYLg+1wo74s/o/MEAB+02SE8RiAgI3rVbhBOTgoW3KweH3k7T3422KubGBJURv3bHsimpl7jfYYSc+kKq6FXY850todatkDgCJ1BxL8zFMVQ4G0D2EXXS8B7HKKCjG2rglSMOnCJfypYYv/GAFSKOB9RJYZv0uXw3BK0h860eGzX8ktcwJGHl7w7esN08f4YrVhBwXnHvN20Txv9f9IO4RMwYwu4tz+Cz116tHAy/zcLOehrWLUARf6vxDywfxOsjyDkNoZiK3nzsN3OfAwKmcpXZo8EJmZxKc19PuJscLauIiv8upkq/vaI9JGwBs7hvDvt7VR9Vi7eAOCCy3F11nn1CiRjWB/mjiFPHeguqBVmXCopWYjv0P9qgOLuVvJZ70I1iV+YdzHzfM5I5q4eCEXjs1P2iFAChN5+W/RLfUu5uTxLUceD3d0Au7E6lVO7HNduCVn6/6lOsh8J9IrggAjvKLU/jFTL5bFoWtAUNkjkJ9EiDvQQtF3EJ60SgqHzsu4NfF3eXqtXnD6a8uvyqkjQAjTFZ6V6NSWe4orVTzvZR+xUnf5ZUOhJj53OEQfA=";
    
    self.view = m_view;
    
    m_dataSource = [[NChart3DDataSource alloc] initWithChart:m_view.chart audioCapturer:m_audioCapturer];
    
    for (NSInteger i = 0; i < DataSourceTypesCount; ++i)
        m_types[i] = [self firstChartForType:(NChart3DDataSourceTypes)(NChart3DDataSourceStatistics + i)];
    
    [self setupChart];
    
    [self createSeries];
    
    if (m_audioCapturer)
        [m_audioCapturer startCaptureSession];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"StartupInfoShown"])
//    {
        [self about:nil];
//        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"StartupInfoShown"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    m_isViewVisible = YES;
    m_view.isUpdatingEnabled = YES;
    if (m_needsUpdate)
    {
        [self createSeries];
        m_needsUpdate = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    m_isViewVisible = NO;
    if (m_view.chart.streamingMode)
        [self performSelector:@selector(stopCaptureSessionAsync:) withObject:nil afterDelay:0.01];
    m_view.isUpdatingEnabled = NO;
}

- (void)stopCaptureSessionAsync:(id)dummy
{
    [m_audioCapturer stopCaptureSession];
}

#pragma mark - Toolbar actions

- (void)showSettings:(id)dummy
{
}

- (void)pinSettings:(id)dummy
{
    self.delegate.isSettingsPanelShown = !(self.delegate.isSettingsPanelShown);
}

- (void)resetTransformations:(id)dummy
{
    [m_dataSource resetChartTransformations];
}

- (void)about:(id)dummy
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                                    message:NSLocalizedString(@"The application demonstrates the features of NChart3D charting library. More information and documentation can be found at www.nchart3d.com.", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:NSLocalizedString(@"nchart3d.com", nil), nil];
    [alert show];
    [alert release];
}

- (NChart3DDataTypes)firstChartForType:(NChart3DDataSourceTypes)type
{
    switch (type)
    {
        case NChart3DDataSourceStatistics:
            return NChart3DDataPopulation;
            
        case NChart3DDataSourceMathematics:
            return NChart3DDataSurfaceType2;
            
        case NChart3DDataSourceStocks:
            return NChart3DDataStocksType1;
            
        case NChart3DDataSourceDNA:
            return NChart3DDataDNA;
            
        case NChart3DDataSourceStreaming:
            return NChart3DDataStreamingColumn;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://nchart3d.com"]];
    }
}

#pragma mark - NChart3DSettingsDelegate

- (id)settingsValueForProp:(NSInteger)prop
{
    switch (prop)
    {
        case NChart3DPropertyDataSourceType:
            return [NSNumber numberWithInt:m_dataSourceType];
            
        case NChart3DPropertyDataType:
            return [NSNumber numberWithInt:m_dataSource.dataType];
            
        default:
            return [m_dataSource settingsValueForPorp:(NChart3DProperties)prop];
    }
}

- (void)settingsSetValue:(id)value forProp:(NSInteger)prop shouldApply:(BOOL)shouldApply
{
    if (shouldApply && !m_isViewVisible)
    {
        shouldApply = NO;
        m_needsUpdate = YES;
    }
    
    switch (prop)
    {
        case NChart3DPropertyDataSourceType:
            m_dataSourceType = (NChart3DDataSourceTypes)((NSNumber *)value).integerValue;
            m_dataSource.dataType = m_types[m_dataSourceType];
            if (shouldApply)
                [self createSeries];
            break;
            
        case NChart3DPropertyDataType:
            m_dataSource.dataType = (NChart3DDataTypes)((NSNumber *)value).integerValue;
            m_types[m_dataSourceType] = m_dataSource.dataType;
            if (shouldApply)
                [self createSeries];
            break;
            
        default:
            [m_dataSource setSettingsValue:value forProp:(NChart3DProperties)prop];
            if (shouldApply)
                [self createSeries];
            break;
    }
}

- (void)closeSettings
{
    if (isIPhone())
    {
        self.delegate.isSettingsPanelShown = NO;
        [m_view.chart playTransition:TRANSITION_TIME reverse:NO];
    }
}

#pragma mark - Apply settings to chart

- (void)setupChart
{
    // Time axis
    m_view.chart.timeAxis.tickShape = NChartTimeAxisTickShapeLine;
    m_view.chart.timeAxis.tickTitlesFont = BoldFontWithSize(11.0f);
    m_view.chart.timeAxis.tickTitlesLayout = NChartTimeAxisShowFirstLastLabelsOnly;
    m_view.chart.timeAxis.tickTitlesPosition = NChartTimeAxisLabelsBeneath;
    m_view.chart.timeAxis.margin = NChartMarginMake(20.0f, 20.0f, 10.0f, 0.0f);
    m_view.chart.timeAxis.autohideTooltip = NO;
    
    // Time axis tooltip
    m_view.chart.timeAxis.tooltip = [[NChartTimeAxisTooltip new] autorelease];
    m_view.chart.timeAxis.tooltip.margin = NChartMarginMake(0.0f, 0.0f, 2.0f, 0.0f);
    m_view.chart.timeAxis.tooltip.textColor = ColorWithRGB(145, 143, 141);
    m_view.chart.timeAxis.tooltip.font = FontWithSize(11.0f);
    
    // Legend
    m_view.chart.legend.background = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor colorWithRed:1.0f
                                                                                                     green:1.0f
                                                                                                      blue:1.0f
                                                                                                     alpha:0.8f]];
    m_view.chart.legend.borderThickness = 0.5f;
    m_view.chart.legend.borderColor = ColorWithRGB(185, 185, 185);
    m_view.chart.legend.blockAlignment = NChartLegendBlockAlignmentBottom;
    m_view.chart.legend.contentAlignment = NChartLegendContentAlignmentJustified;
    m_view.chart.legend.shouldAutodetectColumnCount = YES;
    
    // Caption
    m_view.chart.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 5.0f);
    
    // Antialiasing
    m_view.chart.shouldAntialias = YES;
    
    // Main chart colors
    UIColor *axesColor = ColorWithRGB(130, 130, 130);
    UIColor *saxesColor = ColorWithRGB(180, 180, 180);
    UIColor *textColor = [UIColor blackColor];
    UIFont *font = FontWithSize(16.0f);
    
    m_view.chart.background = GradientBrushWithRGB(255, 255, 255, 219, 219, 224);
    m_view.chart.cartesianSystem.xyPlane.color = ColorWithRGB(238, 238, 238);
    m_view.chart.timeAxis.tooltip.textColor = ColorWithRGB(145, 143, 141);
    m_view.chart.timeAxis.tickTitlesColor = ColorWithRGB(145, 143, 141);
    m_view.chart.timeAxis.tickColor = ColorWithRGB(111, 111, 111);
    
    [m_view.chart.timeAxis setImagesForBeginNormal:nil
                                       beginPushed:nil
                                         endNormal:nil
                                         endPushed:nil
                                        playNormal:[UIImage imageNamed:@"play-light.png"]
                                        playPushed:[UIImage imageNamed:@"play-pushed-light.png"]
                                       pauseNormal:[UIImage imageNamed:@"pause-light.png"]
                                       pausePushed:[UIImage imageNamed:@"pause-pushed-light.png"]
                                            slider:[UIImage imageNamed:@"slider-light.png"]
                                           handler:[UIImage imageNamed:@"handler-light.png"]];

    m_view.chart.caption.textColor = textColor;
    m_view.chart.caption.font = font;
    
    m_view.chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.xAxis.caption.font = font;
    m_view.chart.cartesianSystem.xAxis.textColor = textColor;
    m_view.chart.cartesianSystem.xAxis.font = font;
    m_view.chart.cartesianSystem.xAxis.color = axesColor;
    m_view.chart.cartesianSystem.xAxis.majorTicks.color = axesColor;
    m_view.chart.cartesianSystem.xAxis.minorTicks.color = axesColor;
    m_view.chart.cartesianSystem.xAlongY.color = axesColor;
    m_view.chart.cartesianSystem.xAlongZ.color = axesColor;
    
    m_view.chart.cartesianSystem.sxAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.sxAxis.caption.font = font;
    m_view.chart.cartesianSystem.sxAxis.textColor = textColor;
    m_view.chart.cartesianSystem.sxAxis.font = font;
    m_view.chart.cartesianSystem.sxAxis.color = axesColor;
    m_view.chart.cartesianSystem.sxAxis.majorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.sxAxis.minorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.sxAlongY.color = saxesColor;
    m_view.chart.cartesianSystem.sxAlongZ.color = saxesColor;
    
    m_view.chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.yAxis.caption.font = font;
    m_view.chart.cartesianSystem.yAxis.textColor = textColor;
    m_view.chart.cartesianSystem.yAxis.font = font;
    m_view.chart.cartesianSystem.yAxis.color = axesColor;
    m_view.chart.cartesianSystem.yAxis.majorTicks.color = axesColor;
    m_view.chart.cartesianSystem.yAxis.minorTicks.color = axesColor;
    m_view.chart.cartesianSystem.yAlongX.color = axesColor;
    m_view.chart.cartesianSystem.yAlongZ.color = axesColor;
    
    m_view.chart.cartesianSystem.syAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.syAxis.caption.font = font;
    m_view.chart.cartesianSystem.syAxis.textColor = textColor;
    m_view.chart.cartesianSystem.syAxis.font = font;
    m_view.chart.cartesianSystem.syAxis.color = axesColor;
    m_view.chart.cartesianSystem.syAxis.majorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.syAxis.minorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.syAlongX.color = saxesColor;
    m_view.chart.cartesianSystem.syAlongZ.color = saxesColor;
    
    m_view.chart.cartesianSystem.zAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.zAxis.caption.font = font;
    m_view.chart.cartesianSystem.zAxis.textColor = textColor;
    m_view.chart.cartesianSystem.zAxis.font = font;
    m_view.chart.cartesianSystem.zAxis.color = axesColor;
    m_view.chart.cartesianSystem.zAxis.majorTicks.color = axesColor;
    m_view.chart.cartesianSystem.zAxis.minorTicks.color = axesColor;
    m_view.chart.cartesianSystem.zAlongX.color = axesColor;
    m_view.chart.cartesianSystem.zAlongY.color = axesColor;
    
    m_view.chart.cartesianSystem.szAxis.caption.textColor = textColor;
    m_view.chart.cartesianSystem.szAxis.caption.font = font;
    m_view.chart.cartesianSystem.szAxis.textColor = textColor;
    m_view.chart.cartesianSystem.szAxis.font = font;
    m_view.chart.cartesianSystem.szAxis.color = axesColor;
    m_view.chart.cartesianSystem.szAxis.majorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.szAxis.minorTicks.color = saxesColor;
    m_view.chart.cartesianSystem.szAlongX.color = saxesColor;
    m_view.chart.cartesianSystem.szAlongY.color = saxesColor;
    
    m_view.chart.cartesianSystem.borderColor = axesColor;
    
    m_view.chart.polarSystem.radiusAxis.caption.textColor = textColor;
    m_view.chart.polarSystem.radiusAxis.caption.font = font;
    m_view.chart.polarSystem.radiusAxis.textColor = textColor;
    m_view.chart.polarSystem.radiusAxis.font = font;
    m_view.chart.polarSystem.radiusAxis.color = axesColor;
    m_view.chart.polarSystem.radiusAxis.majorTicks.color = axesColor;
    m_view.chart.polarSystem.radiusAxis.minorTicks.color = axesColor;
    
    m_view.chart.polarSystem.azimuthAxis.caption.textColor = textColor;
    m_view.chart.polarSystem.azimuthAxis.caption.font = font;
    m_view.chart.polarSystem.azimuthAxis.textColor = textColor;
    m_view.chart.polarSystem.azimuthAxis.font = font;
    m_view.chart.polarSystem.azimuthAxis.color = axesColor;
    m_view.chart.polarSystem.azimuthAxis.majorTicks.color = axesColor;
    m_view.chart.polarSystem.azimuthAxis.minorTicks.color = axesColor;
    
    m_view.chart.polarSystem.grid.color = axesColor;
    
    m_view.chart.polarSystem.borderColor = axesColor;
}

- (void)createSeries
{
//    [m_audioCapturer stopCaptureSession];
    [m_dataSource.locker lock];
    
//    [m_view.chart removeAllSeries];
    
    m_view.chart.minZoom = m_view.chart.drawIn3D ? 0.5f : 1.0f;
    
    [m_dataSource createSeries];
    
    BOOL isStreaming = m_view.chart.streamingMode;
    
    m_view.chart.pointSelectionEnabled = !isStreaming;
    
    [m_view.chart.timeAxis stop];
    [m_view.chart.timeAxis goToFirstTick];
    
    [m_view.chart updateData];
    
    [m_view.chart stopTransition];
    
    if (!isStreaming && !isIPhone())
        [m_view.chart playTransition:TRANSITION_TIME reverse:NO];
    
    [m_dataSource setupChartAfterSeriesCreated];

    [m_view.chart flushChanges];
    
//    [m_audioCapturer startCaptureSession];
    [m_dataSource.locker unlock];
}

- (void)rebuildSeries
{
    [m_view.chart rebuildSeries];
    
    [m_view.chart stopTransition];
    [m_view.chart playTransition:TRANSITION_TIME reverse:NO];
}

@end

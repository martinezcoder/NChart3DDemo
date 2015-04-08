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
 

#import "NChart3DDataSource.h"
#import "NChart3DMainViewController.h"

#define BRUSH_COUNT 60


@interface NChart3DDataSource ()

@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) NSArray *names;
@property (nonatomic, retain) NSArray *images;

@property (nonatomic, retain) NSString *xName;
@property (nonatomic, retain) NSNumber *xMin;
@property (nonatomic, retain) NSNumber *xMax;
@property (nonatomic, retain) NSNumber *xStep;
@property (nonatomic, retain) NSArray *xTicks;
@property (nonatomic, retain) NSNumber *xLength;
@property (nonatomic, retain) NSString *xMask;

@property (nonatomic, retain) NSString *yName;
@property (nonatomic, retain) NSNumber *yMin;
@property (nonatomic, retain) NSNumber *yMax;
@property (nonatomic, retain) NSNumber *yStep;
@property (nonatomic, retain) NSArray *yTicks;
@property (nonatomic, retain) NSNumber *yLength;
@property (nonatomic, retain) NSString *yMask;

@property (nonatomic, retain) NSString *zName;
@property (nonatomic, retain) NSNumber *zMin;
@property (nonatomic, retain) NSNumber *zMax;
@property (nonatomic, retain) NSNumber *zStep;
@property (nonatomic, retain) NSArray *zTicks;
@property (nonatomic, retain) NSNumber *zLength;
@property (nonatomic, retain) NSString *zMask;

@property (nonatomic, retain) NSString *syName;
@property (nonatomic, retain) NSNumber *syMin;
@property (nonatomic, retain) NSNumber *syMax;
@property (nonatomic, retain) NSNumber *syStep;
@property (nonatomic, retain) NSArray *syTicks;
@property (nonatomic, retain) NSNumber *syLength;
@property (nonatomic, retain) NSString *syMask;

@property (nonatomic, retain) NSString *azimuthName;
@property (nonatomic, retain) NSNumber *azimuthMin;
@property (nonatomic, retain) NSNumber *azimuthMax;
@property (nonatomic, retain) NSNumber *azimuthStep;
@property (nonatomic, retain) NSArray *azimuthTicks;
@property (nonatomic, retain) NSNumber *azimuthLength;
@property (nonatomic, retain) NSString *azimuthMask;

@property (nonatomic, retain) NSString *radiusName;
@property (nonatomic, retain) NSNumber *radiusMin;
@property (nonatomic, retain) NSNumber *radiusMax;
@property (nonatomic, retain) NSNumber *radiusStep;
@property (nonatomic, retain) NSArray *radiusTicks;
@property (nonatomic, retain) NSNumber *radiusLength;
@property (nonatomic, retain) NSString *radiusMask;

@property (nonatomic, retain) NSArray *timeAxisTicks;

@property (nonatomic, retain) NSMutableArray *brushes;
@property (nonatomic, retain) NSMutableArray *rainbowBrushes;
@property (nonatomic, retain) NSMutableArray *streamingBrushes;

@end

@implementation NChart3DDataSource
{
    NChart *m_chart; // Not retained
    NChart3DAudioCapturer *m_audioCapturer; // Not retained
    NChart3DDataBase *m_dataBase;
    
    NSMutableDictionary *m_settings;
    
    NChart3DDataTypes m_prevChartType;
    NChartPoint *m_prevPointSelected;
    BOOL m_needsResetTransformations;
    NSInteger m_prevValue;
}

@synthesize needsResetTransformations = m_needsResetTransformations;

- (id)initWithChart:(NChart *)chart audioCapturer:(NChart3DAudioCapturer *)capturer
{
    self = [super init];
    if (self)
    {
        m_settings = [NSMutableDictionary new];
        self.locker = [[NSLock new] autorelease];
        
        m_chart = chart;
        m_audioCapturer = capturer;
        
        m_chart.delegate = self;
        m_chart.cartesianSystem.xAxis.dataSource = self;
        m_chart.cartesianSystem.yAxis.dataSource = self;
        m_chart.cartesianSystem.zAxis.dataSource = self;
        m_chart.cartesianSystem.syAxis.dataSource = self;
        
        m_chart.polarSystem.azimuthAxis.dataSource = self;
        
        m_chart.sizeAxis.dataSource = self;
        m_chart.timeAxis.dataSource = self;
        
        if (m_audioCapturer)
            m_audioCapturer.delegate = self;
        
        self.brushes = [NSMutableArray arrayWithObjects:
                        BrushWithRGB(242, 100,  90),
                        BrushWithRGB(245, 180,  85),
                        BrushWithRGB(192, 161,  65),
                        BrushWithRGB(196, 205,  92),
                        BrushWithRGB(128, 149,  73),
                        BrushWithRGB(134, 197,  88),
                        BrushWithRGB( 45, 170,  49),
                        BrushWithRGB( 84, 176, 117),
                        BrushWithRGB( 45, 135, 100),
                        BrushWithRGB(101, 177, 161),
                        BrushWithRGB( 29, 170, 178),
                        BrushWithRGB(136, 217, 242),
                        BrushWithRGB( 86, 147, 214),
                        BrushWithRGB( 60,  95, 214),
                        BrushWithRGB(173, 173, 233),
                        BrushWithRGB(174, 121, 243),
                        BrushWithRGB(197, 105, 205),
                        BrushWithRGB(159,  90, 143),
                        BrushWithRGB(185,  66, 150),
                        BrushWithRGB(160,  48, 203),
                        
                        BrushWithRGB(262, 120, 130),
                        BrushWithRGB(265, 200, 105),
                        BrushWithRGB(212, 181,  85),
                        BrushWithRGB(216, 225, 112),
                        BrushWithRGB(148, 169,  93),
                        BrushWithRGB(154, 217, 108),
                        BrushWithRGB( 65, 180,  69),
                        BrushWithRGB(104, 196, 137),
                        BrushWithRGB( 65, 155, 120),
                        BrushWithRGB(121, 197, 181),
                        BrushWithRGB( 49, 190, 198),
                        BrushWithRGB(156, 237, 262),
                        BrushWithRGB(106, 167, 234),
                        BrushWithRGB( 80, 115, 255),
                        BrushWithRGB(193, 193, 255),
                        BrushWithRGB(194, 141, 255),
                        BrushWithRGB(217, 125, 225),
                        BrushWithRGB(179, 110, 163),
                        BrushWithRGB(205,  86, 170),
                        BrushWithRGB(180,  68, 223),
                        
                        BrushWithRGB(222,  80,  70),
                        BrushWithRGB(225, 160,  65),
                        BrushWithRGB(172, 141,  45),
                        BrushWithRGB(176, 185,  72),
                        BrushWithRGB(108, 129,  53),
                        BrushWithRGB(114, 177,  68),
                        BrushWithRGB( 25, 150,  29),
                        BrushWithRGB( 64, 156,  97),
                        BrushWithRGB( 25, 115,  80),
                        BrushWithRGB( 81, 157, 141),
                        BrushWithRGB(  9, 150, 158),
                        BrushWithRGB(116, 197, 222),
                        BrushWithRGB( 66, 127, 194),
                        BrushWithRGB( 40,  75, 194),
                        BrushWithRGB(153, 153, 213),
                        BrushWithRGB(154, 101, 223),
                        BrushWithRGB(177,  85, 185),
                        BrushWithRGB(139,  70, 123),
                        BrushWithRGB(165,  46, 130),
                        BrushWithRGB(140,  28, 183),
                        nil];
        
        self.rainbowBrushes = [NSMutableArray arrayWithObjects:
                               BrushWithRGB(242, 100,  90),
                               BrushWithRGB(245, 180,  85),
                               BrushWithRGB(192, 161,  65),
                               BrushWithRGB(196, 205,  92),
                               BrushWithRGB(128, 149,  73),
                               BrushWithRGB(134, 197,  88),
                               BrushWithRGB( 45, 170,  49),
                               BrushWithRGB( 84, 176, 117),
                               BrushWithRGB( 45, 135, 100),
                               BrushWithRGB(101, 177, 161),
                               BrushWithRGB( 29, 170, 178),
                               BrushWithRGB(136, 217, 242),
                               BrushWithRGB( 86, 147, 214),
                               BrushWithRGB( 60,  95, 214),
                               BrushWithRGB(173, 173, 233),
                               BrushWithRGB(174, 121, 243),
                               BrushWithRGB(197, 105, 205),
                               BrushWithRGB(159,  90, 143),
                               BrushWithRGB(185,  66, 150),
                               BrushWithRGB(160,  48, 203),
                               nil];
        
        self.streamingBrushes = [NSMutableArray arrayWithObjects:
                                 BrushWithRGB(242, 100,  90),
                                 BrushWithRGB(245, 180,  85),
                                 BrushWithRGB(196, 205,  92),
                                 BrushWithRGB(134, 197,  88),
                                 BrushWithRGB( 45, 170,  49),
                                 BrushWithRGB( 45, 135, 100),
                                 nil];
        
        // Init statistics settings.
        [m_settings setObject:(isIPhone() ? @10 : @20) forKey:[NSNumber numberWithInt:NChart3DPropertyPopulationCountriesCount]];
        [m_settings setObject:@10 forKey:[NSNumber numberWithInt:NChart3DPropertyPopulationPerYearCountriesCount]];
        [m_settings setObject:@5 forKey:[NSNumber numberWithInt:NChart3DPropertyPopulationPerYearYearsCount]];
        [m_settings setObject:@10 forKey:[NSNumber numberWithInt:NChart3DPropertyGDPPerCapitaYearsCount]];
        
        // Init mathematics settings.
        [m_settings setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:NChart3DPropertySurfaceBorder]];
        [m_settings setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:NChart3DPropertySurfaceIsDiscrete]];
        [m_settings setObject:@1 forKey:[NSNumber numberWithInt:NChart3DPropertyLissajousCurveDimension]];
        [m_settings setObject:@7 forKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidOuterRadius]];
        [m_settings setObject:@3 forKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidInnerRadius]];
        [m_settings setObject:@5 forKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidDistance]];
        
        // Init dna settings.
        [m_settings setObject:(isIPhone() ? @5 : @10) forKey:[NSNumber numberWithInt:NChart3DPropertyDNACount]];
        
        // Init streaming settings.
        [m_settings setObject:@0 forKey:[NSNumber numberWithInt:NChart3DPropertyStreamingDimension]];
        [m_settings setObject:(isIPhone() ? @30 : @50) forKey:[NSNumber numberWithInt:NChart3DPropertyStreamingResolution]];
    }
    return self;
}

- (void)dealloc
{
    [self resetToDefaultProperty];
    
    self.brushes = nil;
    self.streamingBrushes = nil;
    self.rainbowBrushes = nil;
    self.locker = nil;
    
    [m_dataBase release];
    [m_settings release];
    
    [m_prevPointSelected release];
    
    [super dealloc];
}

- (void)createSeries
{
    m_prevPointSelected = nil;
    
    [m_chart removeAllSeries];
    
    m_needsResetTransformations = m_prevChartType != self.dataType;
    BOOL oldIsSurface = m_prevChartType >= NChart3DDataSurfaceType1 && m_prevChartType <= NChart3DDataSurfaceType4;
    BOOL newIsSurface = self.dataType >= NChart3DDataSurfaceType1 && self.dataType <= NChart3DDataSurfaceType4;
    BOOL needsReset = !oldIsSurface || !newIsSurface;
    if (m_needsResetTransformations)
    {
        // Another position to save surfase animation.
        if (needsReset)
        {
            [m_chart resetTransition];
        }
        m_prevChartType = self.dataType;
    }
    
    switch (self.dataType)
    {
        case NChart3DDataPopulation:
            [self createPopulation];
            break;
            
        case NChart3DDataPopulationPerYear:
            [self createPopulationPerYear];
            break;
            
        case NChart3DDataPopulationProjection:
            [self createPopulationProjection];
            break;
            
        case NChart3DDataMarketShareSmartphones:
            [self createMarketShareSmartphones];
            break;

        case NChart3DDataMarketShareSmartphonesSimple:
            [self createMarketShareSmartphonesSimple];
            break;

        case NChart3DDataMarketShareSmartphonesSuperSimple:
            [self createMarketShareSmartphonesSuperSimple];
            break;
            
        case NChart3DDataMarketShareBrowsers:
            [self createMarketShareBrowsers];
            break;
            
        case NChart3DDataPopulationPyramid:
            [self createPopulationPyramid];
            break;
            
        case NChart3DDataGDPPerCapita:
            [self createGDPPerCapita];
            break;
            
        case NChart3DDataWindRose:
            [self createWindRose];
            break;
            
        case NChart3DDataSalesFunnel:
            [self createSalesFunnel];
            break;
            
        case NChart3DDataSurfaceType1:
        case NChart3DDataSurfaceType2:
        case NChart3DDataSurfaceType3:
        case NChart3DDataSurfaceType4:
            [self createSurface: needsReset];
            break;
            
        case NChart3DDataLissajousCurve:
            [self createLissajousCurve];
            break;
            
        case NChart3DDataHypotrochoid:
            [self createHypotrochoid];
            break;
            
        case NChart3DDataHyperboloid:
            [self createHyperboloid];
            break;
            
        case NChart3DDataStocksType1:
            [self createStocksType1];
            break;
            
        case NChart3DDataStocksType2:
            [self createStocksType2];
            break;
            
        case NChart3DDataDNA:
            [self createDNA];
            break;
            
        case NChart3DDataStreamingColumn:
        case NChart3DDataStreamingArea:
        case NChart3DDataStreamingStep:
            [self createStreaming];
            break;
            
        case NChart3DDataStreamingSurface:
            [self createStreamingSurface];
            break;
    }
}

- (void)setupChartAfterSeriesCreated
{
    [self resetChartTransformations];
    
    switch (self.dataType)
    {
        case NChart3DDataStocksType1:
        case NChart3DDataStocksType2:
            m_chart.maxZoom = 40.0f;
            break;
            
        default:
            break;
    }
}

- (void)resetChartTransformations
{
    switch (self.dataType)
    {
        case NChart3DDataStocksType1:
        case NChart3DDataStocksType2:
            [m_chart.cartesianSystem.xAxis zoomToRegionFrom:0 to:25 duration:TRANSITION_TIME delay:0.0];
            break;
            
        default:
            [m_chart resetTransformations:TRANSITION_TIME];
            break;
    }
}

- (void)setSettingsValue:(id)value forProp:(NChart3DProperties)prop
{
    if (value)
        [m_settings setObject:value forKey:[NSNumber numberWithInt:prop]];
}

- (id)settingsValueForPorp:(NChart3DProperties)prop
{
    return [m_settings objectForKey:[NSNumber numberWithInt:prop]];
}

#pragma mark - statistic series

- (void)createPopulation
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"list_of_country_by_population.csv"];
    
    NChartColumnSeries *series = [NChartColumnSeries series];
    series.brush = BrushWithRGB(255, 0, 0);
    series.tag = 0;
    series.dataSource = self;
    [m_chart addSeries:series];
    
    [self resetToDefaultProperty];
    
    self.xName = [m_dataBase stringValueForRow:0 column:1];
    
    if (isIPhone())
    {
        self.yName = [NSString stringWithFormat:@"%@ (Millions)", [m_dataBase stringValueForRow:0 column:2]];
        self.yMask = @"%.0f";
    }
    else
    {
        self.yName = [m_dataBase stringValueForRow:0 column:2];
        self.yMask = @"%.0f M";
    }

    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    NSInteger n = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyPopulationCountriesCount]]).integerValue + 1;
    for (NSInteger i = 1; i < n; ++i)
    {
        double value = 0.0;
        if ([m_dataBase doubleValue:&value forRow:i column:2])
        {
            NChartPoint *point = [NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:i - 1 Y:value / 1.0e6] forSeries:series];
            point.currentState.brush = (NChartBrush *)[self.brushes objectAtIndex:(i - 1) % BRUSH_COUNT];
            [pointsArray addObject:point];
        }
        else
            [pointsArray addObject:[NSNull null]];
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:1]];
    }
    
    self.points = @[pointsArray];
    self.xTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.background = BrushWithImage(@"population_back.jpg");
    
    UIColor *borderColor = ColorWithRGB(154, 183, 203);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(179, 204, 220);
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = NO;
    
    UIColor *textColor = ColorWithRGB(104, 133, 153);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.labelsAlignment = NChartAxisLabelsAlignmentRight;
    m_chart.cartesianSystem.xAxis.labelsAngle = -M_PI_2;
    m_chart.cartesianSystem.xAxis.maxLabelLength = 400.0f;
    m_chart.cartesianSystem.xAxis.minTickSpacing = 20.0f;
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalZoom ^ NChartUserInteractionProportionalZoom ^
                                   NChartUserInteractionVerticalZoom);
}

- (void)createPopulationPerYear
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"list_of_country_by_population_by_years.csv"];
    
    NSInteger n = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyPopulationPerYearCountriesCount]]).integerValue;
    NSInteger m = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyPopulationPerYearYearsCount]]).integerValue * 2;
    
    double zSize = (double)m / (double)m_dataBase.columnsCount;
    
    [self resetToDefaultProperty];
    
    self.xName = [m_dataBase stringValueForRow:0 column:0];
    
    if (isIPhone())
    {
        self.yName = @"Population (Millions)";
        self.yMask = @"%.1f";
    }
    else
    {
        self.yName = @"Population";
        self.yMask = @"%.2f M";
    }
    
    self.zName = @"Years";
    self.zLength = [NSNumber numberWithDouble:zSize];
    
    NSMutableArray *zTicksArray = [NSMutableArray array];
    for (NSInteger i = 1; i < m; i += 2)
    {
        [zTicksArray addObject:[m_dataBase stringValueForRow:0 column:i]];
    }
    self.zTicks = zTicksArray;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    for (NSInteger i = 0; i < n; ++i)
    {
        [ticksArray addObject:[m_dataBase stringValueForRow:i + 1 column:0]];
        
        NChartColumnSeries *series = [NChartColumnSeries series];
        series.brush = (NChartBrush *)[self.brushes objectAtIndex:i % BRUSH_COUNT];
        series.tag = i;
        series.dataSource = self;
        [m_chart addSeries:series];
        
        NSMutableArray *points = [NSMutableArray array];
        for (NSInteger j = 1; j < m; j += 2)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:i + 1 column:j])
                [points addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXZWithX:i Y:value / 1.0e6 Z:(j - 1) / 2]
                                                    forSeries:series]];
            else
                [points addObject:[NSNull null]];
        }
        [pointsArray addObject:points];
    }
    
    self.points = pointsArray;
    self.xTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.drawIn3D = YES;
    
    m_chart.cartesianSystem.xAxis.labelsAngle = -M_PI_4;
    m_chart.cartesianSystem.zAxis.labelsAngle = -M_PI_4;
  
    if (!isIPhone())
        m_chart.cartesianSystem.zAxis.labelsAlignment = NChartAxisLabelsAlignmentLeft;
    
    NChartColumnSeriesSettings *setting = [NChartColumnSeriesSettings seriesSettings];
    setting.shouldGroupColumns = NO;
    setting.cylindersResolution = 20;
    setting.shouldSmoothCylinders = YES;
    setting.isRudimentEnabled = m_prevValue == m;
    m_prevValue = m;
    [m_chart addSeriesSettings:setting];
    
    m_chart.background = BrushWithImage(@"population_back.jpg");
    
    UIColor *borderColor = ColorWithRGB(154, 183, 203);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.xAlongZ.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.zAlongX.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.yAlongZ.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.zAlongY.color = ColorWithRGB(219, 230, 230);
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = NO;
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = NChartMarginMake(60.0f, 50.0f, 10.0f, 10.0f);
    else
        m_chart.cartesianSystem.margin = NChartMarginMake(30.0f, 10.0f, 10.0f, 10.0f);
    
    UIColor *textColor = ColorWithRGB(104, 133, 153);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.maxLabelLength = 400.0f;
    m_chart.cartesianSystem.xAxis.minTickSpacing = 10.0f;
    m_chart.cartesianSystem.xAxis.labelsAlignment = NChartAxisLabelsAlignmentRight;
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalMove ^
                                   NChartUserInteractionVerticalMove);
}

- (void)createPopulationProjection
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"projections_of_population_images.csv"];
    
    NSMutableArray *colorsArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        if (isIPhone() && (i == 0 || i == 1))
            continue;
        
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:1]]];
        double r = 0.0;
        double g = 0.0;
        double b = 0.0;
        if ([m_dataBase doubleValue:&r forRow:i column:2] &&
            [m_dataBase doubleValue:&g forRow:i column:3] &&
            [m_dataBase doubleValue:&b forRow:i column:4])
            [colorsArray addObject:BrushWithRGB(r, g, b)];
        else
            [colorsArray addObject:BrushWithRGB(0, 0, 0)];
    }
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"projections_of_population_growth.csv"];
    
    [self resetToDefaultProperty];
    
    self.xName = @"Years";
    
    if (isIPhone())
    {
        self.yName = @"Population (Millions)";
        self.yMask = @"%.0f";
    }
    else
    {
        self.yName = @"Population";
        self.yMask = @"%.0f M";
    }
    self.yMax = isIPhone() ? @2500 : @9000;
    self.yStep = isIPhone() ? @500 : @1000;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    NSMutableArray *namesArray = [NSMutableArray array];
    
    NSInteger m = m_dataBase.rowsCount;
    
    for (NSInteger row = 1; row < m; ++row)
        [ticksArray addObject:[m_dataBase stringValueForRow:row column:0]];
    self.xTicks = ticksArray;
    
    NSInteger tag = 0;
    for (NSInteger column = 2; column < m_dataBase.columnsCount; ++column)
    {
        if (isIPhone() && (column == 2 || column == 3))
            continue;
        
        [namesArray addObject:[m_dataBase stringValueForRow:0 column:column]];
        
        NChartColumnSeries *series = [NChartColumnSeries series];
        series.brush = (NChartBrush *)[colorsArray objectAtIndex:tag];
        series.tag = tag;
        series.dataSource = self;
        [m_chart addSeries:series];
        ++tag;
        
        NSMutableArray *points = [NSMutableArray array];
        for (NSInteger row = 1; row < m; ++row)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:row column:column])
            {
                NChartPoint *point = [NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:row - 1 Y:value] forSeries:series];
                
                // Create tooltip
                point.tooltip = [[NChartTooltip new] autorelease];
                point.tooltip.font = [UIFont systemFontOfSize:12.0f];
                point.tooltip.visible = YES;
                point.tooltip.alwaysInPlotArea = NO;
                point.tooltip.verticalAlignment = NChartTooltipVerticalAlignmentCenter;
                point.tooltip.textColor = ColorWithRGB(255, 255, 255);
                [self updateTooltipTextForPoint:point];
                
                [points addObject:point];
            }
            else
                [points addObject:[NSNull null]];
        }
        [pointsArray addObject:points];
    }
    self.names = namesArray;
    self.points = pointsArray;
    self.images = imagesArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.cartesianSystem.valueAxesType = NChartValueAxesTypeAdditive;
    
    m_chart.background = BrushWithImage(@"population_back.jpg");
    
    UIColor *borderColor = ColorWithRGB(154, 183, 203);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 100);
    m_chart.legend.borderColor = ColorWithRGB(210, 210, 210);
    
    m_chart.legend.shouldAutodetectColumnCount = NO;
    if (isIPhone())
        m_chart.legend.columnCount = 2;
    else
        m_chart.legend.columnCount = 3;
    
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(179, 204, 220);
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = NO;
    
    UIColor *textColor = ColorWithRGB(104, 133, 153);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    
    m_chart.userInteractionMode = NChartUserInteractionTap;
}

- (void)createMarketShareSmartphonesSuperSimple
{
    
    NSMutableArray *colorsArray = [NSMutableArray array];
    for (NSInteger i=0; i<6; ++i)
    {
        int r = rand() % 250;
        int g = rand() % 250;
        int b = rand() % 250;
        [colorsArray addObject:BrushWithRGB(r, g, b)];
    }
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_images.csv"];
    
    //    NSMutableArray *colorsArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:1]]];
    }
    
    
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_sales_by_years2.csv"];
    
    [self resetToDefaultProperty];
    
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    
    for (NSInteger i = 1; i < m_dataBase.rowsCount; ++i)
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    
    for (NSInteger column = 2; column < m_dataBase.columnsCount; ++column)
    {
        NSString *name = [m_dataBase stringValueForRow:0 column:column];
        if (isIPhone())
        {
            if ([name compare:@"Windows Mobile"] == NSOrderedSame)
                name = @"W. Mobile";
            else if ([name compare:@"Windows Phone"] == NSOrderedSame)
                name = @"W. Phone";
        }
        [namesArray addObject:name];
        
        NSMutableArray *states = [NSMutableArray array];
        
        double value = 0.0;
        
        for (NSInteger row = 1; row < m_dataBase.rowsCount; ++row)
        {
            if (![m_dataBase doubleValue:&value forRow:row column:column])
                value = 0.0;
            if (value > 0)
            {
                NChartPointState *state = [NChartPointState pointStateWithCircle:0 value:value];
                [states addObject:state];
            }
            else
                [states addObject:[NSNull null]];
        }
        
        NChartPieSeries *series = [NChartPieSeries series];
        series.brush = (NChartBrush *)[colorsArray objectAtIndex:column - 2];
        series.dataSource = self;
        series.tag = column - 2;
        [m_chart addSeries:series];
        
        NChartPoint *point = [NChartPoint pointWithArrayOfStates:states forSeries:series];
        [pointsArray addObject:@[point]];
        
    }
    
    self.names = namesArray;
    self.points = pointsArray;
    self.images = imagesArray;
    self.timeAxisTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.background = BrushWithImage(@"smartphones_back.jpg");
    
    m_chart.legend.shouldAutodetectColumnCount = NO;
    m_chart.legend.columnCount = 3;
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 100);
    m_chart.legend.borderColor = ColorWithRGB(210, 210, 210);
    
    m_chart.drawIn3D = YES;
    
    NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
    settings.holeRatio = 0.0f;
    [m_chart addSeriesSettings:settings];
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalMove
                                   ^ NChartUserInteractionVerticalMove);
}

- (void)createMarketShareSmartphonesSimple
{
    
    NSMutableArray *colorsArray = [NSMutableArray array];
    for (NSInteger i=0; i<6; ++i)
    {
        int r = rand() % 250;
        int g = rand() % 250;
        int b = rand() % 250;
        [colorsArray addObject:BrushWithRGB(r, g, b)];
    }
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_images.csv"];
    
    //    NSMutableArray *colorsArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:1]]];
    }
    
    
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_sales_by_years2.csv"];
    
    [self resetToDefaultProperty];
    
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    
    for (NSInteger i = 1; i < m_dataBase.rowsCount; ++i)
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    
    for (NSInteger column = 2; column < m_dataBase.columnsCount; ++column)
    {
        NSString *name = [m_dataBase stringValueForRow:0 column:column];
        if (isIPhone())
        {
            if ([name compare:@"Windows Mobile"] == NSOrderedSame)
                name = @"W. Mobile";
            else if ([name compare:@"Windows Phone"] == NSOrderedSame)
                name = @"W. Phone";
        }
        [namesArray addObject:name];
        
        NSMutableArray *states = [NSMutableArray array];

        double value = 0.0;

        for (NSInteger row = 1; row < m_dataBase.rowsCount; ++row)
        {
            if (![m_dataBase doubleValue:&value forRow:row column:column])
                value = 0.0;
            if (value > 0)
            {
                NChartPointState *state = [NChartPointState pointStateWithCircle:0 value:value];
                [states addObject:state];
            }
            else
                [states addObject:[NSNull null]];
        }
        
        NChartPieSeries *series = [NChartPieSeries series];
        series.brush = (NChartBrush *)[colorsArray objectAtIndex:column - 2];
        series.dataSource = self;
        series.tag = column - 2;
        [m_chart addSeries:series];
        
        NChartPoint *point = [NChartPoint pointWithArrayOfStates:states forSeries:series];
        [pointsArray addObject:@[point]];
        
    }
    
    self.names = namesArray;
    self.points = pointsArray;
    self.images = imagesArray;
    self.timeAxisTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.background = BrushWithImage(@"smartphones_back.jpg");
    
    m_chart.legend.shouldAutodetectColumnCount = NO;
    m_chart.legend.columnCount = 3;
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 100);
    m_chart.legend.borderColor = ColorWithRGB(210, 210, 210);
    
    m_chart.drawIn3D = YES;
    
    NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
    settings.holeRatio = 0.0f;
    [m_chart addSeriesSettings:settings];
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalMove
                                   ^ NChartUserInteractionVerticalMove);
}




- (void)createMarketShareSmartphones
{


    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_images.csv"];
    
    NSMutableArray *colorsArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:1]]];

        double r1 = 0.0;
        double g1 = 0.0;
        double b1 = 0.0;
        double r2 = 0.0;
        double g2 = 0.0;
        double b2 = 0.0;
        if ([m_dataBase doubleValue:&r1 forRow:i column:2] &&
            [m_dataBase doubleValue:&g1 forRow:i column:3] &&
            [m_dataBase doubleValue:&b1 forRow:i column:4] &&
            [m_dataBase doubleValue:&r2 forRow:i column:5] &&
            [m_dataBase doubleValue:&g2 forRow:i column:6] &&
            [m_dataBase doubleValue:&b2 forRow:i column:7])
            [colorsArray addObject:GradientBrushWithRGB(r1, g1, b1, r2, g2, b2)];
        else
            [colorsArray addObject:BrushWithRGB(0, 0, 0)];

    }

    
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"smartphones_sales_by_years.csv"];
    
    [self resetToDefaultProperty];
    
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    
    for (NSInteger i = m_dataBase.rowsCount - 5; i > 0; i -= 4)
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    
    for (NSInteger column = 2; column < m_dataBase.columnsCount; ++column)
    {
        NSString *name = [m_dataBase stringValueForRow:0 column:column];
        if (isIPhone())
        {
            if ([name compare:@"Windows Mobile"] == NSOrderedSame)
                name = @"W. Mobile";
            else if ([name compare:@"Windows Phone"] == NSOrderedSame)
                name = @"W. Phone";
        }
        [namesArray addObject:name];
        
        NSMutableArray *states = [NSMutableArray array];
        for (NSInteger row = m_dataBase.rowsCount - 5; row > 0; row -= 4)
        {

            double sum = 0.0;
            for (NSInteger j = 0; j < 4; ++j)
            {
                double value = 0.0;
                if ([m_dataBase doubleValue:&value forRow:row + j column:column])
                    sum += value;
            }

            if (sum > 0)
            {
                NChartPointState *state = [NChartPointState pointStateWithCircle:0 value:sum];
                [states addObject:state];
            }
            else
                [states addObject:[NSNull null]];

 }
        
        NChartPieSeries *series = [NChartPieSeries series];
        series.brush = (NChartBrush *)[colorsArray objectAtIndex:column - 2];
        series.dataSource = self;
        series.tag = column - 2;
        [m_chart addSeries:series];
        
        NChartPoint *point = [NChartPoint pointWithArrayOfStates:states forSeries:series];
        [pointsArray addObject:@[point]];
        
    }
    
    self.names = namesArray;
    self.points = pointsArray;
    self.images = imagesArray;
    self.timeAxisTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.background = BrushWithImage(@"smartphones_back.jpg");
    
    m_chart.legend.shouldAutodetectColumnCount = NO;
    m_chart.legend.columnCount = 3;
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 100);
    m_chart.legend.borderColor = ColorWithRGB(210, 210, 210);
    
    m_chart.drawIn3D = YES;
    
    NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
    settings.holeRatio = 0.0f;
    [m_chart addSeriesSettings:settings];
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalMove
                                   ^ NChartUserInteractionVerticalMove);
}

- (void)createMarketShareBrowsers
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"browsers_images.csv"];
    
    NSMutableArray *colorsArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:1]]];
        double r1 = 0.0;
        double g1 = 0.0;
        double b1 = 0.0;
        double r2 = 0.0;
        double g2 = 0.0;
        double b2 = 0.0;
        if ([m_dataBase doubleValue:&r1 forRow:i column:2] &&
            [m_dataBase doubleValue:&g1 forRow:i column:3] &&
            [m_dataBase doubleValue:&b1 forRow:i column:4] &&
            [m_dataBase doubleValue:&r2 forRow:i column:5] &&
            [m_dataBase doubleValue:&g2 forRow:i column:6] &&
            [m_dataBase doubleValue:&b2 forRow:i column:7])
            [colorsArray addObject:GradientBrushWithRGB(r1, g1, b1, r2, g2, b2)];
        else
            [colorsArray addObject:BrushWithRGB(0, 0, 0)];
    }
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"browsers_usage.csv"];
    
    [self resetToDefaultProperty];
    
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    
    for (NSInteger i = m_dataBase.rowsCount - 1; i > 0; --i)
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    
    for (NSInteger column = 1; column < m_dataBase.columnsCount; ++column)
    {
        NSString *name = [m_dataBase stringValueForRow:0 column:column];
        if (isIPhone() && ([name compare:@"Internet Explorer"] == NSOrderedSame))
            name = @"IE";
        [namesArray addObject:name];
        
        NChartPieSeries *series = [NChartPieSeries series];
        series.brush = (NChartBrush *)[colorsArray objectAtIndex:column - 1];
        series.dataSource = self;
        series.tag = column - 1;
        [m_chart addSeries:series];
        
        NSMutableArray *states = [NSMutableArray array];
        for (NSInteger row = m_dataBase.rowsCount - 1; row > 0; --row)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:row column:column] && value > 0.0)
            {
                [states addObject:[NChartPointState pointStateWithCircle:0 value:value]];
            }
            else
            {
                [states addObject:[NSNull null]];
            }
        }
        
        [pointsArray addObject:@[[NChartPoint pointWithArrayOfStates:states forSeries:series]]];
    }
    self.names = namesArray;
    self.points = pointsArray;
    self.timeAxisTicks = ticksArray;
    self.images = imagesArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.legend.shouldAutodetectColumnCount = NO;
    m_chart.legend.columnCount = 3;
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 100);
    m_chart.legend.borderColor = ColorWithRGB(210, 210, 210);
    
    NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
    settings.holeRatio = isIPhone() ? 0.35f : 0.24f;
    settings.centerCaption = [[NChartTooltip new] autorelease];
    settings.centerCaption.text = isIPhone() ? @"Browser\nWars" : @"Browser Wars";
    settings.centerCaption.verticalAlignment = NChartTooltipVerticalAlignmentCenter;
    [m_chart addSeriesSettings:settings];
    
    m_chart.background = BrushWithImage(@"browsers_back.jpg");
    
    m_chart.polarSystem.margin = NChartMarginMake(20.0f, 20.0f, 20.0f, 20.0f);
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionHorizontalMove
                                   ^ NChartUserInteractionVerticalMove);
}

- (void)createPopulationPyramid
{
    [self resetToDefaultProperty];
    
    self.names = @[@"Male", @"Female"];
    self.images = @[[UIImage imageNamed:@"male_icon.png"], [UIImage imageNamed:@"female_icon.png"]];
    
    if (isIPhone())
    {
        self.xName = @"Population (Thousands)";
        self.xMask = @"%.0f";
    }
    else
    {
        self.xName = @"Population";
        self.xMask = @"%.1f k";
    }
    
    if (!isIPhone())
    {
        self.yName = @"Age";
        self.syName = @"Age";
    }
    
    self.xMin = isIPhone() ? @-400 : @-350;
    self.xMax = isIPhone() ? @400 : @350;
    self.xStep = isIPhone() ? @100 : @50;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *points = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    NSMutableArray *timeAxisTicksArray = [NSMutableArray array];
    
    // Male
    
    NChartBarSeries *seriesMale = [NChartBarSeries series];
    seriesMale.brush = GradientBrushWithRGBA(65, 90, 200, 200, 35, 60, 170, 100);
    seriesMale.tag = 0;
    seriesMale.dataSource = self;
    [m_chart addSeries:seriesMale];
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"population_by_age_male.csv"];
    
    for (NSInteger i = 1; i < m_dataBase.columnsCount; ++i)
    {
        NSMutableArray *states = [NSMutableArray array];
        for (NSInteger year = 1; year < m_dataBase.rowsCount; ++year)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:year column:i])
                [states addObject:[NChartPointState pointStateAlignedToYWithX:-value / 1.0e3 Y:i - 1]];
            else
                [states addObject:[NSNull null]];
        }
        [points addObject:[NChartPoint pointWithArrayOfStates:states forSeries:seriesMale]];
    }
    [pointsArray addObject:points];
    
    // Female
    
    NChartBarSeries *seriesFemale = [NChartBarSeries series];
    seriesFemale.brush = GradientBrushWithRGBA(115, 26, 110, 100, 165, 56, 140, 200);
    seriesFemale.tag = 1;
    seriesFemale.dataSource = self;
    seriesFemale.hostsOnSY = YES;
    [m_chart addSeries:seriesFemale];
    
    points = [NSMutableArray array];
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"population_by_age_female.csv"];
    
    for (NSInteger i = 1; i < m_dataBase.columnsCount; ++i)
    {
        NSMutableArray *states = [NSMutableArray array];
        for (NSInteger year = 1; year < m_dataBase.rowsCount; ++year)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:year column:i])
                [states addObject:[NChartPointState pointStateAlignedToYWithX:value / 1.0e3 Y:i - 1]];
            else
                [states addObject:[NSNull null]];
        }
        [points addObject:[NChartPoint pointWithArrayOfStates:states forSeries:seriesFemale]];
    }
    [pointsArray addObject:points];
    
    // Get ticks
    
    for (NSInteger i = 1; i < m_dataBase.columnsCount; ++i)
        [ticksArray addObject:[m_dataBase stringValueForRow:0 column:i]];
    self.yTicks = ticksArray;
    self.syTicks = ticksArray;
    
    // Get years
    
    for (NSInteger i = 1; i < m_dataBase.rowsCount; ++i)
        [timeAxisTicksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    self.timeAxisTicks = timeAxisTicksArray;
    
    self.points = pointsArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.timeAxis.tooltip.textColor = ColorWithRGB(143, 143, 163);
    
    m_chart.timeAxis.tickColor = ColorWithRGB(143, 143, 163);
    m_chart.timeAxis.tickTitlesColor = ColorWithRGB(143, 143, 163);
    
    [m_chart.timeAxis setImagesForBeginNormal:nil
                                  beginPushed:nil
                                    endNormal:nil
                                    endPushed:nil
                                   playNormal:[UIImage imageNamed:@"play-blue.png"]
                                   playPushed:[UIImage imageNamed:@"play-pushed-blue.png"]
                                  pauseNormal:[UIImage imageNamed:@"pause-blue.png"]
                                  pausePushed:[UIImage imageNamed:@"pause-pushed-blue.png"]
                                       slider:[UIImage imageNamed:@"slider-blue.png"]
                                      handler:[UIImage imageNamed:@"handler-blue.png"]];
    
    m_chart.cartesianSystem.valueAxesType = NChartValueAxesTypeAdditive;
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.yAxis.hasOffset = YES;
    m_chart.cartesianSystem.syAxis.hasOffset = YES;
    
    UIColor *borderColor = ColorWithRGB(183, 183, 203);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(220, 220, 230);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(200, 200, 210);
    m_chart.cartesianSystem.syAlongX.color = ColorWithRGB(200, 200, 210);
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = NO;
    if (isIPhone())
        m_chart.cartesianSystem.xAxis.minTickSpacing = 30;
    
    UIColor *textColor = ColorWithRGB(143, 143, 163);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.syAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.syAxis.caption.textColor = textColor;
    
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 50);
    m_chart.legend.borderColor = ColorWithRGB(220, 220, 230);
    
    if (isIPhone())
        m_chart.background = BrushWithImage(@"male_female_back_iphone.jpg");
    else
        m_chart.background = BrushWithImage(@"male_female_back.jpg");
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalZoom ^ NChartUserInteractionProportionalZoom ^
                                   NChartUserInteractionHorizontalZoom ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionHorizontalMove);
}

- (void)createGDPPerCapita
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"gdp_per_capita.csv"];
    
    NSInteger n = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyGDPPerCapitaYearsCount]]).integerValue;
    
    [self resetToDefaultProperty];
    
    self.xName = @"Years";
    
    if (!isIPhone())
    {
        self.yName = @"Value";
        self.yMask = @"%.2f%%";
    }
    else
    {
        self.yName = @"Value (%)";
        self.yMask = @"%.1f";
    }
    
    self.zName = [m_dataBase stringValueForRow:0 column:0];
    
    NSInteger startYear = m_dataBase.columnsCount - n;
    
    NSMutableArray *yearsTicksArray = [NSMutableArray array];
    for (NSInteger i = startYear; i < m_dataBase.columnsCount; ++i)
    {
        [yearsTicksArray addObject:[m_dataBase stringValueForRow:0 column:i]];
    }
    self.xTicks = yearsTicksArray;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    for (NSInteger i = 1; i < m_dataBase.rowsCount; ++i)
    {
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
        
        double r = 0.0;
        double g = 0.0;
        double b = 0.0;
        
        [m_dataBase doubleValue:&r forRow:i column:1];
        [m_dataBase doubleValue:&g forRow:i column:2];
        [m_dataBase doubleValue:&b forRow:i column:3];
        
        NChartRibbonSeries *series = [NChartRibbonSeries series];
        series.brush = BrushWithRGB(r, g, b);
        series.tag = i - 1;
        series.dataSource = self;
        series.dataSmoother = [NChartDataSmoother2D dataSmoother];
        [m_chart addSeries:series];
        
        NSMutableArray *points = [NSMutableArray array];
        for (NSInteger j = startYear; j < m_dataBase.columnsCount; ++j)
        {
            double value = 0.0;
            if ([m_dataBase doubleValue:&value forRow:i column:j])
                [points addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXZWithX:j - startYear Y: value Z:i - 1]
                                                    forSeries:series]];
            else
                [points addObject:[NSNull null]];
        }
        [pointsArray addObject:points];
    }
    
    self.points = pointsArray;
    self.zTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.drawIn3D = YES;
    
    m_chart.background = BrushWithImage(@"population_back.jpg");
    
    UIColor *borderColor = ColorWithRGB(154, 183, 203);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.xAlongZ.color = ColorWithRGB(219, 230, 230);
    m_chart.cartesianSystem.zAlongX.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.yAlongZ.color = ColorWithRGB(179, 204, 220);
    m_chart.cartesianSystem.zAlongY.color = ColorWithRGB(219, 230, 230);
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = NO;
    
    m_chart.cartesianSystem.xAxis.minTickSpacing = 50.0;
    m_chart.cartesianSystem.xAxis.labelsAngle = -M_PI_4;
    
    m_chart.cartesianSystem.zAxis.labelsAngle = -M_PI_4;
    m_chart.cartesianSystem.zAxis.labelsAlignment = NChartAxisLabelsAlignmentLeft;
    m_chart.cartesianSystem.zAxis.majorTicks.visible = NO;
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = NChartMarginMake(55.0f, 45.0f, 18.0f, 18.0f);
    else
        m_chart.cartesianSystem.margin = NChartMarginMake(35.0f, 25.0f, 18.0f, 18.0f);
    
    UIColor *textColor = ColorWithRGB(104, 133, 153);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalMove ^
                                   NChartUserInteractionHorizontalMove);
}

- (void)createWindRose
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"wind_rose_data.csv"];
    
    [self resetToDefaultProperty];
    
    NChartRadarSeries *series = [NChartRadarSeries series];
    series.brush = GradientBrushWithRGBA(255, 165, 0, 140, 255, 50, 0, 140);
    series.borderBrush = BrushWithRGB(155, 80, 65);
    series.borderThickness = 1.0f;
    series.tag = 0;
    series.dataSource = self;
    [m_chart addSeries:series];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    const NSInteger totalPointsCount = 360;
    const NSInteger pointsCount = isIPhone() ? 72 : 360;
    const NSInteger anglesInPoint = totalPointsCount / pointsCount;
    const NSInteger ticksCount = 12;
    for (NSInteger i = 0; i < pointsCount; ++i)
    {
        NSMutableArray *statesArray = [NSMutableArray array];
        for (NSInteger j = 0; j < ticksCount; ++j)
        {
            [statesArray addObject:[NChartPointState pointStateAlignedToXWithX:i Y:0.0]];
        }
        [pointsArray addObject:[NChartPoint pointWithArrayOfStates:statesArray forSeries:series]];
    }
    
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        double month = 0.0;
        double day = 0.0;
        double hour = 0.0;
        double startAngle = 0.0;
        double endAngle = 0.0;
        double power = 0.0;
        if ([m_dataBase doubleValue:&month forRow:i column:0] &&
            [m_dataBase doubleValue:&day forRow:i column:2] &&
            [m_dataBase doubleValue:&hour forRow:i column:3] &&
            [m_dataBase doubleValue:&startAngle forRow:i column:4] &&
            [m_dataBase doubleValue:&endAngle forRow:i column:5] &&
            [m_dataBase doubleValue:&power forRow:i column:6])
        {
            NSInteger startIndex = (NSInteger)startAngle;
            if (startIndex >= 360)
                startIndex -= 360;
            NSInteger endIndex = (NSInteger)endAngle;
            if (endIndex >= 360)
                endIndex -= 360;
            for (NSInteger angle = startIndex; angle <= endIndex; ++angle)
            {
                NChartPoint *point = [pointsArray objectAtIndex:(NSInteger)((float)angle / (float)anglesInPoint)];
                NChartPointState *state = [point.states objectAtIndex:(NSInteger)month];
                state.doubleY += power;
            }
        }
    }
    
    self.points = @[pointsArray];
    self.timeAxisTicks = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August",
                           @"September", @"October", @"November", @"December"];
    
    self.azimuthStep = isIPhone() ? @9 : @45;
    self.azimuthMax = [NSNumber numberWithInteger:pointsCount];
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.timeAxis.padding = NChartMarginMake(0.0f, 10.0f, 0.0f, 0.0f);
    
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.userInteractionMode = NChartUserInteractionHorizontalRotate | NChartUserInteractionVerticalRotate;
    
    m_chart.polarSystem.azimuthAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.polarSystem.radiusAxis.shouldBeautifyMinAndMax = NO;
    m_chart.polarSystem.radiusAxis.labelsVisible = NO;
    
    m_chart.background = BrushWithImage(@"winds_back.jpg");
    
    UIColor *axesColor = ColorWithRGB(130, 130, 130);
    UIColor *textColor = ColorWithRGB(110, 110, 110);
    
    m_chart.polarSystem.radiusAxis.caption.textColor = textColor;
    m_chart.polarSystem.radiusAxis.textColor = textColor;
    
    m_chart.polarSystem.radiusAxis.color = axesColor;
    m_chart.polarSystem.radiusAxis.majorTicks.color = axesColor;
    m_chart.polarSystem.radiusAxis.minorTicks.color = axesColor;
    
    m_chart.polarSystem.azimuthAxis.caption.textColor = textColor;
    m_chart.polarSystem.azimuthAxis.textColor = textColor;
    
    m_chart.polarSystem.azimuthAxis.color = axesColor;
    m_chart.polarSystem.azimuthAxis.majorTicks.color = axesColor;
    m_chart.polarSystem.azimuthAxis.minorTicks.color = axesColor;
    
    m_chart.polarSystem.grid.color = axesColor;
    
    m_chart.polarSystem.borderColor = axesColor;
}

- (void)createSalesFunnel
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"funnel_example.csv"];
    
    [self resetToDefaultProperty];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *imagesArray = [NSMutableArray array];
    
    for (NSInteger i = m_dataBase.rowsCount - 1; i >= 0; --i)
    {
        [namesArray addObject:[m_dataBase stringValueForRow:i column:0]];
        [imagesArray addObject:[UIImage imageNamed:[m_dataBase stringValueForRow:i column:5]]];
        
        double value = 0.0;
        double next = 0.0;
        double r = 0.0;
        double g = 0.0;
        double b = 0.0;
        if ([m_dataBase doubleValue:&value forRow:i column:1])
        {
            if (i == 0)
                next = 100.0;
            else
                [m_dataBase doubleValue:&next forRow:i - 1 column:1];
            [m_dataBase doubleValue:&r forRow:i column:2];
            [m_dataBase doubleValue:&g forRow:i column:3];
            [m_dataBase doubleValue:&b forRow:i column:4];
            NChartFunnelSeries *series = [NChartFunnelSeries series];
            series.brush = BrushWithRGB(r, g, b);
            series.tag = m_dataBase.rowsCount - 1 - i;
            series.dataSource = self;
            series.topRadius = (next - 3) / 100.0;
            series.bottomRadius = value / 100.0;
            [m_chart addSeries:series];
            
            [pointsArray addObject:@[[NChartPoint pointWithState:[NChartPointState pointStateWithX:0.0 Y:1.0 Z:0.0]
                                                       forSeries:series]]];
        }
    }
    
    self.names = namesArray;
    self.points = pointsArray;
    self.images = imagesArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    NChartFunnelSeriesSettings *settings = [NChartFunnelSeriesSettings seriesSettings];
    settings.gapSum = 0.2;
    [m_chart addSeriesSettings:settings];
    
    m_chart.drawIn3D = YES;
    m_chart.cartesianSystem.visible = NO;
    
    m_chart.userInteractionMode = (NChartUserInteractionVerticalRotate | NChartUserInteractionTap);
    
    m_chart.background = BrushWithImage(@"sales_back.jpg");
    
    m_chart.defaultVerticalRotationAngle = -M_PI_2;
    m_chart.defaultHorizontalRotationAngle = 0.0f;
    
    if (isIPhone())
    {
        m_chart.legend.minimalEntriesPadding = 5;
        m_chart.legend.maxSize = 40;
    }
    else
    {
        m_chart.legend.minimalEntriesPadding = 5;
    }
}

#pragma mark - mathematics series

- (void)createSurface: (BOOL)needsReset
{
    BOOL needBorder = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertySurfaceBorder]]).boolValue;
    BOOL isDiscrete = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertySurfaceIsDiscrete]]).boolValue;
    
    double shift = isDiscrete ? 1.5 : 0.0;
    NSInteger surfaceResolution = isDiscrete ? (isIPhone() ? 30 : 50) : 75;
    
    [self resetToDefaultProperty];
    self.yMin = [NSNumber numberWithDouble:-1.5 + shift];
    self.yMax = [NSNumber numberWithDouble:1.5 + shift];
    
    NChartSolidSeries *series;
    if (isDiscrete)
        series = [NChartColumnSeries series];
    else
        series = [NChartSurfaceSeries series];
    
    [m_chart addSeries:series];
    
    series.brush = BrushWithRGB(255, 0, 0);
    series.tag = 0;
    
    if (needBorder)
        series.borderThickness = 1.0;
    else
        series.borderThickness = 0.0;
    series.dataSource = self;
    
    double x = 0.0, y = 0.0, z = 0.0;
    double minY = -1.0, maxY = 1.0, normalY = 0.0;
    double minRed = 0.0, minGreen = 0.0, minBlue = 0.0;
    double maxRed = 0.0, maxGreen = 0.0, maxBlue = 0.0;
    
    switch (self.dataType)
    {
        case NChart3DDataSurfaceType1:
            minY = -1.0, maxY = 1.0;
            minRed = 36.0 / 255.0; minGreen = 136.0 / 255.0; minBlue = 201.0 / 255.0;
            maxRed = 122.0 / 255.0; maxGreen = 254.0 / 255.0; maxBlue = 254.0 / 255.0;
            break;
            
        case NChart3DDataSurfaceType2:
            minY = -1.0; maxY = 1.0;
            minRed = 169.0 / 255.0; minGreen = 115.0 / 255.0; minBlue = 0.0 / 255.0;
            maxRed = 233.0 / 255.0; maxGreen = 225.0 / 255.0; maxBlue = 0.0 / 255.0;
            break;
            
        case NChart3DDataSurfaceType3:
            minY = -0.5; maxY = 0.5;
            minRed = 18.0 / 255.0; minGreen = 161.0 / 255.0; minBlue = 3.0 / 255.0;
            maxRed = 89.0 / 255.0; maxGreen = 255.0 / 255.0; maxBlue = 168.0 / 255.0;
            break;
            
        case NChart3DDataSurfaceType4:
            minY = -0.5; maxY = 0.5;
            minRed = 137.0 / 255.0; minGreen = 16.0 / 255.0; minBlue = 197.0 / 255.0;
            maxRed = 222.0 / 255.0; maxGreen = 168.0 / 255.0; maxBlue = 255.0 / 255.0;
            break;
            
        default:
            break;
    }
    minY += shift;
    maxY += shift;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < surfaceResolution; ++i)
    {
        for (NSInteger j = 0; j < surfaceResolution; ++j)
        {
            switch (self.dataType)
            {
                case NChart3DDataSurfaceType1:
                    x = 2.0 * (double)(i) / (double)(surfaceResolution) - 1.0;
                    z = 2.0 * (double)(j) / (double)(surfaceResolution) - 1.0;
                    y = sin(x * M_PI) * cos(z * M_PI) + shift;
                    break;
                    
                case NChart3DDataSurfaceType2:
                    x = 2.0 * (double)(i) / (double)(surfaceResolution) - 1.0;
                    z = 2.0 * (double)(j) / (double)(surfaceResolution) - 1.0;
                    y = 1.5 * atan(-36.0 * x * z) / (maxY - minY) + shift;
                    break;
                    
                case NChart3DDataSurfaceType3:
                    x = 2.0 * (double)(i) / (double)(surfaceResolution) - 1.0;
                    z = 2.0 * (double)(j) / (double)(surfaceResolution) - 1.0;
                    double r = sqrt(x * x + z * z);
                    y = cos(r * M_PI * 4.0) * exp(-1.5 * r - 1.0) + shift;
                    break;
                    
                case NChart3DDataSurfaceType4:
                    x = 2.0 * (double)(i) / (double)(surfaceResolution) - 1.0;
                    z = 2.0 * (double)(j) / (double)(surfaceResolution) - 1.0;
                    double xz = fabs(x) * fabs(z);
                    y = (1.0 - xz) * 0.3 * sin((1.0 - xz) * M_PI * 4.0) + shift;
                    break;
                    
                default:
                    break;
            }
            NChartPointState *state = [NChartPointState pointStateWithX:x Y:y Z:z];
            normalY = (y - minY) / (maxY - minY);
            state.brush = [NChartSolidColorBrush solidColorBrushWithColor:[UIColor
                                                                           colorWithRed:(1.0 - normalY) * minRed + normalY * maxRed
                                                                           green:(1.0 - normalY) * minGreen + normalY * maxGreen
                                                                           blue:(1.0 - normalY) * minBlue + normalY * maxBlue
                                                                           alpha:1.0f]];
            if (needBorder)
            {
                NChartBrush *borderBrush = [[state.brush copy] autorelease];
                [borderBrush scaleColorWithRScale:0.65f gScale:0.65f bScale:0.65f];
                state.borderBrush = borderBrush;
            }
            else
                state.borderBrush = nil;
            [pointsArray addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
    }
    
    self.points = @[pointsArray];
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = !isDiscrete;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.drawIn3D = YES;
    m_chart.pointSelectionEnabled = NO;
    
    UIColor *borderInnerColor = ColorWithRGB(125, 125, 155);
    UIColor *borderOuterColor = ColorWithRGB(150, 150, 180);
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.xAlongZ.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongZ.color = borderInnerColor;

    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.background = BrushWithImage(@"surface_background.jpg");
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = NChartMarginMake(60.0f, 60.0f, 20.0f, 20.0f);
    else
        m_chart.cartesianSystem.margin = NChartMarginMake(35.0f, 10.0f, 10.0f, 10.0f);
    
    m_chart.userInteractionMode = NChartUserInteractionAll ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionHorizontalMove;
    
    NChartColumnSeriesSettings *setting = [NChartColumnSeriesSettings seriesSettings];
    setting.cylindersResolution = 6;
    [m_chart addSeriesSettings:setting];
}

- (void)createLissajousCurve
{
    BOOL is3D = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyLissajousCurveDimension]]).integerValue == 1;
    
    [self resetToDefaultProperty];
    
    NChartBubbleSeries *series = [NChartBubbleSeries series];
    series.dataSource = self;
    series.tag = 0;
    [m_chart addSeries:series];
    
    const NSInteger resolution = 250;
    const NSInteger yearsCount = 10;
    
    NSMutableArray *timeAxisTicksArray = [NSMutableArray array];
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    for (NSInteger i = 1; i <= yearsCount; ++i)
        [timeAxisTicksArray addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    
    for (int i = 0; i <= resolution; ++i)
    {
        NSMutableArray *states = [NSMutableArray array];
        for (int j = 0; j < yearsCount; ++j)
        {
            double t = (((2.0 * M_PI) / (double)(resolution)) * (double)(i + j * 2));
            double x = sin(3.0 * t);
            double y = sin(4.0 * t);
            double z = sin(7.0 * t);
            NChartPointState *state = [NChartPointState pointStateWithX:x Y:y Z:z];
            state.marker = [[NChartMarker new] autorelease];
            state.marker.size = 1.0f;
            if (!is3D)
            {
                state.marker.shape = NChartMarkerShapeCircle;
                state.marker.brush = [self.brushes objectAtIndex:i % BRUSH_COUNT];
                state.marker.brush.shadingModel = NChartShadingModelPlain;
                state.marker.brush.opacity = 0.8f;
            }
            else
            {
                state.marker.shape = NChartMarkerShapeSphere;
                state.marker.brush = [self.brushes objectAtIndex:i % BRUSH_COUNT];
                state.marker.brush.shadingModel = NChartShadingModelPhong;
            }
            [states addObject:state];
        }
        [pointsArray addObject:[NChartPoint pointWithArrayOfStates:states forSeries:series]];
    }
    
    self.points = @[pointsArray];
    self.timeAxisTicks = timeAxisTicksArray;
    
    [self resetToDefaultSetting];
    
    m_chart.drawIn3D = is3D;
    
    if (is3D)
    {
        if (!isIPhone())
            m_chart.cartesianSystem.margin = NChartMarginMake(50.0f, 50.0f, 10.0f, 10.0f);
        else
            m_chart.cartesianSystem.margin = NChartMarginMake(30.0f, 10.0f, 10.0f, 10.0f);
    }
    
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.cartesianSystem.xAxis.hasOffset = YES;
    m_chart.cartesianSystem.yAxis.hasOffset = YES;
    m_chart.cartesianSystem.zAxis.hasOffset = YES;
    
    m_chart.background = BrushWithImage(@"surface_background.jpg");
    
    UIColor *borderInnerColor = ColorWithRGB(125, 125, 155);
    UIColor *borderOuterColor = ColorWithRGB(150, 150, 180);
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.xAlongZ.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongZ.color = borderInnerColor;
    
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.timeAxis.tooltip.textColor = textColor;
    
    m_chart.timeAxis.tickColor = borderOuterColor;
    m_chart.timeAxis.tickTitlesColor = textColor;
    
    [m_chart.timeAxis setImagesForBeginNormal:nil
                                  beginPushed:nil
                                    endNormal:nil
                                    endPushed:nil
                                   playNormal:[UIImage imageNamed:@"play-dark-blue.png"]
                                   playPushed:[UIImage imageNamed:@"play-pushed-dark-blue.png"]
                                  pauseNormal:[UIImage imageNamed:@"pause-dark-blue.png"]
                                  pausePushed:[UIImage imageNamed:@"pause-pushed-dark-blue.png"]
                                       slider:[UIImage imageNamed:@"slider-blue.png"]
                                      handler:[UIImage imageNamed:@"handler-blue.png"]];
}

- (void)createHypotrochoid
{
    double R = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidOuterRadius]]).integerValue;
    double r = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidInnerRadius]]).integerValue;
    double d = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyHypotrochoidDistance]]).integerValue;
    
    [self resetToDefaultProperty];
    
    NChartLineSeries *series = [NChartLineSeries series];
    series.dataSource = self;
    series.tag = 0;
    series.brush = BrushWithRGB(255, 0, 0);
    series.lineThickness = 2.0;
    [m_chart addSeries:series];
    
    double minX = 0.0f, maxX = 0.0f;
    double minY = 0.0f, maxY = 0.0f;
    
    
    NSArray *gradientBrushes = @[BrushWithRGB(0, 143, 225), BrushWithRGB(101, 226, 227),
                                 BrushWithRGB(237, 204, 20), BrushWithRGB(220, 120, 0)];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    for (NSInteger angle = 0; angle <= 1000; ++angle)
    {
        double fi = (double)angle / 180.0 * M_PI * 3;
        double x = (R - r) * cos(fi) + d * cos((R - r) / r * fi);
        double y = (R - r) * sin(fi) - d * sin((R - r) / r * fi);
        
        double t = sqrt(x * x + y * y) / (R + d);
        
        if (minX > x)
            minX = x;
        if (maxX < x)
            maxX = x;
        
        if (minY > y)
            minY = y;
        if (maxY < y)
            maxY = y;
        
        NChartPointState *state = [NChartPointState pointStateWithX:x Y:y Z:0.0];
        state.brush = [self getInterpolatedBrushWithRatio:t fromBrushes:gradientBrushes];
        [pointsArray addObject:[NChartPoint pointWithState:state forSeries:series]];
    }
    
    double deltaX = MAX(ABS(minX), ABS(maxX));
    double deltaY = MAX(ABS(minY), ABS(maxY));
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    double screenAspect = screenBounds.size.width / screenBounds.size.height;
    if (screenAspect > 1.0)
        deltaX *= screenAspect;
    else
        deltaY /= screenAspect;
    
    self.xMin = [NSNumber numberWithDouble:-deltaX];
    self.xMax = [NSNumber numberWithDouble: deltaX];
    self.yMin = [NSNumber numberWithDouble:-deltaY];
    self.yMax = [NSNumber numberWithDouble: deltaY];
    
    self.points = @[pointsArray];
    
    [self resetToDefaultSetting];
    
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.xAxis.hasOffset = YES;
    m_chart.cartesianSystem.yAxis.hasOffset = YES;
    
    m_chart.background = BrushWithImage(@"surface_background.jpg");
    
    UIColor *borderInnerColor = ColorWithRGB(125, 125, 155);
    UIColor *borderOuterColor = ColorWithRGB(150, 150, 180);
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
}

- (void)createHyperboloid
{
    [self resetToDefaultProperty];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    int n = 10;
    int m = 50;
    
    double k = 4.0;
    
    NChartLineSeries *series;
    NSMutableArray *points;
    
    NSArray *gradientBrushes = @[@[BrushWithRGB(0, 143, 225), BrushWithRGB(101, 226, 227)],
                                 @[BrushWithRGB(255, 84, 0), BrushWithRGB(237, 204, 20)]];
    const NSInteger gradientBrushesCount = [gradientBrushes count];
    
    for (NSInteger j = 0; j <= m; ++j)
    {
        double v = (double)j / (double)m * 4.0 * M_PI;
        
        // Lines 1
        series = [NChartLineSeries series];
        series.dataSource = self;
        series.tag = 2 * j;
        series.brush = BrushWithRGB(0, 125, 125);
        series.lineThickness = 1.5;
        [m_chart addSeries:series];
        
        points = [NSMutableArray array];
        {
            NChartPointState *state = [NChartPointState pointStateWithX:cos(v) - k * sin(v)
                                                                      Y:k *  1.0
                                                                      Z:sin(v) + k * cos(v)];
            state.brush = [((NSArray *)[gradientBrushes objectAtIndex:j % gradientBrushesCount]) objectAtIndex:1];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        {
            NChartPointState *state = [NChartPointState pointStateWithX:cos(v) + k * sin(v)
                                                                      Y:k * -1.0
                                                                      Z:sin(v) - k * cos(v)];
            state.brush = [((NSArray *)[gradientBrushes objectAtIndex:j % gradientBrushesCount]) objectAtIndex:0];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        [pointsArray addObject:points];
        
        // Lines 2
        series = [NChartLineSeries series];
        series.dataSource = self;
        series.tag = 2 * j + 1;
        series.brush = BrushWithRGB(125, 125, 0);
        series.lineThickness = 1.5;
        [m_chart addSeries:series];
        
        points = [NSMutableArray array];
        {
            NChartPointState *state = [NChartPointState pointStateWithX:cos(v) + k * sin(v)
                                                                      Y:k *  1.0
                                                                      Z:sin(v) - k * cos(v)];
            state.brush = [((NSArray *)[gradientBrushes objectAtIndex:j % gradientBrushesCount]) objectAtIndex:1];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        {
            NChartPointState *state = [NChartPointState pointStateWithX:cos(v) - k * sin(v)
                                                                      Y:k * -1.0
                                                                      Z:sin(v) + k * cos(v)];
            state.brush = [((NSArray *)[gradientBrushes objectAtIndex:j % gradientBrushesCount]) objectAtIndex:0];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        [pointsArray addObject:points];
    }
    
    for (NSInteger i = 0; i <= n; ++i)
    {
        // Circles
        series = [NChartLineSeries series];
        series.dataSource = self;
        series.tag = 2 * (m + 1) + i;
        series.brush = BrushWithRGB(125, 0, 125);
        series.lineThickness = 1.5;
        [m_chart addSeries:series];
        
        points = [NSMutableArray array];
        for (NSInteger j = 0; j <= m; ++j)
        {
            double u = k * (double)(2 * i - n) / (double)n;
            double v = (double)j / (double)m * 4.0 * M_PI;
            // Circles
            double x = sqrt(1.0 + u * u) * cos(v);
            double y = sqrt(1.0 + u * u) * sin(v);
            double z = u;
            
            NChartPointState *state = [NChartPointState pointStateWithX:x Y:z Z:y];
            state.brush = [((NSArray *)[gradientBrushes objectAtIndex:i % gradientBrushesCount]) objectAtIndex:(u > 0 ? 1 : 0)];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        [pointsArray addObject:points];
    }
    
    self.points = pointsArray;
    
    [self resetToDefaultSetting];
    
    m_chart.drawIn3D = YES;
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.background = BrushWithImage(@"background_hyperboloid.jpg");
    
    m_chart.defaultHorizontalRotationAngle = -M_PI;
    m_chart.defaultVerticalRotationAngle = -1.13;
    
    UIColor *borderInnerColor = ColorWithRGB(210, 210, 210);
    UIColor *borderOuterColor = ColorWithRGB(130, 130, 130);
    UIColor *textColor = ColorWithRGB(0, 0, 0);
    
    m_chart.caption.text = @"";
    
    m_chart.cartesianSystem.visible = NO;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.yAxis.hasOffset = NO;
    m_chart.cartesianSystem.zAxis.hasOffset = NO;
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.xAlongZ.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongZ.color = borderInnerColor;
    
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalMove ^
                                   NChartUserInteractionHorizontalMove);
}

#pragma mark - stocks series

- (void)createStocksType1
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"apple_historical_stock.csv"];
    
    NChartColumnSeries *volumeSeries = [NChartColumnSeries series];
    volumeSeries.tag = 0;
    volumeSeries.dataSource = self;
    volumeSeries.brush = BrushWithRGBA(133, 97, 0, 150);
    volumeSeries.hostsOnSY = YES;
    [m_chart addSeries:volumeSeries];
    
    NChartCandlestickSeries *series = [NChartCandlestickSeries series];
    series.tag = 1;
    series.dataSource = self;
    series.borderThickness = 1.0;
    series.negativeColor = ColorWithRGB(255, 67, 67);
    series.positiveColor = ColorWithRGB(42, 222, 177);
    series.negativeBorderColor = ColorWithRGB(255, 67, 67);
    series.positiveBorderColor = ColorWithRGB(42, 222, 177);
    [m_chart addSeries:series];
    
    [self resetToDefaultProperty];
    
    self.xName = @"Date";
    
    self.yMask = isIPhone() ? @"%.0f" : @"%.1f";
    
    self.yMin = @25;
    self.yMax = @105;
    self.yStep = @20;
    
    self.syName = isIPhone() ? @"Volume (Millions)" : @"Volume";
    self.syMask = isIPhone() ? @"%.0f" : @"%.1f M";
    self.syMax = @600.0;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *volumesArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    NSInteger n = m_dataBase.rowsCount;
    for (NSInteger i = n - 1; i > 0; --i)
    {
        double volume = 0.0;
        double close = 0.0;
        double open = 0.0;
        double high = 0.0;
        double low = 0.0;
        NSInteger index = n - 1 - i;
        if ([m_dataBase doubleValue:&volume forRow:i column:2] && [m_dataBase doubleValue:&close forRow:i column:1] &&
            [m_dataBase doubleValue:&open forRow:i column:3] && [m_dataBase doubleValue:&high forRow:i column:4] &&
            [m_dataBase doubleValue:&low forRow:i column:5])
        {
            [pointsArray addObject:[NChartPoint pointWithState:
                                    [NChartPointState pointStateAlignedToXZWithX:index Z:0 low:low open:open close:close high:high]
                                                     forSeries:series]];
            [volumesArray addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:index Y:volume / 1.0e6]
                                                      forSeries:volumeSeries]];
        }
        else
            [pointsArray addObject:[NSNull null]];
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    }
    
    self.points = @[volumesArray, pointsArray];
    self.xTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    UIColor *borderColor = ColorWithRGB(165, 165, 165);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAxis.minorTicks.visible = NO;
    
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    
    UIColor *axesColor = ColorWithRGB(75, 75, 75);
    m_chart.cartesianSystem.xAlongY.color = axesColor;
    m_chart.cartesianSystem.yAlongX.color = axesColor;
    m_chart.cartesianSystem.syAlongX.color = axesColor;
    
    UIColor *textColor = ColorWithRGBA(215, 215, 215, 180);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.syAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.syAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.syAlongX.visible = NO;
    
    m_chart.cartesianSystem.syAxis.hasOffset = NO;
    
    m_chart.cartesianSystem.xAxis.minTickSpacing = 40.0f;
    m_chart.cartesianSystem.xAxis.maxLabelLength = 400.0f;
    m_chart.cartesianSystem.xAxis.labelsAlignment = NChartAxisLabelsAlignmentLeft;
    m_chart.cartesianSystem.xAxis.labelsAngle = M_PI_4;
    
    if (isIPhone())
    {
        m_chart.cartesianSystem.margin = NChartMarginMake(5.0f, 5.0f, 5.0f, 5.0f);
        m_chart.cartesianSystem.syAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 5.0f);
    }
    
    m_chart.background = BrushWithRGB(30, 30, 30);
    
    m_chart.zoomMode = NChartZoomModeDirectional;
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalZoom
                                   ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionProportionalZoom);
    
    {
        NChartCandlestickSeriesSettings *settings = [NChartCandlestickSeriesSettings seriesSettings];
        settings.fillRatio = 0.9;
        [m_chart addSeriesSettings:settings];
    }
}

- (void)createStocksType2
{
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"google_historical_stock.csv"];
    
    NChartAreaSeries *volumeSeries = [NChartAreaSeries series];
    volumeSeries.tag = 0;
    volumeSeries.dataSource = self;
    volumeSeries.brush = GradientBrushWithRGBA(86, 128, 162, 100, 70, 161, 231, 200);
    volumeSeries.hostsOnSY = YES;
    volumeSeries.uniformGradient = YES;
    [m_chart addSeries:volumeSeries];
    
    NChartBandSeries *addlSeries = [NChartBandSeries series];
    addlSeries.tag = 1;
    addlSeries.dataSource = self;
    addlSeries.borderThickness = isIPhone() ? 1.0 : 2.0;
    addlSeries.negativeColor = ColorWithRGBA(64, 210, 198, 25);
    addlSeries.positiveColor = ColorWithRGBA(64, 210, 198, 25);
    addlSeries.lowBorderColor = ColorWithRGB(40, 150, 150);
    addlSeries.highBorderColor = ColorWithRGB(40, 150, 150);
    [m_chart addSeries:addlSeries];
    
    NChartOHLCSeries *series = [NChartOHLCSeries series];
    series.tag = 2;
    series.dataSource = self;
    series.borderThickness = 2.0;
    series.negativeColor = ColorWithRGB(180, 27, 27);
    series.positiveColor = ColorWithRGB(27, 175, 70);
    [m_chart addSeries:series];
    [self resetToDefaultProperty];
    
    self.xName = @"Date";
    
    self.yMask = isIPhone() ? @"%.0f" : @"%.1f";
    
    self.syName = isIPhone() ? @"Volume (Millions)" : @"Volume";
    self.syMask = isIPhone() ? @"%.0f" : @"%.1f M";
    self.syMax = @15.0;
    
    const NSInteger count = 10;
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    NSMutableArray *volumesArray = [NSMutableArray array];
    NSMutableArray *addlArray = [NSMutableArray array];
    NSMutableArray *ticksArray = [NSMutableArray array];
    NSInteger n = m_dataBase.rowsCount - count;
    for (NSInteger i = n - 1; i > 0; --i)
    {
        double volume = 0.0;
        double close = 0.0;
        double open = 0.0;
        double high = 0.0;
        double low = 0.0;
        NSInteger index = n - 1 - i;
        if ([m_dataBase doubleValue:&volume forRow:i column:2] && [m_dataBase doubleValue:&close forRow:i column:1] &&
            [m_dataBase doubleValue:&open forRow:i column:3] && [m_dataBase doubleValue:&high forRow:i column:4] &&
            [m_dataBase doubleValue:&low forRow:i column:5])
        {
            [pointsArray addObject:[NChartPoint pointWithState:
                                    [NChartPointState pointStateAlignedToXZWithX:index Z:0 low:low open:open close:close high:high]
                                                     forSeries:series]];
            [volumesArray addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:index Y:volume / 1.0e6]
                                                      forSeries:volumeSeries]];
            
            double average = 0;
            for (NSInteger j = 1; j <= count; ++j)
            {
                double value = 0.0;
                if ([m_dataBase doubleValue:&value forRow:i + j column:1])
                    average += value / (double)count;
            }
            double deviation = 0;
            for (NSInteger j = 1; j <= count; ++j)
            {
                double value = 0.0;
                if ([m_dataBase doubleValue:&value forRow:i + j column:1])
                    deviation += (average - value) * (average - value) / (double)count;
            }
            deviation = sqrt(deviation);
            [addlArray addObject:[NChartPoint pointWithState:[NChartPointState pointStateAlignedToXWithX:index
                                                                                                     low:average - 3 * deviation
                                                                                                    high:average + 3 * deviation]
                                                   forSeries:addlSeries]];
        }
        else
            [pointsArray addObject:[NSNull null]];
        [ticksArray addObject:[m_dataBase stringValueForRow:i column:0]];
    }
    
    self.points = @[volumesArray, addlArray, pointsArray];
    self.xTicks = ticksArray;
    
    // Chart setting
    [self resetToDefaultSetting];
    
    UIColor *borderColor = ColorWithRGB(113, 130, 142);
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.minorTicks.color = borderColor;
    
    m_chart.cartesianSystem.xAxis.minorTicks.visible = NO;
    
    UIColor *axesColor = ColorWithRGB(60, 90, 109);
    m_chart.cartesianSystem.xAlongY.color = axesColor;
    m_chart.cartesianSystem.yAlongX.color = axesColor;
    m_chart.cartesianSystem.syAlongX.color = axesColor;
    
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.syAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.syAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.minTickSpacing = 40.0f;
    m_chart.cartesianSystem.xAxis.maxLabelLength = 400.0f;
    m_chart.cartesianSystem.xAxis.labelsAlignment = NChartAxisLabelsAlignmentLeft;
    m_chart.cartesianSystem.xAxis.labelsAngle = M_PI_4;
    
    m_chart.cartesianSystem.syAlongX.visible = NO;
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.syAxis.hasOffset = NO;
    
    if (isIPhone())
    {
        m_chart.cartesianSystem.margin = NChartMarginMake(10.0f, 5.0f, 5.0f, 5.0f);
        m_chart.cartesianSystem.syAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 5.0f);
    }
    
    m_chart.background = GradientBrushWithRGB(50, 91, 120, 9, 20, 27);
    
    m_chart.zoomMode = NChartZoomModeDirectional;
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalZoom
                                   ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionProportionalZoom);
    
    {
        NChartOHLCSeriesSettings *settings = [NChartOHLCSeriesSettings seriesSettings];
        settings.fillRatio = 0.9;
        [m_chart addSeriesSettings:settings];
    }
}

#pragma mark - dna series

- (void)createDNA
{
    NSInteger count = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyDNACount]]).integerValue;
    
    [self resetToDefaultProperty];
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"sequence_ticks.csv"];
    
    NSMutableArray *ticksArray = [NSMutableArray array];
    for (NSInteger i = 0; i < MIN(m_dataBase.columnsCount, count); ++i)
        [ticksArray addObject:[m_dataBase stringValueForRow:0 column:i]];
    self.yTicks = ticksArray;
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"sequence_series.csv"];
    
    NSMutableArray *seriesNames = [NSMutableArray array];
    NSMutableArray *seriesColors = [NSMutableArray array];
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        if (isIPhone() && (i == m_dataBase.rowsCount - 1))
            [seriesNames addObject:[NSNull null]];
        else
            [seriesNames addObject:[m_dataBase stringValueForRow:i column:0]];
        double r = 0.0;
        double g = 0.0;
        double b = 0.0;
        double a = 0.0;
        if ([m_dataBase doubleValue:&r forRow:i column:1] && [m_dataBase doubleValue:&g forRow:i column:2] &&
            [m_dataBase doubleValue:&b forRow:i column:3] && [m_dataBase doubleValue:&a forRow:i column:4])
            [seriesColors addObject:BrushWithRGBA(((NSInteger)r), ((NSInteger)g), ((NSInteger)b), ((NSInteger)a))];
            
    }
    self.names = seriesNames;
    
    [m_dataBase release];
    m_dataBase = [[NChart3DDataBase alloc] initWithDataFromFile:@"sequence_points.csv"];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [seriesNames count]; ++i)
    {
        NChartSequenceSeries *series = [NChartSequenceSeries series];
        series.brush = (NChartBrush *)[seriesColors objectAtIndex:i];
        series.tag = i;
        series.dataSource = self;
        [m_chart addSeries:series];
        [pointsArray addObject:[NSMutableArray array]];
    }
    
    for (NSInteger i = 0; i < m_dataBase.rowsCount; ++i)
    {
        double seriesId = 0.0;
        double y = 0.0;
        double close = 0.0;
        double open = 0.0;
        if ([m_dataBase doubleValue:&seriesId forRow:i column:0] && [m_dataBase doubleValue:&y forRow:i column:1] &&
            [m_dataBase doubleValue:&open forRow:i column:2] && [m_dataBase doubleValue:&close forRow:i column:3])
        {
            if (close > 600.0f)
                continue;
            NSInteger tag = (NSInteger)seriesId;
            if (y < count)
            {
                [(NSMutableArray *)[pointsArray objectAtIndex:tag] addObject:[NChartPoint pointWithState:
                                                                              [NChartPointState pointStateAlignedToYWithY:y open:open close:close]
                                                                                               forSeries:(NChartSeries *)[m_chart.series objectAtIndex:tag]]];
            }
        }
    }
    
    self.points = pointsArray;
    
    if (isIPhone())
    {
        self.xMask = @"%.0f";
    }
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.pointSelectionEnabled = NO;
    
    NChartSequenceSeriesSettings *settings = [NChartSequenceSeriesSettings seriesSettings];
    settings.fillRatio = 0.6;
    [m_chart addSeriesSettings:settings];
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.hasOffset = YES;
    
    UIColor *borderColor = ColorWithRGB(100, 130, 136);
    
    m_chart.cartesianSystem.borderColor = borderColor;
    
    m_chart.cartesianSystem.yAlongX.visible = NO;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.majorTicks.color = borderColor;
    m_chart.cartesianSystem.syAxis.minorTicks.color = borderColor;
    
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 20);
    m_chart.legend.textColor = ColorWithRGB(255, 255, 255);
    m_chart.legend.borderColor = ColorWithRGBA(55, 55, 65, 100);
    if (isIPhone())
    {
        m_chart.legend.minimalEntriesPadding = 5;
        m_chart.legend.shouldAutodetectColumnCount = NO;
        m_chart.legend.columnCount = 5;
    }
    
    m_chart.cartesianSystem.xAlongY.color = ColorWithRGB(93, 118, 111);
    m_chart.cartesianSystem.yAlongX.color = ColorWithRGB(93, 118, 111);
    
    m_chart.cartesianSystem.xAxis.textColor = ColorWithRGB(255, 255, 255);
    m_chart.cartesianSystem.yAxis.textColor = ColorWithRGB(255, 255, 255);
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = NChartMarginMake(30.0f, 30.0f, 30.0f, 30.0f);
    else
        m_chart.cartesianSystem.margin = NChartMarginMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    m_chart.cartesianSystem.yAlongX.visible = NO;
    
    m_chart.cartesianSystem.yAxis.majorTicks.visible = NO;
    
    m_chart.background = BrushWithImage(@"dna_back.jpg");
    
    m_chart.zoomMode = NChartZoomModeDirectional;
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalZoom
                                   ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionProportionalZoom);
}

#pragma mark - streaming series

- (void)createStreaming
{
    [self resetToDefaultProperty];
    
    if (!m_audioCapturer)
    {
        m_chart.background = BrushWithRGB(255, 255, 255);
        m_chart.caption.text = NSLocalizedString(@"Microphone is not available, streaming disabled", nil);
        return;
    }
    
    m_chart.caption.text = NSLocalizedString(@"Audio Streaming", nil);
    
    NSInteger resolution = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyStreamingResolution]]).integerValue;
    BOOL is3D = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyStreamingDimension]]).integerValue == 1;
    
    m_audioCapturer.spectrumSize = m_audioCapturer.sampleRate * resolution / 4000;
    
    NSInteger step = [self spectrumStep];
    
    NSInteger jStart = 0;
    NSMutableArray *pointsArray = [NSMutableArray array];
    for (NSInteger i = 0; i < (is3D ? resolution : 1); ++i)
    {
        NChartSolidSeries *series;
        
        switch (self.dataType) {
            case NChart3DDataStreamingColumn:
                series = [NChartColumnSeries series];
                if (is3D)
                    jStart = 1;
                break;
                
            case NChart3DDataStreamingArea:
                series = [NChartAreaSeries series];
                break;
                
            case NChart3DDataStreamingStep:
                series = [NChartStepSeries series];
                break;
                
            default:
                break;
        }
        
        series.dataSource = self;
        series.tag = i;
        series.brush = BrushWithRGB(255, 0, 0);
        
        [m_chart addSeries:series];
        
        NSMutableArray *points = [NSMutableArray array];
        for (NSInteger j = jStart; j < resolution; ++j)
        {
            NChartPointState *state = [NChartPointState pointStateAlignedToXZWithX:j * step Y:0.0 Z:series.tag];
            state.brush = [self getInterpolatedBrushWithRatio:(float)j / (float)(resolution - 1)
                                                  fromBrushes:self.streamingBrushes];
            [points addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
        [pointsArray addObject:points];
    }
    
    self.points = pointsArray;
    
    self.yMin = @0.0;
    self.yMax = @0.3;
    
    if (is3D)
    {
        // Create offset manually.
        if (self.dataType == NChart3DDataStreamingColumn)
        {
            self.xMin = [NSNumber numberWithInteger:0];
            self.xMax = [NSNumber numberWithInteger:step * resolution];
        }
        
        self.zMin = [NSNumber numberWithInteger:-1];
        self.zMax = [NSNumber numberWithInteger:resolution];
    }
    
    self.xName = NSLocalizedString(@"Hz", nil);
    self.xMask = @"%.0f";
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.streamingMode = YES;
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.yAxis.hasOffset = NO;
    m_chart.cartesianSystem.zAxis.hasOffset = NO;
    
    UIColor *borderInnerColor = ColorWithRGB(125, 125, 155);
    UIColor *borderOuterColor = ColorWithRGB(150, 150, 180);
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.xAlongZ.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongZ.color = borderInnerColor;
    
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.zAxis.minorTicks.visible = NO;
    m_chart.cartesianSystem.zAxis.majorTicks.visible = NO;
    
    m_chart.cartesianSystem.zAxis.labelsVisible = NO;
    
    m_chart.drawIn3D = is3D;
    
    m_chart.background = BrushWithImage(@"streaming_back.jpg");
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = (is3D ? NChartMarginMake(50.0f, 50.0f, 50.0f, 10.0f) :
                                          NChartMarginMake(10.0f, 10.0f, 10.0f, 10.0f));
    else
        m_chart.cartesianSystem.margin = (is3D ? NChartMarginMake(35.0f, 10.0f, 10.0f, 10.0f) :
                                          NChartMarginMake(10.0f, 10.0f, 10.0f, 10.0f));
    
    if (self.dataType == NChart3DDataStreamingColumn)
    {
        NChartColumnSeriesSettings *settings = [NChartColumnSeriesSettings seriesSettings];
        settings.shouldGroupColumns = NO;
        [m_chart addSeriesSettings:settings];
    }
    
    if (!is3D)
    {
        m_chart.zoomMode = NChartZoomModeDirectional;
        m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalZoom
                                       ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionProportionalZoom);
    }
    else
    {
        m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalMove ^ NChartUserInteractionHorizontalMove);
    }
}

- (void)createStreamingSurface
{
    [self resetToDefaultProperty];
    
    if (!m_audioCapturer)
    {
        m_chart.caption.text = NSLocalizedString(@"Microphone is not available, streaming disabled", nil);
        m_chart.background = BrushWithRGB(255, 255, 255);
        return;
    }
    
    m_chart.caption.text = NSLocalizedString(@"Audio Streaming", nil);
    
    NSInteger resolution = ((NSNumber *)[m_settings objectForKey:[NSNumber numberWithInt:NChart3DPropertyStreamingResolution]]).integerValue;
    
    m_audioCapturer.spectrumSize = m_audioCapturer.sampleRate * resolution / 4000;
    
    NSInteger step = [self spectrumStep];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    NChartSurfaceSeries *series = [NChartSurfaceSeries series];
    series.dataSource = self;
    series.tag = 0;
    series.brush = BrushWithRGB(255, 0, 0);
    [m_chart addSeries:series];
    
    for (NSInteger i = 0; i < resolution; ++i)
    {
        for (NSInteger j = 0; j < resolution; ++j)
        {
            NChartPointState *state = [NChartPointState pointStateWithX:i * step Y:0.0 Z:j];
//            state.brush = [self.streamingBrushes lastObject];
            state.brush = [self getInterpolatedBrushWithRatio:(float)i / (float)(resolution - 1)
                                                  fromBrushes:self.streamingBrushes];
            [pointsArray addObject:[NChartPoint pointWithState:state forSeries:series]];
        }
    }
    
    self.points = @[pointsArray];
    
    self.yMin = @0.0;
    self.yMax = @0.3;
    
    self.xName = NSLocalizedString(@"Hz", nil);
    self.xMask = @"%.0f";
    
    // Chart setting
    [self resetToDefaultSetting];
    
    m_chart.streamingMode = YES;
    m_chart.pointSelectionEnabled = NO;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = NO;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = NO;
    
    m_chart.cartesianSystem.xAxis.hasOffset = NO;
    m_chart.cartesianSystem.yAxis.hasOffset = NO;
    m_chart.cartesianSystem.zAxis.hasOffset = NO;
    
    UIColor *borderInnerColor = ColorWithRGB(125, 125, 155);
    UIColor *borderOuterColor = ColorWithRGB(150, 150, 180);
    UIColor *textColor = ColorWithRGB(255, 255, 255);
    
    m_chart.cartesianSystem.borderColor = borderOuterColor;
    
    m_chart.cartesianSystem.xAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = borderOuterColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = borderOuterColor;
    
    m_chart.cartesianSystem.xAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.xAlongZ.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongX.color = borderInnerColor;
    m_chart.cartesianSystem.zAlongY.color = borderInnerColor;
    m_chart.cartesianSystem.yAlongZ.color = borderInnerColor;
    
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    
    m_chart.cartesianSystem.zAxis.minorTicks.visible = NO;
    m_chart.cartesianSystem.zAxis.majorTicks.visible = NO;
    
    m_chart.cartesianSystem.zAxis.labelsVisible = NO;
    
    m_chart.background = BrushWithImage(@"streaming_back.jpg");
    
    if (!isIPhone())
        m_chart.cartesianSystem.margin = NChartMarginMake(50.0f, 50.0f, 50.0f, 10.0f);
    else
        m_chart.cartesianSystem.margin = NChartMarginMake(35.0f, 10.0f, 10.0f, 10.0f);
    
    m_chart.drawIn3D = YES;
    
    m_chart.userInteractionMode = (NChartUserInteractionAll ^ NChartUserInteractionVerticalMove ^
                                   NChartUserInteractionHorizontalMove);
}

#pragma mark - series helper

- (void)resetToDefaultProperty
{
    self.points = nil;
    self.names = nil;
    self.images = nil;
    
    self.xName = nil;
    self.xMin = nil;
    self.xMax = nil;
    self.xStep = nil;
    self.xTicks = nil;
    self.xLength = nil;
    self.xMask = nil;
    
    self.yName = nil;
    self.yMin = nil;
    self.yMax = nil;
    self.yStep = nil;
    self.yTicks = nil;
    self.yLength = nil;
    self.yMask = nil;
    
    self.zName = nil;
    self.zMin = nil;
    self.zMax = nil;
    self.zStep = nil;
    self.zTicks = nil;
    self.zLength = nil;
    self.zMask = nil;
    
    self.syName = nil;
    self.syMin = nil;
    self.syMax = nil;
    self.syStep = nil;
    self.syTicks = nil;
    self.syLength = nil;
    self.syMask = nil;
    
    self.azimuthName = nil;
    self.azimuthMin = nil;
    self.azimuthMax = nil;
    self.azimuthStep = nil;
    self.azimuthTicks = nil;
    self.azimuthLength = nil;
    self.azimuthMask = nil;
    
    self.radiusName = nil;
    self.radiusMin = nil;
    self.radiusMax = nil;
    self.radiusStep = nil;
    self.radiusTicks = nil;
    self.radiusLength = nil;
    self.radiusMask = nil;
    
    self.timeAxisTicks = nil;
}

- (void)resetToDefaultSetting
{
    [self resetChartColorSettings];
    
    m_chart.caption.text = nil;
    
    m_chart.drawIn3D = NO;
    m_chart.pointSelectionEnabled = YES;
    m_chart.maxZoom = 1.0;
    m_chart.streamingMode = NO;
    
    m_chart.cartesianSystem.zAxis.labelsVisible = YES;
    
    m_chart.legend.shouldAutodetectColumnCount = YES;
    m_chart.legend.columnCount = 0;
    m_chart.legend.minimalEntriesPadding = 10;
    m_chart.legend.maxSize = 200;
    m_chart.legend.visible = YES;
    
    m_chart.cartesianSystem.visible = YES;
    m_chart.cartesianSystem.borderThickness = 2.0;
    
    m_chart.cartesianSystem.xAxis.labelsAngle = 0.0f;
    m_chart.cartesianSystem.xAxis.maxLabelLength = 0.0;
    m_chart.cartesianSystem.xAxis.minTickSpacing = 50.0;
    m_chart.cartesianSystem.xAxis.labelsAlignment = NChartAxisLabelsAlignmentCenter;
    
    m_chart.cartesianSystem.zAxis.labelsAngle = 0.0f;
    m_chart.cartesianSystem.zAxis.labelsAlignment = NChartAxisLabelsAlignmentCenter;
    
    m_chart.cartesianSystem.valueAxesType = NChartValueAxesTypeAbsolute;
    
    m_chart.cartesianSystem.xAxis.hasOffset = YES;
    m_chart.cartesianSystem.yAxis.hasOffset = NO;
    m_chart.cartesianSystem.zAxis.hasOffset = YES;
    
    m_chart.cartesianSystem.xAxis.shouldBeautifyMinAndMax = YES;
    m_chart.cartesianSystem.yAxis.shouldBeautifyMinAndMax = YES;
    m_chart.cartesianSystem.zAxis.shouldBeautifyMinAndMax = YES;
    m_chart.cartesianSystem.syAxis.shouldBeautifyMinAndMax = YES;
    
    m_chart.cartesianSystem.xAxis.minorTicks.visible = YES;
    m_chart.cartesianSystem.yAxis.minorTicks.visible = YES;
    m_chart.cartesianSystem.zAxis.minorTicks.visible = YES;
    
    m_chart.cartesianSystem.xAxis.majorTicks.visible = YES;
    m_chart.cartesianSystem.yAxis.majorTicks.visible = YES;
    m_chart.cartesianSystem.zAxis.majorTicks.visible = YES;
    
    m_chart.cartesianSystem.borderVisible = YES;
    m_chart.cartesianSystem.xAxis.lineVisible = YES;
    m_chart.cartesianSystem.yAxis.lineVisible = YES;
    m_chart.cartesianSystem.xyPlane.visible = NO;
    m_chart.cartesianSystem.xAlongY.visible = YES;
    m_chart.cartesianSystem.yAlongX.visible = YES;
    
    m_chart.defaultHorizontalRotationAngle = 3.93f;
    m_chart.defaultVerticalRotationAngle = -0.87f;
    
    m_chart.zoomMode = NChartZoomModeProportional;
    m_chart.userInteractionMode = NChartUserInteractionAll;
    
    m_chart.cartesianSystem.margin = (m_chart.drawIn3D ?
                                      NChartMarginMake(50.0f, 50.0f, 10.0f, 10.0f) :
                                      NChartMarginMake(10.0f, 10.0f, 10.0f, 10.0f));
    m_chart.polarSystem.margin = m_chart.cartesianSystem.margin;
    
    m_chart.cartesianSystem.xAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 0.0f);
    m_chart.cartesianSystem.yAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 0.0f);
    m_chart.cartesianSystem.zAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 0.0f);
    m_chart.cartesianSystem.syAxis.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    m_chart.cartesianSystem.syAlongX.visible = YES;
    m_chart.cartesianSystem.yAlongX.visible = YES;
    
    m_chart.timeAxis.padding = NChartMarginMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    {
        NChartPieSeriesSettings *settings = [NChartPieSeriesSettings seriesSettings];
        settings.holeRatio = 0.1f;
        settings.centerCaption = nil;
        [m_chart addSeriesSettings:settings];
    }
    
    {
        NChartColumnSeriesSettings *settings = [NChartColumnSeriesSettings seriesSettings];
        settings.shouldGroupColumns = YES;
        settings.cylindersResolution = 4;
        settings.isRudimentEnabled = YES;
        settings.shouldSmoothCylinders = NO;
        settings.animationType = NChartColumnAnimationTypeSimultaneously;
        [m_chart addSeriesSettings:settings];
    }
    
    {
        NChartFunnelSeriesSettings *settings = [NChartFunnelSeriesSettings seriesSettings];
        settings.gapSum = 0.0;
        [m_chart addSeriesSettings:settings];
    }
    
    {
        NChartSequenceSeriesSettings *settings = [NChartSequenceSeriesSettings seriesSettings];
        settings.fillRatio = 0.7;
        [m_chart addSeriesSettings:settings];
    }
    
    {
        NChartCandlestickSeriesSettings *settings = [NChartCandlestickSeriesSettings seriesSettings];
        settings.fillRatio = 0.7;
        [m_chart addSeriesSettings:settings];
    }
    
    {
        NChartOHLCSeriesSettings *settings = [NChartOHLCSeriesSettings seriesSettings];
        settings.fillRatio = 0.7;
        [m_chart addSeriesSettings:settings];
    }
}

- (void)resetChartColorSettings
{
    // Time axis settings
    m_chart.timeAxis.tickColor = ColorWithRGB(111, 111, 111);
    m_chart.timeAxis.tickShape = NChartTimeAxisTickShapeLine;
    m_chart.timeAxis.tickTitlesColor = ColorWithRGB(145, 143, 141);
    m_chart.timeAxis.tickTitlesFont = BoldFontWithSize(11.0f);
    m_chart.timeAxis.tickTitlesLayout = NChartTimeAxisShowFirstLastLabelsOnly;
    m_chart.timeAxis.tickTitlesPosition = NChartTimeAxisLabelsBeneath;
    m_chart.timeAxis.margin = NChartMarginMake(20.0f, 20.0f, 10.0f, 0.0f);
    m_chart.timeAxis.autohideTooltip = NO;
    
    // Time axis tooltip settings
    m_chart.timeAxis.tooltip.margin = NChartMarginMake(0.0f, 0.0f, 2.0f, 0.0f);
    m_chart.timeAxis.tooltip.textColor = ColorWithRGB(145, 143, 141);
    m_chart.timeAxis.tooltip.font = FontWithSize(11.0f);
    
    [m_chart.timeAxis setImagesForBeginNormal:nil
                                  beginPushed:nil
                                    endNormal:nil
                                    endPushed:nil
                                   playNormal:[UIImage imageNamed:@"play-light.png"]
                                   playPushed:[UIImage imageNamed:@"play-pushed-light.png"]
                                  pauseNormal:[UIImage imageNamed:@"pause-light.png"]
                                  pausePushed:[UIImage imageNamed:@"pause-pushed-light.png"]
                                       slider:[UIImage imageNamed:@"slider-light.png"]
                                      handler:[UIImage imageNamed:@"handler-light.png"]];
    
    // Legend settings
    m_chart.legend.background = BrushWithRGBA(255, 255, 255, 204);
    m_chart.legend.borderThickness = 0.5f;
    m_chart.legend.borderColor = ColorWithRGB(185, 185, 185);
    m_chart.legend.blockAlignment = NChartLegendBlockAlignmentBottom;
    m_chart.legend.contentAlignment = NChartLegendContentAlignmentJustified;
    m_chart.legend.shouldAutodetectColumnCount = YES;
    m_chart.legend.textColor = ColorWithRGB(0, 0, 0);
    m_chart.legend.font = isIPhone() ? FontWithSize(14.0f) : FontWithSize(16.0f);
    
    // Caption
    m_chart.caption.margin = NChartMarginMake(0.0f, 0.0f, 0.0f, 5.0f);
    
    // Antialiasing
    m_chart.shouldAntialias = YES;
    
    // Main chart colors
    UIColor *axesColor = ColorWithRGB(130, 130, 130);
    UIColor *saxesColor = ColorWithRGB(180, 180, 180);
    UIColor *textColor = [UIColor blackColor];
    UIFont *font = FontWithSize(16.0f);
    
    m_chart.background = GradientBrushWithRGB(255, 255, 255, 219, 219, 224);
    
    m_chart.cartesianSystem.xyPlane.color = ColorWithRGB(238, 238, 238);
    
    m_chart.caption.textColor = textColor;
    m_chart.caption.font = font;
    
    m_chart.cartesianSystem.xAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.xAxis.caption.font = font;
    m_chart.cartesianSystem.xAxis.textColor = textColor;
    m_chart.cartesianSystem.xAxis.font = font;
    m_chart.cartesianSystem.xAxis.color = axesColor;
    m_chart.cartesianSystem.xAxis.majorTicks.color = axesColor;
    m_chart.cartesianSystem.xAxis.minorTicks.color = axesColor;
    m_chart.cartesianSystem.xAlongY.color = axesColor;
    m_chart.cartesianSystem.xAlongZ.color = axesColor;
    
    m_chart.cartesianSystem.sxAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.sxAxis.caption.font = font;
    m_chart.cartesianSystem.sxAxis.textColor = textColor;
    m_chart.cartesianSystem.sxAxis.font = font;
    m_chart.cartesianSystem.sxAxis.color = axesColor;
    m_chart.cartesianSystem.sxAxis.majorTicks.color = saxesColor;
    m_chart.cartesianSystem.sxAxis.minorTicks.color = saxesColor;
    m_chart.cartesianSystem.sxAlongY.color = saxesColor;
    m_chart.cartesianSystem.sxAlongZ.color = saxesColor;
    
    m_chart.cartesianSystem.yAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.yAxis.caption.font = font;
    m_chart.cartesianSystem.yAxis.textColor = textColor;
    m_chart.cartesianSystem.yAxis.font = font;
    m_chart.cartesianSystem.yAxis.color = axesColor;
    m_chart.cartesianSystem.yAxis.majorTicks.color = axesColor;
    m_chart.cartesianSystem.yAxis.minorTicks.color = axesColor;
    m_chart.cartesianSystem.yAlongX.color = axesColor;
    m_chart.cartesianSystem.yAlongZ.color = axesColor;
    
    m_chart.cartesianSystem.syAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.syAxis.caption.font = font;
    m_chart.cartesianSystem.syAxis.textColor = textColor;
    m_chart.cartesianSystem.syAxis.font = font;
    m_chart.cartesianSystem.syAxis.color = axesColor;
    m_chart.cartesianSystem.syAxis.majorTicks.color = saxesColor;
    m_chart.cartesianSystem.syAxis.minorTicks.color = saxesColor;
    m_chart.cartesianSystem.syAlongX.color = saxesColor;
    m_chart.cartesianSystem.syAlongZ.color = saxesColor;
    
    m_chart.cartesianSystem.zAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.zAxis.caption.font = font;
    m_chart.cartesianSystem.zAxis.textColor = textColor;
    m_chart.cartesianSystem.zAxis.font = font;
    m_chart.cartesianSystem.zAxis.color = axesColor;
    m_chart.cartesianSystem.zAxis.majorTicks.color = axesColor;
    m_chart.cartesianSystem.zAxis.minorTicks.color = axesColor;
    m_chart.cartesianSystem.zAlongX.color = axesColor;
    m_chart.cartesianSystem.zAlongY.color = axesColor;
    
    m_chart.cartesianSystem.szAxis.caption.textColor = textColor;
    m_chart.cartesianSystem.szAxis.caption.font = font;
    m_chart.cartesianSystem.szAxis.textColor = textColor;
    m_chart.cartesianSystem.szAxis.font = font;
    m_chart.cartesianSystem.szAxis.color = axesColor;
    m_chart.cartesianSystem.szAxis.majorTicks.color = saxesColor;
    m_chart.cartesianSystem.szAxis.minorTicks.color = saxesColor;
    m_chart.cartesianSystem.szAlongX.color = saxesColor;
    m_chart.cartesianSystem.szAlongY.color = saxesColor;
    
    m_chart.cartesianSystem.borderColor = axesColor;
    
    m_chart.polarSystem.radiusAxis.caption.textColor = textColor;
    m_chart.polarSystem.radiusAxis.caption.font = font;
    m_chart.polarSystem.radiusAxis.textColor = textColor;
    m_chart.polarSystem.radiusAxis.font = font;
    m_chart.polarSystem.radiusAxis.color = axesColor;
    m_chart.polarSystem.radiusAxis.majorTicks.color = axesColor;
    m_chart.polarSystem.radiusAxis.minorTicks.color = axesColor;
    
    m_chart.polarSystem.azimuthAxis.caption.textColor = textColor;
    m_chart.polarSystem.azimuthAxis.caption.font = font;
    m_chart.polarSystem.azimuthAxis.textColor = textColor;
    m_chart.polarSystem.azimuthAxis.font = font;
    m_chart.polarSystem.azimuthAxis.color = axesColor;
    m_chart.polarSystem.azimuthAxis.majorTicks.color = axesColor;
    m_chart.polarSystem.azimuthAxis.minorTicks.color = axesColor;
    
    m_chart.polarSystem.grid.color = axesColor;
    
    m_chart.polarSystem.borderColor = axesColor;
}

- (UIColor *)colorLerpFrom:(UIColor *)start
                        to:(UIColor *)end
              withDuration:(float)t
{
    const CGFloat *startComponent = CGColorGetComponents(start.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(end.CGColor);
    
    float startAlpha = CGColorGetAlpha(start.CGColor);
    float endAlpha = CGColorGetAlpha(end.CGColor);
    
    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * t;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * t;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * t;
    float a = startAlpha + (endAlpha - startAlpha) * t;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (NChartSolidColorBrush *)getInterpolatedBrushWithRatio:(float)ratio fromBrushes:(NSArray *)brushes
{
    float nRatio = ratio * (float)(brushes.count - 1);
    if (ratio <= 0.0f)
        return [brushes firstObject];
    else if (ratio >= 1.0f)
        return [brushes lastObject];
    int numberOfFirst = (int)(nRatio);
    int numberOfSecond = (int)(nRatio) + 1;
    float durarion = nRatio - (int)nRatio;
    UIColor *resultColor = [self colorLerpFrom:((NChartSolidColorBrush *)brushes[numberOfFirst]).color
                                            to:((NChartSolidColorBrush *)brushes[numberOfSecond]).color
                                  withDuration:durarion];
    return [NChartSolidColorBrush solidColorBrushWithColor:resultColor];
}

- (NChartBrush *)getGradientBrushWithRatio:(float)startRatio toRatio:(float)endRatio fromBrushes:(NSArray *)brushes
{
    UIColor *startColor = [self getInterpolatedBrushWithRatio:startRatio fromBrushes:brushes].color;
    UIColor *endColor = [self getInterpolatedBrushWithRatio:endRatio fromBrushes:brushes].color;
    return [NChartLinearGradientBrush linearGradientBrushFromColor:startColor
                                                           toColor:endColor];
}

#pragma mark - audio capture halper

- (int)spectrumStep
{
    return (int)roundf((float)(m_audioCapturer.sampleRate) / (float)(m_audioCapturer.spectrumSize));
}

- (BOOL)isStreaming
{
    return (self.dataType >= NChart3DDataStreamingColumn) && (self.dataType <= NChart3DDataStreamingSurface);
}

#pragma mark - NChart3DAudioCapturerDelegate

- (void)audioCapturerSpectrumData:(const float *)spectrum withFFTSize:(NSInteger)fftSize
{
    if (![self isStreaming])
        return;
    
    if (![m_audioCapturer isInited])
        return;
    
    if (![self.locker tryLock])
        return;
    
    [m_chart beginTransaction];
    
    if (self.dataType == NChart3DDataStreamingSurface)
    {
        NSArray *points = ((NChartSeries *)[m_chart.series objectAtIndex:0]).points;
        NSInteger n = sqrt([points count]);
        for (NSInteger i = 0; i < n - 1; ++i)
        {
            for (NSInteger j = 0; j < n - 1; ++j)
            {
                NChartPoint *sourcePoint = [points objectAtIndex:i * n + j + 1];
                NChartPoint *destinationPoint = [points objectAtIndex:i * n + j];
                destinationPoint.currentState.doubleY = sourcePoint.currentState.doubleY;
//                destinationPoint.currentState.brush = sourcePoint.currentState.brush;
            }
        }
        for (NSInteger i = 0; i < n - 1; ++i)
        {
            NChartPoint *point = [points objectAtIndex:i * n + n - 2]; // Previous at last point.
            double y = sqrt(spectrum[i]);
            point.currentState.doubleY = y;
//            point.currentState.brush = [self getInterpolatedBrushWithRatio:MIN(1.0, MAX(1.0 - y / 0.2, 0.0))
//                                                               fromBrushes:self.streamingBrushes];
        }
    }
    else if (m_chart.drawIn3D)
    {
        for (NSInteger i = 0, n = [m_chart.series count]; i < n - 1; ++i)
        {
            
            NSArray *destinationPoints = ((NChartSeries *)[m_chart.series objectAtIndex:i]).points;
            NSArray *sourcePoints = ((NChartSeries *)[m_chart.series objectAtIndex:i + 1]).points;
            
            for (NSInteger j = 0, m = [sourcePoints count]; j < m; ++j)
            {
                NChartPoint *sourcePoint = [sourcePoints objectAtIndex:j];
                NChartPoint *destinationPoint = [destinationPoints objectAtIndex:j];
                destinationPoint.currentState.doubleY = sourcePoint.currentState.doubleY;
                destinationPoint.currentState.brush = sourcePoint.currentState.brush;
            }
        }
        NSArray *lastPoints = ((NChartSeries *)[m_chart.series lastObject]).points;
        // Column series is special series with separated values. We need skip first zero value for best view.
        // Another series look good with zero borders.
        NSInteger m = self.dataType == NChart3DDataStreamingColumn ? [lastPoints count] : [lastPoints count] - 1;
        NSInteger shift = self.dataType == NChart3DDataStreamingColumn ? 1 : 0;
        for (NSInteger j = 0; j < m; ++j)
        {
            NChartPoint *point = [lastPoints objectAtIndex:j];
            double y = sqrt(spectrum[j + shift]);
            point.currentState.doubleY = y;
//            if (self.dataType == NChart3DDataStreamingStep)
//            {
//                point.currentState.brush = [self getInterpolatedBrushWithRatio:MIN(1.0, MAX(1.0 - y / 0.2, 0.0))
//                                                                   fromBrushes:self.streamingBrushes];
//            }
//            else
//            {
//                point.currentState.brush = [self getInterpolatedBrushWithRatio:MIN(1.0, MAX(1.0 - y / 0.2, 0.0))
//                                                                   fromBrushes:self.streamingBrushes];
//            }
        }
    }
    else
    {
        NSArray *points = ((NChartSeries *)[m_chart.series objectAtIndex:0]).points;
        for (NSInteger j = 0, m = [points count]; j < m - 1; ++j)
        {
            NChartPoint *point = [points objectAtIndex:j];
            point.currentState.doubleY = sqrt(spectrum[j]);
        }
    }
    [m_chart streamData];
    [m_chart endTransaction];
    
    [self.locker unlock];
}

#pragma mark - NChartSeriesDataSource

- (NSArray *)seriesDataSourcePointsForSeries:(NChartSeries *)series
{
    return [self.points objectAtIndex:series.tag];
}

- (NSString *)seriesDataSourceNameForSeries:(NChartSeries *)series
{
    if (series.tag < self.names.count)
    {
        id name = [self.names objectAtIndex:series.tag];
        return [name isKindOfClass:[NSString class]] ? (NSString *)name : nil;
    }
    else
    {
        return nil;
    }
}

- (UIImage *)seriesDataSourceImageForSeries:(NChartSeries *)series
{
    return self.images ? (UIImage *)[self.images objectAtIndex:series.tag] : nil;
}

#pragma mark - NChartValueAxisDataSource

- (NSString *)valueAxisDataSourceNameForAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xName;
            
        case NChartValueAxisY:
            return self.yName;
            
        case NChartValueAxisZ:
            return self.zName;
            
        case NChartValueAxisSY:
            return self.syName;
            
        case NChartValueAxisAzimuth:
            return self.azimuthName;
            
        case NChartValueAxisRadius:
            return self.radiusName;
            
        default:
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceMinForValueAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xMin;
            
        case NChartValueAxisY:
            return self.yMin;
            
        case NChartValueAxisZ:
            return self.zMin;
            
        case NChartValueAxisSY:
            return self.syMin;
            
        case NChartValueAxisAzimuth:
            return self.azimuthMin;
            
        case NChartValueAxisRadius:
            return self.radiusMin;
            
        default:
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceMaxForValueAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xMax;
            
        case NChartValueAxisY:
            return self.yMax;
            
        case NChartValueAxisZ:
            return self.zMax;
            
        case NChartValueAxisSY:
            return self.syMax;
            
        case NChartValueAxisAzimuth:
            return self.azimuthMax;
            
        case NChartValueAxisRadius:
            return self.radiusMax;
            
        default:
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceStepForValueAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xStep;
            
        case NChartValueAxisY:
            return self.yStep;
            
        case NChartValueAxisZ:
            return self.zStep;
            
        case NChartValueAxisSY:
            return self.syStep;
            
        case NChartValueAxisAzimuth:
            return self.azimuthStep;
            
        case NChartValueAxisRadius:
            return self.radiusStep;
            
        default:
            return nil;
    }
}

- (NSArray *)valueAxisDataSourceTicksForValueAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xTicks;
            
        case NChartValueAxisY:
            return self.yTicks;
            
        case NChartValueAxisZ:
            return self.zTicks;
            
        case NChartValueAxisSY:
            return self.syTicks;
            
        case NChartValueAxisAzimuth:
            return self.azimuthTicks;
            
        case NChartValueAxisRadius:
            return self.radiusTicks;
            
        default:
            return nil;
    }
}

- (NSNumber *)valueAxisDataSourceLengthForValueAxis:(NChartValueAxis *)axis
{
    switch (axis.kind)
    {
        case NChartValueAxisX:
            return self.xLength;
            
        case NChartValueAxisY:
            return self.yLength;
            
        case NChartValueAxisZ:
            return self.zLength;
            
        case NChartValueAxisSY:
            return self.syLength;
            
        case NChartValueAxisAzimuth:
            return self.azimuthLength;
            
        case NChartValueAxisRadius:
            return self.radiusLength;
            
        default:
            return nil;
    }
}

- (NSString *)valueAxisDataSourceDouble:(double)value toStringForValueAxis:(NChartValueAxis *)axis
{
    if (self.dataType == NChart3DDataPopulationPyramid && axis.kind == NChartValueAxisX)
        return [NSString stringWithFormat:self.xMask, ABS(value)];
    else if (self.dataType == NChart3DDataPopulationPerYear && axis.kind == NChartValueAxisY && value == 0.0)
        return @"";
    else if (self.dataType == NChart3DDataWindRose)
    {
        if (isIPhone())
        {
            switch ((NSInteger)value) {
                case 0:
                    return @"N";
                    
                case 9:
                    return @"NE";
                    
                case 18:
                    return @"E";
                    
                case 27:
                    return @"SE";
                    
                case 36:
                    return @"S";
                    
                case 45:
                    return @"SW";
                    
                case 54:
                    return @"W";
                    
                case 63:
                    return @"NW";
                    
                default:
                    return @"";
            }
        }
        else
        {
            switch ((NSInteger)value) {
                case 0:
                    return @"N";
                    
                case 45:
                    return @"NE";
                    
                case 90:
                    return @"E";
                    
                case 135:
                    return @"SE";
                    
                case 180:
                    return @"S";
                    
                case 225:
                    return @"SW";
                    
                case 270:
                    return @"W";
                    
                case 315:
                    return @"NW";
                    
                default:
                    return @"";
            }
        }
    }
    else
    {
        switch (axis.kind)
        {
            case NChartValueAxisX:
                return self.xMask ? [NSString stringWithFormat:self.xMask, value] : nil;
                
            case NChartValueAxisY:
                return self.yMask ? [NSString stringWithFormat:self.yMask, value] : nil;
                
            case NChartValueAxisZ:
                return self.zMask ? [NSString stringWithFormat:self.zMask, value] : nil;
                
            case NChartValueAxisSY:
                return self.syMask ? [NSString stringWithFormat:self.syMask, value] : nil;
                
            default:
                return nil;
        }
    }
}

#pragma mark - NChartSizeAxisDataSource

- (float)sizeAxisDataSourceMaxSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    return 15.0f;
}

-(float)sizeAxisDataSourceMinSizeForSizeAxis:(NChartSizeAxis *)sizeAxis
{
    return 15.0f;
}

#pragma mark - NChartTimeAxisDataSource

-(NSArray *)timeAxisDataSourceTimestampsForAxis:(NChartTimeAxis *)timeAxis
{
    return self.timeAxisTicks;
}

#pragma mark - NChartDelegate

- (void)updateTooltipTextForPoint:(NChartPoint *)point
{
    if (!point)
        return;
    
    if (!point.currentState || [point.currentState isEqual:[NSNull null]])
        return;
    
    if (!point.tooltip)
        return;

    switch (self.dataType)
    {
        case NChart3DDataPopulation:
        case NChart3DDataPopulationPerYear:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f M", nil), point.currentState.doubleY];
            break;
            
        case NChart3DDataPopulationProjection:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f", nil), point.currentState.doubleY];
            break;
            
        case NChart3DDataMarketShareSmartphones:
        case NChart3DDataMarketShareSmartphonesSimple:
        case NChart3DDataMarketShareSmartphonesSuperSimple:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(isIPhone() ? @"%@:\n%.1fM sales" : @"%@: %.1fM sales", nil),
                                  point.series.name, point.currentState.value / 1.0e3];
            break;
            
        case NChart3DDataMarketShareBrowsers:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%@: %.1f%%", nil),
                                  point.series.name, point.currentState.value];
            break;
            
            
        case NChart3DDataSalesFunnel:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%@: %.1f%% - %.1f%%", nil), point.series.name,
                                  ((NChartFunnelSeries *)point.series).topRadius * 100.0f,
                                  ((NChartFunnelSeries *)point.series).bottomRadius * 100.0f];
            break;
            
        case NChart3DDataPopulationPyramid:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%.2f K", nil), ABS(point.currentState.doubleX)];
            break;
            
        case NChart3DDataGDPPerCapita:
            point.tooltip.text = [NSString stringWithFormat:NSLocalizedString(@"%.2f%%", nil), point.currentState.doubleY];
            break;
            
        default:
            break;
    }
}

- (void)chartDelegateTimeIndexOfChart:(NChart *)chart changedTo:(double)timeIndex
{
    if (self.dataType == NChart3DDataMarketShareSmartphones || self.dataType == NChart3DDataMarketShareSmartphonesSimple || self.dataType == NChart3DDataMarketShareSmartphonesSuperSimple || self.dataType == NChart3DDataMarketShareBrowsers ||
        self.dataType == NChart3DDataPopulationPyramid) // All types with time axis.
    {
        for (NChartSeries *series in chart.series)
        {
            for (NChartPoint *point in series.points)
            {
                [self updateTooltipTextForPoint:point];
            }
        }
    }
}

- (void)chartDelegatePointOfChart:(NChart *)chart selected:(NChartPoint *)point
{
    if (self.dataType == NChart3DDataPopulationProjection)
        return; // Const tooltips.
    
    if (self.dataType >= NChart3DDataPopulation && self.dataType <= NChart3DDataSalesFunnel)
    {
        BOOL needHighlight = self.dataType == NChart3DDataMarketShareSmartphones || self.dataType == NChart3DDataMarketShareSmartphonesSimple || self.dataType == NChart3DDataMarketShareSmartphonesSuperSimple ||self.dataType == NChart3DDataMarketShareBrowsers;
        
        if (needHighlight)
        {
            [m_prevPointSelected highlightWithMask:NChartHighlightTypeNone duration:0.25f delay:0.0];
        }
        [[m_prevPointSelected tooltip] setVisible:NO animated:0.25f];
        
        if (point == m_prevPointSelected)
            m_prevPointSelected = nil;
        else if (point)
        {
            if (needHighlight)
            {
                point.highlightShift = 0.2f;
                [point highlightWithMask:NChartHighlightTypeShift duration:0.25f delay:0.0f];
            }
            
            // Create tooltip.
            if (!point.tooltip)
            {
                point.tooltip = [[NChartTooltip new] autorelease];
                point.tooltip.background = BrushWithRGB(35, 35, 35);
                point.tooltip.background.opacity = 0.8f;
                point.tooltip.padding = NChartMarginMake(5.0f, 5.0f, 2.0f, 2.0f);
                point.tooltip.borderRadius = 5.0f;
                point.tooltip.font = [UIFont systemFontOfSize:16.0f];
                point.tooltip.textColor = ColorWithRGB(255, 255, 255);
                point.tooltip.visible = NO;
            }
            
            // Set text of tooltip.
            [self updateTooltipTextForPoint:point];
            
            [point.tooltip setVisible:YES animated:0.25f];
            m_prevPointSelected = point;
        }
    }
}

- (void)chartDelegateChart:(NChart *)chart object:(id)object didEndAnimating:(NChartAnimationType)animation
{
}

@end

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
 

#define TRANSITION_TIME 0.5f

#define FontWithSize(s) [UIFont systemFontOfSize:s]

#define BoldFontWithSize(s) [UIFont boldSystemFontOfSize:s]

#define ColorWithRGBA(r, g, b, a) [UIColor colorWithRed:(CGFloat)(r) / 255.0f \
                                                  green:(CGFloat)(g) / 255.0f \
                                                   blue:(CGFloat)(b) / 255.0f \
                                                  alpha:(CGFloat)(a) / 255.0f]

#define ColorWithRGB(r, g, b) [UIColor colorWithRed:(CGFloat)(r) / 255.0f \
                                              green:(CGFloat)(g) / 255.0f \
                                               blue:(CGFloat)(b) / 255.0f \
                                              alpha:1.0f]

#define BrushWithRGBA(r, g, b, a) [NChartSolidColorBrush solidColorBrushWithColor:ColorWithRGBA(r, g, b, a)]

#define BrushWithRGB(r, g, b) [NChartSolidColorBrush solidColorBrushWithColor:ColorWithRGB(r, g, b)]

#define BrushWithImage(path) [NChartTextureBrush textureBrushWithImage:[UIImage imageNamed:path]                \
                                                       backgroundColor:[UIColor blackColor]                     \
                                                              position:NChartTexturePositionScaleKeepMaxAspect]

#define GradientBrushWithRGBA(r1, g1, b1, a1, r2, g2, b2, a2)                               \
    [NChartLinearGradientBrush linearGradientBrushFromColor:ColorWithRGBA(r1, g1, b1, a1)   \
                                                    toColor:ColorWithRGBA(r2, g2, b2, a2)]


#define GradientBrushWithRGB(r1, g1, b1, r2, g2, b2)                                 \
    [NChartLinearGradientBrush linearGradientBrushFromColor:ColorWithRGB(r1, g1, b1) \
                                                    toColor:ColorWithRGB(r2, g2, b2)]

typedef enum
{
    NChart3DDataSourceStatistics,
    NChart3DDataSourceMathematics,
    NChart3DDataSourceStocks,
    NChart3DDataSourceDNA,
    NChart3DDataSourceStreaming,
} NChart3DDataSourceTypes;

#define DataSourceTypesCount 5

typedef enum
{
    // Statistics
    NChart3DDataPopulation,
    NChart3DDataPopulationPerYear,
    NChart3DDataPopulationProjection,
    NChart3DDataMarketShareSmartphones,
    NChart3DDataMarketShareSmartphonesSimple,
    NChart3DDataMarketShareSmartphonesSuperSimple,
    NChart3DDataMarketShareBrowsers,
    NChart3DDataPopulationPyramid,
    NChart3DDataGDPPerCapita,
    NChart3DDataWindRose,
    NChart3DDataSalesFunnel,
    // Mathematics
    NChart3DDataSurfaceType1,
    NChart3DDataSurfaceType2,
    NChart3DDataSurfaceType3,
    NChart3DDataSurfaceType4,
    NChart3DDataLissajousCurve,
    NChart3DDataHypotrochoid,
    NChart3DDataHyperboloid,
    // Stocks
    NChart3DDataStocksType1,
    NChart3DDataStocksType2,
    // DNA
    NChart3DDataDNA,
    // Streaming
    NChart3DDataStreamingColumn,
    NChart3DDataStreamingArea,
    NChart3DDataStreamingStep,
    NChart3DDataStreamingSurface,
} NChart3DDataTypes;

typedef enum
{
    NChart3DPropertyDataSourceType,
    NChart3DPropertyDataType,
    
    // Population
    NChart3DPropertyPopulationCountriesCount,
    // Population per year
    NChart3DPropertyPopulationPerYearCountriesCount,
    NChart3DPropertyPopulationPerYearYearsCount,
    // GDP per capita
    NChart3DPropertyGDPPerCapitaYearsCount,
    
    // Surface
    NChart3DPropertySurfaceBorder,
    NChart3DPropertySurfaceIsDiscrete,
    // Lissajous curve
    NChart3DPropertyLissajousCurveDimension,
    // Hypotrochoid
    NChart3DPropertyHypotrochoidOuterRadius,
    NChart3DPropertyHypotrochoidInnerRadius,
    NChart3DPropertyHypotrochoidDistance,
    
    // DNA
    NChart3DPropertyDNACount,
    
    // Streaming
    NChart3DPropertyStreamingDimension,
    NChart3DPropertyStreamingResolution,
} NChart3DProperties;

typedef enum
{
    NChart3DSettingsCharts,
    NChart3DSettingsStill,
} NChart3DSettings;

extern BOOL isIPhone();

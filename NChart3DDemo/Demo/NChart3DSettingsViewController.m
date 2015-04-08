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
 

#import "NChart3DSettingsViewController.h"
#ifdef NCHART3D_SOURCES
#import "NChart3D.h"
#else
#import <NChart3D/NChart3D.h>
#endif // NCHART3D_SOURCES


#define typeCell(typeID)                                                                            \
    [NChart3DTableViewCell cellWithText:[self chartNameForChartType:typeID]                         \
                                  image:[UIImage imageNamed:[self seriesImageForSeriesType:typeID]] \
                                 target:self                                                        \
                                 action:@selector(checkElem:)                                       \
                                    tag:NChart3DPropertyDataSourceType                              \
                                  value:typeID]

#define checkCell(checkName, checkID, checkValue) \
    [NChart3DTableViewCell cellWithText:checkName target:self action:@selector(checkElem:) tag:checkID value:checkValue]

#define switchCell(switchName, switchID) \
    [NChart3DSwitchTableViewCell cellWithText:switchName switchTag:switchID switchTarget:self switchSelector:@selector(switchElem:)]

#define sliderCell(sliderMin, sliderMax, sliderID) \
    [NChart3DSliderTableViewCell cellWithMin:sliderMin max:sliderMax target:self action:@selector(slideElem:) tag:sliderID]

#define disclosureCell(disID) \
    [NChart3DDisclosureTableViewCell cellWithDisclosureID:disID target:self action:@selector(pushElem:) tag:NChart3DPropertyDataSourceType]

@interface NChart3DSettingsViewController ()

@property (nonatomic, retain) NSArray *settings;
@property (nonatomic, retain) NSArray *captions;

@end

@implementation NChart3DSettingsViewController
{
    NChart3DSettings m_settingsType;
    NChart3DSettings m_prevSettingsType;
}

- (id)initWithSettingsID:(NChart3DSettings)settingsID
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        m_settingsType = settingsID;
        m_prevSettingsType = settingsID;
        self.title = [self titleForSettingsID:settingsID];
        
        if (isIPhone() && m_settingsType != NChart3DSettingsCharts)
        {
            UIBarButtonItem *pinItem;
            
            if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            {
                pinItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sidepanel_close.png"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(pinSettings:)] autorelease];
            }
            else
            {
                pinItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(pinSettings:)] autorelease];
            }
            
            [self.navigationItem setLeftBarButtonItems:@[pinItem]];
        }
    }
    return self;
}

- (void)dealloc
{
    self.settings = nil;
    self.captions = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateSettingsList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSettings:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)[self.settings objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell *)[((NSArray *)[self.settings objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section < self.captions.count ? (NSString *)[self.captions objectAtIndex:section] : nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((NChart3DTableViewCell *)[((NSArray *)[self.settings objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row]) performAction];
}

#pragma mark - Helpers

- (NSString *)chartNameForChartType:(NChart3DDataSourceTypes)type
{
    switch (type)
    {
        case NChart3DDataSourceStatistics:
            return NSLocalizedString(@"Statistics", nil);
            
        case NChart3DDataSourceMathematics:
            return NSLocalizedString(@"Mathematics", nil);
            
        case NChart3DDataSourceStocks:
            return NSLocalizedString(@"Stocks", nil);
            
        case NChart3DDataSourceDNA:
            return NSLocalizedString(@"DNA", nil);
            
        case NChart3DDataSourceStreaming:
            return NSLocalizedString(@"Microphone", nil);
    }
    return nil;
}

- (NSString *)seriesImageForSeriesType:(NChart3DDataSourceTypes)type
{
    switch (type)
    {
        case NChart3DDataSourceStatistics:
            return @"multi.png";
            
        case NChart3DDataSourceMathematics:
            return @"surface.png";
            
        case NChart3DDataSourceStocks:
            return @"candlestick.png";
            
        case NChart3DDataSourceDNA:
            return @"sequence.png";
            
        case NChart3DDataSourceStreaming:
            return @"discrete_surface.png";
    }
    return nil;
}

- (NSString *)titleForSettingsID:(NChart3DSettings)settingsID
{
    switch (settingsID)
    {
        case NChart3DSettingsCharts:
            return NSLocalizedString(@"Chart type", nil);
            
        case NChart3DSettingsStill:
            return NSLocalizedString(@"Settings", nil);
            
        default:
            return nil;
    }
}

- (void)pinSettings:(id)dummy
{
    [self.settingsDelegate closeSettings];
}

#pragma mark - Settings changing

#define currentDataType() ((NSNumber *)[self.settingsDelegate settingsValueForProp:NChart3DPropertyDataType]).intValue
#define currentDataSource() ((NSNumber *)[self.settingsDelegate settingsValueForProp:NChart3DPropertyDataSourceType]).intValue

- (NSArray *)createCaptionsArray
{
    switch (m_settingsType)
    {
        case NChart3DSettingsCharts:
            return @[];
    
        case NChart3DSettingsStill:
            switch (currentDataType())
            {
                case NChart3DDataPopulation:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Number of countries", nil)];
                    
                case NChart3DDataPopulationPerYear:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Number of countries", nil),
                             NSLocalizedString(@"Number of years", nil)];
                    
                case NChart3DDataPopulationProjection:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Number of years", nil)];
                    
                case NChart3DDataMarketShareSmartphones:
                case NChart3DDataMarketShareSmartphonesSimple:
                case NChart3DDataMarketShareSmartphonesSuperSimple:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataMarketShareBrowsers:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataPopulationPyramid:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataGDPPerCapita:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Number of years", nil)];
                    
                case NChart3DDataWindRose:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataSalesFunnel:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataSurfaceType1:
                case NChart3DDataSurfaceType2:
                case NChart3DDataSurfaceType3:
                case NChart3DDataSurfaceType4:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Options", nil)];
                    
                case NChart3DDataLissajousCurve:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Dimension", nil)];
                    
                case NChart3DDataHypotrochoid:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Parameters", nil)];
                    
                case NChart3DDataHyperboloid:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil)];
                    
                case NChart3DDataDNA:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Number of sequences", nil)];
                    
                case NChart3DDataStreamingColumn:
                case NChart3DDataStreamingArea:
                case NChart3DDataStreamingStep:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Dimension", nil),
                             NSLocalizedString(@"Resolution", nil)];
                    
                case NChart3DDataStreamingSurface:
                    return @[NSLocalizedString(@"Category", nil),
                             NSLocalizedString(@"Charts", nil),
                             NSLocalizedString(@"Resolution", nil)];
            }
            break;
    }
    
    return nil;
}

- (NSArray *)createSettingsArray
{
    NSArray *types;
    switch (m_settingsType)
    {
        case NChart3DSettingsCharts:
            return @[@[typeCell(NChart3DDataSourceStatistics),
                       typeCell(NChart3DDataSourceMathematics),
                       typeCell(NChart3DDataSourceStocks),
                       typeCell(NChart3DDataSourceDNA),
                       typeCell(NChart3DDataSourceStreaming)]];
            break;
            
        case NChart3DSettingsStill:
        {
            switch (currentDataSource())
            {
                case NChart3DDataSourceStatistics:
                    types = @[checkCell(NSLocalizedString(@"Population", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataPopulation),
                              checkCell(NSLocalizedString(@"Population per year", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataPopulationPerYear),
                              checkCell(NSLocalizedString(@"Projection of population", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataPopulationProjection),
                              checkCell(NSLocalizedString(@"Smartphones market share", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataMarketShareSmartphones),
                              checkCell(NSLocalizedString(@"Smartphones market share simple", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataMarketShareSmartphonesSimple),
                              checkCell(NSLocalizedString(@"Smartphones market share super simple", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataMarketShareSmartphonesSuperSimple),
                              checkCell(NSLocalizedString(@"Browsers market share", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataMarketShareBrowsers),
                              checkCell(NSLocalizedString(@"Population pyramid", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataPopulationPyramid),
                              checkCell(NSLocalizedString(@"GDP growth (annual %)", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataGDPPerCapita),
                              checkCell(NSLocalizedString(@"Wind rose", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataWindRose),
                              checkCell(NSLocalizedString(@"Sales funnel", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataSalesFunnel)];
                    break;
                    
                case NChart3DDataSourceMathematics:
                    types = @[checkCell(NSLocalizedString(@"y = a·atan(b·x·z)", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataSurfaceType2),
                              checkCell(NSLocalizedString(@"y = sin(a·x)·cos(b·z)", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataSurfaceType1),
                              checkCell(NSLocalizedString(@"y = a·cos(b·(x²+z²))·exp(c·(x²+z²))", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataSurfaceType3),
                              checkCell(NSLocalizedString(@"y = a·(1-x·z)·sin(1-x·z)", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataSurfaceType4),
                              checkCell(NSLocalizedString(@"Lissajous curve", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataLissajousCurve),
                              checkCell(NSLocalizedString(@"Hypotrochoid", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataHypotrochoid),
                              checkCell(NSLocalizedString(@"Hyperboloid", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataHyperboloid)];
                    break;
                    
                case NChart3DDataSourceStocks:
                    types = @[checkCell(NSLocalizedString(@"Apple historical stock", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStocksType1),
                              checkCell(NSLocalizedString(@"Google historical stock", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStocksType2)];
                    break;
                    
                case NChart3DDataSourceDNA:
                    types = @[checkCell(NSLocalizedString(@"DNA", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataDNA)];
                    break;
                    
                case NChart3DDataSourceStreaming:
                    types = @[checkCell(NSLocalizedString(@"Column", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStreamingColumn),
                              checkCell(NSLocalizedString(@"Area", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStreamingArea),
                              checkCell(NSLocalizedString(@"Step", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStreamingStep),
                              checkCell(NSLocalizedString(@"Surface", nil),
                                        NChart3DPropertyDataType,
                                        NChart3DDataStreamingSurface)];
                    break;
            }
            switch (currentDataType())
            {
                    // NChart3DDataSourceStatistics
                    
                case NChart3DDataPopulation:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[sliderCell(isIPhone() ? 3 : 5, isIPhone() ? 10 : 20,
                                          NChart3DPropertyPopulationCountriesCount)]];
                    
                case NChart3DDataPopulationPerYear:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[sliderCell(isIPhone() ? 3 : 5, isIPhone() ? 10 : 20,
                                          NChart3DPropertyPopulationPerYearCountriesCount)],
                             @[sliderCell(1, 7, NChart3DPropertyPopulationPerYearYearsCount)]];
                    
                case NChart3DDataPopulationProjection:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataMarketShareSmartphones:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataMarketShareBrowsers:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataPopulationPyramid:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataGDPPerCapita:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[sliderCell(8, 40, NChart3DPropertyGDPPerCapitaYearsCount)]];
                    
                case NChart3DDataWindRose:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataSalesFunnel:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                    // NChart3DDataSourceMathematics
                    
                case NChart3DDataSurfaceType1:
                case NChart3DDataSurfaceType2:
                case NChart3DDataSurfaceType3:
                case NChart3DDataSurfaceType4:
                    if (!isIPhone())
                        return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                                 types,
                                 @[switchCell(NSLocalizedString(@"Border", nil),
                                              NChart3DPropertySurfaceBorder),
                                   switchCell(NSLocalizedString(@"Discrete", nil),
                                              NChart3DPropertySurfaceIsDiscrete)]];
                    else
                        return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                                 types,
                                 @[switchCell(NSLocalizedString(@"Border", nil),
                                              NChart3DPropertySurfaceBorder),
                                   switchCell(NSLocalizedString(@"Discrete", nil),
                                              NChart3DPropertySurfaceIsDiscrete)]];
                    
                case NChart3DDataLissajousCurve:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[checkCell(NSLocalizedString(@"2D", nil),
                                         NChart3DPropertyLissajousCurveDimension,
                                         0),
                               checkCell(NSLocalizedString(@"3D", nil),
                                         NChart3DPropertyLissajousCurveDimension,
                                         1)]];
                    
                case NChart3DDataHypotrochoid:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[sliderCell(1, 5, NChart3DPropertyHypotrochoidInnerRadius),
                               sliderCell(6, 20, NChart3DPropertyHypotrochoidOuterRadius),
                               sliderCell(1, 20, NChart3DPropertyHypotrochoidDistance)]];
                    
                case NChart3DDataHyperboloid:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                    // NChart3DDataSourceStocks
                    
                case NChart3DDataStocksType1:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                case NChart3DDataStocksType2:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types];
                    
                    // NChart3DDataSourceDNA
                    
                case NChart3DDataDNA:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             @[sliderCell(1, isIPhone() ? 10 : 15, NChart3DPropertyDNACount)]];
                    
                    // NChart3DDataSourceStreaming
                    
                case NChart3DDataStreamingColumn:
                case NChart3DDataStreamingArea:
                case NChart3DDataStreamingStep:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[checkCell(NSLocalizedString(@"2D", nil),
                                         NChart3DPropertyStreamingDimension,
                                         0),
                               checkCell(NSLocalizedString(@"3D", nil),
                                         NChart3DPropertyStreamingDimension,
                                         1)],
                             @[sliderCell(isIPhone() ? 25 : 40, isIPhone() ? 50 : 75,
                                          NChart3DPropertyStreamingResolution)]];
                    
                case NChart3DDataStreamingSurface:
                    return @[@[disclosureCell(NChart3DPropertyDataSourceType)],
                             types,
                             @[sliderCell(isIPhone() ? 25 : 40, isIPhone() ? 50 : 75,
                                          NChart3DPropertyStreamingResolution)]];
            }
        }
            break;
    }
    
    return nil;
}

- (void)updateSettingsList
{
    self.captions = [self createCaptionsArray];
    self.settings = [self createSettingsArray];
    
    for (NSArray *sectionArray in self.settings)
    {
        for (NChart3DTableViewCell *cell in sectionArray)
        {
            NSNumber *value = [self.settingsDelegate settingsValueForProp:cell.tag];
            if ([cell isMemberOfClass:[NChart3DSwitchTableViewCell class]])
            {
                ((NChart3DSwitchTableViewCell *)cell).switchControl.on = value.boolValue;
            }
            else if ([cell isMemberOfClass:[NChart3DSliderTableViewCell class]])
            {
                ((NChart3DSliderTableViewCell *)cell).currentValue = value.intValue;
            }
            else if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
            {
                NChart3DDataSourceTypes type = (NChart3DDataSourceTypes)(value.intValue);
                if (((NChart3DDisclosureTableViewCell *)cell).disclosureID == NChart3DSettingsCharts)
                {
                    cell.textLabel.text = [self chartNameForChartType:type];
                    cell.imageView.image = [UIImage imageNamed:[self seriesImageForSeriesType:type]];
                }
                else
                {
                    cell.textLabel.text = [self chartNameForChartType:type];
                    cell.imageView.image = [UIImage imageNamed:[self seriesImageForSeriesType:type]];
                }
                cell.value = value.intValue;
            }
            else
            {
                cell.checked = value.intValue == cell.value;
            }
        }
    }
}

- (void)updateSettings:(id)dummy
{
    [self updateSettingsList];
    [self.tableView reloadData];
}

- (void)checkElem:(NChart3DTableViewCell *)cell
{
    if (cell.checked)
    {
        cell.selected = NO;
        if (!self.shouldPopOnSelection)
            [self.settingsDelegate closeSettings];
        return;
    }
    
    NSInteger section = 0;
    for (NSInteger i = 0, n = self.settings.count; i < n; ++i)
    {
        if (((NChart3DTableViewCell *)[[self.settings objectAtIndex:i] lastObject]).tag == cell.tag)
        {
            section = i;
            break;
        }
    }
    NSArray *array = (NSArray *)[self.settings objectAtIndex:section];
    for (NChart3DTableViewCell *elem in array)
    {
        if (elem.checked)
            elem.checked = NO;
    }
    
    self.view.userInteractionEnabled = NO;
    self.navigationItem.titleView.userInteractionEnabled = NO;
    // Cell may die, because showWaiter calls runloop to run and many things can happen in between.
    // Thats why we retain it.
    [cell retain];
    [cell showWaiter];
    [self.settingsDelegate settingsSetValue:[NSNumber numberWithInt:cell.value] forProp:cell.tag shouldApply:YES];
    [cell hideWaiter];
    cell.checked = YES;
    [cell release];
    self.navigationItem.titleView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    
    if (self.shouldPopOnSelection)
        [self.navigationController popViewControllerAnimated:YES];
    else
    {
        [self updateSettings:nil];
        [self.settingsDelegate closeSettings];
    }
}

- (void)switchElem:(NChart3DSwitch *)switcher
{
    self.navigationItem.titleView.userInteractionEnabled = NO;
    // Switcher and it's cell may die, because showWaiter calls runloop to run and many things can happen in between
    // (like, for example, updateSettings call). Thats why we retain switcher and it's cell.
    NChart3DTableViewCell *cell = [switcher.cell retain];
    [switcher retain];
    [switcher.cell showWaiter];
    
    [self.settingsDelegate settingsSetValue:[NSNumber numberWithBool:switcher.on] forProp:switcher.tag shouldApply:YES];
    
    [switcher.cell hideWaiter];
    [switcher release];
    [cell release];
    self.navigationItem.titleView.userInteractionEnabled = YES;
}

- (void)slideElem:(NChart3DSliderTableViewCell *)cell
{
    self.navigationItem.titleView.userInteractionEnabled = NO;
    [self.settingsDelegate settingsSetValue:[NSNumber numberWithInt:cell.currentValue] forProp:cell.tag shouldApply:YES];
    self.navigationItem.titleView.userInteractionEnabled = YES;
}

- (void)pushElem:(NChart3DDisclosureTableViewCell *)cell
{
    NChart3DSettingsViewController *ctrl = [[[NChart3DSettingsViewController alloc]
                                             initWithSettingsID:(NChart3DSettings)(cell.disclosureID)] autorelease];
    ctrl.settingsDelegate = self.settingsDelegate;
    ctrl.shouldPopOnSelection = YES;
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end

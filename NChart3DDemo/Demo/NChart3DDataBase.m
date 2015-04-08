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
 

#import "NChart3DDataBase.h"


@implementation NChart3DDataBase
{
    NSArray *m_data;
    NSInteger m_rowsCount;
    NSInteger m_columnsCount;
}

+ (NChart3DDataBase *)dataBaseWithDataFromFile:(NSString *)fileName
{
    return [[[NChart3DDataBase alloc] initWithDataFromFile:fileName] autorelease];
}

- (id)initWithDataFromFile:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        NSMutableArray *values = [NSMutableArray array];
        NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        for (NSString *line in lines)
        {
            NSArray *cols = [self parseLine:line];
            if (cols)
            {
                if (cols.count > m_columnsCount)
                    m_columnsCount = cols.count;
                [values addObject:cols];
            }
        }
        m_data = [values retain];
        m_rowsCount = values.count;
    }
    return self;
}

- (void)dealloc
{
    [m_data release];
    
    [super dealloc];
}

- (NSArray *)parseLine:(NSString *)line
{
    if (!line || line.length == 0)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    NSString *currentString = nil;
    NSRange range = NSMakeRange(0, 0);
    BOOL inEscapedString = NO;
    unichar letter = 0;
    
    for (NSUInteger i = 0, n = line.length; i < n; ++i)
    {
        [line getCharacters:&letter range:NSMakeRange(range.location + range.length, 1)];
        if (letter == '\"')
        {
            if (i < n - 1)
                [line getCharacters:&letter range:NSMakeRange(range.location + range.length + 1, 1)];
            else
                letter = 0;
            if (letter != '\"')
            {
                inEscapedString = !inEscapedString;
                if (range.length > 0)
                {
                    currentString = (currentString ?
                                     [currentString stringByAppendingString:[line substringWithRange:range]] :
                                     [line substringWithRange:range]);
                    range.location += range.length + 1;
                    range.length = 0;
                }
                else
                {
                    ++range.location;
                }
                continue;
            }
        }
        else if (!inEscapedString && letter == ',')
        {
            if (range.length > 0)
            {
                currentString = (currentString ?
                                 [currentString stringByAppendingString:[line substringWithRange:range]] :
                                 [line substringWithRange:range]);
                [result addObject:currentString];
                currentString = nil;
                range.location += range.length + 1;
                range.length = 0;
            }
            else if (currentString)
            {
                [result addObject:currentString];
                currentString = nil;
                ++range.location;
            }
            else
            {
                [result addObject:[NSNull null]];
                ++range.location;
            }
            continue;
        }
        ++range.length;
    }
    
    if (range.length > 0)
    {
        currentString = (currentString ?
                         [currentString stringByAppendingString:[line substringWithRange:range]] :
                         [line substringWithRange:range]);
        [result addObject:currentString];
    }
    else if (currentString)
    {
        [result addObject:currentString];
    }
    else
    {
        [result addObject:[NSNull null]];
    }
    
    return result;
}

- (NSString *)stringValueForRow:(NSInteger)row column:(NSInteger)column
{
    NSString *result = nil;
    NSArray *rowArray = nil;
    if (row < m_data.count)
    {
        id rawRowArray = [m_data objectAtIndex:row];
        if ([rawRowArray isKindOfClass:[NSArray class]])
            rowArray = (NSArray *)rawRowArray;
    }
    if (rowArray && column < rowArray.count)
    {
        id rawValue = [rowArray objectAtIndex:column];
        if ([rawValue isKindOfClass:[NSString class]])
            result = (NSString *)rawValue;
    }
    return result;
}

- (BOOL)doubleValue:(double *)value forRow:(NSInteger)row column:(NSInteger)column
{
    NSString *str = [self stringValueForRow:row column:column];
    return str ? [[NSScanner scannerWithString:str] scanDouble:value] : NO;
}

- (NSInteger)rowsCount
{
    return m_rowsCount;
}

- (NSInteger)columnsCount
{
    return m_columnsCount;
}

@end

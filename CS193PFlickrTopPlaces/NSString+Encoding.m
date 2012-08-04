//
//  NSString+Encoding.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "NSString+Encoding.h"

@implementation NSString (Encoding)

- (NSString*)stringByEscapingForURLArgument {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString* escaped = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"/" withString:@"|"];
    return escaped;
}

- (NSString*)stringByUnescapingFromURLArgument {
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    NSString* result = [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    result = [resultString stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
    return result;
}

@end

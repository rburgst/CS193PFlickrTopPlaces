//
//  NSString+Encoding.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

- (NSString*)stringByEscapingForURLArgument;
- (NSString*)stringByUnescapingFromURLArgument;

@end

//
//  RbFlickrCache.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RbFlickrCache : NSObject

- (BOOL)put:(NSData*)data forURL:(NSURL*)url;
- (NSData*)get:(NSURL*)url;

@property (nonatomic) NSUInteger maxSize;

@end

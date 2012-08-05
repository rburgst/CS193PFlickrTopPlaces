//
//  RbFlickrTopPlacesTVC.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RbFlickrGenericTVC.h"

@interface RbFlickrTopPlacesTVC : RbFlickrGenericTVC

@property (nonatomic, strong) NSDictionary* placesByCountry;
@property (nonatomic, strong) NSArray* countries;

@end

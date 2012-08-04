//
//  RbFlickrPhotosForPlaceTVC.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 04.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RbFlickrPhotoListTVC.h"

@interface RbFlickrPhotosForPlaceTVC : RbFlickrPhotoListTVC
@property (nonatomic, strong) NSDictionary* place;
@end

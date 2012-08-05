//
//  RbFlickrPlaceListTVC.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RbFlickrGenericTVC.h"

#define RECENTS_KEY @"RbFlickrPhotoViewController.recents"

@interface RbFlickrPhotoListTVC : RbFlickrGenericTVC

@property (nonatomic, strong) NSArray* photoList;

@end

//
//  RbFlickrPhotoViewController.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RbFlickrPhotoViewController : UIViewController

@property (nonatomic, strong) NSURL* photoURL;
@property (nonatomic, strong) NSString *photoTitle;

@end

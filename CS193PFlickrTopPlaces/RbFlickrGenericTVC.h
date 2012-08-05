//
//  RbFlickrGenericTVC.h
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnotationsProvider <NSObject>

- (NSArray*)annotationsForList;

@end

@interface RbFlickrGenericTVC : UITableViewController

@property (strong, nonatomic) UIBarButtonItem *mapBarButton;
@property (strong, nonatomic) UIBarButtonItem *spinnerBarButton;

- (void)showSpinner:(BOOL)spinning;

@end

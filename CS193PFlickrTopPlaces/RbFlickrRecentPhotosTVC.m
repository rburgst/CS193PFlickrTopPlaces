//
//  RbFlickrRecentPhotosTVC.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrRecentPhotosTVC.h"
#import "FlickrFetcher.h"
#import "RbFlickrPhotoViewController.h"



@interface RbFlickrRecentPhotosTVC ()

@end

@implementation RbFlickrRecentPhotosTVC


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.photoList = [defaults objectForKey:RECENTS_KEY];
}
@end

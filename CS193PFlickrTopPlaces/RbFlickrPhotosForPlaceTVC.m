//
//  RbFlickrPhotosForPlaceTVC.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 04.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrPhotosForPlaceTVC.h"
#import "FlickrFetcher.h"

@implementation RbFlickrPhotosForPlaceTVC

@synthesize place = _place;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.photoList = nil;
}

- (void)loadPhotosForPlace:(NSDictionary*)place
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    dispatch_queue_t downloadQueue = dispatch_queue_create("PhotosForPlaceDownload", NULL);
    
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:place maxResults:50];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoList = photos;
            self.navigationItem.rightBarButtonItem = nil;
        });
    });

    dispatch_release(downloadQueue);
}

- (void)setPlace:(NSDictionary *)place {
    if (_place != place) {
        _place = place;
        
        [self loadPhotosForPlace:place];
    }
}

@end

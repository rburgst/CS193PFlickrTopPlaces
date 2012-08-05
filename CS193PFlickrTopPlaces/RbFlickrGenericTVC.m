//
//  RbFlickrGenericTVC.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrGenericTVC.h"
#import "MapViewController.h"

@interface RbFlickrGenericTVC ()


@end

@implementation RbFlickrGenericTVC

@synthesize mapBarButton = _mapBarButton;
@synthesize spinnerBarButton = _spinnerBarButton;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    self.mapBarButton = nil;
    self.spinnerBarButton = nil;
    
    [super viewDidUnload];
}

- (UIBarButtonItem*)spinnerBarButton
{
    if (!_spinnerBarButton) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        _spinnerBarButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    return _spinnerBarButton;
}

- (void)showSpinner:(BOOL)spinning {
    if (spinning) {
        self.mapBarButton = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = self.spinnerBarButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.mapBarButton;
        self.mapBarButton = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowMap"] && [self conformsToProtocol:@protocol(AnnotationsProvider)]) {
        id<AnnotationsProvider> provider = (id<AnnotationsProvider>) self;
        MapViewController *mvc = (MapViewController*) segue.destinationViewController;
        mvc.annotations = [provider annotationsForList];
        if ([self conformsToProtocol:@protocol(MapViewControllerDelegate)]) {
            mvc.delegate = (id<MapViewControllerDelegate>) self;
        }
    }
}
@end

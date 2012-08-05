//
//  MapViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController() <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) dispatch_queue_t downloadQueue;

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize downloadQueue = _downloadQueue;


- (dispatch_queue_t)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    }
    return _downloadQueue;
}

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    
    
    if ([self.annotations count] > 0) {
        id<MKAnnotation> first = [self.annotations objectAtIndex:0];
        CLLocationCoordinate2D coord = [first coordinate];
        MKMapPoint topLeft = MKMapPointForCoordinate(coord);
        MKMapPoint bottomRight = MKMapPointForCoordinate(coord);
        
        // detect the ideal zoom size
        for (id<MKAnnotation> annotation in self.annotations) {
            MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
            topLeft.x = MIN(point.x, topLeft.x);
            topLeft.y = MIN(point.y, topLeft.y);
            bottomRight.x = MAX(point.x, bottomRight.x);
            bottomRight.y = MAX(point.x, bottomRight.y);
        }
        
        MKMapRect rect = MKMapRectMake(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
        UIEdgeInsets insets = UIEdgeInsetsMake(30.0, 30.0, 30.0, 30.0);
        [self.mapView setVisibleMapRect:rect edgePadding:insets animated:YES];

        [self.mapView addAnnotations:self.annotations];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}



#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        if ([self.delegate mapViewControllerShouldShowImages:self]) {
            aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        }
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    id<MKAnnotation> annotation = aView.annotation;
    dispatch_async(self.downloadQueue, ^{
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (aView && aView.annotation == annotation) {
                [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
            }
        });
        
    });
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
    [self.delegate mapViewController:self detailDisclosurePressed:control forAnnotation:view];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    dispatch_release(_downloadQueue);
    _downloadQueue = 0;
    
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

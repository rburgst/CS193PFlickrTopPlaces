//
//  RbFlickrPhotoViewController.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrPhotoViewController.h"
#import "FlickrFetcher.h"

@interface RbFlickrPhotoViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL haveInitialSize;

@end




@implementation RbFlickrPhotoViewController

@synthesize image;
@synthesize scrollView;
@synthesize photoURL = _photoURL;
@synthesize photoTitle = _photoTitle;
@synthesize haveInitialSize = _haveInitialSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    if (self.photoURL) {
        [self loadAndShowImage];
    }
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.photoURL = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)loadAndShowImage
{
    [self.scrollView setZoomScale:1.0];
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.minimumZoomScale = 0.2;
    self.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoURL]];
    CGSize size = self.image.image.size;
    self.image.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = self.image.bounds.size;
    CGRect sBounds = self.image.bounds;
    CGRect sFrame = self.image.frame;
    NSLog(@"image bounds: %f,%f,%f,%f",
          sBounds.origin.x, sBounds.origin.y, sBounds.size.width, sBounds.size.height);
    NSLog(@"image frame: %f,%f,%f,%f",
          sFrame.origin.x, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
}

- (void)setPhotoURL:(NSURL *)photoURL {
    if (_photoURL != photoURL) {
        _photoURL = photoURL;

        self.haveInitialSize = NO;
        
        if (self.scrollView) {
            [self loadAndShowImage];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // this is the only place where we can make assumptions about the geometry of the screen
    if (!self.haveInitialSize) {
        // determine the best zoom level to show the image as large as possible without
        // wasted pixels
        CGSize size = self.image.bounds.size;
        CGRect bounds = self.scrollView.bounds;
        CGSize boundsSize = bounds.size;
        
        float widthFactor = size.width / boundsSize.width;
        float heightFactor = size.height / boundsSize.height;
        float boundsAspect = boundsSize.width / boundsSize.height;
        
        CGRect zoomRect;
        float zoomHeight;
        float zoomWidth;
        
        if (heightFactor < widthFactor) {
            zoomWidth = size.height * boundsAspect;
            zoomHeight = size.height;
            zoomRect = CGRectMake(bounds.origin.x + (size.width - zoomWidth)/2, bounds.origin.y, zoomWidth, zoomHeight);
        } else {
            zoomWidth = size.width;
            zoomHeight = size.width / boundsAspect;
            zoomRect = CGRectMake(bounds.origin.x, bounds.origin.y + (size.height - zoomHeight)/2, zoomWidth, zoomHeight);
        }
        
        CGRect finalRect = [self.scrollView convertRect:zoomRect fromView:self.image];
        NSLog(@"before contentSize: %f,%f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);

        
        [self.scrollView zoomToRect:finalRect animated:NO];
        
        NSLog(@"image: %f/%f, scrollview: %f/%f, zoomRect:%f,%f,%f,%f", size.width, size.height,
              boundsSize.width, boundsSize.height,
              zoomRect.origin.x, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height);
        NSLog(@"zoomScale: %f", self.scrollView.zoomScale);
        NSLog(@"contentOrigin: %f,%f, contentScale: %f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.contentScaleFactor);
        NSLog(@"contentSize: %f,%f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        CGRect visibleRect = [scrollView convertRect:self.scrollView.bounds toView:self.image];
        NSLog(@"visRect:%f,%f,%f,%f", 
              visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
        
        self.haveInitialSize = YES;
    }
}

- (IBAction)infoPressed:(id)sender {
    CGSize size = self.image.bounds.size;
    CGSize boundsSize = self.scrollView.frame.size;
    CGRect sBounds = self.scrollView.bounds;
    CGRect sFrame = self.scrollView.frame;
    
    NSLog(@"image: %f/%f, scrollview: %f/%f", size.width, size.height,
          boundsSize.width, boundsSize.height);
    NSLog(@"scroll bounds: %f,%f,%f,%f",
          sBounds.origin.x, sBounds.origin.y, sBounds.size.width, sBounds.size.height);
    NSLog(@"scroll frame: %f,%f,%f,%f",
          sFrame.origin.x, sFrame.origin.y, sFrame.size.width, sFrame.size.height);
    NSLog(@"zoomScale: %f", self.scrollView.zoomScale);
    NSLog(@"contentOrigin: %f,%f, contentScale: %f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.contentScaleFactor);
    NSLog(@"contentSize: %f,%f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    CGRect visibleRect = [scrollView convertRect:self.scrollView.bounds toView:self.image];
    NSLog(@"visRect:%f,%f,%f,%f",
          visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
}

#pragma mark - UIScrollViewDelegate

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.image;
}
@end

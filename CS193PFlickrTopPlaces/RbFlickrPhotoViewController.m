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

@end




@implementation RbFlickrPhotoViewController

@synthesize image;
@synthesize scrollView;
@synthesize photoURL = _photoURL;
@synthesize photoTitle = _photoTitle;

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
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoURL]];
    CGSize size = self.image.image.size;
    self.scrollView.contentSize = size;
    self.image.frame = CGRectMake(0, 0, size.width, size.height);
    [self.scrollView setNeedsDisplay];
}

- (void)setPhotoURL:(NSURL *)photoURL {
    if (_photoURL != photoURL) {
        _photoURL = photoURL;

        if (self.scrollView) {
            [self loadAndShowImage];
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.image;
}
@end

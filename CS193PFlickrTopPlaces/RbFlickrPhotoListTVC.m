//
//  RbFlickrPlaceListTVC.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrPhotoListTVC.h"
#import "FlickrFetcher.h"
#import "RbFlickrPhotoViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "MapViewController.h"

#define SEGUE_SHOW_PHOTO @"Show Photo"

@interface RbFlickrPhotoListTVC () <AnnotationsProvider,MapViewControllerDelegate>

@property (nonatomic) dispatch_queue_t photoQueue;
@property (nonatomic, strong) UIImage* emptyImage;

@end

@implementation RbFlickrPhotoListTVC

@synthesize photoList = _photoList;
@synthesize photoQueue = _photoQueue;
@synthesize emptyImage = _emptyImage;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (dispatch_queue_t)photoQueue {
    if (!_photoQueue) {
        _photoQueue = dispatch_queue_create("flickr photo downloader", NULL);
    }
    return _photoQueue;
}

- (UIImage*)emptyImage {
    if (!_emptyImage) {
        _emptyImage = [UIImage imageNamed:@"indicator.jpeg"];
    }
    return _emptyImage;
}

- (void)setPhotoList:(NSArray *)photoList
{
    if (_photoList != photoList) {
        _photoList = photoList;
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload
{
    if (_photoQueue) dispatch_release(_photoQueue);
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.photoList = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)addPhotoToRecents:(NSDictionary*)photoDescription
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recents = [[defaults objectForKey:RECENTS_KEY] mutableCopy];
    if (!recents) recents = [NSMutableArray array];
    
    if ([recents containsObject:photoDescription]) {
        [recents removeObject:photoDescription];
    }
    
    [recents insertObject:photoDescription atIndex:0];
    while ([recents count] > 20) {
        [recents removeLastObject];
    }
    [defaults setObject:recents forKey:RECENTS_KEY];
    [defaults synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_SHOW_PHOTO]) {
        
        NSDictionary *photo = nil;
        
        if ([sender isKindOfClass:[NSDictionary class]]) {
            photo = (NSDictionary *) sender;
        } else {
            photo = [self.photoList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
        
        [self addPhotoToRecents:photo];
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhotoURL:url];
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)showPhoto:(NSDictionary*)photo
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[RbFlickrPhotoViewController class]]) {
        RbFlickrPhotoViewController *photoVC = (RbFlickrPhotoViewController *)detail;
        photoVC.photoTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
        [self addPhotoToRecents:photo];
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        photoVC.photoURL = url;
    } else {
        [self performSegueWithIdentifier:SEGUE_SHOW_PHOTO sender:self];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *photoDescription = [self.photoList objectAtIndex:indexPath.row];
    NSString *title = [photoDescription objectForKey:FLICKR_PHOTO_TITLE];
    NSString *subtitle = [photoDescription valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if ([title length] == 0) {
        title = subtitle;
    }
    if ([title length] == 0) {
        title = @"Unknown";
    }
        
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    cell.imageView.image = self.emptyImage;
    NSUInteger oldRow = indexPath.row;
    cell.tag = oldRow;
    
    dispatch_async(self.photoQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:photoDescription format:FlickrPhotoFormatSquare];
        UIImage *loadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (oldRow == cell.tag) {
                cell.imageView.image = loadedImage;
            }
        });
        
    });
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSDictionary* photo = [self.photoList objectAtIndex:indexPath.row];
        [self showPhoto:photo];
    }
}

#pragma mark - AnnotationsProvider

- (NSArray*)annotationsForList
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self.photoList count]];
    for (NSDictionary* photo in self.photoList) {
        [result addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return result;
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
     FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
     NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
     NSData *data = [NSData dataWithContentsOfURL:url];
     return data ? [UIImage imageWithData:data] : nil;
}

- (void)mapViewController:(MapViewController *)sender detailDisclosurePressed:(UIControl *)button forAnnotation:(MKAnnotationView *)aView
{
    FlickrPhotoAnnotation *pa = (FlickrPhotoAnnotation*) aView.annotation;
    [self showPhoto:pa.photo];
}

- (BOOL)mapViewControllerShouldShowImages:(MapViewController *)sender {
    return YES;
}
@end

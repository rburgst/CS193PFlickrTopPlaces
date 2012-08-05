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

@interface RbFlickrPhotoListTVC ()

@end

@implementation RbFlickrPhotoListTVC

@synthesize photoList = _photoList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        NSDictionary *photo = [self.photoList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        [self addPhotoToRecents:photo];
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhotoURL:url];
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
//    NSURL *photoURL = [FlickrFetcher urlForPhoto:photoDescription format:FlickrPhotoFormatLarge];
//    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
    
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

@end

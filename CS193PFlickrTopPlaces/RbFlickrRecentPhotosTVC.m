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
    
    self.photoList = [FlickrFetcher recentGeoreferencedPhotos];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        NSDictionary *photo = [self.photoList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhotoURL:url];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

//
//  RbFlickrTopPlacesTVC.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 7/29/12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrTopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "RbFlickrPhotoListTVC.h"

@interface RbFlickrTopPlacesTVC ()

@end

@implementation RbFlickrTopPlacesTVC

@synthesize places = _topPlaces;
@synthesize placesByCountry = _placesByCountry;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray* topPlaces = [FlickrFetcher topPlaces];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES];
    self.places = [topPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.places = nil;
}

- (NSString*)getCountry:(NSDictionary*) place
{
    NSString *content = [place objectForKey:@"_content"];
    NSArray* components = [content componentsSeparatedByString:@", "];
    if ([components count] > 1) {
        return [components lastObject];
    }
    return @"Unknown";
}

- (NSDictionary*)filterCountries:(NSArray*) places
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:100];
    for (NSDictionary *place in places) {
        NSString* country = [self getCountry:place];
        NSMutableArray *citiesInCountry = [dict objectForKey:country];
        if (!citiesInCountry) citiesInCountry = [NSMutableArray array];
        [citiesInCountry addObject:place];
        [dict setObject:citiesInCountry forKey:country];
    }
    
    NSMutableDictionary *sortedDict = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
    // now sort cities
    for (NSString *country in [dict keyEnumerator]) {
        NSMutableArray *cities = [dict objectForKey:country];
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES];
        NSArray *sortedCities = [cities sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        [sortedDict setObject:sortedCities forKey:country];
    }
    
    return sortedDict;
}

-(void)setPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        self.placesByCountry = [self filterCountries:topPlaces];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        self.countries = [[self.placesByCountry allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (NSDictionary*)placeForIndexPath:(NSIndexPath*)indexPath
{
    NSString *country = [self.countries objectAtIndex:indexPath.section];
    NSDictionary *place = [[self.placesByCountry objectForKey:country] objectAtIndex:indexPath.row];
    return place;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Photos For Place"]) {
        RbFlickrPhotoListTVC *photoListTVC = (RbFlickrPhotoListTVC*) segue.destinationViewController;
        NSDictionary *place = [self placeForIndexPath:[self.tableView indexPathForSelectedRow]];
        photoListTVC.photoList = [FlickrFetcher photosInPlace:place maxResults:50];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *country = [self.countries objectAtIndex:section];
    return [[self.placesByCountry objectForKey:country] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSDictionary *place = [self placeForIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *content = [place objectForKey:@"_content"];
    NSString *title;
    NSString *subtitle;
    NSCharacterSet *dividerSet = [NSCharacterSet characterSetWithCharactersInString:@", "];
    NSArray* components = [content componentsSeparatedByString:@", "];
    title = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:dividerSet];
    int i = 0;
    for (NSString* component in components) {
        if (i++ == 0) continue;
        if (i == 2) {
            subtitle = component;
        } else {
            subtitle = [subtitle stringByAppendingFormat:@", %@",component];
        }
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

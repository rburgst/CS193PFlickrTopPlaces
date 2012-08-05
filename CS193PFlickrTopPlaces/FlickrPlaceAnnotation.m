//
//  FlickrPlaceAnnotation.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    
    NSString* title;
    NSString* subtitle;
    
    [FlickrPlaceAnnotation descriptionsForPlace:place forTitle:&title andSubtitle:&subtitle];
    annotation.title = title;
    annotation.subtitle = subtitle;
    return annotation;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

+ (BOOL)descriptionsForPlace:(NSDictionary*)place forTitle:(NSString**)outTitle andSubtitle:(NSString**)outSubtitle
{
    NSString *content = [place objectForKey:FLICKR_PLACE_NAME];
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
    *outTitle = title;
    *outSubtitle = subtitle;
    return YES;
}
@end

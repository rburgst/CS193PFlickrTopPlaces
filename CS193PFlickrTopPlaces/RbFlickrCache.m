//
//  RbFlickrCache.m
//  CS193PFlickrTopPlaces
//
//  Created by Rainer Burgstaller on 05.08.12.
//  Copyright (c) 2012 Rainer Burgstaller. All rights reserved.
//

#import "RbFlickrCache.h"
#import "NSString+Encoding.h"

#define MAX_SIZE 10 * 1024 * 1024

@interface RbFlickrCache ()

- (void)setup;
- (NSUInteger)fileSize:(NSString*)path withFileManager:(NSFileManager*)fm;

@property (nonatomic) NSUInteger currentSize;
@property (nonatomic, strong) NSMutableArray* imageList;
@property (nonatomic, strong) NSString* basePath;

@end


@implementation RbFlickrCache

@synthesize maxSize = _maxSize;
@synthesize currentSize = _currentSize;
@synthesize imageList = _imageList;
@synthesize basePath = _basePath;

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dumpToLog
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSLog(@"Image Cache: %d size %d, max: %d", [self.imageList count], self.currentSize, self.maxSize);
    for (NSString* file in self.imageList) {
        NSLog(@" - %@ size %d", [self urlForPath:file], [self fileSize:file withFileManager:fm]);
    }
}
- (void)setup
{
    NSFileManager* fm = [NSFileManager defaultManager];
    self.basePath = NSTemporaryDirectory();
    [fm createDirectoryAtPath:self.basePath withIntermediateDirectories:YES attributes:nil error:nil];
    self.maxSize = MAX_SIZE;
    
    for (NSString *filePath in [fm enumeratorAtPath:self.basePath]) {
        NSString *fullPath = [self.basePath stringByAppendingPathComponent:filePath];
        NSUInteger fileSize = [self fileSize:fullPath withFileManager:fm];
        self.currentSize += fileSize;
        [self.imageList addObject:fullPath];
    }
    [self dumpToLog];
}

- (NSMutableArray*)imageList {
    if (!_imageList) {
        _imageList = [NSMutableArray arrayWithCapacity:10];
    }
    return _imageList;
}

- (NSString*)pathForURL:(NSURL*)url
{
    NSString *urlString = [url absoluteString];
    return [self.basePath stringByAppendingPathComponent:[urlString stringByEscapingForURLArgument]];
}

- (NSURL*)urlForPath:(NSString*)path
{
    NSString* finalURL = [[path substringFromIndex:[self.basePath length]] stringByUnescapingFromURLArgument];
    return [NSURL URLWithString:finalURL];
}

- (NSUInteger)fileSize:(NSString*)path withFileManager:(NSFileManager*)fm
{
    NSError *error;
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:&error];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    NSUInteger fileSize = [fileSizeNumber unsignedIntegerValue];
    return fileSize;
}

- (void)purge
{
    NSFileManager* fm = [NSFileManager defaultManager];
    int i = 0;
    NSError* error;
    
    if (self.currentSize > self.maxSize) NSLog(@"Purging: cur size: %d, max: %d", self.currentSize, self.maxSize);
    while (self.currentSize > self.maxSize && i < [self.imageList count]) {
        NSString* firstFile = [self.imageList objectAtIndex:i];
        NSUInteger fileSize = [self fileSize:firstFile withFileManager:fm];
        
        NSLog(@"Purging file %@ with size %d", firstFile, fileSize);
        if ([fm removeItemAtPath:firstFile error:&error]) {
            self.currentSize -= fileSize;
            [self.imageList removeObjectAtIndex:i];
            NSLog(@"  success, new size %d, mxsize: %d", self.currentSize, self.maxSize);
        } else {
            i++;
        }
    }
    
    [self dumpToLog];
}

- (BOOL)put:(NSData *)data forURL:(NSURL *)url
{
    NSUInteger fileSize = [data length];
    if (fileSize > MAX_SIZE) {
        return NO;
    }
 
    NSLog(@"Caching image: %@, size %d", url, fileSize);
    self.currentSize += fileSize;
    
    [self purge];
    
    NSString *path = [self pathForURL:url];
    NSError *error;
    BOOL result = [data writeToFile:path options:0 error:&error];
    if (result) {
        [self.imageList addObject:path];
        NSLog(@"  cached file name: %@, success %d", path, result);
    }

    return result;
}

- (NSData*)get:(NSURL *)url
{
    NSString *path = [self pathForURL:url];
    NSData *result = [NSData dataWithContentsOfFile:path];
    if (result) {
        NSLog(@"Getting image %@ from cache", url);
    }
    return result;
}
@end


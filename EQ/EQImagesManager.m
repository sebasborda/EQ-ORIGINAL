//
//  EQImagesManager.m
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQImagesManager.h"

@interface EQImagesManager()

@property (nonatomic,strong) NSMutableDictionary *cacheDictionary;

@end

@implementation EQImagesManager

NSString * CACHE_DIRECTORY_FORMAT = @"%@/Caches/Pictures/%@";

+ (EQImagesManager *)sharedInstance
{
    static EQImagesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQImagesManager alloc] init];
        [sharedInstance loadCache];
    });
    return sharedInstance;
}

- (void)loadCache{
    [APP_DELEGATE showLoadingView];
    self.cacheDictionary = [NSMutableDictionary dictionary];
    
    // make a directory for these
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDir;
    
    NSString *picturesPath = [NSString stringWithFormat:CACHE_DIRECTORY_FORMAT, NSHomeDirectory(),@""];
    
    if (![mgr fileExistsAtPath:picturesPath isDirectory:&isDir]) {
        [mgr createDirectoryAtPath:picturesPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        // load pictures
        NSDirectoryEnumerator *dir = [mgr enumeratorAtPath: picturesPath];
        NSString *picture;
        while ((picture = [dir nextObject])) {
            UIImage *img = [UIImage imageWithContentsOfFile:[picturesPath stringByAppendingString:picture]];
            NSString *fileName = [[picture componentsSeparatedByString:@"/"] lastObject];
            [self.cacheDictionary setObject:img forKey:fileName];
        }
    }
    
    [APP_DELEGATE hideLoadingView];
}

- (BOOL)saveImage:(UIImage *)image named:(NSString *)name{
    if (![self existImageNamed:name]) {
        // Save Image
        NSString *filePath = [NSString stringWithFormat:CACHE_DIRECTORY_FORMAT, NSHomeDirectory(), name];
        NSData *imageData = UIImageJPEGRepresentation(image, 90);
        NSError *error = nil;
        if ([imageData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            [self.cacheDictionary setObject:image forKey:name];
            return YES;
        }
    }
    
    return  NO;
}

- (BOOL)existImageNamed:(NSString *)name{
    return [self.cacheDictionary objectForKey:name] != nil;
}

- (UIImage *)imageNamed:(NSString *)name{
    return [self.cacheDictionary objectForKey:name];
}

- (void)clearCache{
    // delete all of them so we get up to date
    for (NSString *fileName in [self.cacheDictionary allKeys]) {
        // remove from disk
        NSString *filePath = [NSString stringWithFormat:CACHE_DIRECTORY_FORMAT, NSHomeDirectory(), fileName];
        NSFileManager *mgr = [NSFileManager defaultManager];
        [mgr removeItemAtPath:filePath error:nil];
    }
    
    [self.cacheDictionary removeAllObjects];
}

@end

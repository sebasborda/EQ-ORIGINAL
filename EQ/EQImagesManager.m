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
@property (nonatomic,strong) NSFileManager *fileManager;

@end

NSString * const CACHE_DIRECTORY_FORMAT_CATALOGS = @"%@/Caches/Pictures/Catalogs/%@";
NSString * const CACHE_DIRECTORY_FORMAT_ARTICLES = @"%@/Caches/Pictures/Articles/%@";


@implementation EQImagesManager

+ (EQImagesManager *)sharedInstance
{
    static EQImagesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQImagesManager alloc] init];
        sharedInstance.fileManager = [NSFileManager defaultManager];
        //TODO: uncomment to use cache
//        [sharedInstance loadCache];
    });
    return sharedInstance;
}

- (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void)loadCache {
    [self loadCache:CACHE_DIRECTORY_FORMAT_CATALOGS];
    [self loadCache:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (void)loadCache:(NSString *)baseDirectory{
    [APP_DELEGATE showLoadingView];
    self.cacheDictionary = [NSMutableDictionary dictionary];
    
    // make a directory for these
    BOOL isDir;
    NSString *picturesPath = [NSString stringWithFormat:baseDirectory, [self documentDirectory],@""];
    
    if (![self.fileManager fileExistsAtPath:picturesPath isDirectory:&isDir]) {
        NSError *error = nil;
        [self.fileManager createDirectoryAtPath:picturesPath withIntermediateDirectories:YES attributes:nil error:&error];
    } else {
        // load pictures
        NSDirectoryEnumerator *dir = [self.fileManager enumeratorAtPath: picturesPath];
        NSString *picture;
        while ((picture = [dir nextObject])) {
            NSString *fileName = [[picture componentsSeparatedByString:@"/"] lastObject];
            if ([[fileName componentsSeparatedByString:@"."] count] == 1) {
                NSString *directory = [fileName copy];
                NSString *directoryPath = [picturesPath stringByAppendingFormat:@"%@/",directory];
                // load pictures
                NSDirectoryEnumerator *subDir = [self.fileManager enumeratorAtPath:directoryPath];
                NSString *newPicture;
                while ((newPicture = [subDir nextObject])) {
                    UIImage *img = [UIImage imageWithContentsOfFile:[directoryPath stringByAppendingString:newPicture]];
                    fileName = [directory stringByAppendingFormat:@"/%@",newPicture];
                    [self.cacheDictionary setObject:img forKey:fileName];
                }
            } else {
                UIImage *img = [UIImage imageWithContentsOfFile:[picturesPath stringByAppendingString:picture]];
                [self.cacheDictionary setObject:img forKey:fileName];
            }
            
        }
    }
    
    [APP_DELEGATE hideLoadingView];
}

- (BOOL)saveImage:(UIImage *)image named:(NSString *)name baseDirectory:(NSString *)baseDirectory{

    if (![self existImageNamed:name baseDirectory:baseDirectory]) {
        // Save Image
        NSString *filePath = [NSString stringWithFormat:baseDirectory, [self documentDirectory], name];

        NSData *imageData = UIImageJPEGRepresentation(image, 90);
        NSArray *nameParts = [name componentsSeparatedByString:@"/"];
        if ([nameParts count] > 1) {
            NSMutableArray *parts = [NSMutableArray arrayWithArray:nameParts];
            [parts removeLastObject];
            NSString *directory = [NSString stringWithFormat:baseDirectory, [self documentDirectory], [parts componentsJoinedByString:@"/"]];
            // make a directory for these
            BOOL isDir;
            if (![self.fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
                NSError *error = nil;
                [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
            }
        }

        NSError *error = nil;
        if ([imageData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            //TODO: uncomment to use cache
            //            [self.cacheDictionary setObject:image forKey:name];
            return YES;
        }
    }

    return  NO;
}

- (BOOL)saveCatalogImage:(UIImage *)image named:(NSString *)name{
    return [self saveImage:image named:name baseDirectory:CACHE_DIRECTORY_FORMAT_CATALOGS];
}

- (BOOL)saveArticleImage:(UIImage *)image named:(NSString *)name{
    return [self saveImage:image named:name baseDirectory:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (UIImage *)catalogImageNamed:(NSString *)name{
    return [self imageNamed:name defaltImage:nil baseDirectory:CACHE_DIRECTORY_FORMAT_CATALOGS];
}

- (UIImage *)articleImageNamed:(NSString *)name{
    return [self imageNamed:name defaltImage:nil baseDirectory:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (UIImage *)catalogImageNamed:(NSString *)name defaltImage:(NSString *)defaultImage {
    return [self imageNamed:name defaltImage:defaultImage baseDirectory:CACHE_DIRECTORY_FORMAT_CATALOGS];
}

- (UIImage *)articleImageNamed:(NSString *)name defaltImage:(NSString *)defaultImage {
    return [self imageNamed:name defaltImage:defaultImage baseDirectory:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (UIImage *)imageNamed:(NSString *)name defaltImage:(NSString *)defaultImage baseDirectory:(NSString *)baseDirectory {
    NSString *picturesPath = [NSString stringWithFormat:baseDirectory, [self documentDirectory],@""];
    name = name ? name : defaultImage;
    UIImage *image = [UIImage imageWithContentsOfFile:[picturesPath stringByAppendingString:name]];

    if (image == nil) {
        image = [UIImage imageNamed:defaultImage];
    }

    return image;
}

- (BOOL)existCatalogImageNamed:(NSString *)name {
    return [self existImageNamed:name baseDirectory:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (BOOL)existArticleImageNamed:(NSString *)name {
    return [self existImageNamed:name baseDirectory:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (BOOL)existImageNamed:(NSString *)name baseDirectory:(NSString *)baseDirectory{
    NSString *filePath = [NSString stringWithFormat:baseDirectory, [self documentDirectory], name];
    return [self.fileManager fileExistsAtPath:filePath];
}

- (void)clearCatalogsCache {
    [self clearCache:CACHE_DIRECTORY_FORMAT_CATALOGS];
}

- (void)clearArticlesCache {
    [self clearCache:CACHE_DIRECTORY_FORMAT_ARTICLES];
}

- (void)clearCache:(NSString *)baseDirectory{
    NSString *picturesPath = [NSString stringWithFormat:baseDirectory, [self documentDirectory],@""];

    // make a directory for these
    BOOL isDir;
    if ([self.fileManager fileExistsAtPath:picturesPath isDirectory:&isDir]) {
        NSError *error = nil;
        if (![self.fileManager removeItemAtPath:picturesPath error:&error]) {
            NSLog(@"Fail");
        }
    }
}

//TODO: uncomment to use cache
//- (UIImage *)imageNamed:(NSString *)name {
//    return [self.cacheDictionary objectForKey:name];
//}
//
//- (UIImage *)imageNamed:(NSString *)name defaltImage:(NSString *)defaultImage{
//    UIImage *image = [self.cacheDictionary objectForKey:name];
//    if (image == nil) {
//        image = [UIImage imageNamed:defaultImage];
//    }
//
//    return image;
//}
//
//- (BOOL)existImageNamed:(NSString *)name{
//    return [self.cacheDictionary objectForKey:name] != nil;
//}
//
//- (void)clearCache{
//    // delete all of them so we get up to date
//    for (NSString *fileName in [self.cacheDictionary allKeys]) {
//        // remove from disk
//        NSString *filePath = [NSString stringWithFormat:CACHE_DIRECTORY_FORMAT, [self documentDirectory], fileName];
//        [self.fileManager removeItemAtPath:filePath error:nil];
//    }
//    
//    [self.cacheDictionary removeAllObjects];
//}

@end

//
//  EQImagesManager.h
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CACHE_DIRECTORY_FORMAT_CATALOGS;
extern NSString * const CACHE_DIRECTORY_FORMAT_ARTICLES;

@interface EQImagesManager : NSObject

+ (EQImagesManager *)sharedInstance;
- (void)loadCache;
- (BOOL)saveCatalogImage:(UIImage *)image named:(NSString *)name;
- (BOOL)saveArticleImage:(UIImage *)image named:(NSString *)name;

- (BOOL)existCatalogImageNamed:(NSString *)name;
- (BOOL)existArticleImageNamed:(NSString *)name;
- (UIImage *)catalogImageNamed:(NSString *)name;
- (UIImage *)articleImageNamed:(NSString *)name;
- (UIImage *)catalogImageNamed:(NSString *)name defaltImage:(NSString *)defaultImage;
- (UIImage *)articleImageNamed:(NSString *)name defaltImage:(NSString *)defaultImage;
- (void)clearCatalogsCache;
- (void)clearArticlesCache;

@end

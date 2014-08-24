//
//  EQImageView.m
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQImageView.h"
#import "AFNetworking.h"
#import "EQImagesManager.h"

@interface EQImageView()

@end

@implementation EQImageView

- (void)loadURL:(NSString *)imagePath{
    if (imagePath) {
        NSString *fileName = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        UIImage *image = [[EQImagesManager sharedInstance] articleImageNamed:fileName];
        if (image) {
            [self setImage:image];
        } else{
            NSURL *imageURL = [NSURL URLWithString:[[IMAGES_BASE_URL stringByAppendingString:imagePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image){
                [self setImage:image];
                [[EQImagesManager sharedInstance] saveArticleImage:image named:fileName];
            }];
            
            [operation start];
        }

    } else {
        [self setImage:[UIImage imageNamed:@"catalogoFotoProductoInexistente.png"]];
    }
}

@end

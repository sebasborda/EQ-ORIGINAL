//
//  EQImageView.m
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQImageView.h"
#import "AFNetworking.h"
#import "EQLoadingView.h"
#import "EQImagesManager.h"

@interface EQImageView()

@property (nonatomic,strong) EQLoadingView* loadingView;

@end

@implementation EQImageView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self= [super initWithCoder:aDecoder];
    if (self) {
        self.loadingView = [[EQLoadingView alloc] initViewWithSize:self.frame.size showLargeImage:NO];
    }
    return self;
}

- (void)loadURL:(NSString *)urlString{
    if (urlString) {
        NSString *fileName = [[urlString componentsSeparatedByString:@"/"] lastObject];
        UIImage *image = [[EQImagesManager sharedInstance] imageNamed:fileName];
        if (image) {
            [self setImage:image];
        } else{
            [self.loadingView show];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image){
                [self setImage:image];
                
                [[EQImagesManager sharedInstance] saveImage:image named:fileName];
                [self.loadingView hide];
            }];
            
            [operation start];
        }

    } else {
        [self setImage:[UIImage imageNamed:@"noDisponible.jpg"]];
    }

}

@end

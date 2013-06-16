//
//  EQNetworkManager.m
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQNetworkManager.h"
#import "AFNetworking.h"
#import "EQSession.h"

@implementation EQNetworkManager

+ (void)makeRequest:(EQRequest *)request showLoading:(BOOL)show{
    @synchronized (self) {
        if (show) {
            [APP_DELEGATE showLoadingView];
        }
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request.urlRequest success:^(NSURLRequest *urlRequest, NSHTTPURLResponse *urlResponse, NSDictionary *JSON) {
            NSArray *jsonArray = nil;
            BOOL error = false;
            NSString *message = nil;
            
            for (NSString* key in [JSON allKeys]) {
                if ([key isEqualToString:@"data"]) {
                    jsonArray = [JSON objectForKey:key];
                } else if([key isEqualToString:@"error"]) {
                    error = [[JSON objectForKey:key] boolValue];
                } else if([key isEqualToString:@"message"]){
                    message = [JSON objectForKey:key];
                }
            }
            
            if (!error) {
                request.successBlock(jsonArray);
            } else {
                NSLog(@"Failed: %@ for request %@",message, [[urlRequest URL] absoluteString]);
                request.failBlock([NSError errorWithDomain:@"EQ-Server" code:9999 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]]);
            }
            
            if (show) {
                [APP_DELEGATE hideLoadingView];
            }
            
        } failure:^(NSURLRequest *urlRequest , NSURLResponse *response , NSError *error , id JSON)
                                             {
                                                 NSLog(@"Failed: %@ for request %@",[error localizedDescription], [[urlRequest URL] absoluteString]);
                                                 request.failBlock(error);
                                                 
                                                 if (show) {
                                                     [APP_DELEGATE hideLoadingView];
                                                 }
                                             }];
        [operation start];
    }
}

+ (void)makeRequest:(EQRequest *)request{
    [EQNetworkManager makeRequest:request showLoading:YES];
}

@end

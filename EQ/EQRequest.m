//
//  EQRequest.m
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQRequest.h"
#import "AFNetworking.h"

@implementation EQRequest

- (id)initWithParams:(NSMutableDictionary *)params
 successRequestBlock:(void(^)(NSArray* jsonArray))success
    failRequestBlock:(void(^)(NSError* error))fail{
    self = [super init];
    if (self) {
        NSURLRequest *url = [self generateRequestWithParameters:params];
        self.urlRequest = url;
        if (success == nil) {
            self.successBlock = ^(NSArray* jsonArray){
                NSLog(@"url: %@ result: %i", [[url URL] absoluteString], [jsonArray count]);
            };
            
        } else{
            self.successBlock = success;
        }
        
        
        if (fail == nil) {
            self.failBlock = ^(NSError *error){
                NSLog(@"EQRequest fail error:%@ UserInfo:%@",error ,error.userInfo);
            };
        } else {
            self.failBlock = fail;
        }
    }
    
    return self;
}

-(NSURLRequest *)generateRequestWithParameters:(NSMutableDictionary *)parameters{
    NSURLRequest *request = nil;
    if ([[parameters allKeys] containsObject:@"POST"]) {
        [parameters removeObjectForKey:@"POST"];
        NSURL *url = [NSURL URLWithString:@BASE_URL];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        httpClient.parameterEncoding = AFJSONParameterEncoding;
        request = [httpClient requestWithMethod:@"POST" path:@BASE_URL parameters:parameters];
    } else {
        NSMutableString *queryString = [NSMutableString string];
        //add extra parameters
        for (NSString* key in [parameters allKeys]) {
            NSString *format = [queryString length] == 0 ? @"?%@=%@" : @"&%@=%@";
            [queryString appendFormat:format,key, [parameters objectForKey:key]];
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%s%@",BASE_URL,queryString];
        NSURL *URL = [NSURL URLWithString:urlString];
        request = [NSURLRequest requestWithURL:URL];
        if ([queryString length] == 0 || URL == nil || request == nil) {
            NSLog(@"error");
        }
    }
    
    return request;
}

@end

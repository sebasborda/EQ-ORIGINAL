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

-(NSURLRequest *)generateRequestWithParameters:(NSMutableDictionary *)params{
    NSMutableString *queryString = [NSMutableString stringWithFormat:@"%@?action=%@&object=%@",@BASE_URL,params[@"action"],params[@"object"]];
    BOOL post = [params[@"POST"] boolValue];
    NSURLRequest *request = nil;
    [params removeObjectForKey:@"object"];
    [params removeObjectForKey:@"action"];
    
    if (post) {
        [params removeObjectForKey:@"POST"];        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@BASE_URL]];
        httpClient.parameterEncoding = AFJSONParameterEncoding;
        request = [httpClient requestWithMethod:@"POST" path:@BASE_URL parameters:params];
    } else {
        for (NSString *key in params.allKeys) {
            NSString *value = [NSString stringWithFormat:@"%@",params[key]];
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [queryString appendFormat:@"&%@=%@",key,value];
        }
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString]];
    }
    
    return request;
}

@end

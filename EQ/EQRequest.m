//
//  EQRequest.m
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQRequest.h"
#import "AFNetworking.h"
#import "NSDictionary+EQ.h"
#import "EQSession.h"
#import "EQDefines.h"

@implementation EQRequest

- (id)initWithParams:(NSMutableDictionary *)params
 successRequestBlock:(void(^)(NSArray* jsonArray))success
    failRequestBlock:(void(^)(NSError* error))fail
     runInBackground:(BOOL)runInBackground{
    self = [super init];
    if (self) {
        NSURLRequest *url = [self generateRequestWithParameters:params];
        self.urlRequest = url;
        if (success == nil) {
            self.successBlock = ^(NSArray* jsonArray){
                NSLog(@"url: %@ result: %i", [[url URL] absoluteString], [jsonArray count]);
            };
            
        } else{
            self.successBlock = ^(NSArray* jsonArray){
                if (runInBackground) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        success(jsonArray);
                    });
                } else {
                    success(jsonArray);
                }
            };
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
    NSURLRequest *request = nil;
    if (DEBUG_ERROR && [[params objectForKey:@"action"] isEqualToString:@"listar"]) {
        if ([[params objectForKey:@"object"] isEqualToString:@"pedido"]) {
            NSString *url = [NSString stringWithFormat:@"%@reporte_error/pedido/orders-%@.json",IMAGES_BASE_URL, DEBUG_ERROR_CODE];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

        } else if ([[params objectForKey:@"object"] isEqualToString:@"pedido_articulo"]) {
            NSString *url = [NSString stringWithFormat:@"%@reporte_error/pedido/items-%@.json",IMAGES_BASE_URL, DEBUG_ERROR_CODE];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        }
    }
    
    if (request == nil) {
        NSString *object = params[@"object"];
        NSString *tipo = params[@"tipo"];
        NSString *action = params[@"action"];

        NSMutableString *queryString = [NSMutableString stringWithFormat:@"%@?action=%@&usuario=%@&password=%@",@API_URL,action,params[@"usuario"],params[@"password"]];
        if (object) {
            [queryString appendFormat:@"&object=%@",object];
            [params removeObjectForKey:@"object"];
        } else if (tipo) {
            [queryString appendFormat:@"&tipo=%@",tipo];
            [params removeObjectForKey:@"tipo"];
        }

        BOOL post = [params[@"POST"] boolValue];
        [params removeObjectForKey:@"action"];
        [params removeObjectForKey:@"usuario"];
        [params removeObjectForKey:@"password"];
        
        if (post) {
            [params removeObjectForKey:@"POST"];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:queryString]];
            httpClient.parameterEncoding = AFFormURLParameterEncoding;
            NSMutableDictionary *parameters = nil;
            if ([action isEqualToString:@"reportarerror"]) {
                parameters = params;
            } else {
                NSNumber *identifier = [params objectForKey:@"id"];
                [params removeObjectForKey:@"id"];

                parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"atributos":[params toJSON]}];
                if (identifier) {
                    [parameters addEntriesFromDictionary:@{@"id":identifier}];
                }
            }
            
            request = [httpClient requestWithMethod:@"POST" path:queryString parameters:parameters];
        } else {
            for (NSString *key in params.allKeys) {
                NSString *value = [NSString stringWithFormat:@"%@",params[key]];
                [queryString appendFormat:@"&%@=%@",key,value];
            }
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString]];
        }
    }
    
    return request;
}

- (NSString *)description {
    return [[self.urlRequest URL] absoluteString];
}

@end

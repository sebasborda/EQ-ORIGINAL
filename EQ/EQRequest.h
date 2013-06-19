//
//  EQRequest.h
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessRequest)(id);
typedef void(^FailRequest)(NSError *);

@interface EQRequest : NSObject

@property (nonatomic,strong) SuccessRequest successBlock;
@property (nonatomic,strong) FailRequest failBlock;
@property (nonatomic,strong) NSURLRequest *urlRequest;

- (id)initWithParams:(NSMutableDictionary *)params
 successRequestBlock:(void(^)(NSArray* jsonArray))success
    failRequestBlock:(void(^)(NSError* error))fail;

@end

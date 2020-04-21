//
//  NetWorking.h
//  AFSSLTest
//
//  Created by Thomas on 2020/4/21.
//  Copyright © 2020 Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//block支持
typedef void (^SuccessBlock)(NSString *key, NSDictionary *result);
typedef void (^FailureBlock)(NSString *key, NSError *error);
typedef void (^RequestSuccessBlock)(id response);
typedef void (^RequestFailureBlock)(id error);

typedef enum {
    RequestMethodGet = 1,
    RequestMethodPost
}RequestMethod;

@interface NetWorking : NSObject

//http请求
+ (instancetype)requestUrl:(NSString *)url
                    method:(RequestMethod)method
                    params:(NSDictionary *)params
              successBlock:(RequestSuccessBlock)successBlock
              failureBlock:(RequestFailureBlock)failureBlock;

@end



NS_ASSUME_NONNULL_END

//
//  NetWorking.m
//  AFSSLTest
//
//  Created by Thomas on 2020/4/21.
//  Copyright © 2020 Thomas. All rights reserved.
//

#import "NetWorking.h"
#import <AFNetworking.h>

@interface NetWorking ()
//成功回调
@property (nonatomic, copy) RequestSuccessBlock successBlock;
//失败回调
@property (nonatomic, copy) RequestFailureBlock failureBlock;
//http请求对象
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
//session任务
@property (nonatomic, strong) NSURLSessionTask *task;
@end

//为了解决NSLog打印不全
#define NSLog(...) ;//printf("%s\n",[[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

@implementation NetWorking
static AFHTTPSessionManager *manager;

- (instancetype)init {
    if (self = [super init]) {
        _httpManager = [NetWorking sharedManager];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"...dealloc...%@", NSStringFromClass(self.class));
}

+ (AFHTTPSessionManager *)sharedManager {
    if (!manager) {
        //需要设置baseUrl，不然设置证书模式时会抛出异常
        NSURL *baseUrl = [NSURL URLWithString:@"https://www.ptcode.online"];
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
//        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10;
        //可接受返回的数据的格式
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", @"multipart/form-data", @"image/jpeg", @"image/png", @"application/octet-stream", @"application/json;charset=UTF-8", nil];
//        manager.securityPolicy = [self noSecurityPolicy];
        //禁用缓存
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        manager.securityPolicy = [self customSecurityPolicy];
    }
    return manager;
}

//设置非校验证书模式
+ (AFSecurityPolicy *)noSecurityPolicy {
    AFSecurityPolicy *sec = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    sec.allowInvalidCertificates = YES;
    [sec setValidatesDomainName:NO];
    return sec;
}

//证书校验模式
+ (AFSecurityPolicy *)customSecurityPolicy {
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//证书的路径
    //加密模式
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"json"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
//    certData = [self getCerData:certData];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    return securityPolicy;
}

//解密操作
+(NSData *)getCerData:(NSData *)data{
    return data;
}


+ (instancetype)requestUrl:(NSString *)url
                    method:(RequestMethod)method
                    params:(NSDictionary *)params
              successBlock:(RequestSuccessBlock)successBlock
              failureBlock:(RequestFailureBlock)failureBlock {
    NetWorking *request = [[NetWorking alloc] init];
    request.successBlock = successBlock;
    request.failureBlock = failureBlock;
    [request startRequestUrl:url method:method params:params];
    return request;
}

//开始http请求
- (void)startRequestUrl:(NSString *)url method:(RequestMethod)method params:(NSDictionary *)params {
    if (!url || url.length <= 0) {
        return;
    }
    if (method == RequestMethodGet) {
        self.task = [self.httpManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            if (self.successBlock) {
                self.successBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }];
    } else if (method == RequestMethodPost) {
        self.task = [self.httpManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            if (self.successBlock) {
                self.successBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            //打印结果
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }];
    }

    //打印请求
    NSLog(@"\n请求地址:%@\n请求参数:%@", url, params);
}

@end

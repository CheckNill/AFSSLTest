//
//  ViewController.m
//  AFSSLTest
//
//  Created by Thomas on 2020/4/21.
//  Copyright © 2020 Thomas. All rights reserved.
//

#import "ViewController.h"
#import "NetWorking.h"
#define weakSelf(self)             __weak __typeof(&*self)weakSelf = self

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLb;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self click:nil];
}

- (IBAction)click:(id)sender {
    weakSelf(self);
    [NetWorking requestUrl:@"https://www.ptcode.online/test.json" method:RequestMethodGet params:nil successBlock:^(id  _Nonnull response) {
        weakSelf.textLb.text = [NSString stringWithFormat:@"%@",response];
    } failureBlock:^(id  _Nonnull error) {        
        weakSelf.textLb.text = [NSString stringWithFormat:@"%@",error];
    }];
}



@end

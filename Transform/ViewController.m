//
//  ViewController.m
//  Transform
//
//  Created by 李居彬 on 16/1/25.
//  Copyright © 2016年 ljb. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+LJBExp.h"
#import "Model1.h"
#import "Model2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *arr1 = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
        dict1[@"id"] = [NSString stringWithFormat:@"%d",i];
        dict1[@"name"] = [NSString stringWithFormat:@"张三 %d",i];
        dict1[@"age"] = @"20";
        dict1[@"tmpArry"] = @[[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"score",@"2",@"lesson", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"score",@"2",@"lesson", nil]];
        [arr1 addObject:dict1];
    }
    //解析 模型中包含模型的 json
    NSMutableArray *result1 = [NSMutableArray array];
    for (NSDictionary *dict in arr1) {
        Model1 *model1 = [Model1 ljbObjectWithDict:dict];
        model1.tmpArry = [Model2 ljbObjectWithArray:model1.tmpArry];
        [result1 addObject:model1];
    }
    //
    for (Model1 *model in result1) {
        NSLog(@"%@,%@,%zd",model._id,model.name,model.tmpArry);
        for (Model2 *model2 in model.tmpArry) {
            NSLog(@"%@",model2.score);
        }
    }
    
    //解析 单个模型的 json
    NSMutableArray *arr2 = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"score"] = [NSString stringWithFormat:@"%zd",i];
        dict[@"lesson"] = @"abc";
        [arr2 addObject:dict];
    }
    
    NSArray *result2 = [Model2 ljbObjectWithArray:arr2];
    for (Model2 *model in result2) {
        NSLog(@"%@,%@",model.score,model.lesson);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

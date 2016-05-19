//
//  NSObject+LJBExp.m
//  Transform
//
//  Created by 李居彬 on 16/1/25.
//  Copyright © 2016年 ljb. All rights reserved.
//

#import "NSObject+LJBExp.h"
#import <objc/runtime.h>

@implementation NSObject (LJBExp)

+ (instancetype)ljbObjectWithDict:(NSDictionary *)dict {
    NSObject *object = [[self alloc] init];
    if ([dict isEqual:[NSNull null]]
        || !dict) {
        return object;
    }
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        NSString *mapKey = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *dictKey = mapKey;
        if ([mapKey hasPrefix:@"_"]) {
            NSMutableString *tmpStr = [NSMutableString stringWithString:mapKey];
            int lenght = 0;
            for (int i = 0; i < tmpStr.length; i++) {
                if ([[tmpStr substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"_"]) {
                    lenght++;
                } else {
                    break;
                }
            }
            NSRange range = NSMakeRange(0, lenght);
            [tmpStr replaceCharactersInRange:range withString:@""];
            dictKey = tmpStr;
        }
        //二级转换
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if (![dict[dictKey] isEqual:[NSNull null]]
            && dict[dictKey]) {
            if ([dict[dictKey] isKindOfClass:[NSDictionary class]]
                && ![ivarType containsString:@"NS"]) {
                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                // 获取类
                Class modelClass = NSClassFromString(ivarType);
                
                id value = [modelClass ljbObjectWithDict:dict[dictKey]];
                [object setValue:value forKey:mapKey];
            } else {
                [object setValue:dict[dictKey] forKey:mapKey];
            }
        }  else if ([dict[dictKey] isEqual:[NSNull null]]
                   || dict[dictKey] == nil) {
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            // 获取类
            if ([ivarType containsString:@"NS"]) {
                Class modelClass = NSClassFromString(ivarType);
                [object setValue:[modelClass new] forKey:mapKey];
            } else {
                NSLog(@"非系统类型对象:%@",ivarType);
            }
        }
    }
    
    return object;
}

+ (NSArray *)ljbObjectWithArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
    if ([array isEqual:[NSNull null]]
        || !array.count) {
        return resultArray;
    }
    for (NSObject *tmpObject in array) {
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            NSObject *object = [self ljbObjectWithDict:(NSDictionary *)tmpObject];
            [resultArray addObject:object];
        } else {
            [resultArray addObject:tmpObject];
        }
    }
    
    return resultArray;
}


@end

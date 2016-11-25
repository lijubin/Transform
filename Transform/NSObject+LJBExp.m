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
        if ([dictKey hasPrefix:@"_"]) {
            dictKey = [dictKey substringFromIndex:1];
        }
        if ([dict[dictKey] isEqual:[NSNull null]]
            || !dict[dictKey]) {
            if ([dictKey hasPrefix:@"_"]) {
                NSMutableString *tmpStr = [NSMutableString stringWithString:dictKey];
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
        }
        //二级转换
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        if (![dict[dictKey] isEqual:[NSNull null]]
            && dict[dictKey]) {
            if ([dict[dictKey] isKindOfClass:[NSDictionary class]]
                && ![ivarType containsString:@"NS"]) {//字典转模型
                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                // 获取类
                Class modelClass = NSClassFromString(ivarType);
                
                id value = [modelClass ljbObjectWithDict:dict[dictKey]];
                [object setValue:value forKey:mapKey];
            } else {//数组转模型
                //数组转模型的使用。数组需要通过协议来使用转换。
                //如：@property(nonatomic,strong)NSArray<YFReceiptAddress> *receipt_address;//收货地址列表
                if ([ivarType containsString:@"NSArray"]
                    && [ivarType containsString:@"<"]
                    && [ivarType containsString:@">"]
                    && [dict[dictKey] isKindOfClass:[NSArray class]]) {//定义了需要转换的数组时进行多级转换
                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    //获取泛型类
                    NSRange startRange = [ivarType rangeOfString:@"<"];
                    NSRange endRange = [ivarType rangeOfString:@">"];
                    if (startRange.location != NSNotFound
                        && endRange.location != NSNotFound) {
                        NSString *modelString = [ivarType substringWithRange:NSMakeRange(startRange.location + startRange.length,endRange.location - (startRange.location + startRange.length))];
                        // 获取类
                        Class modelClass = NSClassFromString(modelString);
                        id value = [modelClass ljbObjectWithArray:dict[dictKey]];
                        [object setValue:value forKey:mapKey];
                    } else {
                        [object setValue:dict[dictKey] forKey:mapKey];
                    }
                } else {//不转换
                    //类型判断。类型不一致时，强制类型转换
                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    Class modelClass = NSClassFromString(ivarType);
                    if ([dict[dictKey] isKindOfClass:[modelClass class]]) {
                        [object setValue:dict[dictKey] forKey:mapKey];
                    } else {
                        if ([ivarType isEqualToString:@"NSString"]) {
                            [object setValue:[NSString stringWithFormat:@"%@",dict[dictKey]] forKey:mapKey];
                        } else if ([ivarType isEqualToString:@"NSNumber"]) {
                            NSString *tmpStr = [NSString stringWithFormat:@"%@",dict[dictKey]];
                            NSNumber *numTemp = [NSNumber numberWithFloat:[tmpStr floatValue]];
                            [object setValue:numTemp forKey:mapKey];
                        } else {
                            [object setValue:dict[dictKey] forKey:mapKey];
                        }
                    }
                }
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
//                NSLog(@"非系统类型对象:%@",ivarType);
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

#pragma mark - 数据缓存
+ (void)writeDataCache:(NSString *)dataCacheId dataLists:(NSArray *)dataLists {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (dataLists == nil
        || dataLists.count == 0) {
        [userDefault removeObjectForKey:dataCacheId];
    } else {
        [userDefault removeObjectForKey:dataCacheId];
        NSMutableArray *dataArray = [NSMutableArray array];
        for (int i = 0; i < (dataLists.count > 10 ? 10 : dataLists.count); i++) {
            NSDictionary *dataDict = dataLists[i];
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            //处理 需要存储的字典信息
            if ([dataDict isEqual:[NSNull null]]
                || !dataDict) {
                continue;
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
                //模型转字典
                if (![dataDict[dictKey] isEqual:[NSNull null]]
                    && dataDict[dictKey]) {
                    if ([dataDict[dictKey] isKindOfClass:[NSString class]]
                        && [dataDict[dictKey] isEqual:@""]) {
                        continue;
                    }
                    if ([dataDict[dictKey] isKindOfClass:[NSNumber class]]
                        && ([dataDict[dictKey] isEqual:@""])) {
                        continue;
                    }
                    resultDict[dictKey] = dataDict[dictKey];
                }
            }
            if (resultDict) {
                [dataArray addObject:resultDict];
            }
        }
        [userDefault setObject:dataArray forKey:dataCacheId];
    }
}

#pragma mark - 读取缓存数据
+ (NSArray *)readDataCache:(NSString *)dataCacheId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *tmpArray = [userDefault objectForKey:dataCacheId];
    NSArray *resultArray = nil;
    if (tmpArray == nil || tmpArray.count == 0) {
        resultArray = nil;
    } else {
        resultArray = [self ljbObjectWithArray:tmpArray];
    }
    return resultArray;
}

@end

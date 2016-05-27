//
//  NSObject+LJBExp.h
//  一公里
//
//  Created by liuguopan on 16/1/5.
//  Copyright © 2016年 viewcreator3d. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LJBExp)

/**
 *  字典转模型
 *
 *  @param dict 需要转换的字典
 *
 *  @return 返回模型数据
 */
+ (instancetype)ljbObjectWithDict:(NSDictionary *)dict;

/**
 *  数组转模型
 *
 *  @param array 数组中含有需要转换的字典
 *
 *  @return 含有转换后的模型的数组
 */
+ (NSArray *)ljbObjectWithArray:(NSArray *)array;

/**
 *  数据列表缓存
 *
 *  @param dataCacheId 数据Id
 *  @param dataLists   数据信息
 */
+ (void)writeDataCache:(NSString *)dataCacheId dataLists:(NSArray *)dataLists;

+ (NSArray *)readDataCache:(NSString *)dataCacheId;

@end

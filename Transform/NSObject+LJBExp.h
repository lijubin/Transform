//
//  NSObject+LJBExp.h
//  Transform
//
//  Created by 李居彬 on 16/1/25.
//  Copyright © 2016年 ljb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LJBExp)

/**字典转模型*/
+ (instancetype)ljbObjectWithDict:(NSDictionary *)dict;

/**数组转模型*/
+ (NSArray *)ljbObjectWithArray:(NSArray *)array;

@end

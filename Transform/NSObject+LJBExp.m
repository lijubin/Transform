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
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char * propertyName = property_getName(property);
        NSString *mapKey = [[NSString alloc] initWithUTF8String:propertyName];
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
        if (![dict[dictKey] isEqual:[NSNull null]]
            && dict[dictKey]) {
            [object setValue:dict[dictKey] forKey:mapKey];
        }
    }
    
    return object;
}

+ (NSArray *)ljbObjectWithArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
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

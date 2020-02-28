//
//  ZPPerson.h
//  关联对象
//
//  Created by 赵鹏 on 2019/5/16.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPPerson : NSObject
//{
//    int _age;
//}

//- (void)setAge:(int)age;
//- (int)age;

/**
 在原类里面添加一个属性，系统会做如下的三件事：
 1、会在.h文件中生成一个带下横线的成员变量；
 2、会在.h文件中生成这个属性的set和get方法的声明；
 3、会在.m文件中生成这个属性的set和get方法的实现。
 */
@property (nonatomic, assign) int age;

@end

NS_ASSUME_NONNULL_END

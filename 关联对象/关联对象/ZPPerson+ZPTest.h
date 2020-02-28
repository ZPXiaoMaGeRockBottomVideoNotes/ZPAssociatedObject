//
//  ZPPerson+ZPTest.h
//  关联对象
//
//  Created by 赵鹏 on 2019/5/16.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZPPerson (ZPTest)

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int weight;

@end

NS_ASSUME_NONNULL_END

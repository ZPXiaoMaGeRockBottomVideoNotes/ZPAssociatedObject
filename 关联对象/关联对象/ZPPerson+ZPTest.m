//
//  ZPPerson+ZPTest.m
//  关联对象
//
//  Created by 赵鹏 on 2019/5/16.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 ·分类会在程序编译结束的时候变为以下的数据结构（分类的底层结构）：
 struct _category_t {
     const char *name;
     struct _class_t *cls;
     const struct _method_list_t *instance_methods;
     const struct _method_list_t *class_methods;
     const struct _protocol_list_t *protocols;
     const struct _prop_list_t *properties;
 };
 由上面的结构体可以看出分类是可以添加属性的，并且在程序编译结束的时候会存储在结构体中的properties元素中。给分类添加属性与给原类添加属性的不同之处就在于给分类添加属性之后，系统只会在分类的.h文件中生成这个属性的set和get方法的声明，而不会生成带下横线的成员变量以及set、get方法的实现；

 ·可以给分类添加属性，但是不能添加成员变量。一旦给分类添加成员变量则编译不能通过，会报错；

 ·给分类添加属性后，系统为什么不能自动生成带下横线的成员变量？
 1、这就要从原类和分类的底层结构上来分析了，原类的底层结构如下：
 typedef struct objc_class *Class;

 struct objc_class {
     Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

 #if !__OBJC2__
     Class _Nullable super_class                              OBJC2_UNAVAILABLE;
     const char * _Nonnull name                               OBJC2_UNAVAILABLE;
     long version                                             OBJC2_UNAVAILABLE;
     long info                                                OBJC2_UNAVAILABLE;
     long instance_size                                       OBJC2_UNAVAILABLE;
     struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
     struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
     struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
     struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
 #endif

 } OBJC2_UNAVAILABLE;
 由此可以看出原类的底层结构其实也是一个结构体，这与上面的分类的底层结构相比较可以看出，分类比原类少了一个"struct objc_ivar_list * _Nullable ivars"元素，所以给分类添加完属性之后，系统在编译的时候不会自动生成带下横线的成员变量，因为分类的结构体中没有地方进行存储；
 2、上述是从代码的角度分析为何不能在分类中添加成员变量，还可以从程序运行的角度来进行分析：分类在程序运行的时候会利用Runtime运行时机制把分类中的方法合并到原类中去，而在程序运行的时候，原类的内存分布就已经确定了，不允许再在原类中添加实例变量了，因为那样会改变原类的内存分布。而类拓展可以给原类增加实例变量的原因就在于，类拓展是在程序编译的时候把成员变量添加到原类中去的，而在程序编译的时候，原类的内存分布还没有确定下来了，所以能够进行添加。参考：https://blog.csdn.net/lixuezhi86/article/details/81713166
 
 ·如果想让分类也和原类一样，在分类中添加完属性之后，其他类能够正常地使用点语法来给这个属性赋值和取值，就应该在分类中使用关联对象的方式；
 ·以本分类为例，想要把name和weight属性跟ZPPerson对象关联在一起，所以name和weight属性就叫做ZPPerson类的关联对象；
 ·使用关联对象的方式给分类添加属性是Runtime运行时机制的又一重大应用。
 ·使用关联对象方式的步骤：
 1、在分类的.h文件中添加新的属性；
 2、在分类的.m文件中撰写这个属性的set和get方法。
 然后在其他类中就可以使用点语法来访问这个分类里面的属性了。
 ·应当注意的是，当使用关联对象的方式给分类添加属性之后，在程序编译结束的时候，会产生这个属性的set、get方法的声明以及set、get方法的实现，并且会把这些东西存放在struct _category_t结构体（分类的底层实现）中，但还是不会产生带下横线的成员变量。
 */

#import "ZPPerson+ZPTest.h"
#import <objc/runtime.h>

@implementation ZPPerson (ZPTest)

//是一个指针，里面可以存储地址值。
static const void *nameKey = &nameKey;
static const void *weightKey = &weightKey;

- (void)setName:(NSString *)name
{
    /**
     设置关联对象：
     ·下面函数中的第一个参数是object，表示要给哪个对象添加关联对象，这里是要给本类添加关联对象，所以要写self；
     ·第二个参数是key，设置关联对象的时候要一并设置的，在其他方法中获取关联对象的时候要根据这个key再进行获取；
     ·第三个参数是value，表示要把哪个关联对象与本类关联起来，这里要写name；
     ·第四个参数是policy，表示关联策略，意思是将来保存这个关联对象name的时候使用的是什么策略，就如同在.h文件中撰写的用来修饰属性的关键字一样，不同的属性关键字决定将来用什么样的策略来管理它的内存。下面列明了策略与属性关键字的对应关系：
     关联策略(objc_AssociationPolicy)       .h文件中用来修饰属性的关键字
     OBJC_ASSOCIATION_ASSIGN               assign
     OBJC_ASSOCIATION_RETAIN_NONATOMIC     strong, nonatomic
     OBJC_ASSOCIATION_COPY_NONATOMIC       copy, nonatomic
     OBJC_ASSOCIATION_RETAIN               strong, atomic
     OBJC_ASSOCIATION_COPY                 copy, atomic
     这个参数的值要根据.h文件中的这个关联对象是用何种关键字来修饰的而决定，所以这里要选择"OBJC_ASSOCIATION_COPY_NONATOMIC"关联策略。
     */
    objc_setAssociatedObject(self, nameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    /**
     获取关联对象：
     ·下面函数中的第一个参数是object，表示要从哪里获取关联对象，这里是要从ZPPerson获取关联对象，所以要写self；
     ·第二个参数是key，在set方法中设置关联对象的时候要一并设置的，在本方法中获取的时候要根据这个key进行获取。
     */
    return objc_getAssociatedObject(self, nameKey);
}

- (void)setWeight:(int)weight
{
    objc_setAssociatedObject(self, weightKey, [NSNumber numberWithInt:weight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)weight
{
    return [objc_getAssociatedObject(self, weightKey) intValue];
}

@end

//
//  ViewController.m
//  关联对象
//
//  Created by 赵鹏 on 2019/5/16.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ViewController.h"
#import "ZPPerson.h"
#import "ZPPerson+ZPTest.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZPPerson *person = [[ZPPerson alloc] init];
    person.age = 10;
    person.name = @"jack";
    person.weight = 30;
    
    ZPPerson *person1 = [[ZPPerson alloc] init];
    person1.age = 20;
    person1.name = @"rose";
    person1.weight = 50;
    
    NSLog(@"person - age is %d, name is %@, weight is %d", person.age, person.name, person.weight);
    
    NSLog(@"person1 - age is %d, name is %@, weight is %d", person1.age, person1.name, person1.weight);
}

@end

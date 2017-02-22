//
//  ViewController.m
//  BRStringPicker
//
//  Created by 任波 on 17/2/22.
//  Copyright © 2017年 renbo. All rights reserved.
//

#import "ViewController.h"
#import "BRStringPicker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)clickSelectBtn:(id)sender {
    NSArray *dataArr = @[@"高中", @"中专", @"大专", @"本科", @"硕士", @"博士", @"博士后"];
    // 调用这个类方法
    [BRStringPicker showPickerWithTitle:@"请选择学历" dataSource:dataArr defaultSelIndex:0 resultBlock:^(NSString *selectedValue) {
        NSLog(@"你选择的学历是：%@", selectedValue);
        self.label.text = selectedValue;
    }];
}

@end

# BRStringPicker
字符串选择器



# 效果图

![效果图](https://github.com/borenfocus/BRStringPicker/blob/master/BRStringPicker/%E6%95%88%E6%9E%9C%E5%9B%BE.gif)



# 使用说明

1. 导入头文件：`import "BRStringPicker.h"`

2. 直接调用`showPickerWithTitle: ...`这个类方法

   ```objective-c
   - (IBAction)clickSelectBtn:(id)sender {
       NSArray *dataArr = @[@"高中", @"中专", @"大专", @"本科", @"硕士", @"博士", @"博士后"];
       // 调用这个类方法
       [BRStringPicker showPickerWithTitle:@"请选择学历" dataSource:dataArr defaultSelIndex:0 resultBlock:^(NSString *selectedValue) {
           NSLog(@"你选择的学历是：%@", selectedValue);
           self.label.text = selectedValue;
       }];
   }
   ```

   ​
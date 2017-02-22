//
//  BRStringPicker.h
//  BRStringPicker
//
//  Created by 任波 on 17/2/22.
//  Copyright © 2017年 renbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DoneResultBlock)(NSString *selectedValue);

@interface BRStringPicker : UIView
/**
 *  显示底部弹出选择框PickerView
 *  title       :  Picker的标题
 *  dataArr     :  滚轮上显示的数据(必填,会根据数据多少自动设置弹层的高度)
 *  index       :  设置默认选项
 *  resultBlock :  回调选择的状态字符串(stateStr格式:state/row)
 *
 */
+ (void)showPickerWithTitle:(NSString *)title dataSource:(NSArray *)dataArr defaultSelIndex:(NSInteger)index resultBlock:(DoneResultBlock)resultBlock;

@end

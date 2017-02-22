//
//  BRStringPicker.m
//  BRStringPicker
//
//  Created by 任波 on 17/2/22.
//  Copyright © 2017年 renbo. All rights reserved.
//

#import "BRStringPicker.h"

// 屏幕宽度
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
// 屏幕高度
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
// 工具条高度
#define TOOLBAR_HEIGHT 40
// 选择器高度
#define STRPICKER_HEIGHT (([UIScreen mainScreen].bounds.size.width >= 400)?216.0:180.0)

// RGB颜色(16进制)
#define kUIColorHex(rgbValue) \
[UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((CGFloat)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

@interface BRStringPicker ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSString *selectedValue;   // 选中的字符串
    NSInteger bgHeight;        // 弹层的高度
}
@property (nonatomic ,strong) UIView *bgView;            //picker背景视图
@property (nonatomic ,strong) UIPickerView *strPicker;   //字符串选择器
@property (nonatomic ,strong) UIView *toolBarView;       //工具栏
@property (nonatomic ,strong) UIButton *doneBtn;         //完成按钮
@property (nonatomic ,strong) UIButton *cancelBtn;       //取消按钮
@property (nonatomic ,strong) UILabel *titleLabel;       //标题

/** Picker的标题 */
@property (nonatomic, copy) NSString *pickerTitle;
/** 滚轮上显示的数据(必填,会根据数据多少自动设置弹层的高度) */
@property (nonatomic, strong) NSArray *dataSource;
/** 设置默认选项,格式:选项文字/id (先设置dataArr,不设置默认选择第0个) */
@property (nonatomic, assign) NSInteger defaultSelIndex;
/** 回调选择的状态字符串(stateStr格式:state/row) */
@property (nonatomic, copy) DoneResultBlock resultBlock;

/** 显示视图 */
- (void)showPickerView;

@end
@implementation BRStringPicker

+ (void)showPickerWithTitle:(NSString *)title dataSource:(NSArray *)dataArr defaultSelIndex:(NSInteger)index resultBlock:(DoneResultBlock)resultBlock {
    BRStringPicker *picker = [[BRStringPicker alloc]initWithTitle:title dataSource:dataArr defaultSelIndex:index resultBlock:resultBlock];
    [picker showPickerView];
}

- (instancetype)initWithTitle:(NSString *)title dataSource:(NSArray *)dataArr defaultSelIndex:(NSInteger)index resultBlock:(DoneResultBlock)resultBlock {
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.userInteractionEnabled = YES;
        [self addSubview:self.maskView];
        //bgHeight = HEIGHT_OF_POPBOX - 100;
        [self addSubview:self.bgView];
        self.pickerTitle = title;
        self.dataSource = dataArr;
        self.defaultSelIndex = index;
        self.resultBlock = resultBlock;
    }
    return self;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:self.strPicker];
        [_bgView addSubview:self.toolBarView];
    }
    return _bgView;
}

- (UIPickerView *)strPicker {
    if (_strPicker == nil) {
        _strPicker = [[UIPickerView alloc] init];
        _strPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _strPicker.backgroundColor = [UIColor whiteColor];
        _strPicker.showsSelectionIndicator = YES;
        _strPicker.dataSource = self;
        _strPicker.delegate = self;
    }
    return _strPicker;
}

- (UIView *)toolBarView {
    if (_toolBarView == nil) {
        _toolBarView = [[UIView alloc] init];
        _toolBarView.backgroundColor = kUIColorHex(0x349DDA);
        _toolBarView.layer.borderColor = kUIColorHex(0xEEEEEE).CGColor;
        _toolBarView.layer.borderWidth = 0.5f;
        [_toolBarView addSubview:self.doneBtn];
        [_toolBarView addSubview:self.cancelBtn];
        [_toolBarView addSubview:self.titleLabel];
    }
    return _toolBarView;
}

- (UIButton *)doneBtn {
    if (_doneBtn == nil) {
        _doneBtn = [[UIButton alloc] init];
        _doneBtn.layer.borderColor = kUIColorHex(0xEEEEEE).CGColor;
        _doneBtn.layer.borderWidth = 0.5f;
        _doneBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [_doneBtn setTitleColor:kUIColorHex(0xFFFFFF) forState:UIControlStateNormal];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UIButton *)cancelBtn {
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.layer.borderColor = kUIColorHex(0xEEEEEE).CGColor;
        _cancelBtn.layer.borderWidth = 0.5f;
        _cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [_cancelBtn setTitleColor:kUIColorHex(0xFFFFFF) forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kUIColorHex(0xEEEEEE);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.text = self.pickerTitle;
    }
    return _titleLabel;
}

- (void)layoutSelfSubviews {
    self.bgView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, bgHeight);
    self.strPicker.frame = CGRectMake(0, 40, SCREEN_WIDTH, bgHeight - TOOLBAR_HEIGHT);
    self.toolBarView.frame = CGRectMake(0, 0, SCREEN_WIDTH, TOOLBAR_HEIGHT);
    self.doneBtn.frame = CGRectMake(SCREEN_WIDTH - 66, 0, 66, 40);
    self.cancelBtn.frame = CGRectMake(0, 0, 66, 40);
    self.titleLabel.frame = CGRectMake(66, 0, SCREEN_WIDTH - 132, 40);
}

#pragma mark - set相关

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    // 设置弹层高度
    if (dataSource.count < 6) {
        bgHeight = 162.0 + TOOLBAR_HEIGHT;
    } else {
        bgHeight = STRPICKER_HEIGHT + TOOLBAR_HEIGHT;
    }
    // 刷新布局
    [self layoutSelfSubviews];
    [self.strPicker setNeedsLayout];
    // 刷新数据
    [self.strPicker reloadAllComponents];
    // 如果没有设置默认选中，就默认选中第0个元素
    selectedValue = dataSource[0];
    [self.strPicker selectRow:0 inComponent:0 animated:NO];
}

- (void)setDefaultSelIndex:(NSInteger)defaultSelIndex {
    _defaultSelIndex = defaultSelIndex;
    // 默认选择赋值
    selectedValue = [NSString stringWithFormat:@"%@",self.dataSource[defaultSelIndex]];
    [self.strPicker selectRow:defaultSelIndex inComponent:0 animated:NO];
}

- (void)setPickerTitle:(NSString *)pickerTitle {
    _pickerTitle = pickerTitle;
    self.titleLabel.text = pickerTitle;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataSource[row];
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // 滑动选择赋值
    selectedValue = [NSString stringWithFormat:@"%@",self.dataSource[row]];
}

#pragma mark - 按钮相关
/** 点击完成按钮 */
- (void)clickDoneBtn {
    // 回调，把选择的值传出去
    self.resultBlock(selectedValue);
    [self removeSelfFromSupView];
}

/** 点击取消按钮 */
- (void)clickCancelBtn {
    [self removeSelfFromSupView];
}

/** 点击背景释放界面 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeSelfFromSupView];
}

#pragma mark - 显示弹层相关
/** 弹出视图 */
- (void)showPickerView {
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    [[[UIApplication sharedApplication].delegate window] endEditing:YES];
    // 动画出现
    CGRect frame = self.bgView.frame;
    if (frame.origin.y == SCREEN_HEIGHT) {
        frame.origin.y -= bgHeight;
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.frame = frame;
        }];
    }
}

/** 移除视图 */
- (void)removeSelfFromSupView {
    CGRect selfFrame = self.bgView.frame;
    if (selfFrame.origin.y == SCREEN_HEIGHT - bgHeight) {
        selfFrame.origin.y += bgHeight;
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.frame = selfFrame;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end

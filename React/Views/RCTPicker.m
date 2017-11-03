/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTPicker.h"

#import "RCTConvert.h"
#import "RCTUtils.h"

@interface RCTPicker() <UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation RCTPicker

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    _color = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:21]; // TODO: selected title default should be 23.5
    _selectedIndex = NSNotFound;
    _textAlign = NSTextAlignmentCenter;
    self.delegate = self;
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)setItems:(NSArray<NSDictionary *> *)items
{
  _items = [items copy];
  [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
  if (_selectedIndex != selectedIndex) {
    BOOL animated = _selectedIndex != NSNotFound; // Don't animate the initial value
    _selectedIndex = selectedIndex;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self selectRow:selectedIndex inComponent:0 animated:animated];
    });
  }
}

#pragma mark - UIPickerViewDataSource protocol

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView
numberOfRowsInComponent:(__unused NSInteger)component
{
  return _items.count;
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(__unused UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(__unused NSInteger)component
{
  return [RCTConvert NSString:_items[row][@"label"]];
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
  UILabel *label;
  UIImageView *icon;
  if (!view) {
    view = [[UIView alloc] initWithFrame:(CGRect){
      CGPointZero,
      {
        [pickerView rowSizeForComponent:component].width,
        [pickerView rowSizeForComponent:component].height,
      }
    }];
    label = [[UILabel alloc] initWithFrame:(CGRect){
      CGPointZero,
      {
        [pickerView rowSizeForComponent:component].width,
        [pickerView rowSizeForComponent:component].height,
      }
    }];
  }
  else{
    label = [view.subviews objectAtIndex:0];
  }
  
  for (UIView *child in view.subviews) {
    [child removeFromSuperview];
  }
  
  label.font = _font;
  
  label.textColor = [RCTConvert UIColor:_items[row][@"textColor"]] ?: _color;
  
  label.textAlignment = _textAlign;
  label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
  [view addSubview:label];
  
  NSArray *imageSources = _items[row][@"image"];
  if (imageSources != (id)[NSNull null]) {
    if(imageSources.count > 0){
      NSDictionary *source = imageSources[0];
      icon = [[UIImageView alloc] initWithImage:[RCTConvert UIImage:source]];
      CGSize expectedLabelSize = [label.text boundingRectWithSize:label.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size;
      [icon setFrame:CGRectMake(((view.frame.size.width/2) - (expectedLabelSize.width/2) - [source[@"width"] floatValue])-8, ([pickerView rowSizeForComponent:component].height/2) - ([source[@"width"] floatValue]/2) + 3, [source[@"width"] floatValue], [source[@"height"] floatValue])];
      [view addSubview: icon];
    }
  }
  
  return view;
//  return label;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(__unused NSInteger)component
{
  _selectedIndex = row;
  if (_onChange) {
    _onChange(@{
      @"newIndex": @(row),
      @"newValue": RCTNullIfNil(_items[row][@"value"]),
    });
  }
}

@end

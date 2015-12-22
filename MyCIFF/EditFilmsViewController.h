//
//  EditFilmsViewController.h
//  MyCIFF
//
//  Created by Erin McGee on 4/8/14.
//  Copyright (c) 2014 Erin McGee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TodaysFilmsViewController.h"

@interface EditFilmsViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic)          NSArray *introArray;
@property (strong, nonatomic)          NSArray *colorArray;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *introPicker;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *filmComments;
@property (weak, nonatomic) IBOutlet UITextField *filmTitle;
@property (weak, nonatomic) IBOutlet UILabel *theaterColor;
@property (weak, nonatomic) IBOutlet UIPickerView *colorPicker;

@property (strong, nonatomic) PFObject *film;
@property (strong, nonatomic) NSString *controller;

- (IBAction)datePickerDateChanged:(id)sender;

@end

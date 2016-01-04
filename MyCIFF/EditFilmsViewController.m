//
//  EditFilmsViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 4/8/14.
//  Copyright (c) 2014 Erin McGee. All rights reserved.
//

#import "EditFilmsViewController.h"
#import "AllFilmsViewController.h"
#import "TodaysFilmsViewController.h"

@interface EditFilmsViewController ()

@end

@implementation EditFilmsViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datePicker.hidden=true;
    self.colorPicker.delegate = self;
    self.colorPicker.dataSource = self;
    self.colorPicker.hidden=true;
    self.colorArray= @[@"Blue", @"Brown", @"Green",
                       @"Grey", @"Orange", @"Purple", @"Red", @"Yellow"];
    [self.datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YY hh:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:[self.film objectForKey: @"filmDate"]];
    self.filmTitle.text=[self.film objectForKey: @"title"];
    self.dateTimeLabel.text=dateString;
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm a"];
    dateString = [dateFormatter stringFromDate:[self.film objectForKey: @"filmDate"]];
    NSDate *datePickerDate=[dateFormatter dateFromString:dateString];
    [self.datePicker setDate:datePickerDate];
    self.filmComments.text=[self.film objectForKey: @"comments"];
    self.theaterColor.text=[self.film objectForKey:@"theater"];
    self.filmLength.text=[self.film objectForKey:@"filmLength"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches){
        if(touch.view.tag == 2){
            if(self.datePicker.hidden){
                self.datePicker.hidden = false;
                self.colorPicker.hidden = true;
            }
        }else if(touch.view.tag == 3){
            if(self.colorPicker.hidden){
                self.datePicker.hidden = true;
                self.colorPicker.hidden = false;
            }
        }
        else{
            self.datePicker.hidden = true;
            self.colorPicker.hidden = true;
        }
        
        [self.filmTitle resignFirstResponder];
        [self.filmComments resignFirstResponder];
        [self.filmLength resignFirstResponder];
    }
}
- (IBAction)cancelAddFilm:(id)sender {
    
    if([self.controller isEqualToString:@"All"]){
        AllFilmsViewController *allView = [[AllFilmsViewController alloc] initWithNibName:@"AllFilmsViewController" bundle:nil];
        [self presentViewController:allView animated:NO completion:nil];
    }else if([self.controller isEqualToString:@"Today"]){
        TodaysFilmsViewController *allView = [[TodaysFilmsViewController alloc] initWithNibName:@"TodaysFilmsViewController" bundle:nil];
        [self presentViewController:allView animated:NO completion:nil];
    }
}

- (IBAction)editFilm:(id)sender {
    NSString *alertString = @"Data Insertion failed";
    if (self.filmTitle.text.length>0)
    {
        
        if(self.theaterColor.text==nil){
            self.theaterColor.text=@"";
        }
        NSMutableString *filmTitle = [NSMutableString string];
        NSString * secondChar=[self.filmTitle.text substringWithRange:NSMakeRange(1, 2)];
        if([secondChar rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound){
            NSString *previousChar=@" ";
            for (NSInteger i=0; i<self.filmTitle.text.length; i++){
                NSString *ch = [self.filmTitle.text substringWithRange:NSMakeRange(i, 1)];
                if([ch isEqualToString:@" "] || [ch isEqualToString:@"-"] || [ch isEqualToString:@":"] || [ch isEqualToString:@"'"]){
                    [filmTitle appendString:ch];
                }else{
                    if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound && !   [previousChar isEqualToString:@" "]) {
                        [filmTitle appendString:[ch lowercaseString]];
                    }else{
                    [filmTitle appendString:ch];
                    }
                }
                previousChar=ch;
            }
        }else{
            [filmTitle setString:self.filmTitle.text];
        }
        
        self.film[@"title"] = [filmTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.film[@"filmDate"] = self.datePicker.date;
        self.film[@"comments"] = self.filmComments.text;
        self.film[@"theater"] = self.theaterColor.text;
        self.film[@"filmLength"] = self.filmLength.text;
        EKEventStore *store = [[EKEventStore alloc] init];
        EKEvent* event = [store eventWithIdentifier:self.film[@"eventID"]];
        event.title = [NSString stringWithFormat:@"CIFF: %@",[filmTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        event.startDate = self.datePicker.date;
        event.endDate = [self.datePicker.date dateByAddingTimeInterval: (self.filmLength.text.intValue *60)];
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        [self.film saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                                      alertString message:error.description
                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        if([self.controller isEqualToString:@"All"]){
            AllFilmsViewController *allView = [[AllFilmsViewController alloc] initWithNibName:@"AllFilmsViewController" bundle:nil];
            [self presentViewController:allView animated:NO completion:nil];
        }else if([self.controller isEqualToString:@"Today"]){
            TodaysFilmsViewController *allView = [[TodaysFilmsViewController alloc] initWithNibName:@"TodaysFilmsViewController" bundle:nil];
            [self presentViewController:allView animated:NO completion:nil];
        }
        
    }
    else{
        alertString = @"Enter a title and time";
    }
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 8;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
        return [self.colorArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
        self.theaterColor.text=[self.colorArray objectAtIndex:row];
}


- (IBAction)datePickerDateChanged:(id)sender {
    
    NSDate *today1 = self.datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/YYYY' 'hh:mm a"];
    NSString *dateString11 = [dateFormat stringFromDate:today1];
    self.dateTimeLabel.text=dateString11;
}

@end

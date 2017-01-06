//
//  ViewController.m
//  addProduct
//
//  Created by Navpreet Singh on 11/07/16.
//  Copyright © 2016 Navpreet Singh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate,ELCImagePickerControllerDelegate> {
     NSDictionary *categories;
     UIPickerView *categorySelect;
     NSMutableArray *userPickedImages;
     ELCImagePickerController *imagePicker;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    userPickedImages = [[NSMutableArray alloc] init];
    
    self.title = @"ADD PRODUCT";
    
    
    //get Categories web service call
    [webServices sharedInstance].delegate = self;
    [[webServices sharedInstance] getCategories];
    
    categorySelect = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 200, 300, 200)];
    categorySelect.showsSelectionIndicator = YES;
    categorySelect.hidden = NO;
    categorySelect.delegate = self;
    self.cate.inputView = categorySelect;
    
    
    //datePicker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.expDate.inputView = self.datePicker;
}


- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    self.expDate.text = [dateFormatter stringFromDate:datePicker.date];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)responseOfGetRequestFromWebservice:(NSDictionary *)revDict {
    categories = revDict;
}
-(void)responseOfPostRequestFromWebservice:(NSDictionary *)revDict {
    
    
    if ([[revDict objectForKey:@"message"] isEqualToString:@"Success"]) {
        
        [SVProgressHUD showSuccessWithStatus:[revDict objectForKey:@"message"]];
        
        //CLEAR ALL
        userPickedImages = [[NSMutableArray alloc] init];
        self.cate.text = @"";
        self.name.text = @"";
        self.desc.text = @"";
        self.expDate.text = @"";
        
        [self relodeCollection];
    }
    
}


// UIPickerViewDataSource
//Columns in picker views
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}


//Rows in each Column
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    return categories.count;
}

// UIPickerViewDelegate
-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [categories.allValues objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    [self.cate setText:[categories.allValues objectAtIndex:row]];
}

- (IBAction)addImageButtonAction:(id)sender {
    
    imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.imagePickerDelegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (IBAction)addProduct:(id)sender {
    
    if ([self.cate.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please Select Categaory"];
    } else if ([self.name.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please Enter Name"];
    } else if ([self.desc.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please Enter Description"];
    } else if ([self.expDate.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please Select Exp. Date"];
    } else if (!(userPickedImages.count > 0)) {
        [SVProgressHUD showErrorWithStatus:@"Product have atleast one image"];
    } else {
        
        NSString *catid = [categories.allKeys objectAtIndex:[categories.allValues indexOfObject:self.cate.text]];
        NSArray *imags = [userPickedImages copy];
    
        //get Categories web service call
        [webServices sharedInstance].delegate = self;
        [[webServices sharedInstance] postProductWithData:catid productName:self.name.text productDesc:self.desc.text productExp:self.expDate.text images:imags];
        
    }
}

- (IBAction)deletePickedImage:(id)sender {
    
    NSIndexPath *deleteAtIndex = [self.collectionView indexPathForCell:(UICollectionViewCell *)[[(UIButton *)sender superview] superview]];
    [userPickedImages removeObjectAtIndex:deleteAtIndex.row];
    
    [self relodeCollection];
}


#pragma mark:- UIImagePickerDelegate
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Photos Canceled!");
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    if([info count] > 0) {
        for (NSDictionary *imageInfo in info) {
            UIImage *image = [imageInfo valueForKey:UIImagePickerControllerOriginalImage];
            //do anything here
            [userPickedImages addObject:image];
            [self relodeCollection];
        }
    }
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}



-(void)relodeCollection {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

//Uicollection View Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return userPickedImages.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [(UIImageView *)[cell viewWithTag:100] setImage:[userPickedImages objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width/4.1, 100);
}

@end

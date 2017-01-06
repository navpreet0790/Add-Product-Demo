//
//  ViewController.h
//  addProduct
//
//  Created by Navpreet Singh on 11/07/16.
//  Copyright © 2016 Navpreet Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "webServices.h"
#import "SVProgressHUD.h"
#import "ELCImagePickerController.h"


@interface ViewController : UIViewController<webServiceResponce>

//Outlets
@property (weak, nonatomic) IBOutlet UITextField *cate;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *desc;
@property (weak, nonatomic) IBOutlet UITextField *expDate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


//Properties
@property (strong,nonatomic) UIDatePicker *datePicker;


//Actions
- (IBAction)addImageButtonAction:(id)sender;
- (IBAction)addProduct:(id)sender;
- (IBAction)deletePickedImage:(id)sender;

@end


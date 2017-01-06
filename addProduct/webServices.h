//
//  webServices.h
//  addProduct
//
//  Created by Navpreet Singh on 11/07/16.
//  Copyright © 2016 Navpreet Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import <AFNetworking/AFNetworking.h>



@protocol webServiceResponce <NSObject>

-(void)responseOfGetRequestFromWebservice:(NSDictionary *)revDict;
-(void)responseOfPostRequestFromWebservice:(NSDictionary *)revDict;

@end


@interface webServices : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic) id<webServiceResponce> delegate;

-(void)getCategories;
-(void)postProductWithData:(NSString *)cat_id productName:(NSString *)name productDesc:(NSString *)desc productExp:(NSString *)exp images:(NSArray *)imgs;


@end

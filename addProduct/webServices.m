//
//  webServices.m
//  addProduct
//
//  Created by Navpreet Singh on 11/07/16.
//  Copyright © 2016 Navpreet Singh. All rights reserved.
//

#import "webServices.h"

@implementation webServices

+ (instancetype)sharedInstance
{
    static webServices *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[webServices alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}



-(void)getCategories {
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://demo.com/machinetest/product/get_categories"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}




-(void)postProductWithData:(NSString *)cat_id productName:(NSString *)name productDesc:(NSString *)desc productExp:(NSString *)exp images:(NSArray *)imgs {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD show];
    
    
    NSDictionary *params = @{@"category_id"     : cat_id,
                             @"name"            : name,
                             @"desc"            : desc,
                             @"expiry"          : exp };
    
    
    
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    
    // configure the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://demo.com/machinetest/product/save_product"]];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    NSMutableData *httpBody = [NSMutableData data];
    
    
    // add params (all params are strings)
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    for (int i = 0; i < imgs.count; i++) {
        
        UIImage *imageAtIndex = imgs[i];
        
        NSLog(@"%@",[NSString stringWithFormat:@"product_image[%d].jpg",i]);
        
        NSData *renderedJPEGData = UIImageJPEGRepresentation(imageAtIndex, 0.1f);
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [NSString stringWithFormat:@"product_image[%d]",i],[NSString stringWithFormat:@"product_image[%d].jpg",i]] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:renderedJPEGData];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    request.HTTPBody = httpBody;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"error = %@", connectionError);
            [SVProgressHUD showErrorWithStatus:@"Error Occured!"];
            return;
        }
        
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            NSLog(@"Array: %@", json);
            [self.delegate responseOfPostRequestFromWebservice:json];
        }
    }];
}




#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        NSLog(@"Array: %@", json);
    }
    
    [self.delegate responseOfGetRequestFromWebservice:json];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end

//
//  RootViewController.h
//  DropNotes
//
//  Created by Matheus Brum on 04/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBRestClient.h"
#import "DBLoginController.h"
@interface RootViewController : UITableViewController <DBRestClientDelegate,DBSessionDelegate,DBLoginControllerDelegate>{
    DBRestClient *restClient;
    NSMutableArray *superArray;
	NSDateFormatter *formatter;
}
@property (nonatomic,retain)    DBRestClient *restClient;
- (DBRestClient*)restClient ;
-(void)setUpSession;
-(void)resalvarTexto:(NSString *)texto comTitulo:(NSString *)tit noPath:(NSString *)pt;
@end

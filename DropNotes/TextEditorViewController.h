//
//  TextEditorViewController.h
//  DropNotes
//
//  Created by Matheus Brum on 04/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBRestClient.h"

@interface TextEditorViewController : UIViewController {
    NSDictionary *dict;
    IBOutlet UITextView *textV;
}
@property (nonatomic,retain)NSDictionary *dict;
-(void)save;
@end

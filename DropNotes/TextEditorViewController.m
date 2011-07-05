//
//  TextEditorViewController.m
//  DropNotes
//
//  Created by Matheus Brum on 04/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextEditorViewController.h"
#import "RootViewController.h"

@implementation TextEditorViewController
@synthesize dict;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=[dict objectForKey:@"nome"];
    [textV setText:[dict objectForKey:@"texto"]];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(save) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view from its nib.
}
-(void)save{
    NSLog(@"Salvando");
    RootViewController *root=(RootViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [root resalvarTexto:textV.text comTitulo:[dict objectForKey:@"nome"] noPath:[dict objectForKey:@"path"]];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [textV becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self save];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

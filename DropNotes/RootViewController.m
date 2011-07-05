//
//  RootViewController.m
//  DropNotes
//
//  Created by Matheus Brum on 04/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "DropboxSDK.h"
#import "DBMetadata.h"
#import "RootViewController.h"
#import "TextEditorViewController.h"
@implementation RootViewController
@synthesize restClient;
- (void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem *btCancel=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)]autorelease];
    self.navigationItem.leftBarButtonItem=btCancel;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title=@"DropNotes";
    [self.navigationController setToolbarHidden:NO animated:NO];
    UIBarButtonItem *espaco=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]autorelease];
    UIBarButtonItem *btAdd=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd   target:self action:@selector(add)]autorelease];
    self.toolbarItems=[NSArray arrayWithObjects:espaco,btAdd,espaco, nil];
    superArray=[[NSMutableArray alloc]init];
    if (![[DBSession sharedSession] isLinked]) {
        DBLoginController* controller = [[DBLoginController new] autorelease];
		[controller presentFromController:self];	
    }
    [self setUpSession];
    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd MMM yyyy-HH:mm"];
}
-(void)add{
    NSString *nome=[NSString stringWithFormat:@"%@.txt",[formatter stringFromDate:[NSDate date]]];
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[formatter stringFromDate:[NSDate date]]];
    NSString *novoTexto=[NSString stringWithFormat:@"Novo texto"];
    NSError *erro;
    [novoTexto writeToFile:tmpPath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&erro];
    [restClient uploadFile:nome toPath:@"/DropNotes/" fromPath: tmpPath];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
-(void)resalvarTexto:(NSString *)texto comTitulo:(NSString *)tit noPath:(NSString *)pt{
    NSString *titTXT=[NSString stringWithFormat:@"%@.txt",tit];
    NSError *erro;
    [texto writeToFile:pt atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&erro];
    [restClient uploadFile:titTXT toPath:@"/DropNotes/" fromPath:pt];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
-(void)refresh{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [superArray removeAllObjects];
    [restClient loadMetadata:@"/DropNotes/"];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [superArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text= [[[superArray objectAtIndex:indexPath.row]objectForKey:@"nome"]stringByDeletingPathExtension];
    cell.textLabel.numberOfLines=2;
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSString *pathToDelete=[[superArray objectAtIndex:indexPath.row]objectForKey:@"path"];
        [restClient deletePath:pathToDelete];
        [superArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }else if (editingStyle == UITableViewCellEditingStyleInsert){
    }   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *nome= [[superArray objectAtIndex:indexPath.row]objectForKey:@"nome"];
    NSString *pathToDownload=[[superArray objectAtIndex:indexPath.row]objectForKey:@"path"];
    NSString *documentsDirectory = NSTemporaryDirectory();
    NSString *finalSTR=[documentsDirectory stringByAppendingPathComponent:nome];//[NSString stringWithFormat:@"%@/%@",documentsDirectory,nome];
    [restClient loadFile:pathToDownload intoPath:finalSTR];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload{
    [super viewDidUnload];
}
#pragma mark- LoginController
- (void)loginControllerDidLogin:(DBLoginController*)controller{
    [self setUpSession];
}
- (void)loginControllerDidCancel:(DBLoginController*)controller{
}
#pragma mark- Rest Client Delegate
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata;{
    NSArray* validExtensions = [NSArray arrayWithObjects:@"txt", nil];
    NSMutableArray* arrayResposta = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
    	NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
			NSString *nome=[child.path stringByReplacingOccurrencesOfString:@"/DropNotes/" withString:@""];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:child.path,@"path",nome,@"nome",child.humanReadableSize,@"tamanho",nil];
			[arrayResposta addObject:dict];
        }
    }
	[superArray addObjectsFromArray:arrayResposta];
	[self.tableView reloadData];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
	[superArray removeAllObjects];
	[restClient loadMetadata:@"/DropNotes/"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath{
	NSString *documentsDirectory = NSTemporaryDirectory();
	NSString *titulo=[destPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",documentsDirectory] withString:@""];
	titulo=[titulo stringByDeletingPathExtension];
	NSString *texto = [[NSString alloc] initWithContentsOfFile:destPath encoding:NSASCIIStringEncoding error:NULL];
	NSMutableDictionary* newNote = [[NSMutableDictionary alloc] init]; 
	[newNote setValue:texto forKey:@"texto"]; 	
	[newNote setObject:[NSDate date] forKey:@"data"]; 
	[newNote setValue:titulo forKey:@"nome"]; 
	[newNote setValue:destPath forKey:@"path"]; 
	TextEditorViewController *editor=[[[TextEditorViewController alloc]initWithNibName:@"TextEditorViewController" bundle:nil]autorelease];
    editor.dict=newNote;
    [self.navigationController pushViewController:editor animated:YES];
    [newNote autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath{
	[self refresh];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
	DBLoginController* loginController = [[DBLoginController new] autorelease];
	[loginController presentFromController:self.navigationController];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
-(void)setUpSession{
    if (restClient==nil) {
        restClient=[self restClient];
        restClient.delegate = self;
    }
    [restClient  createFolder:@"/DropNotes/"];
    [restClient loadMetadata:@"/DropNotes/"];
}
- (DBRestClient*)restClient {
	if (!restClient) {
		restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
	return restClient;
}
- (void)dealloc
{
    [super dealloc];
}

@end

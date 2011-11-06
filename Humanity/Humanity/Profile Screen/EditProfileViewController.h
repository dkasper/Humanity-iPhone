//
//  EditProfileViewController.h
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *editorTableView;
}

@property (retain, nonatomic) UITableView *editorTableView;

@end

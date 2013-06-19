//
//  EQNewOrderViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/21/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQNewOrderViewController.h"
#import "EQArticleCell.h"
#import "EQEditOrderDetailCell.h"
#import "Articulo.h"
#import "EQImageView.h"

@interface EQNewOrderViewController ()

@property (nonatomic,strong) EQNewOrderViewModel *viewModel;
@property (nonatomic,strong) UIAlertView* cancelOrderAlert;
@property (nonatomic,strong) UIAlertView* saveOrderAlert;

@end

@implementation EQNewOrderViewController

- (id)init {
    self = [super init];
    if (self) {
        self.viewModel = [EQNewOrderViewModel new];
        self.viewModel.delegate = self;
    }
    
    return self;
}

- (id)initWithOrder:(Pedido *)order {
    self = [super init];
    if (self) {
        self.viewModel = [[EQNewOrderViewModel alloc] initWithOrder:order];
        self.viewModel.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    for (UISegmentedControl *control in self.segmentedControls) {
        [control setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor], UITextAttributeTextColor,
          [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
          [UIFont fontWithName:@"Arial" size:11.0], UITextAttributeFont,
          nil]
                               forState:UIControlStateSelected];
        [control setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor grayColor], UITextAttributeTextColor,
          [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
          [UIFont fontWithName:@"Arial" size:11.0], UITextAttributeFont,
          nil]
                               forState:UIControlStateNormal];
    }
    
    [self.tableGroup1 registerClass:[UITableViewCell class] forCellReuseIdentifier:@"group1Cell"];
    [self.tableGroup2 registerClass:[UITableViewCell class] forCellReuseIdentifier:@"group2Cell"];
    
    UINib *nibArticles = [UINib nibWithNibName:@"EQArticleCell" bundle: nil];
    [self.tableGroup3 registerNib:nibArticles forCellReuseIdentifier:@"ArticleCell"];
    
    UINib *nibDetail = [UINib nibWithNibName:@"EQEditOrderDetailCell" bundle: nil];
    [self.tableOrderDetail registerNib:nibDetail forCellReuseIdentifier:@"EditOrderDetailCell"];
    
    [self loadQuantity];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.orderClientLabel.text = self.clientNameLabel.text;
    self.orderLabel.text = self.viewModel.order.identifier ? @"": [self.viewModel.order.identifier stringValue];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy"];
    self.dateLabel.text = [dateFormat stringFromDate:[NSDate date]];
    [self.viewModel loadData];
}

- (IBAction)saveOrder:(id)sender {
    self.saveOrderAlert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:@"¿Desea guardar el pedido?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancelar"
                                           otherButtonTitles:@"Guardar", nil];
    [self.saveOrderAlert show];
}

- (IBAction)cancelOrder:(id)sender {
    self.cancelOrderAlert = [[UIAlertView alloc] initWithTitle:@"Cancelar Pedido"
                                                     message:@"Todo lo cargado se perdera, esta seguro que quiere cancelarlo?"
                                                    delegate:self
                                           cancelButtonTitle:@"Si, cancelarlo"
                                           otherButtonTitles:@"No, seguir cargando", nil];
    [self.cancelOrderAlert show];
}

- (IBAction)segmentStatusChange:(id)sender {
    [self notImplemented];
}

- (IBAction)quantityButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.quantityTextField.text = [NSString stringWithFormat:@"%i",button.tag];
}

- (IBAction)categoryButtonAction:(id)sender {
    NSArray *categories = [NSArray arrayWithObjects:@"Artistica",@"Limpieza", nil];
    EQTablePopover *tablePopover = [[EQTablePopover alloc] initWithData:categories delegate:self];
    [self presentPopoverInView:sender withContent:tablePopover];
}

- (IBAction)saveQuantity:(id)sender {
    [self.viewModel addItemQuantity:[self.quantityTextField.text intValue]];
}

- (IBAction)segmentSortChanged:(id)sender {
    [self notImplemented];
}

- (IBAction)articleDetailButton:(id)sender {
    [self notImplemented];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.tableGroup1]) {
        return [self.viewModel.group1 count];
    } else if ([tableView isEqual:self.tableGroup2]) {
        return [self.viewModel.group2 count];
    } else if ([tableView isEqual:self.tableGroup3]) {
        return [self.viewModel.articles count];
    } else if ([tableView isEqual:self.tableOrderDetail]) {
        return [self.viewModel.items count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.tableGroup1]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group1Cell" forIndexPath:indexPath];
        cell.textLabel.text = [self.viewModel.group1 objectAtIndex:indexPath.row];
        return cell;
    } else if ([tableView isEqual:self.tableGroup2]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group2Cell" forIndexPath:indexPath];
        cell.textLabel.text = [self.viewModel.group2 objectAtIndex:indexPath.row];
        return cell;
    } else if ([tableView isEqual:self.tableGroup3]) {
        EQArticleCell *cell = (EQArticleCell *)[tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
        Articulo *articulo = [self.viewModel.articles objectAtIndex:indexPath.row];
        [cell.articleImage loadURL:articulo.imagenURL];
        cell.codeLabel.text = articulo.codigo;
        cell.nameLabel.text = articulo.nombre;
        return cell;
    } else if ([tableView isEqual:self.tableOrderDetail]) {
        EQEditOrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditOrderDetailCell" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.tableGroup1]) {
        [self.viewModel defineSelectedGroup1:indexPath.row];
    } else if ([tableView isEqual:self.tableGroup2]) {
        [self.viewModel defineSelectedGroup2:indexPath.row];
    } else if ([tableView isEqual:self.tableGroup3]) {
        [self.viewModel defineSelectedArticle:indexPath.row];
        [self loadQuantity];
    } else if ([tableView isEqual:self.tableOrderDetail]) {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.tableGroup1]) {
        return 44;
    } else if ([tableView isEqual:self.tableGroup2]) {
        return 44;
    } else if ([tableView isEqual:self.tableGroup3]) {
        return 123;
    } else if ([tableView isEqual:self.tableOrderDetail]) {
        return 44;
    }
    
    return 44;
}

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    [self.viewModel defineSelectedCategory:selectedData];
    [self.viewModel loadData];
    [self loadQuantity];
    [self.categoryButton setTitle:[NSString stringWithFormat:@"  %@",selectedData] forState:UIControlStateNormal];
    [self closePopover];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:self.cancelOrderAlert]) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if([alertView isEqual:self.saveOrderAlert]){
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.viewModel save];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)modelDidUpdateData{
    self.discountLabel.text = [NSString stringWithFormat:@"%i%% (%i)",[self.viewModel discountPercentage], [self.viewModel discountValue]];
    
    self.subTotalLabel.text = [NSString stringWithFormat:@"$%.2f",[[self.viewModel subTotal] floatValue]];
    self.totalLabel.text = [NSString stringWithFormat:@"%.2f",[self.viewModel total]];
    
    [self.tableGroup1 reloadData];
    [self.tableGroup2 reloadData];
    [self.tableOrderDetail reloadData];
    [super modelDidUpdateData];
}

- (void)loadQuantity{
    int minimum = [self.viewModel.articleSelected.minimoPedido intValue];
    int multiplicity = [self.viewModel.articleSelected.multiploPedido intValue];
    int base = minimum;
    for (int index = 0; [self.quantityButtons count] > index; index++) {
        UIButton *button = self.quantityButtons[index];
        if (self.viewModel.articleSelected) {
            if (index > 0 || base == 0) {
                do {
                    base += multiplicity;
                } while ((base % 2) != 0);
            }
            
            NSString *text = [NSString stringWithFormat:@"%i",base];
            [button setTitle:text forState:UIControlStateNormal];
            button.hidden = NO;
        } else {
            button.hidden = YES;
        }
    }
    
    self.itemsLabel.text = [self.viewModel.itemsQuantity stringValue];
}

- (void)modelDidAddItem{
    [self.tableGroup1 reloadData];
}

- (void)modelAddItemDidFail{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"No se pudo agregar el articulo verifique que la cantidad sea correcta multiplo de 2 y %@ y un minimo de %@",self.viewModel.articleSelected.multiploPedido, self.viewModel.articleSelected.minimoPedido] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

@end

//
//  SubscriptionManager.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/25/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import StoreKit

func requestSubscription(onCompletion : (product : SKProduct) -> ()) {
    
}

//
//#import "BLInAppPurchaseManager.h"
//#import "BLLogging.h"
//#import "SKProduct+LocalizedPrice.h"
//
//@implementation BLInAppPurchaseManager
//
//static NSString *MULTIGAME_KEY = @"king.chase.multi.game";
//
//-(void) requestMultiGameUpgrade:(void (^)(SKProduct *product))onCompletion {
//    BOOL shouldStart = NO;
//    @synchronized(self) {
//        if (multiGameUpgrade == nil) {
//            if (req == nil) {
//                NSSet *productIdentifiers = [NSSet setWithObject:MULTIGAME_KEY];
//                req = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
//                req.delegate = self;
//                afterProductRequest = onCompletion;
//                shouldStart = YES;
//            } else {
//                LINFO(@"Still requesting product. %@", MULTIGAME_KEY);
//            }
//        }
//    }
//    
//    if (shouldStart) {
//        [req start];
//    }
//    
//    onCompletion(multiGameUpgrade);
//}
//
//-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    void (^onCompletion)(BOOL) = ^(BOOL success) {
//        if (success) {
//            // display the thankyou message
//            [self upgradeApp:NO];
//        }
//    };
//    
//    switch(buttonIndex) {
//    case 1:
//        [self purchaseMultiGameUpgrade:onCompletion];
//        break;
//    case 2:
//        [self refreshPurchase:onCompletion];
//        break;
//    }
//}
//
//-(void) upgradeApp:(BOOL) tryingToStartNewGame {
//    if ([self isMultiGameUpgradePurchased]) {
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You!", @"thankyou-title") message:NSLocalizedString(@"Thank you for upgrading! Your support is appreciated.", @"thankyou-prompt") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"ok") otherButtonTitles:nil];
//        [av show];
//    } else {
//        [self requestMultiGameUpgrade:^(SKProduct *product) {
//            UIAlertView *av = nil;
//            NSString *prompt;
//            
//            if (tryingToStartNewGame) {
//            prompt = NSLocalizedString(@"This version of King Chase only allows one active game at a time. To start a new game, please end your current game, or upgrade for unlimited active games.", @"upgrade-prompt-new-game");
//            } else {
//            prompt = NSLocalizedString(@"This version of King Chase only allows one active game at a time. Purchasing this upgrade will allow you to have unlimited active games.", @"upgrade-prompt");
//            }
//            
//            if (product) {
//            NSString *upgradeButtonText = [NSString stringWithFormat:NSLocalizedString(@"Upgrade (%@)",@"upgrade"),product.localizedPrice];
//            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Upgrade", @"upgrade-title") message:prompt delegate:self cancelButtonTitle:NSLocalizedString(@"Don't Upgrade",@"no-upgrade") otherButtonTitles:upgradeButtonText, NSLocalizedString(@"Restore Previous Purchase", @"restore-purchase"), nil];
//            } else {
//            NSString *notAbleToContactAppStore = NSLocalizedString(@"The App Store can not be contacted. Please check your internet connection and try again.", @"upgrade-prompt-not-connected");
//            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Upgrade", @"upgrade-title") message:[NSString stringWithFormat:@"%@\n\n%@", prompt, notAbleToContactAppStore] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"ok") otherButtonTitles:nil];
//            }
//            [av show];
//            }];
//    }
//    }
//    
//    
//    - (void)purchaseMultiGameUpgrade:(void (^)(BOOL))onCompletion {
//        afterTransaction = onCompletion;
//        SKPayment *payment = [SKPayment paymentWithProduct:multiGameUpgrade];
//        [[SKPaymentQueue defaultQueue] addPayment:payment];
//        }
//        
//        - (void)refreshPurchase:(void (^)(BOOL))onCompletion {
//            afterTransaction = onCompletion;
//            
//            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//            }
//            
//            - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
//                NSArray *products = response.products;
//                multiGameUpgrade = [products count] == 1 ? [products firstObject] : nil;
//                if (multiGameUpgrade)
//                {
//                    LINFO(@"Retrieved product with id: %@", MULTIGAME_KEY);
//                    LDBUG(@"Product title: %@" , multiGameUpgrade.localizedTitle);
//                    LDBUG(@"Product description: %@" , multiGameUpgrade.localizedDescription);
//                    LDBUG(@"Product price: %@" , multiGameUpgrade.price);
//                    LDBUG(@"Product id: %@" , multiGameUpgrade.productIdentifier);
//                    afterProductRequest(multiGameUpgrade);
//                } else {
//                    afterProductRequest(nil);
//                }
//                
//                for (NSString *invalidProductId in response.invalidProductIdentifiers)
//                {
//                    LCRIT(@"Invalid product id: %@" , invalidProductId);
//                }
//}
//
//#pragma -
//#pragma Public methods
//
//-(BOOL) isMultiGameUpgradePurchased {
//    return YES;
//    // nobody bought this...just give it to everyone.
//    // return [[NSUserDefaults standardUserDefaults] boolForKey:MULTIGAME_KEY];
//    }
//    
//    //
//    // call this method once on startup, and only if there is something that needs buying
//    //
//    - (void)loadStore
//        {
//            if (![self isMultiGameUpgradePurchased]) {
//                // restarts any purchases if they were interrupted last time the app was open
//                [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//                
//                // get the product description (defined in early sections)
//                [self requestMultiGameUpgrade:^(SKProduct *product) {}];
//            }
//        }
//        
//        //
//        // call this before making a purchase
//        //
//        - (BOOL)canMakePurchases
//            {
//                return [SKPaymentQueue canMakePayments];
//}
//
//#pragma -
//#pragma Purchase helpers
//
////
//// saves a record of the transaction by storing the receipt to disk
////
//- (void)recordTransaction:(SKPaymentTransaction *)transaction
//{
//    if ([transaction.payment.productIdentifier isEqualToString:MULTIGAME_KEY])
//    {
//        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//        [def setValue:transaction.transactionReceipt forKey:@"multiGameTransactionReceipt" ];
//        [def setBool:YES forKey:MULTIGAME_KEY];
//        [def synchronize];
//    }
//}
//
////
//// This allows us to mark a user as upgraded without having to pay.
//-(void) markAsPurchased {
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    [def setValue:@"DevOverridePurchase" forKey:@"multiGameTransactionReceipt" ];
//    [def setBool:YES forKey:MULTIGAME_KEY];
//    [def synchronize];
//    }
//    
//    
//    //
//    // removes the transaction from the queue and posts a notification with the transaction result
//    //
//    - (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
//{
//    // remove the transaction from the payment queue.
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    afterTransaction(wasSuccessful);
//    }
//    
//    //
//    // called when the transaction was successful
//    //
//    - (void)completeTransaction:(SKPaymentTransaction *)transaction
//{
//    [self recordTransaction:transaction];
//    [self finishTransaction:transaction wasSuccessful:YES];
//    }
//    
//    //
//    // called when a transaction has been restored and and successfully completed
//    //
//    - (void)restoreTransaction:(SKPaymentTransaction *)transaction
//{
//    [self recordTransaction:transaction.originalTransaction];
//    [self finishTransaction:transaction wasSuccessful:YES];
//    }
//    
//    //
//    // called when a transaction has failed
//    //
//    - (void)failedTransaction:(SKPaymentTransaction *)transaction
//{
//    if (transaction.error.code != SKErrorPaymentCancelled)
//    {
//        LCRIT(@"Unable to complete purchase: %@", transaction.error);
//        [self finishTransaction:transaction wasSuccessful:NO];
//    }
//    else
//    {
//        // this is fine, the user just cancelled, so don’t notify
//        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    }
//}
//
//#pragma mark -
//#pragma mark SKPaymentTransactionObserver methods
//
//-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
//    LCRIT(@"Restore failed: %@", error.localizedDescription);
//}
//
//-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
//    
//    LINFO(@"Restore completed. %@", queue.transactions);
//    if (queue.transactions.count == 0) {
//        LWARN(@"No transactions returned.", nil);
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Failed", @"restore-failed") message:NSLocalizedString(@"AppStore did not return any prior purchases. Check that you are using the correct account. Please contact king.chase.app@gmail.com if you continue to have problems.",@"contact-support") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles:nil];
//        [av show];
//    }
//    }
//    
//    //
//    // called when the transaction status is updated
//    //
//    - (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
//{
//    for (SKPaymentTransaction *transaction in transactions)
//    {
//        switch (transaction.transactionState)
//        {
//        case SKPaymentTransactionStatePurchased:
//            [self completeTransaction:transaction];
//            break;
//        case SKPaymentTransactionStateFailed:
//            [self failedTransaction:transaction];
//            break;
//        case SKPaymentTransactionStateRestored:
//            [self restoreTransaction:transaction];
//            break;
//        default:
//            break;
//        }
//    }
//}
//
//@end

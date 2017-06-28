//
//  ViewController.m
//  ReactiveCocoaExample_3
//
//  Created by Uber on 27/06/2017.
//  Copyright © 2017 Uber. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

// UI
@property (weak, nonatomic) IBOutlet UITextField *mainTextField;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;

// Data
@property (nonatomic, strong) NSString* username;

@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* passwordConfirmation;

@property (nonatomic, assign) BOOL createEnabled;

@property (nonatomic, strong) NSString* help;

@end

@implementation ViewController

#pragma mark - Helpers methods

- (void) preSetting {
    self.passwordConfirmation = @"12345";
    self.help = @"Here helps";
}



#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self preSetting];
   
    
    /*
    // 1.
    [RACObserve(self, username) subscribeNext:^(NSString* newName) {
        NSLog(@"%@", newName);
    }];
    */
   
    
    // 2.
    [[[[RACObserve(self, username)
          // Вызывает дальнейший блок только три раза.
          // Тоесть вызывается только если у нас равно "joshaber"
          // и только три раза, потом блок уже не трогуют
      distinctUntilChanged] take:3]
   
        // filter - возвращает массив
        // который отвечает какому-либо if`у
    filter:^(NSString* newUsername) {
        return [newUsername isEqualToString:@"joshaber"];
    }]
    subscribeNext:^(id _) {
        NSLog(@"Hi me!");
    }];
    
    
    // 3. Комбинирование сигналов
    [[RACSignal combineLatest:@[RACObserve(self, password),
                               RACObserve(self, passwordConfirmation)]
                        // reduce - возвращает всегда одно значение. Например сумму массива
                      reduce:^id(NSString* currentPassword, NSString* currentConfirmPassword){
                          return @([currentPassword isEqualToString:currentConfirmPassword]);
                      }]
    subscribeNext:^(NSNumber* passwordMathch) {
        self.createEnabled = [passwordMathch boolValue];
    }];
    
    
    // 4. RAC + трансформация
    RAC(self, helpLabel.text) = [[RACObserve(self, help)
                                  filter:^BOOL(NSString *newHelp) {
                                      return newHelp != nil;
                                  }]
                                 map:^(NSString *newHelp) {
                                     return [newHelp uppercaseString];
                                 }];
    
    
    // Записать в тетрадь !
    // 5.
    RACSignal* clientSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        // Тут делаем основные вычисления
        
        [subscriber sendNext:@"hey"]; // вот так отправляем результат
        [subscriber sendNext:@"from"];
        [subscriber sendNext:@"clientSignal"];
        [subscriber sendCompleted]; // говорим что все готово
        return nil;
    }];
    
    
    // подписываемся и обрабатываем различные типы евентов
    
    [clientSignal subscribeNext:^(NSString* newMessage) {
             NSLog(@"clientSignal newMessage = %@",newMessage);
    }error:^(NSError *error) {
        NSLog(@"clientSignal error = %@",error);
    }completed:^{
          NSLog(@"clientSignal completed");
    }];
    
    
    

    // 6.
    RACSignal* sharedSignal = [[RACSignal merge:@[[self fetchUserRepos], [self fetchOrgRepos]]] deliverOn:[RACScheduler scheduler]];
    
    [sharedSignal subscribeCompleted:^{
        NSLog(@"END");
    }];
    
    
    // 7. Сигнал в сигнале
    RACSignal* helloWorld = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"Hello, "];
        [subscriber sendNext:@"world!"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal* joiner = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableArray* strings = [NSMutableArray array];
        
        return [helloWorld subscribeNext:^(NSString* x) {
            [strings addObject:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendNext:[strings componentsJoinedByString:@""]];
            [subscriber sendCompleted];
        }];
    }];
    
    [joiner subscribeNext:^(id x) {
        
    }];
}

#pragma mark - Actions

- (IBAction)usernameAction:(UIButton *)sender
{
    self.username = self.mainTextField.text;
}

- (IBAction)passwordAction:(UIButton *)sender
{
    self.password = self.mainTextField.text;
}

- (IBAction)helpAction:(UIButton *)sender
{
    self.help = self.mainTextField.text;
}

#pragma mark - Reactive methods

- (RACSignal*) fetchUserRepos {
    
   return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       NSInteger count = 0;
       for (int i=0; i<=100; i++) {
           NSLog(@"fetching user repositories...");
           count++;
       }
       [subscriber sendCompleted];
       return nil;
   }];
}

- (RACSignal*) fetchOrgRepos {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        NSInteger count = 0;
        for (int i=0; i<=100; i++) {
            NSLog(@"fetching org repositories...");
            count++;
        }
        [subscriber sendCompleted];
        return nil;
    }];
}



@end

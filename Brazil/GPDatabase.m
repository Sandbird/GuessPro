//
//  GPDatabase.m
//  Brazil
//
//  Created by zhaozilong on 13-10-31.
//
//

#import "GPDatabase.h"
#include <sqlite3.h>
#import "ZZAcquirePath.h"

@interface GPDatabase() {
    sqlite3 *_database;
}

@end

@implementation GPDatabase

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)openBundleDatabaseWithName:(NSString *)dbName {
    NSString *path = [ZZAcquirePath getBundleDirectoryWithFileName:dbName];
    [self openDatabaseIn:path];
}

- (void)openDatabaseIn:(NSString *)dbPath {
    if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
        
        NSAssert(NO, @"Open database failed");
    }
}

- (void)close {
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert(NO, @"Close database failed");
    }
}

- (NSMutableArray *)PuzzleSequenceIsOutOfOrder:(BOOL)isOut groupName:(PuzzleGroup)groupTag {
    
    NSString *sel = nil;
    if (isOut) {
        sel = @"SELECT id FROM pictrue ORDER BY random()";
    } else {
        sel = @"SELECT id FROM pictrue ORDER BY id";
    }

    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询PuzzleSequence信息失败");
    }
    
    NSMutableArray *seqArray = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        [seqArray addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
    }
    sqlite3_finalize(stmt);
    
    return seqArray;
}

- (PuzzleClass *)puzzlesWithGroup:(PuzzleGroup)groupTag indexOfPic:(int)index {
    
    PuzzleClass *pc = nil;
    
    //开始查询
    NSString *sel = nil;
    
    if (IS_KAYAC) {
        sel = [NSString stringWithFormat:@"SELECT PicName, AnswerCN, AnswerJA, AnswerEN, WordNum, GroupName, Hiragana, Position FROM pictrue WHERE id = %d", index];
    } else {
        sel = [NSString stringWithFormat:@"SELECT PicName, AnswerCN, AnswerJA, AnswerEN, WordNum, GroupName, Tips, Information FROM pictrue WHERE id = %d", index];
    }
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询pictrue信息失败");
    }
    
    NSString *picName = nil;
    NSString *answerCN = nil;
    NSString *answerJA = nil;
    NSString *answerEN = nil;
    int wordNum = 0;
    NSString *groupName = nil;
    
    NSString *tips = nil;
    NSString *information = nil;
    
//    NSString *hiragana = @"";
//    NSString *position = nil;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        picName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        picName = [picName stringByAppendingString:@".png"];
        
        answerCN = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
        
//        answerJA = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
//        
//        answerEN = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
        
        wordNum = sqlite3_column_int(stmt, 4);
        
        char *cGroupName = (char *)sqlite3_column_text(stmt, 5);
        if (cGroupName != NULL) {
            groupName = [NSString stringWithUTF8String:cGroupName];
        } else {
            groupName = @"无分类名称";
        }
        
        
        char *cTips = (char *)sqlite3_column_text(stmt, 6);
        if (cTips != NULL) {
            tips = [NSString stringWithUTF8String:cTips];
        } else {
            tips = @"等待添加提示信息...";
        }
        
        
        char *cInfo = (char *)sqlite3_column_text(stmt, 7);
        if (cInfo != NULL) {
            information = [NSString stringWithUTF8String:cInfo];
        } else {
            information = @"等待添加Information...";
        }
        
        
        pc = [PuzzleClass puzzleWithIdKey:index picName:picName answerCN:answerCN JA:answerJA EN:answerEN groupName:groupName wordNum:wordNum];
        
        pc.tips = tips;
        pc.isBuiedTips = NO;
        pc.isBuiedAnswer = NO;
        pc.information = information;
        
        
//        if (IS_KAYAC) {
//            char *cHiragana = (char *)sqlite3_column_text(stmt, 6);
//            if (cHiragana != NULL) {
//                hiragana = [NSString stringWithUTF8String:cHiragana];
//            }
//            
//            position = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
//            pc.Hiragana = hiragana;
//            pc.Position = position;
//        }
        
    }
    sqlite3_finalize(stmt);
    
    //抽取随机文字
    sel = [NSString stringWithFormat:@"SELECT AnswerCN, AnswerJA, AnswerEN FROM pictrue WHERE id != %d ORDER BY RANDOM();", index];
    sqlite3_stmt *stmt_random;
    if (sqlite3_prepare_v2(_database, [sel UTF8String], -1, &stmt_random, nil) != SQLITE_OK) {
        sqlite3_close(_database);
        NSAssert(NO, @"查询pictrue信息失败");
    }

    while (sqlite3_step(stmt_random) == SQLITE_ROW) {
        
        
        NSString *tempCN = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt_random, 0)];
        
        //查重复字
        int length = [tempCN length];
        for (int i = 0; i < length; i++) {
            NSRange range = NSMakeRange(i, 1);
            NSString *aWord = [tempCN substringWithRange:range];
            NSRange wordRange = [answerCN rangeOfString:aWord];
            if (wordRange.location == NSNotFound) {
                answerCN = [answerCN stringByAppendingString:aWord];
                
                if ([answerCN length] >= NUM_OF_WORD_SELECTED) {
                    break;
                }
            }
        }
        
//        answerJA = [NSMutableString stringWithUTF8String:(char *)sqlite3_column_text(stmt_random, 1)];
//        
//        answerEN = [NSMutableString stringWithUTF8String:(char *)sqlite3_column_text(stmt_random, 2)];
    }
    sqlite3_finalize(stmt_random);
    
    pc.wordMixes = [GPDatabase wordMixedWithString:answerCN];
    return pc;
}

+ (NSString *)wordMixedWithString:(NSString *)answer {
    //限定备选字符串只有24个
    int count = [answer length];
    int minus = count - NUM_OF_WORD_SELECTED;
    NSMutableString *newAnswer = [NSMutableString stringWithString:answer];
    if (minus > 0) {
        NSRange range = NSMakeRange(NUM_OF_WORD_SELECTED, minus);
        [newAnswer deleteCharactersInRange:range];
    }
    
    //重新排序字符串
    NSString *mixesWord = @"";
    for (int i = 0; i < NUM_OF_WORD_SELECTED; i++) {
        int num = [GPDatabase randomNumBelow:NUM_OF_WORD_SELECTED - i];
        
        NSString *single = [newAnswer substringWithRange:NSMakeRange(num, 1)];
        
        mixesWord = [mixesWord stringByAppendingString:single];
        
        [newAnswer deleteCharactersInRange:NSMakeRange(num, 1)];
    }
    
    return mixesWord;
}

+ (int)randomNumBelow:(int)low {
    NSAssert(low > 0, @"low不能小于等于0");
    return arc4random() % low;
}

/*
//RSA算法
unsigned long prime1,prime2,ee;

unsigned long *kzojld(unsigned long p,unsigned long q) //扩展欧几里得算法求模逆
{
	unsigned long i=0,a=1,b=0,c=0,d=1,temp,mid,ni[2];
	mid=p;
	while(mid!=1)
	{
		while(p>q)
		{p=p-q;	mid=p;i++;}
        a=c*(-1)*i+a;b=d*(-1)*i+b;
		temp=a;a=c;c=temp;
		temp=b;b=d;d=temp;
		temp=p;p=q;q=temp;
		i=0;
	}
	ni[0]=c;ni[1]=d;
	return(ni);
}

unsigned long momi(unsigned long a,unsigned long b,unsigned long p)     //模幂算法
{
	unsigned long c;
	c=1;
	if(a>p) a=a%p;
	if(b>p) b=b%(p-1);
	while(b!=0)
	{
		while(b%2==0)
        {
            b=b/2;
            a=(a*a)%p;
        }
		b=b-1;
		c=(a*c)%p;
	}
	return(c);
}

void RSAjiami()   //RSA加密函数
{
	unsigned long c1,c2;
	unsigned long m,n,c;
	n=prime1*prime2;
	system("cls");
	printf("Please input the message：\n");
	scanf("%lu",&m);getchar();
	c=momi(m,ee,n);
	printf("The cipher is：%lu",c);
	return;
}

void RSAjiemi()   //RSA解密函数
{
	unsigned long m1,m2,e,d,*ni;
	unsigned long c,n,m,o;
	o=(prime1-1)*(prime2-1);
	n=prime1*prime2;
	system("cls");
	printf("Please input the cipher：\n");
    scanf("%lu",&c);getchar();
	ni=kzojld(ee,o);
	d=ni[0];
	m=momi(c,d,n);
	printf("The original message is：%lu",m);
	return;
}

void main()
{	unsigned long m;
	char cho;
	printf("Please input the two prime you want to use:\n");
	printf("P=");scanf("%lu",&prime1);getchar();
	printf("Q=");scanf("%lu",&prime2);getchar();
	printf("E=");scanf("%lu",&ee);getchar();
	if(prime1<prime2)
	{m=prime1;prime1=prime2;prime2=m;}
	while(1)
	{
        system("cls");
        printf("\t*******RSA密码系统*******\n");
        printf("Please select what do you want to do:\n");
        printf("1.Encrpt.\n");
        printf("2.Decrpt.\n");
        printf("3.Exit.\n");
        printf("Your choice:");
        scanf("%c",&cho);getchar();
        switch(cho)
        {	case '1':RSAjiami();break;
            case '2':RSAjiemi();break;
            case '3':exit(0);
            default:printf("Error input.\n");break;
        }
        getchar();
	}
}
*/


@end

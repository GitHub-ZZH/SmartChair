//
//  BluetoothMessage.m
//  SmartChair
//
//  Created by 张志恒 on 2025/12/1.
//

#import "BluetoothMessage.h"
#import "MyBluetoothManager.h"

@implementation BluetoothMessage

+ (void)sendMessage
{
    
}

+ (void)setSetBackForward
{
    
}

+ (void)setSetBackBackward
{
    
}

+ (void)analysisData:(NSData *)data
{
    if (data.length < 13) {
        NSLog(@"数据错误❎❎❎❎❎❎❎❎❎");
        return;
    }

    
    NSData *content = [data subdataWithRange:NSMakeRange(2, 8)];
    [self parseMotorReply:content];
    
//    const uint8_t *bytes = data.bytes;
//
//    // 头部 2 字节：0x03F3
//    uint16_t header = (bytes[0] << 8) | bytes[1];
//    // 尾部 2 字节：0x0D0A
//    uint16_t tail = (bytes[data.length - 2] << 8) | bytes[data.length - 1];
//
//    if (header == 0x03F3 && tail == 0x0D0A) {
//        NSLog(@"数据校验通过 ✅");
//        
//        [self parseMotorReply:data];
//    } else {
//        NSLog(@"数据校验失败 ❌ header=0x%04X tail=0x%04X", header, tail);
//    }
}
+ (void)parseMotorReply:(NSData *)data {
    if (data.length < 8) {
        NSLog(@"数据长度不足");
        return;
    }

    const Byte *bytes = data.bytes;

    for (int i = 0; i < 4; i++) {

        Byte idAndState = bytes[i * 2];
        Byte position   = bytes[i * 2 + 1];

        Byte state = idAndState & 0x0F;
        Byte motorID   = (idAndState >> 4) & 0x0F;

//        // 如果 ID 为 0，一般认为无效
//        if (motorID == 0) {
//            continue;
//        }

        MotorModel *model = nil;
        for (MotorModel *tempModel in [MyBluetoothManager sharedInstance].allMotorArr) {
            if (tempModel.motorID == motorID) {
                model = tempModel;
                break;
            }
        }
        if (model == nil) {
            model = [[MotorModel alloc] init];
            model.motorID = motorID;
            [[MyBluetoothManager sharedInstance].allMotorArr addObject:model];
        }
        model.status = state;
        model.progress = position;
        
        NSString *str = [NSString stringWithFormat:@"电机ID=%d  状态=%d:%@  位置=%d%%", motorID, state, [MotorModel statusDescription:model.status], position];
        NSLog(@"%@", str);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"update_motor_list" object:nil];
}

+ (NSData *)messageWith:(NSInteger)index pressed:(BOOL)pressed needSave:(BOOL)save
{
    NSData *originalData = [MyBluetoothManager sharedInstance].originalData.copy;
    
    Byte *byte = (Byte *)originalData.bytes;

    // Data1：按键控制
    byte[0] = 0x00;
    
    [self setKey:index pressed:pressed data:byte];
    
    //存储
    NSData *temp = [NSData dataWithBytes:byte length:sizeof(byte)];
    if (save) {
        [[MyBluetoothManager sharedInstance].originalData setData:temp.copy];
    }
    
    NSData *packetData = [self packetMessageWithData:byte];
    
    return packetData;
}

+ (NSData *)messagePositionWith:(NSArray *)positionArr
{
    uint8_t bytes[8] = {0};

    bytes[0] = 0x01;                     // 电机位置控制
    bytes[1] = MIN(positionArr.count, 3);      // 控制数量 0~3

    for (int i = 0; i < bytes[1]; i++) {
        NSDictionary *dict = positionArr[i];
        bytes[2 + i * 2] = [dict[@"motorID"] intValue];
        bytes[3 + i * 2] = [dict[@"progress"] intValue];
    }

    NSData *packetData = [self packetMessageWithData:bytes];
    return packetData;
//    return [NSData dataWithBytes:bytes length:8];
    
//    NSData *originalData = [BluetoothManager sharedInstance].originalData.copy;
    
//    Byte *byte = (Byte *)originalData.bytes;

    // Data1：位置控制
//    byte[0] = 0x01;
    
//    [self setKey:index pressed:pressed data:byte];
    
//    NSData *packetData = [self packetMessageWithData:byte];
    
//    return packetData;
}


+ (NSData *)packetMessageWithData:(Byte *)byteData
{
    NSLog(@"======要发送的数据%s", byteData);
    
    NSMutableData *dataM = [NSMutableData data];
    
    // header1 , 1个字节
    Byte header1[1] = {0x03};
    [dataM appendData:[NSData dataWithBytes:header1 length:sizeof(header1)]];
    // header2 , 1个字节
    Byte header2[1] = {0xF3};
    [dataM appendData:[NSData dataWithBytes:header2 length:sizeof(header2)]];
    
    // data
    [dataM appendData:[NSData dataWithBytes:byteData length:sizeof(byteData)]];
    
    {
        // 计算字节和
        int sum = header1[0] + header2[0];
        for (int i = 0; i < sizeof(byteData); i++) {
            sum += byteData[i];
        }
        
        // check
        Byte checkType[1] = {sum & 0xFF};
        [dataM appendData:[NSData dataWithBytes:checkType length:sizeof(checkType)]];
    }
    
    // end1 , 1个字节
    Byte end1[1] = {0x0D};
    [dataM appendData:[NSData dataWithBytes:end1 length:sizeof(end1)]];
    // end2 , 1个字节
    Byte end2[1] = {0x0A};
    [dataM appendData:[NSData dataWithBytes:end2 length:sizeof(end2)]];
    
    return dataM;
}

#pragma mark - Func
+ (void)setKey:(NSInteger)keyIndex pressed:(BOOL)pressed data:(Byte *)data {
    if (keyIndex < 1) {
        return;
    }
    // keyIndex: 1 ~ 56
    NSInteger zeroIndex = keyIndex - 1;

    NSInteger byteIndex = zeroIndex / 8 + 1; // +1 因为 data[0] 是 Data1
    NSInteger bitIndex  = zeroIndex % 8;

    if (pressed) {
        data[byteIndex] |= (1 << bitIndex);
    } else {
        data[byteIndex] &= ~(1 << bitIndex);
    }
}

+ (void)logCurrentData:(NSData *)data {
    NSMutableString *log = [NSMutableString string];
    Byte *bytes = (Byte *)data.bytes;
    for (int i = 0; i < sizeof(bytes); i++) {
        [log appendFormat:@"DATA%d: 0x%02X\n", i + 1, bytes[i]];
    }
//    Mylog(@"\n%@", log);
}

@end

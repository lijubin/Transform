# Transform
字典转模型，数组转模型。模型中包含模型的转换。（模型中有关键字时 请在前面加_下划线的个数不限制如_id，__id）
带数组的json需要转换的可以通过。定义同名协议来实现自动转换。@property(nonatomic,strong)NSArray<YFReceiptAddress> *receipt_address;指定类型。
//关键字作为成员变量时，在模型中将该字段加下划线就可，如服务器返回的是id，model里面定义_id即可实现转换。
@protocol YFReceiptAddress <NSObject>

@end

@class YFReceiptAddress;

@interface YFUserInfo : NSObject

@property(nonatomic,copy)NSString *userid;//用户id
@property(nonatomic,copy)NSNumber *user_status;//认证状态 是否已经认证 0 未提交 1 审核中 2 已认证
@property(nonatomic,copy)NSString *invoice_status; // 发票状态  0 未提交 1 审核中 2 审核通过 3 审核失败
@property(nonatomic,copy)NSString *address_status; // 地址状态 0 未提交 1 审核中 2 审核通过 3 审核失败
@property(nonatomic,copy)NSString *userinfo_status; // 用户信息状态 0 未提交 1 审核中 2 审核通过 3 审核失败
@property(nonatomic,copy)NSNumber *user_type;//0个人1企业
@property(nonatomic,copy)NSString *username;//用户名
@property(nonatomic,copy)NSString *nickname;//昵称
@property(nonatomic,copy)NSString *phone;//手机号
@property(nonatomic,copy)NSString *headimgurl;//用户头像
@property(nonatomic,copy)NSNumber *need_invoice;//0不开发票 1开发票
@property(nonatomic,copy)NSString *invoice_title;//发票抬头
@property(nonatomic,copy)NSNumber *balance;//账户余额
@property(nonatomic,copy)NSString *coupon;//优惠券
@property(nonatomic,copy)NSNumber *integral;//积分
@property(nonatomic,copy)NSNumber *vip;//用户等级
@property(nonatomic,strong)NSArray<YFReceiptAddress> *receipt_address;//收货地址列表

@end

@interface YFReceiptAddress : NSObject
@property(nonatomic,copy)NSString *_id;//地址id
@property(nonatomic,copy)NSString *consignee;//收货人
@property(nonatomic,copy)NSNumber *region_id;//区域id
@property(nonatomic,copy)NSString *region_name;//区域名称
@property(nonatomic,copy)NSString *address;//详细地址
@property(nonatomic,copy)NSString *_default;//0 非默认地址 1 默认地址
@property(nonatomic,copy)NSString *phone_mob;//手机号
@property(nonatomic,copy)NSString *status; // 0"--审核状态 0待审核 1 审核通过 2 审核失败
@end

//将字典转换为模型。
YFUserInfo *userInfo = [YFUserInfo ljbObjectWithDict:dict];




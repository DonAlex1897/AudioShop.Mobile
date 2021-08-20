class Basket {
  double totalPrice;
  double discount;
  double priceToPay;
  String userId;
  String salespersonCouponCode;
  String otherCouponCode;
  List<int> episodeIds = [];
  int orderType;

  Basket({
    this.totalPrice,
    this.discount,
    this.priceToPay,
    this.userId,
    this.salespersonCouponCode,
    this.otherCouponCode,
    this.orderType,
    this.episodeIds});

}
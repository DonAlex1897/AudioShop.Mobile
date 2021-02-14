class Basket {
  double totalPrice;
  double discount;
  double priceToPay;
  String userId;
  String salespersonCouponCode;
  String otherCouponCode;
  List<int> episodeIds = [];

  Basket({
    this.totalPrice,
    this.discount,
    this.priceToPay,
    this.userId,
    this.salespersonCouponCode,
    this.otherCouponCode,
    this.episodeIds});

}
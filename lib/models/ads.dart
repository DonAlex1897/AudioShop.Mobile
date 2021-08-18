import 'package:flutter/cupertino.dart';

class Ads{
  int id;
  String title;
  String description;
  String link;
  String fileAddress;
  bool isEnabled;

  Ads({
    this.id,
    this.title,
    this.description,
    this.link,
    this.fileAddress,
    this.isEnabled});

  Ads.fromJson(Map<String, dynamic> json, String fileUrl)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        link = json['link'],
        fileAddress = json['file'] != null ?
        fileUrl + json['id'].toString() + '/' + json['file']['fileName'] : '',
        isEnabled = json['isEnabled'];

}
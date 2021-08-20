import 'package:mobile/models/message.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();
  factory Singleton() => _singleton;
  Singleton._internal();
  static Singleton get shared => _singleton;

  List<Message> privateMessages = [];
  List<Message> publicMessages = [];
}
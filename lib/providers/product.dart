import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  bool isFavorite; //not final as it'll be changeable

  Product({
    @required this.id, //named argument need foundation.dart package important
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    //what it does is basically invert value, if we select true turn to false and vice versa so that on click change reflects easily
    isFavorite = !isFavorite;
    notifyListeners(); //kindda like setstate in provider widget
    final url =
        'https://shop-app-68e91-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      // final response = await http.patch(url,
      //     body: json.encode({
      //       'isFavorite': isFavorite,
      final response = await http.put(url,
          body: json.encode(
            isFavorite, //just wanna send the bool value that;s why put and not a whole new value od isFavorite would be sent
          ));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
  // void toggleFavoriteStatus() {
  //   //what it does is basically invert value, if we select true turn to false and vice versa so that on click change reflects easily
  //   isFavorite = !isFavorite;
  //   notifyListeners(); //kindda like setstate in provider widget
  // }
}

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //to convert data into json to send off

class Products with ChangeNotifier {
//Change notifier class is in-built flutter class- related to inherited widget which flutter used behind scene for communication with the help of the context
  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ), */
  ];

  //var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    //if (_showFavoritesOnly == true) {
    // return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [
      ..._items
    ]; //to pass item vals as a list,and also actula value won't be modified until we want to
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  //void showFavoritesOnly() {
  //_showFavoritesOnly = true;
  //notifyListeners();
  /// }

  //void showAll() {
  // _showFavoritesOnly = false;
  // notifyListeners();
  //}
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shop-app-68e91-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title, //keys must march
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,

            //it'll not drop anything already existing but just overwrite
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> fetchAndSetProducts([bool filterByuser = false]) async {
    //making method flexible sqaure brackets to have a optional positional argument setting default, if no val takes default
    final filterString =
        filterByuser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shop-app-68e91-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'; //filtering in firebase special commands
    //for using this method in firebase we need to define the rules: index setup
    //"products":{
    //"".indexOn":["creatorId"]}
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body)
          as Map<String, dynamic>; //to see what response we get
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      url =
          'https://shop-app-68e91-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[prodId] ??
                    false, //double ?? means that if this whole string isn't true then fall back to false, basically if prodId==null in this scenario
            imageUrl: prodData['imageUrl']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

//using await and async instead of then and catch error
  Future<void> addProduct(Product product) async {
    try {
      final url =
          'https://shop-app-68e91-default-rtdb.firebaseio.com/products.json?auth=$authToken';
      final response =
          await http //here return used as http will return future, then .then will give another future overall only the last future value is returned
              .post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          // 'isFavorite': product.isFavorite,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        // id: DateTime.now().toString(),
        id: json.decode(response.body)['name'],
      );
      _items.add(
          newProduct); //adds at the end if I want this to be at the beginning
      //I could use _items.insert(0,newProduct)

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    //invisibly wrapped in then block

    //_items.add(value);
  }

//use future to show something while everything loads
//USING THEN AND CATCHERROR INSTEAD OF ASUNC AND WAIT
  /* Future<void> addProduct(Product product) {
    const url =
        'https://shop-app-68e91-default-rtdb.firebaseio.com/products.json';
    return http //here return used as http will return future, then .then will give another future overall only the last future value is returned
        .post(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite,
      }),
    )
        .then((response) {
      //only run once response is there and not immediately
      //this approach should only be taken if we want to do something with resposnse, in this case like creating an id, that is uniquely generated by the flutter itself which helps in managing data more effectively
      // print(json.decode(response.body)); will show map with name key and contains crypric messafe that dart shows here
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        // id: DateTime.now().toString(),
        id: json.decode(response.body)['name'],
      );
      _items.add(
          newProduct); //adds at the end if I want this to be at the beginning
      //I could use _items.insert(0,newProduct)

      notifyListeners();
    }).catchError((error) {
      print(error); //will prevent the app from crashing
      throw error; //will let us do something with the error
    });
    //_items.add(value);
  } */

  Future<void> deleteProduct(String id) async {
    // statuscode is of http it throws an error and all
    // 200 201 everything worked
    // 300 redirected
    // 400 codes somwthing went wrong
    // 500 kindda same something went wrong
    final url =
        'https://shop-app-68e91-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[
        existingProductIndex]; //to set refrence or pointer to the product that's being deleted

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete error");
    }
    existingProduct = null; //to let dart remove that object in memory

    //optimistic deletion so that we can rollback if our deletion is failed
  }
}

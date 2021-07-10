import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //to register our provider
import './providers/orders.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart'; //where we defined our provider
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products._screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null
                  ? []
                  : previousProducts
                      .items), //for higher version than 3.0.0 we'll use create instead of builder as builder won't work
          //value: Products(),
        ),
        ChangeNotifierProvider(
          builder: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx, auth, previousOrders) => Orders(auth.token,
              auth.userId, previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.redAccent,
          ),
          //home: ProductsOverviewScreen(),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          // : auth.isAuth
                          //     ? ProductsOverviewScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      body: Center(
        child: Text('Let\'s build a shop!'),
      ),
    );
  }
}

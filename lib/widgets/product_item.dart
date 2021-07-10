import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  //final String id;
  //final String title;
  //final String imageUrl;
  //ProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(
      context,
      listen: false,
    );
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
            },
            child: Image.network(product.imageUrl, fit: BoxFit.cover)),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            //as we set listener to false in main build and use consumer here so that we could avoid rebuild of widget again and again when heart is clicked for favorite
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              //to show info-popup whether we sure that we wanna add or not or show info that item added to the cart
              Scaffold.of(context)
                  .hideCurrentSnackBar(); //this helps in preventing the snackbar displaying message move aside when clicked multiple timw within 2 sec
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart!',
                  //textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 2),
                //to tell duration
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              )); //displays at the bottom of the page
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import './product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsdata = Provider.of<Products>(context);
    final products = showFavs ? productsdata.favoriteItems : productsdata.items;
    return GridView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //builder: (c) => products[i], //basically activating litener via id
        value: products[i],
        child: ProductItem(
            //products[i].id,
            //products[i].title,
            //products[i].imageUrl),
            ),
      ),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //amt of cml
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ), //define how grid should be generally structured
    );
  }
}

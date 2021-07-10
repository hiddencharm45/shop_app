import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Orders"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                //error handling stuff
                return Center(
                  child: Text("Something"),
                );
              } else {
                return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, i) =>
                              OrderItem(orderData.orders[i]),
                        ));
              }
            }
          },
        ));
  }
}
//Alternative method
// body: FutureBuilder(
//   future:Provider.of<Orders>(context,listen:flase).fetchandSetOrders(),
//   builder:(ctx,dataSnapshot)=> {
//     if(dataSnapshot.connectionState==ConnectionState.waiting){
//       return Center(CircularProgressIndicator());

//     }
//     else{
//       if(dataSnapshot.error !=null){
//         //do error handling stuff

//       }
//       else{
//         return a Listview widget from above like
//return Consumer<Orders>(builder:(ctx,orderData)=> and then item count and all)
//       }
//     }
//   }//returns widget we wanna build
// )

//Goes into an infinite loop so to prevent that replcing it with the code above
//  void initState() {
//     Future.delayed(Duration.zero).then((_) async {
//       setState(() {
//         _isLoading = true;
//       });
//       await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
//       setState(() {
//         _isLoading = false;
//       });
//     });

//     super.initState();
//   }

//HELPS IN DOING EVERYTHING WITHOUT CONVERTING TO STATEFULL WIDGET

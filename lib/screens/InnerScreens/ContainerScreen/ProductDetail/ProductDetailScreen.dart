import 'package:botaniqmicrogreens/constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../commonViews/CustomToast.dart';
import '../../MainScreen/MainScreenState.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0, // scroll offset (0 = top)
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 5.dp,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Background Image
                        Image.asset(
                          productDetail[0]['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180.dp,
                        ),

                        // Text positioned above bottom
                        Positioned(
                          left: 10.dp,
                          bottom: 10.dp, // 👈 distance from bottom
                          child: objCommonWidgets.customText(
                            context,
                            productDetail[0]['name'],
                            30,
                            objConstantColor.white,
                            objConstantFonts.montserratBold,
                          ),
                        ),

                        Positioned(
                          top: 10.dp,
                          right: 15.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(4.dp),
                              minSize: 35.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                objConstantAssest.wishUnCheckWhite,
                                width: 20.dp,
                              ),
                              onPressed: () {

                              },
                            ),
                          ),
                        ),


                        Positioned(
                          top: 10.dp,
                          left: 15.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(4.dp),
                              minSize: 35.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                objConstantAssest.backIcon,
                                color: objConstantColor.white,
                                width: 25.dp,
                              ),
                              onPressed: () {
                                ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
                                    ScreenName.home);
                              },
                            ),
                          ),
                        )
                      ],
                    ),


                    Padding(
                      padding: EdgeInsets.all(14.dp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.dp),
                          objCommonWidgets.customText(context,
                              productDetail[0]['description'],
                              14.5,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratMedium, textAlign: TextAlign.justify),

                          SizedBox(height: 20.dp),



                          /// Nutrients section
                          objCommonWidgets.customText(context,
                              'Nutritional Benefits',
                              18,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratSemiBold),
                          SizedBox(height: 5.dp),

                          /// Nutrient cards inside wrap
                          Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              for (var n in productDetail[0]['nutrients'])
                                Container(
                                  width: 150.dp,
                                  padding: EdgeInsets.all(14.dp),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18.dp),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// Circle icon background
                                      Container(
                                        padding: EdgeInsets.all(8.dp),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: objConstantColor.navyBlue.withOpacity(0.08),
                                        ),
                                        child: Text(
                                          _getVitaminIcon(n["vitamin"]),
                                          style: TextStyle(fontSize: 20.dp),
                                        ),
                                      ),
                                      SizedBox(height: 10.dp),

                                      /// Vitamin name
                                      Text(
                                        n["vitamin"],
                                        style: TextStyle(
                                          fontSize: 15.dp,
                                          fontWeight: FontWeight.w600,
                                          color: objConstantColor.navyBlue,
                                        ),
                                      ),
                                      SizedBox(height: 6.dp),

                                      /// Benefit text
                                      Text(
                                        n["benefit"],
                                        style: TextStyle(
                                          fontSize: 13.dp,
                                          height: 1.3,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),


                    SizedBox(height: 15.dp),


                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.dp),
                      child: objCommonWidgets.customText(context,
                          'Microgreens',
                          20,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold),
                    ),
                    SizedBox(height: 5.dp),




                    Scrollbar(
                      thumbVisibility: true,
                      child: SizedBox(
                        height: 250.dp, // adjust depending on your product card height
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.dp),
                          scrollDirection: Axis.horizontal, // single row scroll
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 200, // 👈 fixed width for each card
                                child: _buildProductCard(product, index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 15.dp,)



                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: objConstantColor.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.dp, 15.dp, 20.dp, 10.dp),
                child: Row(
                  children: [
                    /// Count Handler
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 7.dp),
                        decoration: BoxDecoration(
                          border: Border.all(color: objConstantColor.navyBlue, width: 1),
                          borderRadius: BorderRadius.circular(5.dp),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              child: Image.asset(
                                objConstantAssest.minusIcon,
                                width: 13.dp,
                                height: 15.dp,
                              ),
                            ),

                            Text(
                              '2',
                              style: TextStyle(
                                fontSize: 20.dp,
                                fontFamily: objConstantFonts.montserratMedium,
                                color: objConstantColor.navyBlue,
                              ),
                            ),

                            CupertinoButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              child: Image.asset(
                                objConstantAssest.addIcon,
                                width: 13.dp,
                                height: 15.dp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12.dp), // 👈 gap between the two

                    /// Add to Cart Button
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 12.dp),
                          decoration: BoxDecoration(
                            color: objConstantColor.navyBlue,
                            borderRadius: BorderRadius.circular(4.dp),
                          ),
                          alignment: Alignment.center,
                          child: objCommonWidgets.customText(
                            context,
                            'Add to Cart',
                            15,
                            objConstantColor.white,
                            objConstantFonts.montserratMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

  }

  /// Helper method for nutrient icons
  String _getVitaminIcon(String vitamin) {
    switch (vitamin) {
      case "Vitamin A":
        return "👁";
      case "Vitamin C":
        return "🍊";
      case "Vitamin K":
        return "🦴";
      case "Folate":
        return "🧬";
      case "Calcium & Magnesium":
        return "🥛";
      case "Iron":
        return "❤️";
      case "Protein":
        return "💪";
      default:
        return "🌱";
    }
  }

  Widget protein(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon or Emoji for Fitness
          const Text(
            "💪",
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 10),

          // Circular progress ring (Protein Strength)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: 45 / 10, // assuming 10g = max reference
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                ),
              ),
              Text(
                "${45.toStringAsFixed(1)} g",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Fitness-focused text
          const Text(
            "Rich in Plant Protein",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Boosts muscle growth, recovery & energy levels.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }



  // 🔹 Table header style
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(10.dp),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.dp,
          color: objConstantColor.white,
          fontFamily: objConstantFonts.montserratMedium
        ),
      ),
    );
  }

  // 🔹 Normal cell style
  Widget _buildCell(String text) {
    return Padding(
      padding: EdgeInsets.all(10.dp),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.dp, color: objConstantColor.navyBlue,
            fontFamily: objConstantFonts.montserratMedium),
      ),
    );
  }



  // ✅ Product Card Widget
  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final GlobalKey sourceKey = GlobalKey(); // 👈 unique key per product heart

    return GestureDetector(
      onTap: (){
        final plant = productDetailsMaster.firstWhere(
              (item) => item["id"] == product['id'],
          orElse: () => {},
        );
        if (plant.isNotEmpty) {
          productDetail = [];
          productDetail.add(plant);
          ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
              ScreenName.productDetail);
        }
        scrollToTop();
      },
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: objConstantColor.navyBlue.withOpacity(0.2)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(5, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Fixed height image
                SizedBox(
                  height: 130.dp,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.dp),
                    child: Stack(
                      children: [
                        // ✅ Background Image
                        Positioned.fill(
                          child: Image.asset(
                            product["image"],
                            fit: BoxFit.cover,
                          ),
                        ),

                        // ✅ Top-right heart button
                        Positioned(
                          top: 6.dp,
                          right: 6.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              key: sourceKey,
                              padding: EdgeInsets.all(4.dp),
                              minSize: 28.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                product["isWish"]
                                    ? objConstantAssest.wishRed
                                    : objConstantAssest.wishUnCheckWhite,
                                width: 15.dp,
                              ),
                              onPressed: () {
                                setState(() {
                                  products[index]["isWish"] = !products[index]["isWish"];
                                  product["isWish"] = products[index]["isWish"];

                                  if (isInWishList(product["id"])){
                                    wishList[index]["isWish"] = products[index]["isWish"];
                                  }else{
                                    wishList.add(products[index]);
                                  }

                                });
                                debugPrint("Favorite clicked for ${product["name"]}");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ✅ Name
                Text(
                  "${product["name"]}",
                  style: TextStyle(
                    color: objConstantColor.black,
                    fontSize: 15.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.dp),
                  child: Row(
                    children: [
                      Text(
                        "₹${product["price"]}/_",
                        style: TextStyle(
                          color: objConstantColor.green,
                          fontSize: 14.dp,
                          fontFamily: ConstantAssests.montserratSemiBold,
                        ),
                      ),
                      SizedBox(width: 3.dp),
                      Text(
                        "₹${product["actualPrice"]}/_",
                        style: TextStyle(
                          color: objConstantColor.gray,
                          fontSize: 14.dp,
                          fontFamily: ConstantAssests.montserratMedium,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: objConstantColor.gray,
                          decorationThickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  "${product["gram"]}",
                  style: TextStyle(
                    color: objConstantColor.navyBlue,
                    fontSize: 14.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                ),

                const Spacer(),

                // ✅ Add to cart button
                SizedBox(
                  height: 35.dp,
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: objConstantColor.navyBlue,
                    borderRadius: BorderRadius.circular(5.dp),
                    child: Text(
                      (!isInCart(product["id"])) ? "Add to Cart" : 'View in Cart',
                      style: TextStyle(
                        color: objConstantColor.white,
                        fontSize: 13.dp,
                        fontFamily: ConstantAssests.montserratSemiBold,
                      ),
                    ),
                    onPressed: () {

                      setState(() {
                        if (!isInCart(product["id"])) {
                          cartList.add(product);
                          CustomToast.show(context, "${product["name"]} added to cart successfully!");
                        } else {
                          CustomToast.show(context, "${product["name"]} have already added in your cart...");
                        }
                      });


                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ Offer label
        Positioned(
            top: 9.dp,
            left: 1.dp,
            child: Container(
              color: objConstantColor.yellow,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 5.dp, top: 1.dp, bottom: 1.dp, right: 10.dp),
                child: Text(
                  "${product["offer"]}% OFF",
                  style: TextStyle(
                    color: objConstantColor.black,
                    fontSize: 12.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                ),
              ),
            ))
      ]),
    );
  }


  bool isInCart(int productID){
    return cartList.any((item) => item["id"] == productID);
  }

  bool isInWishList(int productID){
    return wishList.any((item) => item["id"] == productID);
  }



}
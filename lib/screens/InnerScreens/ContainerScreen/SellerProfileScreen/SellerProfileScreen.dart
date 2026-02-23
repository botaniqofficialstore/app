import 'package:botaniqmicrogreens/Utility/NetworkImageLoader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import 'SellerProfileScreenState.dart';


class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerProfileScreenStateProvider);
    final notifier = ref.read(sellerProfileScreenStateProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // optional
        statusBarIconBrightness: Brightness.dark, // ANDROID → black icons
        statusBarBrightness: Brightness.light, // iOS → black icons
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.dp, vertical: 10.dp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              onPressed: () {
                                Navigator.pop(context);
                              }, child: Icon(Icons.arrow_back_ios_new,
                            color: Colors.black, size: 18.dp,)
                          ),

                          SizedBox(height: 10.dp),
                          Row(
                            children: [

                              ClipOval(
                                child: SizedBox(
                                  width: 90.dp,
                                  height: 90.dp,
                                  child: NetworkImageLoader(
                                    imageUrl: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
                                    placeHolder: objConstantAssest
                                        .placeHolder,
                                    size: 90.dp,
                                    imageSize: 90.dp,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    _StatColumn(label: "Posts", count: "30"),
                                    _StatColumn(
                                        label: "Reviews", count: "4.2k"),
                                    _StatColumn(
                                        label: "Products", count: "5"),
                                  ],
                                ),
                              )
                            ],

                          ),
                          SizedBox(height: 15.dp),
                          objCommonWidgets.customText(
                              context, state.name, 15, Colors.black,
                              objConstantFonts.montserratSemiBold),
                          SizedBox(height: 5.dp),
                          objCommonWidgets.customText(
                              context, state.bio, 10.5, Colors.black,
                              objConstantFonts.montserratRegular,
                              textAlign: TextAlign.justify),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // The Persistent Tab Bar (Instagram Style)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        onTap: (index) => notifier.setTabIndex(index),
                        indicatorColor: Colors.black,
                        indicatorWeight: 1,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on_sharp)),
                          Tab(icon: Icon(Icons.shopping_basket_outlined)),
                          Tab(icon: Icon(Icons.rate_review_outlined)),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _EmptyGrid(message: "No Posts Yet"),
                  _EmptyGrid(message: "No products"),
                  _EmptyGrid(message: "No Reviews"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;
  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        objCommonWidgets.customText(context, count, 16, Colors.black, objConstantFonts.montserratSemiBold),
        objCommonWidgets.customText(context, label, 10, Colors.black.withAlpha(150), objConstantFonts.montserratMedium),
      ],
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  final String message;
  const _EmptyGrid({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// Delegate to keep the TabBar pinned at the top while scrolling
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
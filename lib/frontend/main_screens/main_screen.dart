import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:my_chat/global_uses/constants.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:my_chat/frontend/main_screens/call_log_collection.dart';
import 'package:my_chat/frontend/main_screens/chat_and_Status.dart';
import 'package:my_chat/frontend/main_screens/friends/friends.dart';
import 'package:my_chat/frontend/main_screens/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../../controller/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());
    return Scaffold(
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
        key: controller.bottomNavigationKey,
        color: Theme.of(context).primaryColor,
        index: controller.page.value,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: kWhite,
        onTap: (index) {
          controller.onItemClick(index);
          controller.pageController.jumpToPage(index);
        },
        items: const [

          Icon(
            Icons.chat_rounded,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.contacts_rounded,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.phone_rounded,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.settings_rounded,
            size: 30,
            color: Colors.white,
          ),
        ],
      )),
      backgroundColor: Theme.of(context).backgroundColor,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children: const [
          ChatAndStatusScreen(),
          FriendsScreen(),
          CallLogCollection(),
          SettingsWindow(),
        ],
      ),
    );
  }
}
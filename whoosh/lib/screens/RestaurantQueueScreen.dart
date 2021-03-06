import 'dart:async';

import 'package:flutter/material.dart';

import 'package:whoosh/commons/Commons.dart';
import 'package:whoosh/entity/Group.dart';
import 'package:whoosh/commons/RestaurantCommonWidget.dart';
import 'package:whoosh/entity/Restaurant.dart';
import 'package:whoosh/requests/WhooshService.dart';
import 'package:whoosh/screens/RestaurantSettingsScreen.dart';
import 'package:whoosh/screens/QRCodeScreen.dart';
import 'package:whoosh/screens/RestaurantHeaderBuilder.dart';
import '../commons/QueueingCommonWidget.dart';


class RestaurantQueueScreen extends StatelessWidget {
  final String restaurantName;
  final int restaurantId;

  RestaurantQueueScreen(this.restaurantName, this.restaurantId);

  @override
  Widget build(BuildContext context) {
    var _settingsCallBack = () {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (context) =>
            RestaurantSettingsScreen(restaurantName, restaurantId)
        )
      );
    };

    var _qrCodeCallBack = () {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (context) => QRCodeScreen(restaurantName, restaurantId)
        )
      );
    };

    return Scaffold(
      backgroundColor: Commons.restaurantTheme.backgroundColor,
      body: ListView(
        children: [
          RestaurantHeaderBuilder.generateRestaurantScreenHeader(context, (){},
              _settingsCallBack, _qrCodeCallBack),
          RestaurantQueueCard(restaurantName, restaurantId),
        ],
      ),
    );
  }

}

class RestaurantQueueCard extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  RestaurantQueueCard(this.restaurantName, this.restaurantId);

  @override
  _RestaurantQueueCardState createState() =>
      _RestaurantQueueCardState(restaurantName, restaurantId);
}

class _RestaurantQueueCardState extends State<RestaurantQueueCard> {
  final int restaurantId;
  String restaurantName;
  List<Group> groups = [];
  String iconUrl = "";

  _RestaurantQueueCardState(this.restaurantName, this.restaurantId);

  @override void initState() {
    super.initState();
    fetchRestaurantDetails();
    fetchQueue();
    new Timer.periodic(Duration(milliseconds: 500), (Timer t) => refresh());
  }

  void fetchRestaurantDetails() async {
    dynamic data = await WhooshService.getRestaurantDetails(restaurantId);
    Restaurant currentRestaurant = Restaurant(data);
    if (this.mounted) {
      setState(() {
        restaurantName = currentRestaurant.name;
        iconUrl = currentRestaurant.iconUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20),
          QueueingCommonWidget.generateRestaurantIconAndName(restaurantName,
            iconUrl, Commons.whooshTextWhite),
          RestaurantCommonWidget.generateRestaurantScreenHeading("waitlist"),
          generateQueue(context),
        ]
      )
    );
  }

  Widget generateQueue(BuildContext context) {
    return Column(
      children: groups.map(
        (e) => e.createGroupRestaurantView(restaurantId, restaurantName, context)
      ).toList()
    );
  }

  void fetchQueue() async {
    List<dynamic> data = await WhooshService.getAllGroupsInQueue(restaurantId);
    List<Group> allGroups = data
        .map((data) => Group(data))
        .toList();
    allGroups.sort((a, b) => a.timeOfArrival.compareTo(b.timeOfArrival));
    if (this.mounted) {
      setState(() {
        groups = allGroups;
      });
    }
  }

  Future<bool> refresh() async {
    fetchQueue();
  }

}
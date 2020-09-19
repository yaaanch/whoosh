import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert' show json;

import 'package:whoosh/entity/Group.dart';
import 'package:whoosh/route/route_names.dart';

import '../requests/GetRequestBuilder.dart';

// http://localhost:${port}/#/view-queue?restaurant_id=1
class RestaurantQueueScreen extends StatelessWidget {
  final int restaurantId;
  RestaurantQueueScreen(this.restaurantId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B3148),
      body: ListView(
        children: [
          generateHeader(),
          RestaurantQueueCard(restaurantId),
        ],
      ),
    );
  }

  Widget generateHeader() {
    return AppBar(
      leading: Transform.scale(
        scale: 3,
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: new Image.asset(
            'images/logo.png',
          ),
          tooltip: 'return to homepage',
          onPressed: () {},
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.menu),
        ),
      ],
      backgroundColor: Color(0xFF376ADB),
    );
  }

}

class RestaurantQueueCard extends StatefulWidget {
  final int restaurantId;

  RestaurantQueueCard(this.restaurantId);

  @override
  _RestaurantQueueCardState createState() => _RestaurantQueueCardState(restaurantId);
}

class _RestaurantQueueCardState extends State<RestaurantQueueCard> {
  final int restaurantId;
  String restaurantName;
  List<Group> groups = [];

  _RestaurantQueueCardState(this.restaurantId);

  @override void initState() {
    super.initState();
    fetchRestaurantDetails();
  }

  void fetchRestaurantDetails() async {
    Response response = await GetRequestBuilder()
        .addPath('restaurants')
        .addPath(restaurantId.toString())
        .sendRequest();
    List<dynamic> data = json.decode(response.body);
    String currentRestaurantName = data.single['restaurant_name'];
    if (this.mounted) {
      setState(() {
        restaurantName = currentRestaurantName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children: [
              generateRestaurantHeading(),
              generateWaitListHeading(),
              generateQueue(),
            ]
        )
    );
  }

  Widget generateRestaurantHeading() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            width: 400,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage('images/restaurant_icon.png'),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Container(
                    height: 50,
                    constraints: BoxConstraints(minWidth: 0, maxWidth: 340),
                    child: FittedBox(
                      child: Text(
                        restaurantName ?? 'Loading...',
                        style: TextStyle(
                          color: Color(0xFFEDF6F6),
                          fontSize: 36,
                          fontFamily: "VisbyCF",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget generateWaitListHeading() {
    return Container(
        width: 400,
        margin: const EdgeInsets.all(30.0),
        child: Text(
          'waitlist',
          style: TextStyle(
            color: Color(0xFFEDF6F6),
            fontSize: 40,
            fontFamily: "VisbyCF",
          ),
          textAlign: TextAlign.left,
        )
    );
  }

  Widget generateQueue() {
    fetchQueue();
    return Column(
        children: groups.map(
                (e) => e.createGroupRestaurantView() //TODO: not implemented yet
        ).toList()
    );
  }

  void fetchQueue() async {
    Response response = await GetRequestBuilder()
        .addPath('restaurants')
        .addPath(restaurantId.toString())
        .addPath('groups')
        .addParams('status', '0')
        .sendRequest();
    List<dynamic> data = json.decode(response.body);
    List<Group> allGroups = data
        .where((group) => group['group_size'] <= 5)
        .toList()
        .map((group) => new Group(
        group['group_id'],
        group['group_name'],
        group['group_size'],
        DateTime.parse(group['arrival_time']))
    ).toList();
    allGroups.sort((a, b) => a.timeOfArrival.compareTo(b.timeOfArrival));
    if (this.mounted) {
      setState(() {
        groups = allGroups;
      });
    }
  }

}
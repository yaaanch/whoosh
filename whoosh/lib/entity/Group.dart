import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:whoosh/entity/MonsterFactory.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:whoosh/requests/WhooshService.dart';
import '../requests/PutRequestBuilder.dart';
import '../requests/PostRequestBuilder.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'MonsterType.dart';

class Group {
  int id;
  String name;
  int groupSize;
  DateTime timeOfArrival;
  List<MonsterType> types;

  Group(this.id, this.name, this.groupSize, this.timeOfArrival, this.types);

  Group.fromSize(this.groupSize, this.types) {
    this.id = -1;
    this.name = '';
    this.timeOfArrival = DateTime.now();
  }

  Widget createJoinQueueGroupImage() {
    return generateContainerWithStack(createNewGroupStackElements(), 300);
  }

  Widget createCurrentGroupImage(int noOfGroupsAhead, void Function() refresh, int restaurantId) {
    return generateContainerWithStack(
        createCurrentGroupStackElements(noOfGroupsAhead, refresh, restaurantId), 400
    );
  }

  Widget createOtherGroupImage() {
    return generateContainerWithStack(createOtherGroupStackElements(), 400);
  }

  Widget createGroupRestaurantView(int restaurantId, String restaurantName) {
    return Container(
      margin: EdgeInsets.all(6.0),
      child: Container(
        width: 400,
        height: 75,
        decoration: BoxDecoration( // with rounded corners
            color: Color(0xFFEDF6F6),
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        child: FocusedMenuHolder(
          onPressed: () {
            // do something
          },
          menuWidth: 250,
          blurSize: 4,
          blurBackgroundColor: Color(0xFF2B3148),
          animateMenuItems: false,
          menuBoxDecoration: BoxDecoration(
            color: Color(0xFFEDF6F6),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          menuItems: <FocusedMenuItem> [
            FocusedMenuItem(title: Text(
              'Alert',
              style: TextStyle(
                color: Color(0xFF2B3148),
                fontSize: 20,
                fontFamily: "VisbyCF",
                fontWeight: FontWeight.bold,
              ),
            ), onPressed: () async {
              String textToSent = "Hi! it's your turn! Please proceed to ${restaurantName}.";
              // UNCOMMENT THIS TO TEST SMS
              // await smsGroup(phone_number, textToSent);
            }),
            FocusedMenuItem(title: Text(
              'Confirm Arrival',
              style: TextStyle(
                color: Color(0xFF2B3148),
                fontSize: 20,
                fontFamily: "VisbyCF",
                fontWeight: FontWeight.bold,
              ),
            ), onPressed: () async {
              await changeGroupQueueStatus(1, restaurantId);
              //notifyParent();
            }),
            FocusedMenuItem(title: Text(
              'Kick Out',
              style: TextStyle(
                color: Color(0xFF2B3148),
                fontSize: 20,
                fontFamily: "VisbyCF",
                fontWeight: FontWeight.bold,
              ),
            ), onPressed: () async {
              await changeGroupQueueStatus(2, restaurantId);
              //notifyParent();
            }),
          ],
          child: FlatButton(
            onPressed: () {
              // do something
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeOfArrival.hour.toString().padLeft(2, "0")
                          + ':' + timeOfArrival.minute.toString().padLeft(2, "0"),
                      style: TextStyle(
                        color: Color(0xFF2B3148),
                        fontSize: 25,
                        fontFamily: "VisbyCF",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "91234567", //TODO: change this later
                      style: TextStyle(
                        color: Color(0xFF2B3148),
                        fontSize: 25,
                        fontFamily: "VisbyCF",
                      )
                    )
                  ]
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                            name,
                            style: TextStyle(
                              color: Color(0xFF2B3148),
                              fontSize: 25,
                              fontFamily: "VisbyCF",
                            )
                        ),
                        SizedBox(width: 5),
                        Text(
                            groupSize.toString(),
                            style: TextStyle(
                              color: Color(0xFF2B3148),
                              fontSize: 25,
                              fontFamily: "VisbyCF",
                              fontWeight: FontWeight.bold,
                            )
                        ),
                      ]
                    ),
                    SizedBox(height: 10)
                  ]
                )
              ]
            )
          )
        ),
      )
    );
  }

  Widget generateContainerWithStack(List<Widget> stack, double height) {
    return Container(
        height: height,
        width: 400,
        alignment: Alignment.center,
        child: Stack(
            children: stack
        )
    );
  }
  
  List<Widget> createNewGroupStackElements() {
    return addMonsterStackTo([]);
  }
  
  List<Widget> addMonsterStackTo(List<Widget> currentStack) {
    List<Widget> monsterWidgets = [];
    List<Monster> monsters = [];
    for (int i = 0; i < groupSize; i++) {
      monsters.add(MonsterFactory.getMonsterById(i, types[i]));
    }
    while (monsters.isNotEmpty && monsters.last.id > 2) {
      Monster last = monsters.removeLast();
      monsters.insert(0, last);
    }
    // Add monsters to constrained container
    for (int i = 0; i < groupSize; i++) {
      Monster monster = monsters[i];
      monsterWidgets.add(
          Align(
              alignment: monster.alignment,
              child: Align(
                alignment: monster.alignment,
                child: monster.actor,
              )
          )
      );
    }
    // Add constrained container to main stack
    currentStack.add(
        Align(
            alignment: Alignment.center,
            child: Container(
              width: 200,
              height: 200,
              child: Stack(
                children: monsterWidgets,
              ),
            )
        )
    );
    return currentStack;
  }

  List<Widget> createCurrentGroupStackElements(
      int noOfGroupsAhead, void Function() refresh, int restaurantId) {
    List<Widget> stackElements = [];
    // Add Queue line
    stackElements.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage('images/static/queue_line.png'),
            width: 13,
            height: 400,
          ),
        )
    );
    // Block top half of queue line
    stackElements.add(generateMask(400, 200, Alignment.topCenter));
    stackElements = addMonsterStackTo(stackElements);
    // Add group name bubble
    stackElements.add(
      Align(
        alignment: Alignment.topRight,
          child: Container(
            width: 266,
            height: 160,
            child: Stack(
            alignment: Alignment.topRight,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Image(
                  image: AssetImage('images/static/name_bubble.png')
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 200,
                  height: 110,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Color(0xFFEDF6F6),
                      fontSize: 30,
                      fontFamily: "VisbyCF",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              )
            ],
          )
        ),
      )
    );
    // Add randomize button and no of groups ahead
    stackElements.add(
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 400,
          height: 100,
          child: Stack(
            children: [
              generateMask(400, 50, Alignment(0, 0.4)),
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () async {
                    await randomizeMonsterTypes(restaurantId);
                    refresh();
                  },
                  child: Image(
                    alignment: Alignment.topCenter,
                    image: AssetImage('images/static/randomize_button.png'),
                  ),
                )
              ),
              Align(
                alignment: Alignment(0, 0.4),
                child: Text(
                  noOfGroupsAhead == 0
                      ? 'you\'re next!'
                      : noOfGroupsAhead.toString() + ' groups ahead',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: "VisbyCF",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          )
        ),
      )
    );
    return stackElements;
  }

  dynamic randomizeMonsterTypes(int restaurantId) async {
    types = types.map((e) => MonsterType.generateRandomType()).toList();
    return await updateGroup(restaurantId);
  }

  dynamic updateGroup(int restaurantId) async {
    String monsterTypesString = '';
    types.forEach((element) {
      monsterTypesString += element.toString();
    });
    dynamic response = await WhooshService.updateGroupTypes(id, restaurantId, monsterTypesString);
    return response;
  }

  List<Widget> createOtherGroupStackElements() {
    List<Widget> stackElements = [];
    stackElements.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage('images/static/queue_line.png'),
            width: 13,
            height: 400,
          ),
        )
    );
    return addMonsterStackTo(stackElements);
  }

  Widget generateMask(double width, double height, Alignment align) {
    return Align(
      alignment: align,
      child: Image(
        image: AssetImage('images/static/queue_line_mask.png'),
        width: width,
        height: height,
      ),
    );
  }

  void changeGroupQueueStatus(int statusCode, int restaurantId) async {
    if (statusCode < 0 || statusCode > 2) {
      return;
    }
    Response response = await PutRequestBuilder()
        .addBody(<String, String>{
      "queue_status": statusCode.toString()
    })
        .addPath('restaurants')
        .addPath(restaurantId.toString())
        .addPath('groups')
        .addPath(id.toString())
        .sendRequest();
    dynamic data = jsonDecode(response.body); // use this later
    showToast("Queue status updated successfully!");
  }

  void smsGroup(String phone_number, String text) async {
    Response response = await PostRequestBuilder()
        .addBody(<String, String>{
      "phone_number": phone_number,
      "text": text
    })
        .addPath('sms')
        .sendRequest();
    dynamic data = jsonDecode(response.body); // use this later
    showToast("SMS sent successfully!");
  }

  // TODO: beautify this.
  void showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0
    );
  }

}
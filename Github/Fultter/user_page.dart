import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/Project/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class userPage extends StatefulWidget {
  const userPage({super.key});

  @override
  State<userPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<userPage> {
  @override
  List? rooms;
  List? request;
  List? history;
  int? userID;
  final TextEditingController _reasonController = TextEditingController();

  void showSuccessDialog(BuildContext context, textAlert) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: '$textAlert.',
      btnOkOnPress: () {},
    ).show();
  }

// Error Alert
  void showErrorDialog(BuildContext context, textAlert) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: '$textAlert.',
      btnOkOnPress: () {},
    ).show();
  }

// Question Alert (with Yes/No buttons)
  void showQuestionDialog(BuildContext context, textAlert) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.rightSlide,
      title: 'Are you sure?',
      desc: '$textAlert',
      btnCancelOnPress: () {
        print("Cancel Pressed");
      },
      btnOkOnPress: () {
        print("OK Pressed");
      },
    ).show();
  }

  void rentRoom(slotID, reason) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.rightSlide,
      title: 'Are you sure?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        postRentRoomAPI(slotID, reason);
      },
    ).show();
  }

  Future<void> postRentRoomAPI(int slotID, String reason) async {
    final userID = ModalRoute.of(context)?.settings.arguments as int?;
    // showSuccessDialog(context, '${userID}, ${roomID}');
    try {
      final response = await http.post(
        Uri.parse('http://192.168.2.34:3000/user/rentRoom'),
        body: jsonEncode({
          'userID': userID,
          'slotID': slotID,
          'reason': reason,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          showSuccessDialog(context, response.body.toString());
          getRequestAPI();
        });
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> getRoomAPI() async {
    final userID = ModalRoute.of(context)?.settings.arguments as int?;

    if (userID == null) {
      showErrorDialog(context, "User ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.34:3000/rooms'), // Your API endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms = jsonDecode(response.body); // Update the state with new data
        });
      } else {
        showErrorDialog(context, response.body); // Show error if not 200
      }
    } catch (e) {
      showErrorDialog(context, e.toString()); // Handle exceptions
    }
  }

  Future<void> getRequestAPI() async {
    // showSuccessDialog(context, "getRequestAPI function is called");
    final userID = ModalRoute.of(context)?.settings.arguments as int?;

    if (userID == null) {
      showErrorDialog(context, "User ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://yourserver.com/user/request?userID=$userID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        request = jsonDecode(response.body);
      } else {
        showErrorDialog(context,
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      showErrorDialog(context, "Exception: ${e.toString()}");
    }
  }

  Future<void> getHistoryAPI() async {
    final userID = ModalRoute.of(context)?.settings.arguments as int?;

    if (userID == null) {
      showErrorDialog(context, "User ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://yourserver.com/user/history?userID=$userID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        history = jsonDecode(response.body);
      } else {
        showErrorDialog(context,
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      showErrorDialog(context, "Exception: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRoomAPI();
      getRequestAPI();
      getHistoryAPI();
    });
  }

  Widget build(BuildContext context) {
    userID = ModalRoute.of(context)?.settings.arguments as int;
    DateTime now = DateTime.now(); // Get the current date and time
    Color firstColor = Color.fromARGB(255, 254, 190, 191);
    Color secondColor = Color.fromARGB(255, 87, 150, 225);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          backgroundColor: firstColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.account_circle_rounded,
                      color: Colors.white,
                      shadows: <Shadow>[Shadow(color: Colors.grey, blurRadius: 12.0)],
                      size: 40,
                    ),
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.question,
                        animType: AnimType.rightSlide,
                        title: 'Log out?',
                        btnCancelOnPress: () {
                        },
                        btnOkOnPress: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                      ).show();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: firstColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.home),
                // text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.book),
                // text: 'My request',
              ),
              Tab(
                icon: Icon(Icons.timelapse),
                // text: 'History',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Home
            SafeArea(
              child: Container(
                height: (rooms != null && rooms!.length > 3)
                    ? null
                    : MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: firstColor,
                child: Container(
                  child: rooms != null
                      ? RefreshIndicator(
                          backgroundColor: secondColor,
                          color: firstColor,
                          onRefresh: getRoomAPI,
                          child: ListView.builder(
                            itemCount: rooms?.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Building: ${rooms?[index]["building"]}',
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    )),
                                                Text(
                                                    'Room ID: ${rooms?[index]["roomID"]}',
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    )),
                                                Text(
                                                    rooms?[index][
                                                                "room_time_status"] ==
                                                            "1"
                                                        ? "Status: Available"
                                                        : "Status: Unavailable",
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    )),
                                                Text(
                                                    "Borrow time: ${rooms?[index]["borrow_time"]}",
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    )),
                                                Text(
                                                    "Return date: ${rooms?[index]["return_time"]}",
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    ))
                                              ],
                                            ),
                                            Image.asset(
                                              "assets/clock-tower.jpg",
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            )
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: FilledButton(
                                            onPressed: rooms?[index]
                                                        ["room_time_status"] ==
                                                    "1"
                                                ? () => rentForm(
                                                    rooms?[index]["building"],
                                                    rooms?[index]["roomID"],
                                                    rooms?[index]["slotID"])
                                                : null,
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(rooms?[
                                                                  index][
                                                              "room_time_status"] ==
                                                          "1"
                                                      ? const Color.fromARGB(
                                                          255, 0, 119, 255)
                                                      : secondColor
                                                          .withOpacity(0.3)),
                                            ),
                                            child: const Text(
                                              "Rent",
                                              style: TextStyle(
                                                  fontFamily: 'LilitaOne',
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const Text("No rooms available",
                          style: TextStyle(
                            fontFamily: 'LilitaOne',
                          )),
                ),
              ),
            ),

            // Request
            SafeArea(
              child: RefreshIndicator(
                backgroundColor: secondColor,
                color: firstColor,
                onRefresh: getRequestAPI,
                child: Container(
                  height: (request != null && request!.length > 3)
                      ? null
                      : MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: firstColor,
                  child: request != null
                      ? ListView.builder(
                          itemCount: request?.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID: ${request?[index]["id"]}',
                                                style: const TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  'Building: ${request?[index]["building"]}',
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Text(
                                                  'Room ID: ${request?[index]["roomID"]}',
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Reason: ',
                                                    style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                    ),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        showSuccessDialog(
                                                            context,
                                                            request?[index][
                                                                "request_reason"]),
                                                    child: Text(
                                                      "Show",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'LilitaOne'),
                                                    ),
                                                    style: ButtonStyle(
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(40, 20)),
                                                      padding:
                                                          MaterialStateProperty
                                                              .all(EdgeInsets
                                                                  .zero),
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(secondColor),
                                                      elevation:
                                                          WidgetStateProperty
                                                              .all(3),
                                                      shape: WidgetStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                  "Borrow date: ${request?[index]["borrow_time"]}",
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Text(
                                                  "Return date: ${request?[index]["return_time"]}",
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                            ],
                                          ),
                                          Image.asset(
                                            "assets/clock-tower.jpg",
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No Request available",
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                              ))),
                ),
              ),
            ),

            //history
            SafeArea(
              child: RefreshIndicator(
                backgroundColor: secondColor,
                color: firstColor,
                onRefresh: getHistoryAPI,
                child: Container(
                  height: (history != null && history!.length > 3)
                      ? null
                      : MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: firstColor,
                  child: request != null
                      ? ListView.builder(
                          itemCount: history?.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID: ${history?[index]["id"]}',
                                                style: const TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  'Building: ${history?[index]["building"]}',
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Text(
                                                  'Room ID: ${history?[index]["roomID"]}',
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Row(
                                                children: [
                                                  Text('Reason: ',
                                                      style: TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                      )),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        showSuccessDialog(
                                                            context,
                                                            history?[index][
                                                                "request_reason"]),
                                                    child: Text(
                                                      "Show",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontFamily:
                                                              'LilitaOne',
                                                          color: Colors.white),
                                                    ),
                                                    style: ButtonStyle(
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(40, 20)),
                                                      padding:
                                                          MaterialStateProperty
                                                              .all(EdgeInsets
                                                                  .zero),
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(secondColor),
                                                      elevation:
                                                          WidgetStateProperty
                                                              .all(3),
                                                      shape: WidgetStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                  'Borrow date: ${history?[index]["borrow_time"]}',
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                              Text(
                                                  "Return date: ${history?[index]["return_time"]}",
                                                  style: TextStyle(
                                                    fontFamily: 'LilitaOne',
                                                  )),
                                            ],
                                          ),
                                          Image.asset(
                                            "assets/clock-tower.jpg",
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                          "No History available",
                          style: TextStyle(
                            fontFamily: 'LilitaOne',
                          ),
                        )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future rentForm(building, roomID, slotID) => showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Building: $building Room: $roomID",
                  style: TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reason: ",
                      style: TextStyle(
                        fontFamily: 'LilitaOne',
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _reasonController,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontFamily: 'LilitaOne'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 254, 190, 191),
                          labelText: "Reason",
                          labelStyle: const TextStyle(
                            fontFamily: 'LilitaOne',
                            color: Colors.black45,
                            fontSize: 20,
                          ),
                          hintText: 'Enter your reason',
                          hintStyle: const TextStyle(
                              fontFamily: 'LilitaOne', color: Colors.black54),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.red[300]),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'LilitaOne',
                          )),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.green[300]),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        String reason = _reasonController.text;
                        rentRoom(slotID, reason);
                      },
                      child: Text("Submit",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'LilitaOne',
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_place_picker/utils/uuid.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:uuid/uuid.dart';

class Placesapigoogle extends StatefulWidget {
  Placesapigoogle({
    super.key,
  });

  @override
  State<Placesapigoogle> createState() => _PlacesapigoogleState();
}

class _PlacesapigoogleState extends State<Placesapigoogle> {
  List<dynamic> ListforPlaces = [];
  String tokenForSession = "1234";
  final TextEditingController controller = TextEditingController();
  var uuid = Uuid();

  void makesuggestion(String input) async {
    String googlePlacesApikey = "AIzaSyB0sppwm5PsZzrfHd0n2Pv4nSAz188b_Ls";
    String groundURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$groundURL?input=$input&key=$googlePlacesApikey&sessiontoken=$tokenForSession';

    var responseResult = await http.get(Uri.parse(request));
    var Resultdata = responseResult.body.toString();

    if (responseResult.statusCode == 200) {
      setState(() {
        ListforPlaces =
            jsonDecode(responseResult.body.toString())['predictions'];
      });
    } else {
      throw Exception("Showing data failed");
    }
  }

  void onModify() {
    // ignore: unnecessary_null_comparison
    if (tokenForSession == null) {
      setState(() {
        tokenForSession = uuid.v4();
      });
    }
    makesuggestion(controller.text);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      onModify();
    });
  }

  // void onsendMessage(
  //     double? selectedLAtitude, double? selectedLongtitude) async {
  //   Map<String, dynamic> messages = {
  //     "sendBy": stat.model!.name,
  //     "message": "msg",
  //     "time": FieldValue.serverTimestamp(),
  //     "type": "location",
  //     "name": "",
  //     "duration": "",
  //     "latitude": selectedLAtitude,
  //     "longitude": selectedLongtitude
  //   };
  //   await FirebaseFirestore.instance
  //       .collection('chatroom')
  //       .doc(widget.chatid)
  //       .collection('chats')
  //       .add(messages);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search Place"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(40)),
                      hintText: 'Search here'),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: ListforPlaces.length,
                itemBuilder: ((context, index) {
                  return ListTile(
                    onTap: () async {
                      List<geocoding.Location> locations =
                          await geocoding.locationFromAddress(
                              ListforPlaces[index]['description']);
                      print(locations);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${locations.last.latitude}"),
                          duration:
                              Duration(seconds: 2), // Kitne sec tak dikhana hai
                        ),
                      );
                      LatLng selectedLatLng = LatLng(
                          locations.last.latitude, locations.last.longitude);
                      print(locations.last.longitude);
                      print(locations.last.latitude);
                      // onsendMessage(
                      //     locations.last.latitude, locations.last.longitude);
                      // // ignore: use_build_context_synchronously
                      // Future.delayed(Duration(seconds: 3), () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => ChatScreen(
                      //         name: widget.name,
                      //         chatid: widget.chatid,
                      //       ),
                      //     ),
                      //   );
                      // }
                      // );
                    },
                    title: Text(ListforPlaces[index]['description']),
                  );
                }),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';



void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  //fetches the place by coordinates and returns the coordinates
  void _findPlace(String searchQuery) async {

    final response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=" +
            searchQuery +
            "&fields=formatted_address%2Cgeometry" +
            "&inputtype=textquery" +
            "&key=AIzaSyCy4fPBLa9J_w_QVwGQiCHK9LA0WNUfW5A"));

    var lat, lng;
    if (response.statusCode == 200) {
      final json_body = jsonDecode(response.body);
      print("\n\n\n\n\n\n JSON");
      print(json_body);

      print(json_body);
      lat = json_body["candidates"][0]["geometry"]["location"]["lat"];
      lng = json_body["candidates"][0]["geometry"]["location"]["lng"];

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 18)));
    }

  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
                  appBar: AppBar(
                    title: Text('Walking Buddy'),
                    backgroundColor: Colors.pinkAccent,
                  ),
                  body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: 'Enter a search term'),
                      onSubmitted: _findPlace,
                    ),
                    Container(
                      height: 630,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 11.0,
                        ),
                      ),
                    ),
                  ]),

                  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: Builder(builder: (context) => FloatingActionButton(
                        onPressed: () {
                    print("pressed");
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindingBuddy()),
                    );
                    },
                      child: const Icon(Icons.navigation),
                      backgroundColor: Colors.green,
                    ))
          ,)
      );
  }
}

class FindingBuddy extends StatefulWidget {

  @override
  _FindingBuddyState createState() => _FindingBuddyState();

}

class _FindingBuddyState extends State<FindingBuddy> {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          print("firebase connected successfully");
          print(snapshot.data);
          return GetRequest();
        }

        return Scaffold(
          appBar: AppBar(
          title: Text('Walking Buddy'),
          backgroundColor: Colors.pinkAccent,
          ),
          body: Image.asset("assets/images/Looking_for_a_buddy.png"),
          );
      },
    );
        // Otherwise, show something whilst waiting for initialization to complete
  }
}

class GetRequest extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    CollectionReference requests = FirebaseFirestore.instance.collection("requests");

    return FutureBuilder<DocumentSnapshot>(
      future: requests.doc("Anne").get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return ContactInfo();
          // return Text("Full Name: ${data['destination']}"); // ${data['last_name']}");
        }

        return Text("loading");
      },
    );
  }
}

class ContactInfo extends StatefulWidget {
  @override
  _ContactInfo createState() => _ContactInfo();
}

class _ContactInfo extends State<ContactInfo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Walking Buddy'),
            backgroundColor: Colors.pinkAccent,
          ),
          body: Center(
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(36.0),
                      child: CircleAvatar(
                          backgroundImage: AssetImage("assets/images/be_approachable.jpeg"),
                          radius: 92.0, backgroundColor: Colors.pink[700])),
                  Padding(padding: EdgeInsets.all(36.0),
                      child: Text("Kris", style: TextStyle(fontSize: 46),)) ,
                  Padding(padding: EdgeInsets.all(4.0),
                      child: Text("0412345678",
                        style: TextStyle(fontSize: 28),)
                  ),
                  Padding(padding: EdgeInsets.all(36.0),
                      child: GestureDetector(
                        onTap: () {
                          print("HELP");
                          // launch('https://google.com');
                          launch("tel://000");
                        },
                          child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,)
                        ,
                      )
                      )
                  ),
                ]
              )
          )


        )
    );

  }
}



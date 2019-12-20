import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userlocation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Location',
      home: HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {
  var inloc;
  var location = new Location();
  var locationStream = new Location();
  var userID;
  final databaseReference = Firestore.instance;

  UserLocation _currentLocation;
  callfunction() async {
    var url = 'https://us-central1-oppofintech-261706.cloudfunctions.net/someMethod';
    var httpClient = new HttpClient();


    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      Map userMap = jsonDecode(response.toString());
      var user = Locations.fromJson(userMap);
      print(user);

    } else {

    }

  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return _currentLocation;
  }
  void createRecord() async{
    DocumentReference ref = await databaseReference.collection('Agent_Location').add({
      'lat': _currentLocation.latitude,
      'long': _currentLocation.longitude,
      'user': '',
    });
    userID = ref.documentID;
  }


  void updateRecord() async{
    locationStream.onLocationChanged().listen((LocationData currentLocation) {
      databaseReference
          .collection('Agent_Location')
          .document(userID)
          .updateData({
        'lat' : currentLocation.latitude,
        'long': currentLocation.longitude,
      });

    });

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Locationn Servicees'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Customer'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Agent')
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(50),
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Agent'),
              color: Colors.amber,
              onPressed: (){
                getLocation();
                createRecord();
                updateRecord();
              },
            ),
            RaisedButton(
              child: Text('customer'),
              color: Colors.amber,
              onPressed: callfunction,
            )
          ],
        ),
      ),
    );
  }

}
class Locations {
  int id;
  String name;

  Locations({this.id, this.name});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
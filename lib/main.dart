import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userlocation.dart';

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
        'user': userID
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
        child: RaisedButton(
          child: Text('Begin'),
          color: Colors.amber,

          onPressed: (){
            getLocation();
            createRecord();
            updateRecord();
          },
        ),
      ),
    );
  }

}
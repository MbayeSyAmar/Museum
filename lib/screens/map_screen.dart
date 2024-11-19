import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Ensure this import is used
import 'package:chat_app/screens/coffee_model.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MapController _mapController;
  List<Marker> allMarkers = [];
  late PageController _pageController;
  int prevPage = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Adding markers from coffeeShops list
    coffeeShops.forEach((shop) {
      allMarkers.add(
        Marker(
          point: LatLng(
              shop.locationCoords.latitude, shop.locationCoords.longitude),
          width: 40.0,
          height: 40.0,
             child: GestureDetector(
             onTap: () {
              // When a marker is clicked, move the map to that marker's position
              _mapController.move(
                LatLng(shop.locationCoords.latitude, shop.locationCoords.longitude),
                14.0,
              );

              // Open a small dialog showing the shop details
              _showMarkerDetails(shop);
            },
            child: Icon(
              Icons.museum,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    });

    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      moveCamera();
    }
  }

  _coffeeShopList(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget? widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 125.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
        onTap: () {},
        child: Stack(children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              height: 125.0,
              width: 275.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0.0, 4.0),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Row(children: [
                  Container(
                    height: 90.0,
                    width: 90.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(coffeeShops[index].thumbNail),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coffeeShops[index].shopName,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        coffeeShops[index].petitedescription,
                        style: TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Container(
                      //   width: 20.0,
                      //   child: Text(
                      //     coffeeShops[index].petitedescription,
                      //     style: TextStyle(
                      //       fontSize: 11.0,
                      //       fontWeight: FontWeight.w300,
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(43.300000, 5.400000), // Set the initial center using initialCenter
              initialZoom: 12.0, // Set the initial zoom level using initialZoom
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: allMarkers),
            ],
          ),
          Positioned(
            bottom: 20.0,
            child: Container(
              height: 200.0,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(
                controller: _pageController,
                itemCount: coffeeShops.length,
                itemBuilder: (BuildContext context, int index) {
                  return _coffeeShopList(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void moveCamera() {
    _mapController.move(
      LatLng(coffeeShops[_pageController.page!.toInt()].locationCoords.latitude,
          coffeeShops[_pageController.page!.toInt()].locationCoords.longitude),
      14.0,
    );
  }
   // Function to show the marker details in a dialog
  void _showMarkerDetails(Coffee shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(shop.shopName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Description: ${shop.description}"),
              Text("Localisation: ${shop.address}"),
              SizedBox(height: 10),
              Text("Latitude: ${shop.locationCoords.latitude}"),
              Text("Longitude: ${shop.locationCoords.longitude}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}




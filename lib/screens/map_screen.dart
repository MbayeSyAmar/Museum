import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chat_app/screens/coffee_model.dart';
import 'package:chat_app/screens/page_collection.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  List<Marker> allMarkers = [];
  late PageController _pageController;
  int prevPage = 0;

  // Liste des dates à mettre en surbrillance
  final List<DateTime> highlightedDates = [
    DateTime(2024, 12, 25), // Noël
    DateTime(2024, 1, 1),   // Nouvel An
    DateTime(2024, 7, 14),  // Fête nationale française
  ];

  // Détails des événements liés aux dates surlignées
  final Map<DateTime, String> eventDetails = {
    DateTime(2024, 12, 25): "Noël : fête de famille et cadeaux 🎁",
    DateTime(2024, 1, 1): "Nouvel An : célébrations de la nouvelle année 🎉",
    DateTime(2024, 7, 14): "Fête nationale : feux d'artifice et festivités 🎇",
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Configuration des marqueurs sur la carte
    coffeeShops.forEach((shop) {
      allMarkers.add(
        Marker(
          point: LatLng(
              shop.locationCoords.latitude, shop.locationCoords.longitude),
          width: 40.0,
          height: 40.0,
          child: GestureDetector(
            onTap: () {
              _mapController.move(
                LatLng(shop.locationCoords.latitude, shop.locationCoords.longitude),
                14.0,
              );
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

  // Construit les éléments de la liste des coffee shops
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
                  color: Colors.blue,
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
                          color: Colors.yellow,
                        ),
                      ),
                      Text(
                        coffeeShops[index].petitedescription,
                        style: TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.yellow,
                        ),
                      ),
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
          Positioned(
            top: 0,
            bottom: 70,
            left: 0,
            right: 0,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(43.296482, 5.375354),
                initialZoom: 18.0,
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
          ),
          Positioned(
            bottom: 40.0,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBarCustom(
              onCalendarPressed: _showCalendarPopup, // Lien vers la fonction popup
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
      18,
    );
  }

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

  // Fonction pour afficher le calendrier avec des événements
  void _showCalendarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Calendrier des événements",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TableCalendar(
  firstDay: DateTime(2023),
  lastDay: DateTime(2025),
  focusedDay: DateTime.now(),
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: Colors.orange,
      shape: BoxShape.circle,
    ),
    markerDecoration: BoxDecoration(
      color: Colors.blue, // Couleur des marqueurs
      shape: BoxShape.circle,
    ),
  ),
  calendarBuilders: CalendarBuilders(
    markerBuilder: (context, date, events) {
      if (highlightedDates.any((d) => isSameDay(d, date))) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue, // Couleur des dates surlignées
            ),
          ),
        );
      }
      return null;
    },
  ),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      if (highlightedDates.any((d) => isSameDay(d, selectedDay))) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Événement"),
            content: Text("Détails de l'événement pour cette date."),
            actions: [
              TextButton(
                child: Text("Fermer"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    });
  },
  headerStyle: HeaderStyle(
    formatButtonVisible: false, // Désactive le bouton FormatButton
  ),
),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BottomNavigationBarCustom extends StatelessWidget {
  final VoidCallback onCalendarPressed;

  const BottomNavigationBarCustom({super.key, required this.onCalendarPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white, size: 42),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Collection()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 42),
            onPressed: onCalendarPressed,
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Color(0xFFFFDB3D), size: 42),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

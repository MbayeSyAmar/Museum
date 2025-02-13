// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:chat_app/screens/coffee_model.dart';
// import 'package:chat_app/screens/page_collection.dart';

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   late MapController _mapController;
//   List<Marker> allMarkers = [];
//   late PageController _pageController;
//   int prevPage = 0;

//   final List<DateTime> highlightedDates = [
//     DateTime(2024, 12, 25),
//     DateTime(2024, 1, 1),
//     DateTime(2024, 7, 14),
//   ];

//   final Map<DateTime, String> eventDetails = {
//     DateTime(2024, 12, 25): "Noël : fête de famille et cadeaux 🎁",
//     DateTime(2024, 1, 1): "Nouvel An : célébrations de la nouvelle année 🎉",
//     DateTime(2024, 7, 14): "Fête nationale : feux d'artifice et festivités 🎇",
//   };

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();

//     coffeeShops.forEach((shop) {
//       allMarkers.add(
//         Marker(
//           point: LatLng(
//               shop.locationCoords.latitude, shop.locationCoords.longitude),
//           width: 40.0,
//           height: 40.0,
//           child: GestureDetector(
//             onTap: () {
//               _mapController.move(
//                 LatLng(shop.locationCoords.latitude, shop.locationCoords.longitude),
//                 14.0,
//               );
//               _showMarkerDetails(shop);
//             },
//             child: Icon(
//               Icons.museum,
//               color: Colors.red,
//               size: 40,
//             ),
//           ),
//         ),
//       );
//     });

//     _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
//       ..addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (_pageController.page!.toInt() != prevPage) {
//       prevPage = _pageController.page!.toInt();
//       moveCamera();
//     }
//   }

//   _coffeeShopList(int index) {
//     return AnimatedBuilder(
//       animation: _pageController,
//       builder: (BuildContext context, Widget? widget) {
//         double value = 1;
//         if (_pageController.position.haveDimensions) {
//           value = _pageController.page! - index;
//           value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
//         }
//         return Center(
//           child: SizedBox(
//             height: Curves.easeInOut.transform(value) * 125.0,
//             width: Curves.easeInOut.transform(value) * 350.0,
//             child: widget,
//           ),
//         );
//       },
//       child: InkWell(
//         onTap: () {},
//         child: Stack(children: [
//           Center(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
//               height: 125.0,
//               width: 275.0,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black54,
//                     offset: Offset(0.0, 4.0),
//                     blurRadius: 10.0,
//                   ),
//                 ],
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: Colors.blue,
//                 ),
//                 child: Row(children: [
//                   Container(
//                     height: 90.0,
//                     width: 90.0,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(10.0),
//                         topLeft: Radius.circular(10.0),
//                       ),
//                       image: DecorationImage(
//                         image: NetworkImage(coffeeShops[index].thumbNail),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 5.0),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         coffeeShops[index].shopName,
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.yellow,
//                         ),
//                       ),
//                       Text(
//                         coffeeShops[index].petitedescription,
//                         style: TextStyle(
//                           fontSize: 8.0,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.yellow,
//                         ),
//                       ),
//                     ],
//                   )
//                 ]),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           'Maps',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: <Widget>[
//           Positioned(
//             top: 0,
//             bottom: 70,
//             left: 0,
//             right: 0,
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: LatLng(43.296482, 5.375354),
//                 initialZoom: 18.0,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                 ),
//                 MarkerLayer(markers: allMarkers),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 40.0,
//             child: Container(
//               height: 200.0,
//               width: MediaQuery.of(context).size.width,
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: coffeeShops.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return _coffeeShopList(index);
//                 },
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: BottomNavigationBarCustom(
//               onCalendarPressed: _showCalendarPopup,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void moveCamera() {
//     _mapController.move(
//       LatLng(coffeeShops[_pageController.page!.toInt()].locationCoords.latitude,
//           coffeeShops[_pageController.page!.toInt()].locationCoords.longitude),
//       18,
//     );
//   }

//   void _showMarkerDetails(Coffee shop) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(shop.shopName),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Description: ${shop.description}"),
//               Text("Localisation: ${shop.address}"),
//               SizedBox(height: 10),
//               Text("Latitude: ${shop.locationCoords.latitude}"),
//               Text("Longitude: ${shop.locationCoords.longitude}"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Fermer'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showCalendarPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.deepPurple, Colors.blueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Calendrier des événements",
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TableCalendar(
//                   firstDay: DateTime(2023),
//                   lastDay: DateTime(2025),
//                   focusedDay: DateTime.now(),
//                   calendarStyle: CalendarStyle(
//                     todayDecoration: BoxDecoration(
//                       color: Colors.orange,
//                       shape: BoxShape.circle,
//                     ),
//                     markerDecoration: BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   calendarBuilders: CalendarBuilders(
//                     markerBuilder: (context, date, events) {
//                       if (highlightedDates.any((d) => isSameDay(d, date))) {
//                         return Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         );
//                       }
//                       return null;
//                     },
//                   ),
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       if (highlightedDates.any((d) => isSameDay(d, selectedDay))) {
//                         showDialog(
//                           context: context,
//                           builder: (_) => AlertDialog(
//                             title: Text("Événement"),
//                             content: Text("Détails de l'événement pour cette date."),
//                             actions: [
//                               TextButton(
//                                 child: Text("Fermer"),
//                                 onPressed: () => Navigator.pop(context),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     });
//                   },
//                   headerStyle: HeaderStyle(
//                     formatButtonVisible: false,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class BottomNavigationBarCustom extends StatelessWidget {
//   final VoidCallback onCalendarPressed;

//   const BottomNavigationBarCustom({super.key, required this.onCalendarPressed});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black,
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       height: 70,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.emoji_events, color: Colors.white, size: 42),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => Collection()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 42),
//             onPressed: onCalendarPressed,
//           ),
//           IconButton(
//             icon: const Icon(Icons.map, color: Color(0xFFFFDB3D), size: 42),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MapPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:table_calendar/table_calendar.dart';
import 'coffee_model.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  List<Marker> allMarkers = [];
  late PageController _pageController;
  int prevPage = 0;
  int? selectedCoffeeIndex;


  final List<DateTime> highlightedDates = [
    DateTime(2024, 12, 25),
    DateTime(2024, 1, 1),
    DateTime(2024, 7, 14),
  ];

  final Map<DateTime, String> eventDetails = {
    DateTime(2024, 12, 25): "Noël : fête de famille et cadeaux 🎁",
    DateTime(2024, 1, 1): "Nouvel An : célébrations de la nouvelle année 🎉",
    DateTime(2024, 7, 14): "Fête nationale : feux d'artifice et festivités 🎇",
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    coffeeShops.forEach((shop) {
      allMarkers.add(
        Marker(
          point: LatLng(
              shop.locationCoords.latitude, shop.locationCoords.longitude),
          width: 40.0,
          height: 40.0,
          child: GestureDetector(
            onTap: () {
              // _mapController.move(
              //   LatLng(shop.locationCoords.latitude,
              //       shop.locationCoords.longitude),
              //   14.0,
              // );
              // _showMarkerDetails(shop);
            },
            child: Icon(
              Icons.push_pin,
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
void _onCoffeeShopTap(int index) {
  setState(() {
    _mapController.move(
      LatLng(coffeeShops[index].locationCoords.latitude,
          coffeeShops[index].locationCoords.longitude),
      18,
    );

    selectedCoffeeIndex = index; // Stocke l'index du coffeeShop sélectionné
  });

  // Afficher la boîte de dialogue avec les détails du coffee shop
  _showMarkerDetails(coffeeShops[index]);
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
        onTap: () {_onCoffeeShopTap(index); },
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
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100), // Augmenter la hauteur de l'AppBar
//         child: AppBar(
//           backgroundColor: Colors.teal[900], // Couleur foncée comme sur l'image
//           automaticallyImplyLeading:
//               false, // Enlever le bouton retour par défaut
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//           Text(
//   'CARTE',
//   style: const TextStyle(
//     fontFamily: 'Arcane Nine', // Assurez-vous d'avoir ajouté la police dans pubspec.yaml
//     fontSize: 64, 
//     fontWeight: FontWeight.w400, // 400 correspond à normal
//     height: 1.0, // Normal line-height en Flutter
//     color: Colors.white,
//   ),
// ),

//               SizedBox(height: 4),
//               Text(
//                 '9 musées',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
      body: Stack(
  children: <Widget>[
    // Texte en haut à gauche
    Positioned(
      top: 30,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CARTE',
            style: const TextStyle(
              fontFamily: 'Arcane Nine',
              fontSize: 64,
              fontWeight: FontWeight.w400,
              height: 1.0,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '9 musées',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),

    // La carte descend après "9 musées"
    Positioned(
      top: 120.0, // Décale la carte vers le bas
      left: 0,
      right: 0,
      bottom: 0, // Garde la carte jusqu'en bas
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(43.296482, 5.375354),
          initialZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: allMarkers),
        ],
      ),
    ),

    // Liste en bas
    Positioned(
      bottom: 5.0,
      left: 0,
      right: 0,
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
      18,
    );
  }

  void _showMarkerDetails(Coffee shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: 350, // Réduction de la taille du pop-up
            height: 350, // Réduction de la hauteur
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  top: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      shop.thumbNail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xFF00292A),
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Pull indicator
                Positioned(
                  left: 155, // Ajustement du placement
                  top: 11,
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Color(0xFFFDFDFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Content container
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF00292A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Titre du musée
                        Text(
                          shop.shopName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Description avec ajustement automatique
                        Text(
                          shop.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true, // Permet d'aller à la ligne
                          overflow: TextOverflow.visible, // Évite la coupure
                          maxLines: null, // Permet plusieurs lignes
                        ),
                        SizedBox(height: 15),
                        // Boutons centrés et adaptables
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Wrap(
                            spacing:
                                10, // Espacement horizontal entre les boutons
                            runSpacing:
                                10, // Espacement vertical si les boutons passent en colonne
                            alignment:
                                WrapAlignment.center, // Centre les boutons
                            children: [
                              // Bouton "En savoir plus"
                              InkWell(
                                onTap: () {
                                  // Action ici
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFB7D6DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'En savoir plus',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.035,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              // Bouton "Voir la collection"
                              InkWell(
                                onTap: () {
                                  // Action ici
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF84ECF0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.collections,
                                        color: Color(0xFF39313C),
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Voir la collection',
                                        style: TextStyle(
                                          color: Color(0xFF39313C),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCalendarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      color: Colors.blue,
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
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (highlightedDates
                          .any((d) => isSameDay(d, selectedDay))) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Événement"),
                            content:
                                Text("Détails de l'événement pour cette date."),
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
                    formatButtonVisible: false,
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


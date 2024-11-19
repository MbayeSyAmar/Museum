import 'package:google_maps_flutter/google_maps_flutter.dart';

class Coffee {
  String shopName;
  String address;
  String description;
  String thumbNail;
  String petitedescription;
  LatLng locationCoords;

  Coffee(
      {this.shopName = '',
      this.address = '',
      this.description = '',
      this.thumbNail = '',
      this.petitedescription = 'cliquez sur l\'con pour plus de détails',
      this.locationCoords = const LatLng(43.300000, 5.400000)});
}

final List<Coffee> coffeeShops = [
  Coffee(
      shopName: 'Musée d\'Histoire',
      address: '2 Rue Henri Barbusse, 13001 Marseille',
      description: 'Le Musée d\'Histoire de Marseille retrace l\'histoire de la ville à travers les âges, de l\'Antiquité à nos jours.',
      locationCoords: LatLng(43.296482, 5.375354),
      thumbNail: 'https://lh3.googleusercontent.com/p/AF1QipOefB_d8cVeo9l4goKm9BqAgiNDIQZ1RlgBpOsQ=s680-w680-h510',
      petitedescription: 'cliquez sur l\'con pour plus de détails'
  ),
  Coffee(
      shopName: 'Civilisations de l\'Europe',
      address: '7 Promenade Robert Laffont, 13002 Marseille',
      description: 'Le MuCEM est un musée dédié aux civilisations de la Méditerranée, avec des expositions sur l\'histoire et les cultures de la région.',
      locationCoords: LatLng(43.295669, 5.365373),
      thumbNail: 'https://aemagazine.ma/wp-content/uploads/2021/02/Ricciotti-4.jpg',
       petitedescription: 'cliquez sur l\'con pour plus de détails'
  ),
  Coffee(
      shopName: 'Musée des Beaux-Arts',
      address: 'Place des Moulins, 13001 Marseille',
      description: 'Le Musée des Beaux-Arts de Marseille propose une riche collection de peintures, sculptures et objets d\'art de la Renaissance à nos jours.',
      locationCoords: LatLng(43.296795, 5.374315),
       petitedescription: 'cliquez sur l\'con pour plus de détails',
      thumbNail: 'https://musees.marseille.fr/sites/default/files/styles/listing_no_lazy/public/2020-09/musee%20des%20beaux%20arts-pano.jpg?itok=ZTH8-Yf3'
  ),
  Coffee(
      shopName: 'Musée de la Faïence',
      address: '37 Rue de la République, 13002 Marseille',
      description: 'Un musée consacré à la faïence marseillaise et à l\'histoire de la céramique dans la région.',
      locationCoords: LatLng(43.296143, 5.366029),
       petitedescription: 'cliquez sur l\'con pour plus de détails',
      thumbNail: 'https://upload.wikimedia.org/wikipedia/commons/b/bf/Ch%C3%A2teau_Pastr%C3%A9_%C3%A0_Marseille.JPG'
  ),
  Coffee(
      shopName: 'Château d\'If',
      address: 'Île d\'If, 13007 Marseille',
      description: 'Le Château d\'If, célèbre pour son rôle dans le roman "Le Comte de Monte-Cristo", est une forteresse située sur une île au large de Marseille.',
      locationCoords: LatLng(43.267016, 5.445340),
       petitedescription: 'cliquez sur l\'con pour plus de détails',
      thumbNail: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Monte-Cristo_if_castle_-_marseille_France_by_JM_Rosier.JPG/640px-Monte-Cristo_if_castle_-_marseille_France_by_JM_Rosier.JPG'
  )
];

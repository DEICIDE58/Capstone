class Abtc {
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;

  Abtc({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
}
//temporary ni, wala patay api HAHAHA
final List<Abtc> abtcList = [
  Abtc(
    name: 'Cebu City Health Department',
    address: 'General Maxilom Ave., Extension, Cebu City, 6000 Cebu',
    phone: '(032) 232-6969',

    latitude: 10.3137,
    longitude: 123.8970,
  ),
  Abtc(
    name: 'Rabies Buster - Animal Bite Clinic (Cebu City Branch)',
    address: '18 General Maxilom Ave, Cebu City, 6000 Cebu',
    phone: '(032) 517-6658',

    latitude: 10.3130,
    longitude: 123.8990,
  ),
  Abtc(
    name: 'Vicente Sotto Memorial Medical Center',
    address: 'B. Rodriguez St., Sambag II, Cebu City, 6000 Cebu',
    phone: '(032) 253-9891 to 99',
    latitude: 10.30807,
    longitude: 123.89129,
  ),
];

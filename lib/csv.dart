class GoogleMaps extends StatefulWidget {
  const GoogleMaps({Key? key}) : super(key: key);

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(37.285172, 127.065014);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkersFromCSV();
  }

  Future<void> _loadMarkersFromCSV() async {
    final csvFilePath = "/Users/weiuijong/untitled1/assets/finalcombined.csv";
    final coordinates = await readCoordinatesFromCSV(csvFilePath);
    setState(() {
      _markers.clear();
      for (final coord in coordinates) {
        _markers.add(Marker(
          markerId: MarkerId(coord[2].toString()),
          position: LatLng(double.parse(coord[4]), double.parse(coord[3])),
          infoWindow: InfoWindow(
            title: coord[0].toString(),
            snippet: coord[1].toString(),
          ),
          visible: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }
    });
  }

  Future<List<List<dynamic>>> readCoordinatesFromCSV(String filePath) async {
    final csvFile = File(filePath);
    final csvContent = await csvFile.readAsBytes();
    final List<List<dynamic>> csvData = CsvToListConverter().convert(utf8.decode(csvContent));
    // CSV 데이터의 첫 번째 행(인덱스)을 제거합니다.
    final List<List<dynamic>> coordinates = csvData.sublist(1);
    return coordinates;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _markers,
        ),
      ),
    );
  }
}
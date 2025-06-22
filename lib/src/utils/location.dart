import 'package:location/location.dart';

/// Requests the current location of the device.
/// Returns a [LocationData] object if successful, or null if the location
/// service is not enabled or permission is denied.
Future<LocationData?> determinePosition() async {
  var location = Location();
  if (!await location.serviceEnabled() && !await location.requestService()) {
    return null;
  }

  if (await location.hasPermission() != PermissionStatus.denied &&
      await location.requestPermission() != PermissionStatus.granted) {
    return null;
  }

  var data = await location.getLocation();
  return data;
}

class FaceScanResult {
  final LightingStatus lighting;
  final DistanceStatus distance;
  final String lightingMessage;
  final String distanceMessage;
  final bool isAcceptable;

  const FaceScanResult({
    required this.lighting,
    required this.distance,
    required this.lightingMessage,
    required this.distanceMessage,
    required this.isAcceptable,
  });
}

enum LightingStatus { unknown, tooDark, optimal, tooBright }

enum DistanceStatus { unknown, tooClose, okay, perfect, tooFar }

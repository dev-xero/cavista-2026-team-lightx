import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';

export 'assets.gen.dart';

extension AssetsExtension on String {
  AssetImage get asImageProvider => AssetImage(this);
  CachedNetworkImageProvider get asNetworkImageProvider => CachedNetworkImageProvider(this);
}

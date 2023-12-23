import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

extension ImageTool on ImageProvider {
  Future<Uint8List?> getBytes(
      {ImageByteFormat format = ImageByteFormat.rawRgba}) async {
    final ImageStream imageStream = resolve(ImageConfiguration.empty);

    final Completer<Uint8List?> completer = Completer<Uint8List?>();

    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) async {
        final ByteData? bytes =
            await imageInfo.image.toByteData(format: format);

        if (!completer.isCompleted) {
          completer.complete(bytes?.buffer.asUint8List());
        }
      },
    );

    imageStream.addListener(listener);
    final imageBytes = await completer.future;

    imageStream.removeListener(listener);

    return imageBytes;
  }
}

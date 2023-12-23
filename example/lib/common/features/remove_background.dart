import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:perfumei/common/extensions/image_provider_extension.dart';

class RemoveBackGround {
  ///Para chamar direto por uma classe
  static Future<Uint8List> processarImagem(ImageProvider imageProvider) async {
    final Uint8List? bytes = await imageProvider.getBytes(format: ImageByteFormat.png);

    return removeWhiteBackground(bytes);
  }

//Para tornar possivel criar uma thread
  static Uint8List removeWhiteBackground(Uint8List? bytes) {
    try {
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Parâmetro de byte está vazio');
      }

      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Não foi possível fazer o decode da imagem');
      }

      final croppedImage = img.copyCrop(image, x: 0, y: 0, width: image.width ~/ 1.9, height: image.height);
      final transparentImage = _makeColorTransparent(croppedImage, 249, 249, 249);
      return Uint8List.fromList(img.encodePng(transparentImage!));
    } catch (e) {
      throw Exception('Não foi possível fazer o decode da imagem');
    }
  }

  static img.Image? _makeColorTransparent(img.Image src, int red, int green, int blue) {
    final bytes = src.getBytes();
    for (int i = 0, len = bytes.lengthInBytes; i < len; i += 4) {
      if (bytes[i] > red && bytes[i + 1] > green && bytes[i + 2] > blue) {
        bytes[i + 3] = 0;
      }
    }

    return src;
  }
}

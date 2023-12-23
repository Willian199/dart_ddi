extension MapUtil on Map {
  String mapToQueryString() {
    final List<String> parts = [];

    forEach((key, value) {
      parts.add('$key=$value');
    });

    return parts.join('&');
  }
}

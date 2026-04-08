final class AutoInjectClassLeaf {
  const AutoInjectClassLeaf(this.id);
  final int id;
}

final class AutoInjectClassConfig {
  const AutoInjectClassConfig(this.name);
  final String name;
}

final class AutoInjectClassMiddle {
  const AutoInjectClassMiddle(this.leaf, this.config);
  final AutoInjectClassLeaf leaf;
  final AutoInjectClassConfig config;
}

final class AutoInjectClassRoot {
  const AutoInjectClassRoot(this.middle, this.leaf);
  final AutoInjectClassMiddle middle;
  final AutoInjectClassLeaf leaf;
}

final class AutoInjectFutureLeaf {
  const AutoInjectFutureLeaf(this.id);
  final int id;
}

final class AutoInjectFutureFlag {
  const AutoInjectFutureFlag(this.enabled);
  final bool enabled;
}

final class AutoInjectFutureRoot {
  const AutoInjectFutureRoot(this.leaf, this.flag);
  final AutoInjectFutureLeaf leaf;
  final AutoInjectFutureFlag flag;
}

final class AutoInjectManyA {
  const AutoInjectManyA(this.value);
  final String value;
}

final class AutoInjectManyB {
  const AutoInjectManyB(this.value);
  final int value;
}

final class AutoInjectManyC {
  const AutoInjectManyC(this.value);
  final bool value;
}

final class AutoInjectManyD {
  const AutoInjectManyD(this.value);
  final double value;
}

final class AutoInjectManyRoot {
  const AutoInjectManyRoot(this.a, this.b, this.c, this.d);
  final AutoInjectManyA a;
  final AutoInjectManyB b;
  final AutoInjectManyC c;
  final AutoInjectManyD d;
}

final class AutoInjectManyFutureRoot {
  const AutoInjectManyFutureRoot(this.a, this.b, this.c, this.d);
  final AutoInjectManyA a;
  final AutoInjectManyB b;
  final AutoInjectManyC c;
  final AutoInjectManyD d;
}

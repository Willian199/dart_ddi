final class CustomBuilderApplicationValue {}

final class CustomBuilderSingletonValue {}

final class CustomBuilderDependentValue {}

final class CustomBuilderIsolatedDependency {}

final class CustomBuilderNeedsIsolatedDependency {
  const CustomBuilderNeedsIsolatedDependency(this.dependency);

  final CustomBuilderIsolatedDependency dependency;
}

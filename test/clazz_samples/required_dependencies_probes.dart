class AsyncRequiresProbe {
  const AsyncRequiresProbe();
}

class RequiresReadyStateProbe {
  const RequiresReadyStateProbe(this.dependencyWasReadyWhenCreated);

  final bool dependencyWasReadyWhenCreated;
}

class AsyncDependencyProbe {
  const AsyncDependencyProbe();
}

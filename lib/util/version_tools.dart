class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;
  final int build;

  Version(this.major, this.minor, this.patch, {this.build = 0});

  factory Version.parse(String version) {
    final parts = version.split('.');
    if (parts.length > 4) {
      throw ArgumentError('Invalid version string: $version');
    }
    final major = int.parse(parts[0]);
    final int minor;
    final int patch;
    final int build;
    if (parts.length > 1) {
      minor = int.parse(parts[1]);
    } else {
      minor = 0;
    }
    if (parts.length > 3) {
      patch = int.parse(parts[2]);
      build = int.parse(parts[3]);
    } else if (parts.length > 2) {
      if (parts[2].contains('+')) {
        final patchParts = parts[2].split('+');
        patch = int.parse(patchParts[0]);
        build = int.parse(patchParts[1]);
      } else {
        patch = int.parse(parts[2]);
        build = 0;
      }
    } else {
      patch = 0;
      build = 0;
    }
    return Version(major, minor, patch, build: build);
  }

  @override
  String toString() {
    final parts = [major, minor, patch];
    String buildString = parts.join('.');
    if (build > 0) {
      buildString += '+$build';
    }
    return buildString;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Version &&
          runtimeType == other.runtimeType &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          build == other.build;

  @override
  int get hashCode =>
      major.hashCode ^ minor.hashCode ^ patch.hashCode ^ build.hashCode;

  @override
  int compareTo(Version other) {
    if (major != other.major) {
      return major.compareTo(other.major);
    }
    if (minor != other.minor) {
      return minor.compareTo(other.minor);
    }
    if (patch != other.patch) {
      return patch.compareTo(other.patch);
    }
    return build.compareTo(other.build);
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator >=(Version other) => compareTo(other) >= 0;
}

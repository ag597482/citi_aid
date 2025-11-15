// Stub file for web - File class that will never be instantiated
// This file is only used on web to satisfy conditional imports
// The File class here matches dart:io.File interface but will never be used
class File {
  final String path;
  File(this.path);
  File.fromUri(Uri uri) : path = uri.path;
  // This class should never be used on web - all File operations are guarded by kIsWeb checks
}


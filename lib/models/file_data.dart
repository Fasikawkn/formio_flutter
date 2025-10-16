/// Represents a file attachment with metadata and content.
///
/// Used for file upload components to package file information
/// in a format suitable for Form.io submissions.

class FileData {
  /// The name of the attachment (including extension)
  final String name;

  /// The type of the attachment (typically 'binary')
  final String type;

  /// The attachment data in base64 format
  final String datas;

  /// The file mimetype (e.g., 'image/jpeg', 'application/pdf')
  final String mimetype;

  const FileData({
    required this.name,
    required this.type,
    required this.datas,
    required this.mimetype,
  });

  /// Converts the FileData to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'datas': datas,
      'mimetype': mimetype,
    };
  }

  /// Creates a FileData instance from a JSON map
  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      name: json['name'] as String,
      type: json['type'] as String,
      datas: json['datas'] as String,
      mimetype: json['mimetype'] as String,
    );
  }

  @override
  String toString() {
    return 'FileData(name: $name, type: $type, mimetype: $mimetype, datas: ${datas.substring(0, datas.length > 50 ? 50 : datas.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileData &&
        other.name == name &&
        other.type == type &&
        other.datas == datas &&
        other.mimetype == mimetype;
  }

  @override
  int get hashCode {
    return name.hashCode ^ type.hashCode ^ datas.hashCode ^ mimetype.hashCode;
  }
}

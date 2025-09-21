class Photo {
  final String id;
  final String filePath;
  final String fileName;
  final DateTime dateCreated;
  final int order;

  Photo({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.dateCreated,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'order': order,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      filePath: map['filePath'],
      fileName: map['fileName'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
      order: map['order'],
    );
  }

  Photo copyWith({
    String? id,
    String? filePath,
    String? fileName,
    DateTime? dateCreated,
    int? order,
  }) {
    return Photo(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      dateCreated: dateCreated ?? this.dateCreated,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'Photo(id: $id, fileName: $fileName, dateCreated: $dateCreated, order: $order)';
  }
}

class StorageItem {
  final int? id;
  final String name;
  final String type; // 'storage', 'folder', 'item'
  final int? parentId;

  StorageItem({
    this.id,
    required this.name,
    required this.type,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parentId': parentId,
    };
  }

  factory StorageItem.fromMap(Map<String, dynamic> map) {
    return StorageItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      parentId: map['parentId'],
    );
  }

  StorageItem copyWith({
    int? id,
    String? name,
    String? type,
    int? parentId,
  }) {
    return StorageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/storage_item.dart';
import '../services/database_helper.dart';

class StorageProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<StorageItem> _items = [];
  List<StorageItem> get items => _items;
  
  // Current parent id dictates what we are viewing
  int? _currentParentId;
  int? get currentParentId => _currentParentId;

  Future<void> loadItems(int? parentId) async {
    _currentParentId = parentId;
    _items = await _dbHelper.getItemsByParentId(parentId);
    notifyListeners();
  }

  Future<void> addItem(String name, String type) async {
    final newItem = StorageItem(
      name: name,
      type: type,
      parentId: _currentParentId,
    );
    await _dbHelper.insertItem(newItem);
    await loadItems(_currentParentId); // reload current view
  }

  Future<void> updateItemName(StorageItem item, String newName) async {
    final updated = item.copyWith(name: newName);
    await _dbHelper.updateItem(updated);
    await loadItems(_currentParentId);
  }

  Future<void> deleteItem(StorageItem item) async {
    if (item.id != null) {
      await _dbHelper.deleteItemAndChildren(item.id!);
      await loadItems(_currentParentId);
    }
  }

  // Moving an item visually means changing its parentId
  Future<void> moveItem(StorageItem item, int? newParentId) async {
    if (item.id != null) {
       final updated = item.copyWith(parentId: newParentId);
       await _dbHelper.updateItem(updated);
       await loadItems(_currentParentId); // Refresh Current View (item will disappear)
    }
  }

  Future<List<StorageItem>> getFolders(int? parentId, StorageItem excludeItem) async {
     final items = await _dbHelper.getItemsByParentId(parentId);
     // Filter out the item to prevent cycles/moving into itself, and only return storages/folders
     return items.where((i) => i.id != excludeItem.id && i.type != 'item').toList();
  }

  Future<List<StorageItem>> searchItems(String query) async {
     return await _dbHelper.searchItems(query);
  }

  Future<String> getItemPath(StorageItem item) async {
     List<String> pathNames = [item.name];
     int? currentParentId = item.parentId;
     
     while (currentParentId != null) {
       final parent = await _dbHelper.getItemById(currentParentId);
       if (parent != null) {
          pathNames.insert(0, parent.name);
          currentParentId = parent.parentId;
       } else {
          break;
       }
     }
     return pathNames.join(' / ');
  }

  Future<StorageItem?> getItemById(int id) async {
     return await _dbHelper.getItemById(id);
  }
}

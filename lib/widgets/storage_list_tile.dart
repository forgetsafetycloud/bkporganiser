import 'package:flutter/material.dart';
import '../models/storage_item.dart';

class StorageListTile extends StatelessWidget {
  final StorageItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onMove;

  const StorageListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.onMove,
  });

  IconData _getIcon() {
    switch (item.type) {
      case 'storage':
        return Icons.sd_storage;
      case 'folder':
        return Icons.folder;
      case 'item':
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getIconColor() {
     switch (item.type) {
      case 'storage':
        return const Color(0xFFFFB300); // Terminal Yellow
      case 'folder':
        return const Color(0xFFFFB300); // Directory Yellow
      case 'item':
      default:
        return Colors.white54; // File Gray
    }
  }

  // Returns the UI labels used in the right side of the mockups
  String _getTypeLabel() {
     switch (item.type) {
      case 'storage':
        return '';
      case 'folder':
        return 'DIR';
      case 'item':
      default:
        return 'FILE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyberGreen = const Color(0xFF00FF00);
    
    return Dismissible(
      key: Key('item_${item.id}'),
      direction: onMove == null 
         ? DismissDirection.endToStart // Only delete for root
         : DismissDirection.horizontal, // Move and delete
         
      // Background for swiping right (MOVE)
      background: Container(
        color: cyberGreen, // Highlight green for move
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Text('RELOCATE [MOV]', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      
      // Secondary background for swiping left (DELETE)
      secondaryBackground: Container(
        color: Colors.redAccent.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Text('PURGE [DEL]', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
           return await showDialog(
             context: context,
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text(">> CONFIRM_PURGE", style: TextStyle(color: Colors.redAccent.shade400)),
                 content: Text("TARGET: ${item.name}\n\nWARNING: DATA LOSS IMMINENT."),
                 actions: [
                   TextButton(
                     onPressed: () => Navigator.of(context).pop(false),
                     child: const Text("[ N ] ABORT", style: TextStyle(color: Colors.white70))
                   ),
                   TextButton(
                       onPressed: () => Navigator.of(context).pop(true),
                       child: Text("[ Y ] EXECUTE", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.bold))
                   ),
                 ],
               );
             },
           );
        } else if (direction == DismissDirection.startToEnd && onMove != null) {
          onMove!();
          return false;
        }
        return false;
      },
      
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
           onDelete();
        }
      },
      
      child: InkWell(
        onTap: onTap,
        child: Container(
          // Subtle border effect for items
          decoration: BoxDecoration(
             border: Border(left: BorderSide(color: Colors.white12, width: 1, style: BorderStyle.solid)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. Icon Context
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: item.type == 'item' ? BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4)
                ) : null,
                child: item.type == 'item' 
                  ? const Text('FILE', style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)) 
                  : Icon(_getIcon(), color: _getIconColor(), size: 28),
              ),
              const SizedBox(width: 16),
              
              // 2. Name & Details Context
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type == 'folder' ? '${item.name} /' : item.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: item.type == 'item' ? Colors.white70 : cyberGreen
                      )
                    ),
                  ],
                ),
              ),
              
              // 3. Trailing details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                      _getTypeLabel(), 
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: item.type == 'storage' ? cyberGreen : Colors.white24,
                        fontSize: 11,
                      )
                   ),
                ],
              ),
              
              if (item.type != 'item') ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

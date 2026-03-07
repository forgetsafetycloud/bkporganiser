import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_provider.dart';
import 'storage_detail_screen.dart';
import '../widgets/storage_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load root level storages (parentId is null)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageProvider>().loadItems(null);
    });
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Storage'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Storage Name',
              hintText: 'e.g., SSD Toshiba 01',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  context.read<StorageProvider>().addItem(text, 'storage');
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(BuildContext context, String query) async {
    final provider = context.read<StorageProvider>();
    final results = await provider.searchItems(query);
    final cyberGreen = const Color(0xFF00FF00);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF111111),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: cyberGreen)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12))
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: cyberGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('>> SEARCH_RESULTS: "$query"', style: TextStyle(color: cyberGreen, fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: results.isEmpty 
                    ? const Center(child: Text('NO MATCHES FOUND', style: TextStyle(color: Colors.white54)))
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (context, index) => Container(height: 1, color: Colors.white12),
                        itemBuilder: (context, index) {
                          final item = results[index];
                          return FutureBuilder<String>(
                            future: provider.getItemPath(item),
                            builder: (context, snapshot) {
                              final path = snapshot.data ?? 'CALCULATING_PATH...';
                              return ListTile(
                                leading: Icon(item.type == 'folder' ? Icons.folder : (item.type == 'storage' ? Icons.sd_storage : Icons.insert_drive_file), color: const Color(0xFFFFB300)),
                                title: Text(item.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text(path, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cyberGreen,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                  ),
                                  onPressed: () async {
                                     // Navigate to the location
                                     Navigator.pop(dialogContext); // close modal
                                     
                                     if (item.parentId != null) {
                                        final parentItem = await provider.getItemById(item.parentId!);
                                        if (parentItem != null && context.mounted) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => StorageDetailScreen(parentItem: parentItem),
                                                ),
                                            ).then((_) {
                                                provider.loadItems(null);
                                            });
                                        }
                                     }
                                  },
                                  child: const Text('GO', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              );
                            }
                          );
                        },
                      )
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: cyberGreen))),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                       style: OutlinedButton.styleFrom(
                         foregroundColor: cyberGreen,
                         side: const BorderSide(color: Colors.white24),
                         shape: const RoundedRectangleBorder(),
                         padding: const EdgeInsets.symmetric(vertical: 16)
                       ),
                       onPressed: () => Navigator.pop(dialogContext),
                       child: const Text('[ X ] CLOSE'),
                    ),
                  )
                )
              ]
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// Powered by: Forget Safety', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            const Text('SYSTEM_READY', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.green, height: 1),
        ),
      ),
      body: Consumer<StorageProvider>(
        builder: (context, provider, child) {
          if (provider.currentParentId != null) {
            return const SizedBox.shrink();
          }

          final items = provider.items;
          
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No storages found.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('MOUNTED UNITS [${items.length}]', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Container(height: 1, color: Colors.white10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return StorageListTile(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StorageDetailScreen(parentItem: item),
                          ),
                        ).then((_) {
                          provider.loadItems(null);
                        });
                      },
                      onDelete: () {
                         provider.deleteItem(item);
                      },
                      onMove: null, 
                    );
                  },
                ),
              ),
              // Removed Dummy Terminal Logs
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: const Color(0xFF00FF00), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '>> SEARCH_QUERY',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Icon(Icons.search, color: Color(0xFF00FF00)),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                       _showSearchResults(context, query.trim());
                    }
                  },
                  style: const TextStyle(color: Color(0xFF00FF00)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

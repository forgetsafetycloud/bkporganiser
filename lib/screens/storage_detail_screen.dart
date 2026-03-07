import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/storage_item.dart';
import '../providers/storage_provider.dart';
import '../widgets/storage_list_tile.dart';

class StorageDetailScreen extends StatefulWidget {
  final StorageItem parentItem;

  const StorageDetailScreen({super.key, required this.parentItem});

  @override
  State<StorageDetailScreen> createState() => _StorageDetailScreenState();
}

class _StorageDetailScreenState extends State<StorageDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageProvider>().loadItems(widget.parentItem.id);
    });
  }

  void _showAddDialog(BuildContext context) {
    // Capture the provider method instead of reading inside dialog context
    final addAction = context.read<StorageProvider>().addItem;

    showDialog(
      context: context,
      builder: (dialogContext) {
        String name = '';
        String type = 'folder'; // Default
        final cyberGreen = const Color(0xFF00FF00);
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF151515),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     // HEADER
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white12))
                       ),
                       child: Row(
                         children: [
                           Icon(Icons.terminal, color: cyberGreen, size: 20),
                           const SizedBox(width: 8),
                           Text('>> INITIALIZE_NEW_UNIT', style: TextStyle(color: cyberGreen, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                         ],
                       ),
                     ),
                     
                     Padding(
                       padding: const EdgeInsets.all(24.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('UNIT_LABEL:', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                           const SizedBox(height: 8),
                           TextField(
                             style: const TextStyle(color: Colors.white, fontSize: 18),
                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.edit_square, color: cyberGreen, size: 20),
                               hintText: 'TOSHIBA_EXT_',
                               hintStyle: const TextStyle(color: Colors.white24),
                               enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cyberGreen, width: 2)),
                               focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cyberGreen, width: 2)),
                             ),
                             autofocus: true,
                             onChanged: (val) => name = val,
                           ),
                           
                           const SizedBox(height: 32),
                           const Text('TYPE_SELECTOR:', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                           const SizedBox(height: 8),
                           Row(
                             children: [
                               Expanded(
                                 child: GestureDetector(
                                   onTap: () => setState(() => type = 'folder'),
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     decoration: BoxDecoration(
                                        color: type == 'folder' ? cyberGreen : Colors.transparent,
                                        border: Border.all(color: type == 'folder' ? cyberGreen : Colors.white12),
                                     ),
                                     child: Text('[ FOLDER ]', textAlign: TextAlign.center, style: TextStyle(color: type == 'folder' ? Colors.black : cyberGreen, fontWeight: FontWeight.bold)),
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: GestureDetector(
                                   onTap: () => setState(() => type = 'item'),
                                   child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: type == 'item' ? cyberGreen : Colors.transparent,
                                        border: Border.all(color: type == 'item' ? cyberGreen : Colors.white12),
                                      ),
                                      child: Text('[ FILE ]', textAlign: TextAlign.center, style: TextStyle(color: type == 'item' ? Colors.black : cyberGreen, fontWeight: FontWeight.bold)),
                                   ),
                                 ),
                               ),
                             ],
                           )
                         ],
                       ),
                     ),
                     
                     // FOOTER BUTTON
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: cyberGreen,
                           foregroundColor: Colors.black,
                           shape: const RoundedRectangleBorder(),
                           padding: const EdgeInsets.symmetric(vertical: 16),
                         ),
                         onPressed: () {
                           if (name.trim().isNotEmpty) {
                             addAction(name.trim(), type);
                             Navigator.pop(dialogContext);
                           }
                         },
                         child: const Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                              Icon(Icons.power_settings_new),
                              SizedBox(width: 8),
                              Text('MOUNT_DRIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                           ],
                         ),
                       ),
                     ),
                  ],
                ),
              )
            );
          }
        );
      },
    );
  }

  void _showMoveDialog(BuildContext context, StorageItem itemToMove) async {
    final provider = context.read<StorageProvider>();
    final cyberGreen = const Color(0xFF00FF00);
    
    if (!context.mounted) return;

    List<StorageItem?> navHistory = [];
    StorageItem? currentTarget;
    List<StorageItem> currentList = await provider.getFolders(null, itemToMove);
    bool isLoading = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {

            Future<void> openFolder(StorageItem folder) async {
                setState(() => isLoading = true);
                navHistory.add(currentTarget);
                currentTarget = folder;
                currentList = await provider.getFolders(folder.id, itemToMove);
                setState(() => isLoading = false);
            }

            Future<void> goBack() async {
                if (navHistory.isEmpty) return;
                setState(() => isLoading = true);
                StorageItem? prev = navHistory.removeLast();
                currentTarget = prev;
                currentList = await provider.getFolders(prev?.id, itemToMove);
                setState(() => isLoading = false);
            }

            return Dialog(
              backgroundColor: const Color(0xFF111111),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: cyberGreen)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white12))
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: cyberGreen, size: 20),
                          const SizedBox(width: 8),
                          Text('>> MOVE_PROTOCOL', style: TextStyle(color: cyberGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    
                    // TARGET SOURCE INFO
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TARGET SOURCE', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                            child: Row(
                              children: [
                                Icon(itemToMove.type == 'folder' ? Icons.folder : Icons.insert_drive_file, color: const Color(0xFFFFB300), size: 16),
                                const SizedBox(width: 12),
                                Expanded(child: Text(itemToMove.name, style: const TextStyle(color: Colors.white))),
                                Text(itemToMove.type == 'item' ? 'FILE' : 'DIR', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    // DESTINATION LIST
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.white12))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('SELECT DESTINATION DRIVE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(isLoading ? 'LOADING_' : 'AWAITING_INPUT_', style: const TextStyle(color: Colors.green, fontSize: 10)),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: isLoading 
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF00)))
                        : ListView(
                            children: [
                               if (currentTarget != null) 
                                 InkWell(
                                     onTap: goBack,
                                     child: Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                         color: Colors.white10,
                                         child: const Row(
                                             children: [
                                                 Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                                                 SizedBox(width: 16),
                                                 Text('[ GO UP ]', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                             ]
                                         )
                                     )
                                 ),
                               if (currentList.isEmpty)
                                  const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('NO DIRECTORIES HERE', style: TextStyle(color: Colors.white54)))),
                               ...currentList.map((dest) {
                                  return InkWell(
                                    onTap: () => openFolder(dest),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
                                      child: Row(
                                        children: [
                                          Icon(dest.type == 'storage' ? Icons.sd_storage : Icons.folder, color: const Color(0xFFFFB300)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(dest.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.white54)
                                        ],
                                      ),
                                    ),
                                  );
                               })
                            ]
                        )
                    ),
                    
                    // FOOTER (CONFIRMATION)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: cyberGreen))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             children: [
                               const Icon(Icons.info, color: Color(0xFFFFB300), size: 14),
                               const SizedBox(width: 8),
                               Text('CONFIRM TRANSFER SEQUENCE', style: TextStyle(color: cyberGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Text('DESTINATION: ${currentTarget?.name ?? 'ROOT'}', style: TextStyle(color: cyberGreen, fontSize: 12)),
                           const SizedBox(height: 16),
                           Row(
                             children: [
                               Expanded(
                                 child: OutlinedButton(
                                   style: OutlinedButton.styleFrom(
                                     foregroundColor: cyberGreen,
                                     side: const BorderSide(color: Colors.white24),
                                     shape: const RoundedRectangleBorder(),
                                     padding: const EdgeInsets.symmetric(vertical: 16)
                                   ),
                                   onPressed: () => Navigator.pop(dialogContext),
                                   child: const Text('[ N ] ABORT'),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: ElevatedButton(
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: cyberGreen,
                                     foregroundColor: Colors.black,
                                     shape: const RoundedRectangleBorder(),
                                     padding: const EdgeInsets.symmetric(vertical: 16)
                                   ),
                                   onPressed: () {
                                     provider.moveItem(itemToMove, currentTarget?.id);
                                     Navigator.pop(dialogContext);
                                   },
                                   child: const Text('[ Y ] EXECUTE', style: TextStyle(fontWeight: FontWeight.bold)),
                                 ),
                               ),
                             ]
                           )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cyberGreen = const Color(0xFF00FF00);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LOCATION', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 16),
                children: [
                   const TextSpan(text: 'ROOT / ', style: TextStyle(color: Colors.white54)),
                   TextSpan(text: '${widget.parentItem.name} /', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]
              )
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white12, height: 1),
        ),
      ),
      body: Consumer<StorageProvider>(
        builder: (context, provider, child) {
          // Because provider state is shared, stay completely hidden if we aren't the focused page
          if (provider.currentParentId != widget.parentItem.id) {
            return const SizedBox.shrink();
          }

          final items = provider.items;
          
          Widget content;
          if (items.isEmpty) {
            content = const Center(
              child: Text(
                'AWAITING_DATA...\n[ TAP + TO INITIALIZE VARS ]',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1),
              ),
            );
          } else {
            content = ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => Container(height: 1, color: Colors.white12),
              itemBuilder: (context, index) {
                final item = items[index];
                return StorageListTile(
                  item: item,
                  onTap: () {
                    if (item.type != 'item') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorageDetailScreen(parentItem: item),
                        ),
                      ).then((_) {
                         provider.loadItems(widget.parentItem.id);
                      });
                    }
                  },
                  onDelete: () {
                    provider.deleteItem(item);
                  },
                  onMove: () => _showMoveDialog(context, item),
                );
              },
            );
          }

          return Column(
            children: [
              // Directory Header Context
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12, width: 1))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder, color: Color(0xFFFFB300), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('DIRECTORY INDEX', style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: cyberGreen),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text('RW_ACCESS', style: TextStyle(color: cyberGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),

              // Content List 
              Expanded(child: content),
              
              // Bottom Status Bar
              Container(
                color: const Color(0xFF151515),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL: ${items.length} ENTRIES', style: TextStyle(color: cyberGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 60) // Offset for FAB
                  ],
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('NEW', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cyberGreen,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(),
      ),
    );
  }
}

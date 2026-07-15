import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/emby_api.dart';
import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../utils/errors.dart';
import '../widgets/poster_card.dart';
import 'detail_page.dart';
import 'player_page.dart';

/// 媒体库浏览页：网格 + 无限滚动分页 + 排序。
class LibraryPage extends StatefulWidget {
  final LibraryView view;
  const LibraryPage({super.key, required this.view});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  static const _pageSize = 60;

  final _items = <MediaItem>[];
  final _scroll = ScrollController();
  int _total = -1;
  bool _loading = false;
  String? _error;
  String _sortBy = 'SortName';
  String _sortOrder = 'Ascending';

  EmbyApi get _api => context.read<AppState>().api!;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        _loadMore();
      }
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _hasMore => _total < 0 || _items.length < _total;

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final isTv = widget.view.collectionType == 'tvshows';
      final result = await _api.getItems(
        parentId: widget.view.id,
        recursive: true,
        includeItemTypes: isTv
            ? 'Series'
            : widget.view.collectionType == 'movies'
                ? 'Movie'
                : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        startIndex: _items.length,
        limit: _pageSize,
      );
      _items.addAll(result.items);
      _total = result.totalCount;
    } catch (e) {
      if (mounted) _error = friendlyError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resort(String sortBy, String order) {
    setState(() {
      _sortBy = sortBy;
      _sortOrder = order;
      _items.clear();
      _total = -1;
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.view.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: L.of(context).sort,
            onSelected: (v) {
              switch (v) {
                case 'name':
                  _resort('SortName', 'Ascending');
                case 'date':
                  _resort('DateCreated', 'Descending');
                case 'year':
                  _resort('ProductionYear', 'Descending');
                case 'rating':
                  _resort('CommunityRating', 'Descending');
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'name', child: Text(L.of(ctx).sortByName)),
              PopupMenuItem(
                  value: 'date', child: Text(L.of(ctx).sortByDateAdded)),
              PopupMenuItem(value: 'year', child: Text(L.of(ctx).sortByYear)),
              PopupMenuItem(
                  value: 'rating', child: Text(L.of(ctx).sortByRating)),
            ],
          ),
        ],
      ),
      body: _items.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _items.isEmpty && _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? Center(child: Text(L.of(context).libraryEmpty))
                  : GridView.builder(
                      controller: _scroll,
                      // 电视 overscan 安全边距
                      padding: EdgeInsets.all(
                          context.watch<AppState>().tvMode ? 40 : 16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        // 0.58 卡得太紧——封面图 + 标题 + 副标题两行文字
                        // 只要字体度量差几像素就溢出（真出过事：换字体
                        // 后海报卡片整片 RenderFlex overflow）。留够余量。
                        childAspectRatio: 0.5,
                      ),
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= _items.length) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator.adaptive(),
                          ));
                        }
                        final item = _items[i];
                        return PosterCard(
                          item: item,
                          width: 160,
                          autofocus: i == 0 && context.read<AppState>().tvMode,
                          imageUrl:
                              _api.imageUrl(item.id, tag: item.primaryImageTag),
                          onTap: () {
                            if (item.isVideo) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => DetailPage(itemId: item.id)));
                            } else if (item.isFolder) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => DetailPage(itemId: item.id)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PlayerPage(item: item)));
                            }
                          },
                        );
                      },
                    ),
    );
  }
}

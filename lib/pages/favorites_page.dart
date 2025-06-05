import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../widgets/character_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Consumer<CharacterProvider>(
            builder: (context, provider, child) {
              if (provider.favoriteCharacters.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<SortType>(
                icon: const Icon(Icons.sort),
                onSelected: provider.setSortType,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortType.name,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: provider.sortType == SortType.name
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sort by Name',
                          style: TextStyle(
                            color: provider.sortType == SortType.name
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortType.status,
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: provider.sortType == SortType.status
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sort by Status',
                          style: TextStyle(
                            color: provider.sortType == SortType.status
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortType.species,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: provider.sortType == SortType.species
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sort by Species',
                          style: TextStyle(
                            color: provider.sortType == SortType.species
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          if (provider.favoriteCharacters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add characters to favorites by tapping the star icon',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Sort indicator
              if (provider.favoriteCharacters.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sorted by ${_getSortLabel(provider.sortType)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.favoriteCharacters.length} favorite${provider.favoriteCharacters.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Favorites list
              Expanded(
                child: ListView.builder(
                  itemCount: provider.favoriteCharacters.length,
                  itemBuilder: (context, index) {
                    final character = provider.favoriteCharacters[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: child,
                        );
                      },
                      child: CharacterCard(
                        key: ValueKey(character.id),
                        character: character,
                        onFavoriteToggle: () => provider.toggleFavorite(character),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSortLabel(SortType sortType) {
    switch (sortType) {
      case SortType.name:
        return 'Name';
      case SortType.status:
        return 'Status';
      case SortType.species:
        return 'Species';
    }
  }
}
import 'package:flutter/material.dart';

enum SortOption { name, category, status }

class SortingUtils {
  static List<T> sortItems<T>({
    required List<T> items,
    required SortOption sortOption,
    required bool ascending,
    required String Function(T) getName,
    required String Function(T) getCategory,
    required String Function(T) getStatus,
  }) {
    items.sort((a, b) {
      int comparisonResult = 0;

      switch (sortOption) {
        case SortOption.name:
          comparisonResult = getName(a).compareTo(getName(b));
          break;
        case SortOption.category:
          comparisonResult = getCategory(a).compareTo(getCategory(b));
          break;
        case SortOption.status:
          comparisonResult = getStatus(a).compareTo(getStatus(b));
          break;
      }

      return ascending ? comparisonResult : -comparisonResult;
    });

    return items;
  }

    static Widget buildSortMenu({
    required SortOption sortOption,
    required bool ascending,
    required Function(SortOption) onSortOptionChanged,
    required Function(bool) onSortOrderChanged,
  }) {
    return PopupMenuButton<SortOption>(
      onSelected: onSortOptionChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SortOption.name,
          child: Text('Name', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        PopupMenuItem(
          value: SortOption.category,
          child: Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        PopupMenuItem(
          value: SortOption.status,
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
      child: Row(
        children: [
          Icon(
            Icons.sort, // Sort icon
            color: Colors.blue,
            size: 20,
          ), // Space between icon and text
          Text(
            'Sort by: ${_getSortOptionText(sortOption)}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.blue,
            ),
            onPressed: () => onSortOrderChanged(!ascending),
            tooltip: ascending ? 'Sort Descending' : 'Sort Ascending',
          ),
        ],
      ),
    );
  }


  static String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Name';
      case SortOption.category:
        return 'Category';
      case SortOption.status:
        return 'Status';
      default:
        return '';
    }
  }
}
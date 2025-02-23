import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freefood/providers/filter_provider.dart';
import 'package:freefood/utils/string_extensions.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterProvider = Provider.of<FilterProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(
        top: 16,
        left: 16,
        right: MediaQuery.of(context).size.width * 0.5,
        bottom: _isExpanded ? 16 : 0,
      ),
      child: Card(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                'Filters',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filterProvider.filterOptions.entries.map((entry) {
                    final isSelected = filterProvider.selectedFilters.contains(entry.key);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(entry.key.capitalize()),
                      avatar: Icon(
                        entry.value,
                        size: 18,
                        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (_) => filterProvider.toggleFilter(entry.key),
                      selectedColor: colorScheme.secondaryContainer,
                      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.4),
                      checkmarkColor: colorScheme.onSecondaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
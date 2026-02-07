import 'package:flutter/material.dart';
import '../../utils/code_snippets.dart';

/// Code Preview Widget for displaying algorithm code
class CodePreview extends StatelessWidget {
  final String operation;
  final int? highlightedLine;

  const CodePreview({super.key, required this.operation, this.highlightedLine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final code = CodeSnippets.getSnippet(operation);
    final lines = code.trim().split('\n');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _getOperationTitle(operation),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Code Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.asMap().entries.map((entry) {
                  final lineNum = entry.key + 1;
                  final lineText = entry.value;
                  final isHighlighted = highlightedLine == lineNum;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: isHighlighted
                        ? BoxDecoration(
                            color: Colors.yellow.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line number
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$lineNum',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                        // Code line
                        Expanded(child: _buildCodeLine(lineText, isDark)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeLine(String line, bool isDark) {
    // Simple syntax highlighting
    final spans = <TextSpan>[];
    final keywords = [
      'void',
      'if',
      'else',
      'return',
      'for',
      'while',
      'new',
      'int',
      'throw',
      'Node',
      'T',
    ];
    final types = [
      'Queue',
      'Stack',
      'Set',
      'Map',
      'PriorityQueue',
      'Node',
      'Edge',
    ];

    // Split by words and highlight
    final words = line.split(RegExp(r'(\s+|[(){}\[\];,<>=!+\-*/])'));
    String remaining = line;

    // Simple approach - just color keywords
    for (final word in words) {
      if (word.isEmpty) continue;

      final idx = remaining.indexOf(word);
      if (idx > 0) {
        // Add non-word chars before this word
        spans.add(
          TextSpan(
            text: remaining.substring(0, idx),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        );
        remaining = remaining.substring(idx);
      }

      Color textColor = isDark ? Colors.white70 : Colors.black87;

      if (keywords.contains(word)) {
        textColor = const Color(0xFF569CD6); // Blue for keywords
      } else if (types.contains(word)) {
        textColor = const Color(0xFF4EC9B0); // Teal for types
      } else if (word.contains('//') || line.trimLeft().startsWith('//')) {
        textColor = const Color(0xFF6A9955); // Green for comments
      } else if (RegExp(r'^\d+$').hasMatch(word)) {
        textColor = const Color(0xFFB5CEA8); // Light green for numbers
      }

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: textColor,
            fontWeight: keywords.contains(word)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      );
      remaining = remaining.length > word.length
          ? remaining.substring(word.length)
          : '';
    }

    // Add any remaining
    if (remaining.isNotEmpty) {
      spans.add(
        TextSpan(
          text: remaining,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _getOperationTitle(String operation) {
    switch (operation) {
      case 'push':
        return 'Stack Push';
      case 'pop':
        return 'Stack Pop';
      case 'peek':
        return 'Stack Peek';
      case 'enqueue':
        return 'Queue Enqueue';
      case 'dequeue':
        return 'Queue Dequeue';
      case 'insert_bst':
        return 'BST Insert';
      case 'search_bst':
        return 'BST Search';
      case 'inOrder':
        return 'In-Order Traversal';
      case 'preOrder':
        return 'Pre-Order Traversal';
      case 'postOrder':
        return 'Post-Order Traversal';
      case 'bfs':
        return 'Breadth-First Search';
      case 'dfs':
        return 'Depth-First Search';
      case 'dijkstra':
        return 'Dijkstra\'s Algorithm';
      case 'rotateRight':
        return 'AVL Right Rotation';
      case 'rotateLeft':
        return 'AVL Left Rotation';
      default:
        return operation;
    }
  }
}

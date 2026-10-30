import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

/// Each card's accent colour cycles through these so a long list doesn't
/// read as one flat block.
const _accentColors = [
  Color(0xFF2F6F5E),
  Color(0xFF3B5BA9),
  Color(0xFFB4530A),
  Color(0xFF8A4FBE),
];

/// One post in the list: a numbered badge, title, and a short preview of
/// the body — a shadowed card instead of a default Material Card. Tapping
/// it opens the full post in a bottom sheet.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.index,
    required this.onTap,
  });

  final Post post;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColors[index % _accentColors.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${post.id}',
                    style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C2A27),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7A76),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: accent.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onTap;

  const ProCard({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    required this.icon,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121212), // Matte Black
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Icon(icon, color: Colors.grey[500], size: 18),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300, // Thin Swiss style
                  letterSpacing: -0.5,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Minimal Progress Line
              ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[900],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

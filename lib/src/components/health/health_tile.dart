import 'package:flutter/material.dart';

class HealthTile extends StatelessWidget {
  const HealthTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.context,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
        left: 7,
        right: 7,
      ),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: color.withOpacity(0.6),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColorDark,
                      )),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

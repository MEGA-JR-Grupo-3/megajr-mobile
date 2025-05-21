import 'package:flutter/material.dart';

// You might define this as a global variable or manage it via a state management solution
// For a simple direct translation, we'll keep it outside the widget for access
bool _globalNotificationsEnabled = true;

bool getNotificationsEnabled() => _globalNotificationsEnabled;
void setNotificationsEnabled(bool value) {
  _globalNotificationsEnabled = value;
}

class NotificationControl extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const NotificationControl({
    super.key,
    required this.enabled,
    required this.onToggle,
  });

  @override
  State<NotificationControl> createState() => _NotificationControlState();
}

class _NotificationControlState extends State<NotificationControl> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Equivalent to mb-6
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined, // BellIcon equivalent
                size: 24, // h-6 w-6
                color: Colors.grey[500], // text-gray-500
              ),
              const SizedBox(width: 8), // mr-2
              Text(
                'Notificações',
                style: TextStyle(
                  fontWeight: FontWeight.w600, // font-semibold
                  // You might want to use Theme.of(context).textTheme.subtitle1?.color
                  // for dynamic text color based on theme.
                ),
              ),
            ],
          ),
          // Using Material Design Switch
          Switch(
            value: widget.enabled,
            onChanged: widget.onToggle,
            activeColor: Theme.of(context).primaryColor, // Use primary color for active state
            inactiveThumbColor: Colors.grey[400], // Color of the thumb when off
            inactiveTrackColor: Colors.grey[300], // Color of the track when off
          ),
          const SizedBox(width: 8), // For spacing between switch and text
          Text(
            widget.enabled ? 'Permitir' : 'Desativado',
            style: TextStyle(
              fontSize: 14, // text-sm
              fontWeight: FontWeight.w500, // font-medium
              color: Colors.grey[700], // text-gray-900 dark:text-gray-300
            ),
          ),
        ],
      ),
    );
  }
}
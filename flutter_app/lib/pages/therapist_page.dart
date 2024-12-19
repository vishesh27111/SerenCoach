void _showPermissionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Camera Permission Required'),
      content: Text(
          'This feature requires camera access. Please enable it in your device settings.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            openAppSettings(); // Open app settings
          },
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}

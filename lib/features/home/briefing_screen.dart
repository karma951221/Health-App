import 'package:flutter/material.dart';

class BriefingScreen extends StatelessWidget {
  const BriefingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Briefing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Summary',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Weather Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '🌤️',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weather',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '22°C Partly Cloudy',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Humidity: 65%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transit Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transit Information',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _TransitItem(
                      line: 'Line 2',
                      status: 'Normal',
                      delay: 'No delay',
                      icon: '🚇',
                    ),
                    const Divider(height: 16),
                    _TransitItem(
                      line: 'Line 5',
                      status: 'Delayed',
                      delay: '5 min',
                      icon: '🚇',
                    ),
                    const Divider(height: 16),
                    _TransitItem(
                      line: 'Bus 100',
                      status: 'Normal',
                      delay: 'No delay',
                      icon: '🚌',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Events Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Events',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _EventItem(
                      time: '09:00 AM',
                      title: 'Team Meeting',
                      duration: '1 hour',
                    ),
                    const Divider(height: 16),
                    _EventItem(
                      time: '02:00 PM',
                      title: 'Lunch Break',
                      duration: '1 hour',
                    ),
                    const Divider(height: 16),
                    _EventItem(
                      time: '04:00 PM',
                      title: 'Project Review',
                      duration: '30 min',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitItem extends StatelessWidget {
  final String line;
  final String status;
  final String delay;
  final String icon;

  const _TransitItem({
    required this.line,
    required this.status,
    required this.delay,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = status == 'Normal' ? Colors.green : Colors.orange;

    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                delay,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(51),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventItem extends StatelessWidget {
  final String time;
  final String title;
  final String duration;

  const _EventItem({
    required this.time,
    required this.title,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                duration,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Icon(
          Icons.event,
          size: 20,
          color: theme.iconTheme.color,
        ),
      ],
    );
  }
}

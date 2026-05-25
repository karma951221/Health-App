import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/weather/weather_service.dart';
import 'morning_briefing_cubit.dart';

/// 알람을 해제하면 나타나는 "좋은 아침" 브리핑 화면.
class MorningBriefingScreen extends StatelessWidget {
  const MorningBriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MorningBriefingCubit(WeatherService())..load(),
      child: const _MorningBriefingView(),
    );
  }
}

class _MorningBriefingView extends StatelessWidget {
  const _MorningBriefingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('좋은 아침이에요', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                _formatDate(now),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: BlocBuilder<MorningBriefingCubit, MorningBriefingState>(
                  builder: (context, state) => _Body(state: state),
                ),
              ),
              AppPrimaryButton(
                label: '시작하기',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final MorningBriefingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MorningBriefingCubit>();

    switch (state.status) {
      case BriefingStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case BriefingStatus.success:
        return _WeatherCard(weather: state.weather!);

      case BriefingStatus.permissionDenied:
        return _BriefingMessage(
          icon: Icons.location_off_outlined,
          title: '위치 권한이 필요해요',
          body: '오늘 날씨를 보려면 위치 권한을 허용해주세요.',
          actionLabel: '권한 허용',
          onAction: cubit.load,
        );

      case BriefingStatus.permissionDeniedForever:
        return _BriefingMessage(
          icon: Icons.location_off_outlined,
          title: '위치 권한이 꺼져 있어요',
          body: '설정에서 위치 권한을 허용하면 날씨를 볼 수 있어요.',
          actionLabel: '설정 열기',
          onAction: cubit.openSettings,
        );

      case BriefingStatus.locationDisabled:
        return _BriefingMessage(
          icon: Icons.gps_off_outlined,
          title: '위치 서비스가 꺼져 있어요',
          body: '기기의 위치 서비스를 켠 뒤 다시 시도해주세요.',
          actionLabel: '다시 시도',
          onAction: cubit.load,
        );

      case BriefingStatus.failure:
        return _BriefingMessage(
          icon: Icons.cloud_off_outlined,
          title: '날씨를 못 가져왔어요',
          body: state.message ?? '잠시 후 다시 시도해주세요.',
          actionLabel: '다시 시도',
          onAction: cubit.load,
        );
    }
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather});

  final MorningWeather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather.temperature.round()}°',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                weather.description,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (weather.tempMax != null && weather.tempMin != null) ...[
          const SizedBox(height: 8),
          Text(
            '최고 ${weather.tempMax!.round()}°  ·  최저 ${weather.tempMin!.round()}°',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BriefingMessage extends StatelessWidget {
  const _BriefingMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyState(icon: icon, title: title, body: body),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[date.weekday - 1];
  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  return '${date.month}월 ${date.day}일 ($weekday) · $time';
}

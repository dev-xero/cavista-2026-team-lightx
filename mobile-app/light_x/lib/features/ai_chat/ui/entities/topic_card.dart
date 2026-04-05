import 'package:flutter/material.dart';
import 'package:light_x/features/ai_chat/providers/entities/ai_chat_message.dart';
import 'package:light_x/routes/app_router.dart';

class TopicCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const TopicCard({required this.title, required this.subtitle, required this.icon, required this.route});
}

final _sleepCard = TopicCard(
  title: 'Sleep Insights',
  subtitle: 'Review deep sleep and recovery trends',
  icon: Icons.bedtime,
  route: Routes.healthAnalysis.path,
);

final _heartRateCard = TopicCard(
  title: 'Heart Metrics',
  subtitle: 'View heart rate zones and variability',
  icon: Icons.favorite,
  route: Routes.healthAnalysis.path,
);

final _goalsCard = TopicCard(
  title: 'Daily Goals',
  subtitle: 'Set or adjust your daily targets',
  icon: Icons.flag,
  route: Routes.home.path,
);

final topicCatalog = <AiChatTopic, TopicCard>{
  AiChatTopic.sleep: _sleepCard,
  AiChatTopic.heartRate: _heartRateCard,
  AiChatTopic.goals: _goalsCard,
};

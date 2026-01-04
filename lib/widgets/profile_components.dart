import 'package:flutter/material.dart';

// ==========================================
// 1. PROFILE HEADER
// ==========================================
class ProfileHeader extends StatelessWidget {
  final String name;
  final String imagePath;
  final int level;
  final int signs;
  final int goal;
  final double progress;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditName;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.imagePath,
    required this.level,
    required this.signs,
    required this.goal,
    required this.progress,
    required this.onEditAvatar,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF58C56E), width: 3),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            GestureDetector(
              onTap: onEditAvatar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF58C56E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Clickable Name
        GestureDetector(
          onTap: onEditName,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level $level",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58C56E))),
                  Text("$signs / $goal Signs",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress == 0 ? 0.05 : progress,
                  minHeight: 8,
                  backgroundColor:
                      const Color(0xFF58C56E).withValues(alpha: 0.2),
                  color: const Color(0xFF58C56E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. STATS GRID
// ==========================================
class StatsGrid extends StatelessWidget {
  final int streak;
  final int signs;
  final int rank;
  final VoidCallback onRankTap; // Callback for navigation

  const StatsGrid({
    super.key,
    required this.streak,
    required this.signs,
    required this.rank,
    required this.onRankTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(context, 'Streak', '$streak Days', '🔥',
            isHighlight: streak > 0),
        const SizedBox(width: 12),
        _buildCard(context, 'Signs', '$signs', '🤟'),
        const SizedBox(width: 12),
        _buildCard(context, 'Rank', rank == 0 ? '--' : '#$rank', '🏆',
            onTap: onRankTap),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, String label, String value, String emoji,
      {bool isHighlight = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isHighlight
                ? Border.all(
                    color: Colors.orange.withValues(alpha: 0.5), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? Colors.orange : Colors.black87)),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. ACHIEVEMENTS TEASER
// ==========================================
class AchievementsTeaser extends StatelessWidget {
  final VoidCallback onTap; // Callback for navigation

  const AchievementsTeaser({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF58C56E), Color(0xFF3EA353)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF58C56E).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Achievements",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("Check your rank",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. MENU OPTION TILE
// ==========================================
class ProfileMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : const Color(0xFF58C56E).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20,
            color: isDestructive ? Colors.red : const Color(0xFF58C56E)),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : Colors.black87)),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}

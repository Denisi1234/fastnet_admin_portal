import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:admin_portal/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          // Stat Cards Row
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Users', '14,205', '+12%', Icons.group, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('Active Listings', '3,842', '+5%', Icons.home_work, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('Total Bookings', '8,192', '+18%', Icons.calendar_month, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('Revenue (MTD)', '\$1.2M', '-2%', Icons.attach_money, AppTheme.danger)),
            ],
          ),
          const SizedBox(height: 48),
          
          // Chart Section
          const Text(
            'Revenue Trends',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: AppTheme.border, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(padding: const EdgeInsets.only(top: 8), child: Text(months[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 1.4),
                      FlSpot(3, 3.4),
                      FlSpot(4, 2),
                      FlSpot(5, 2.2),
                    ],
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          // Mock Activity List
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final isPositive = index % 2 == 0;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPositive ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPositive ? Icons.check : Icons.priority_high,
                      color: isPositive ? AppTheme.success : AppTheme.warning,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    isPositive ? 'New booking confirmed for "Luxury Villa"' : 'Host identity verification pending review',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('2 hours ago', style: TextStyle(color: AppTheme.textSecondary)),
                  trailing: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textPrimary),
                    child: const Text('Details', style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color trendColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: AppTheme.textSecondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trendColor == AppTheme.success ? Icons.arrow_upward : Icons.arrow_downward,
                  color: trendColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('vs last month', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:admin_portal/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriodIndex = 1; // 0=This Week, 1=This Month, 2=This Year

  static const List<String> _periods = ['This Week', 'This Month', 'This Year'];

  // Revenue data (in millions TSh)
  static const List<double> _grossRevenue = [2.1, 2.4, 2.2, 3.1, 2.8, 3.4, 3.0, 3.8, 4.1, 3.6, 4.4, 4.8];
  static final List<double> _netPayout = _grossRevenue.map((v) => v * 0.6).toList();

  static const List<String> _months12 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const List<String> _months6 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  // User growth data
  static const List<double> _userGrowth = [1200, 1450, 1800, 2100, 2600, 3100];

  // Bar chart data
  static const List<String> _propertyTypes = ['Lodge', 'Villa', 'Hotel', 'Apartment', 'Beach Resort'];
  static const List<double> _bookingsCount = [420, 285, 310, 198, 71];

  // Top lodges
  static const List<Map<String, dynamic>> _topLodges = [
    {'name': 'Zanzibar Sunset Beach Villa', 'city': 'Zanzibar', 'bookings': 284, 'revenue': '3,200,000', 'occupancy': '91%'},
    {'name': 'Arusha Highland Lodge', 'city': 'Arusha', 'bookings': 201, 'revenue': '2,850,000', 'occupancy': '78%'},
    {'name': 'Dar es Salaam Executive Hotel', 'city': 'Dar es Salaam', 'bookings': 189, 'revenue': '2,100,000', 'occupancy': '73%'},
    {'name': 'Mwanza Lake View Lodge', 'city': 'Mwanza', 'bookings': 142, 'revenue': '1,650,000', 'occupancy': '65%'},
    {'name': 'Moshi Safari Camp', 'city': 'Moshi', 'bookings': 98, 'revenue': '980,000', 'occupancy': '54%'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── A. Page Header ──────────────────────────────────────────────
          _buildHeader(),
          const SizedBox(height: 40),

          // ── B. KPI Summary Row ──────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Revenue', 'TSh 8.4M', '+22%', Icons.attach_money, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('Total Bookings', '1,284', '+18%', Icons.calendar_month, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('Avg Occupancy Rate', '74%', '+5%', Icons.hotel, AppTheme.success)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard('New Users', '312', '+31%', Icons.person_add, AppTheme.success)),
            ],
          ),
          const SizedBox(height: 48),

          // ── C. Revenue Trend Chart ──────────────────────────────────────
          _buildSectionTitle('Revenue Trend'),
          const SizedBox(height: 24),
          Container(
            height: 320,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) =>
                            const FlLine(color: AppTheme.border, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toStringAsFixed(1)}M',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= 0 && i < _months12.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _months12[i],
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Gross Revenue line
                        LineChartBarData(
                          spots: List.generate(
                            _grossRevenue.length,
                            (i) => FlSpot(i.toDouble(), _grossRevenue[i]),
                          ),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primary.withOpacity(0.08),
                          ),
                        ),
                        // Net Payout line
                        LineChartBarData(
                          spots: List.generate(
                            _netPayout.length,
                            (i) => FlSpot(i.toDouble(), _netPayout[i]),
                          ),
                          isCurved: true,
                          color: AppTheme.success,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.success.withOpacity(0.07),
                          ),
                          dashArray: [6, 4],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendDot(AppTheme.primary),
                    const SizedBox(width: 6),
                    const Text('Gross Revenue', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(width: 24),
                    _buildLegendDot(AppTheme.success),
                    const SizedBox(width: 6),
                    const Text('Net Payout', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // ── D. Bookings by Property Type — Bar Chart ────────────────────
          _buildSectionTitle('Bookings by Property Type'),
          const SizedBox(height: 24),
          Container(
            height: 280,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 500,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_propertyTypes[groupIndex]}\n${rod.toY.toInt()} bookings',
                        const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < _propertyTypes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _propertyTypes[i],
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppTheme.border, strokeWidth: 1),
                ),
                barGroups: List.generate(_bookingsCount.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _bookingsCount[i],
                        color: AppTheme.primary,
                        width: 36,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 500,
                          color: AppTheme.surfaceHighlight,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ── E. Top Performing Lodges Table ──────────────────────────────
          _buildSectionTitle('Top Lodges by Revenue'),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceHighlight),
                dividerThickness: 1,
                dataRowMaxHeight: 64,
                dataRowMinHeight: 64,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Rank', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Lodge Name', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('City', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Bookings', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('Revenue (TSh)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('Occupancy %', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)), numeric: true),
                ],
                rows: List.generate(_topLodges.length, (i) {
                  final lodge = _topLodges[i];
                  return DataRow(cells: [
                    DataCell(_buildRankBadge(i + 1)),
                    DataCell(
                      Text(
                        lodge['name'] as String,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(lodge['city'] as String, style: const TextStyle(color: AppTheme.textSecondary))),
                    DataCell(Text('${lodge['bookings']}', style: const TextStyle(color: AppTheme.textPrimary))),
                    DataCell(Text(lodge['revenue'] as String, style: const TextStyle(color: AppTheme.textPrimary))),
                    DataCell(
                      _buildOccupancyBadge(lodge['occupancy'] as String),
                    ),
                  ]);
                }),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ── F. User Growth Chart ─────────────────────────────────────────
          _buildSectionTitle('User Growth'),
          const SizedBox(height: 24),
          Container(
            height: 280,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < _months6.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _months6[i],
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _userGrowth.length,
                      (i) => FlSpot(i.toDouble(), _userGrowth[i]),
                    ),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 5,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.18), AppTheme.primary.withOpacity(0.01)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics & Reports',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Platform performance overview',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 16),
              // Period filter chips
              Row(
                children: List.generate(_periods.length, (i) {
                  final selected = _selectedPeriodIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriodIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          _periods[i],
                          style: TextStyle(
                            color: selected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting report…'), backgroundColor: AppTheme.textPrimary),
            );
          },
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Export Report'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            side: const BorderSide(color: AppTheme.border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.textSecondary, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.arrow_upward, color: trendColor, size: 15),
                const SizedBox(width: 3),
                Text(
                  change,
                  style: TextStyle(color: trendColor, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 6),
                const Text('vs last month', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildRankBadge(int rank) {
    final colors = {
      1: const Color(0xFFD4AF37), // gold
      2: const Color(0xFF9E9E9E), // silver
      3: const Color(0xFFCD7F32), // bronze
    };
    final color = colors[rank] ?? AppTheme.border;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: rank <= 3 ? color : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOccupancyBadge(String value) {
    final pct = int.tryParse(value.replaceAll('%', '')) ?? 0;
    final color = pct >= 80
        ? AppTheme.success
        : pct >= 60
            ? AppTheme.warning
            : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

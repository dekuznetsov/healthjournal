import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:window_manager/window_manager.dart';
import 'models/health_record.dart';
import 'services/database_helper.dart';
import 'services/report_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Initialize window manager
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(414, 896),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMinimumSize(const Size(414, 896));
      await windowManager.setMaximumSize(const Size(414, 896));
    });
  }

  await DatabaseHelper().seedData();
  runApp(const HealthDiaryApp());
}

class HealthDiaryApp extends StatelessWidget {
  const HealthDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Щоденник здоров\'я',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<HealthRecord> _records = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _dbHelper.getRecords();
    setState(() {
      _records.clear();
      _records.addAll(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Щоденник Гіпертоніка та Діабетика'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Додати'),
              Tab(icon: Icon(Icons.history), text: 'Журнал'),
              Tab(icon: Icon(Icons.show_chart), text: 'Графік'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Щоденник здоров\'я', style: TextStyle(color: Colors.white, fontSize: 24)),
                    SizedBox(height: 8),
                    Text('Керування даними', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Звітність', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
                title: const Text('Сформувати звіт'),
                subtitle: const Text('За останні 30 днів'),
                onTap: () async {
                  await ReportService().generateAndShowReport(_records);
                  if (mounted) Navigator.pop(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Розробка', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Очистити базу'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Підтвердження'),
                      content: const Text('Ви впевнені, що хочете видалити всі записи?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Скасувати')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Видалити', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _dbHelper.deleteAllRecords();
                    _loadRecords();
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.dataset, color: Colors.teal),
                  title: const Text('Заповнити базу (1 рік)'),
                  subtitle: const Text('Довільні значення (DEBUG)'),
                  onTap: () async {
                    await _dbHelper.seedYearlyData();
                    _loadRecords();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AddDataTab(onRecordAdded: _loadRecords),
            JournalTab(records: _records, onDelete: (id) async {
              await _dbHelper.deleteRecord(id);
              _loadRecords();
            }),
            ChartsTab(records: _records),
          ],
        ),
      ),
    );
  }
}

class AddDataTab extends StatefulWidget {
  final VoidCallback onRecordAdded;
  const AddDataTab({super.key, required this.onRecordAdded});

  @override
  State<AddDataTab> createState() => _AddDataTabState();
}

class _AddDataTabState extends State<AddDataTab> {
  final _formKey = GlobalKey<FormState>();
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _pulseController = TextEditingController();
  final _sugarController = TextEditingController();
  
  String _period = 'morning';

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _period = (hour >= 5 && hour < 12) ? 'morning' : 'evening';
  }

  String? _validateRequired(String? v, int min, int max, String label) {
    if (v == null || v.isEmpty) return 'Обов\'язково';
    final val = int.tryParse(v);
    if (val == null) return 'Тільки цифри';
    if (val < min || val > max) return '$label має бути від $min до $max';
    return null;
  }

  String? _validateSugar(String? v) {
    if (v == null || v.isEmpty) return 'Обов\'язково';
    final val = double.tryParse(v.replaceFirst(',', '.'));
    if (val == null) return 'Некоректний формат';
    if (val < 1.0 || val > 30.0) return 'Цукор має бути від 1.0 до 30.0';
    return null;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      double? sugarVal;
      if (_period == 'morning') {
        final parsed = double.tryParse(_sugarController.text.replaceFirst(',', '.'));
        if (parsed != null) {
          sugarVal = double.parse(parsed.toStringAsFixed(1));
        }
      }
      
      final record = HealthRecord(
        systolic: int.parse(_sysController.text),
        diastolic: int.parse(_diaController.text),
        pulse: int.parse(_pulseController.text),
        sugar: sugarVal,
        timestamp: DateTime.now(),
        period: _period,
      );

      await DatabaseHelper().insertRecord(record);
      widget.onRecordAdded();
      
      _sysController.clear();
      _diaController.clear();
      _pulseController.clear();
      _sugarController.clear();

      if (!mounted) return;

      String message = 'Дані збережено';
      if (sugarVal != null) {
        if (sugarVal > 10.0) {
          message += '\nУВАГА: Необхідно звернутись до лікаря!';
        } else if (sugarVal > 7.0) {
          message += '\nПорада: Рекомендовано вживати менше вуглеводів.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: (sugarVal != null && sugarVal > 10.0) ? Colors.red : Colors.teal,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'morning', label: Text('Ранок'), icon: Icon(Icons.wb_sunny)),
                ButtonSegment(value: 'evening', label: Text('Вечір'), icon: Icon(Icons.nightlight_round)),
              ],
              selected: {_period},
              onSelectionChanged: (val) => setState(() => _period = val.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _sysController,
              decoration: const InputDecoration(labelText: 'Верхній тиск (SYS)', border: OutlineInputBorder(), hintText: '70-250'),
              keyboardType: TextInputType.number,
              validator: (v) => _validateRequired(v, 70, 250, 'SYS'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _diaController,
              decoration: const InputDecoration(labelText: 'Нижній тиск (DIA)', border: OutlineInputBorder(), hintText: '40-150'),
              keyboardType: TextInputType.number,
              validator: (v) => _validateRequired(v, 40, 150, 'DIA'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pulseController,
              decoration: const InputDecoration(labelText: 'Пульс', border: OutlineInputBorder(), hintText: '30-200'),
              keyboardType: TextInputType.number,
              validator: (v) => _validateRequired(v, 30, 200, 'Пульс'),
            ),
            if (_period == 'morning') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _sugarController,
                decoration: const InputDecoration(labelText: 'Рівень цукру', border: OutlineInputBorder(), hintText: '1.0-30.0'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateSugar,
                onChanged: (_) => setState(() {}),
              ),
              Builder(builder: (context) {
                final val = double.tryParse(_sugarController.text.replaceFirst(',', '.'));
                if (val == null) return const SizedBox();
                if (val > 10.0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('⚠️ Необхідно звернутись до лікаря!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  );
                } else if (val > 7.0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('💡 Рекомендовано вживати менше вуглеводів.', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  );
                }
                return const SizedBox();
              }),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalTab extends StatelessWidget {
  final List<HealthRecord> records;
  final Function(int) onDelete;
  
  const JournalTab({super.key, required this.records, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('Журнал порожній'));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(r.timestamp);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              r.period == 'morning' ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
              color: r.period == 'morning' ? Colors.orange : Colors.indigo,
            ),
            title: Text('${r.systolic}/${r.diastolic}, пульс: ${r.pulse}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.sugar != null) Text('Цукор: ${r.sugar}'),
                Text(dateStr, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => onDelete(r.id!),
            ),
          ),
        );
      },
    );
  }
}

enum ChartPeriod { week, month, year, all, custom }

class ChartsTab extends StatefulWidget {
  final List<HealthRecord> records;
  const ChartsTab({super.key, required this.records});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  DateTimeRange? _customRange;
  int? _dragStartIndex;
  int? _dragEndIndex;
  bool _isDragging = false;

  List<HealthRecord> _getFilteredRecords() {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        start = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.month:
        start = now.subtract(const Duration(days: 30));
        break;
      case ChartPeriod.year:
        start = now.subtract(const Duration(days: 365));
        break;
      case ChartPeriod.all:
        start = null;
        break;
      case ChartPeriod.custom:
        if (_customRange != null) {
          start = _customRange!.start;
          // Set end to the very end of the selected day
          end = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
        }
        break;
    }

    Iterable<HealthRecord> filtered = widget.records;
    if (start != null) {
      // Use inclusive comparison for the start date
      final s = start;
      filtered = filtered.where((r) => r.timestamp.isAfter(s) || r.timestamp.isAtSameMomentAs(s));
    }
    if (end != null) {
      // Use inclusive comparison for the end date
      final e = end;
      filtered = filtered.where((r) => r.timestamp.isBefore(e) || r.timestamp.isAtSameMomentAs(e));
    }

    return List<HealthRecord>.from(filtered)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _handleDragUpdate(int index) {
    if (_dragEndIndex == index) return; // Optimization: only update if index changed
    setState(() {
      _dragStartIndex ??= index;
      _dragEndIndex = index;
    });
  }

  void _handleDragEnd(List<HealthRecord> currentRecords) {
    if (_dragStartIndex != null && _dragEndIndex != null) {
      int startIdx = min(_dragStartIndex!, _dragEndIndex!);
      int endIdx = max(_dragStartIndex!, _dragEndIndex!);

      if (startIdx >= 0 && endIdx < currentRecords.length) {
        setState(() {
          _customRange = DateTimeRange(
            start: currentRecords[startIdx].timestamp,
            end: currentRecords[endIdx].timestamp,
          );
          _selectedPeriod = ChartPeriod.custom;
          _dragStartIndex = null;
          _dragEndIndex = null;
        });
      }
    } else {
      setState(() {
        _dragStartIndex = null;
        _dragEndIndex = null;
      });
    }
  }

  Future<void> _selectCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _selectedPeriod = ChartPeriod.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();

    if (widget.records.isEmpty) {
      return const Center(child: Text('Немає даних для графіків'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              SegmentedButton<ChartPeriod>(
                segments: const [
                  ButtonSegment(value: ChartPeriod.week, label: Text('7д')),
                  ButtonSegment(value: ChartPeriod.month, label: Text('30д')),
                  ButtonSegment(value: ChartPeriod.year, label: Text('Рік')),
                  ButtonSegment(value: ChartPeriod.all, label: Text('Все')),
                ],
                selected: {_selectedPeriod == ChartPeriod.custom ? ChartPeriod.all : _selectedPeriod},
                onSelectionChanged: (val) => setState(() => _selectedPeriod = val.first),
              ),
              IconButton.filledTonal(
                onPressed: _selectCustomRange,
                icon: const Icon(Icons.date_range),
                tooltip: 'Вибрати період',
                isSelected: _selectedPeriod == ChartPeriod.custom,
              ),
              if (_selectedPeriod == ChartPeriod.custom)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedPeriod = ChartPeriod.month),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Скинути', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          if (_selectedPeriod == ChartPeriod.custom && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Період: ${DateFormat('dd.MM.yy').format(_customRange!.start)} - ${DateFormat('dd.MM.yy').format(_customRange!.end)}',
                style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          if (filteredRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text('За вибраний період даних немає'),
            )
          else ...[
            const Text('Графік тиску', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: _buildPressureChart(filteredRecords),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('SYS', Colors.red),
                const SizedBox(width: 20),
                _buildLegendItem('DIA', Colors.blue),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Графік цукру', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: _buildSugarChart(filteredRecords),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  bool _isHighlighted(int index) {
    if (_dragStartIndex == null || _dragEndIndex == null) return false;
    int start = min(_dragStartIndex!, _dragEndIndex!);
    int end = max(_dragStartIndex!, _dragEndIndex!);
    return index >= start && index <= end;
  }

  Widget _buildPressureChart(List<HealthRecord> sortedRecords) {
    return BarChart(
      key: ValueKey('pressure_${sortedRecords.length}_${_selectedPeriod}_${_customRange?.start}'),
      BarChartData(
        barGroups: sortedRecords.asMap().entries.map((e) {
          final isHighlighted = _isHighlighted(e.key);
          final sys = e.value.systolic.toDouble();
          final dia = e.value.diastolic.toDouble();
          
          // Ensure sys is at least as large as dia for safe stacking
          final maxVal = max(sys, dia);
          final minVal = min(sys, dia);

          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: maxVal,
                width: 14,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    minVal,
                    isHighlighted ? Colors.blue.withAlpha(150) : Colors.blue,
                  ),
                  BarChartRodStackItem(
                    minVal,
                    maxVal,
                    isHighlighted ? Colors.red.withAlpha(150) : Colors.red,
                  ),
                ],
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 0 && idx < sortedRecords.length) {
                  final r = sortedRecords[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('dd.MM').format(r.timestamp),
                          style: const TextStyle(fontSize: 9),
                        ),
                        Icon(
                          r.period == 'morning' ? Icons.wb_sunny : Icons.nightlight_round,
                          size: 10,
                          color: r.period == 'morning' ? Colors.orange : Colors.indigo,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final r = sortedRecords[groupIndex];
              final dateStr = DateFormat('dd.MM').format(r.timestamp);
              final periodStr = r.period == 'morning' ? '☀️' : '🌙';
              return BarTooltipItem(
                '$dateStr $periodStr\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                children: [
                  const TextSpan(
                    text: 'SYS: ',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                  TextSpan(
                    text: '${r.systolic}\n',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const TextSpan(
                    text: 'DIA: ',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                  ),
                  TextSpan(
                    text: '${r.diastolic}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              );
            },
          ),
          touchCallback: (event, response) {
            if (event is FlPanStartEvent || event is FlTapDownEvent) {
              _isDragging = true;
            }
            
            if (_isDragging && response != null && response.spot != null) {
              _handleDragUpdate(response.spot!.touchedBarGroupIndex);
            }
            
            if (event is FlPanEndEvent || event is FlTapUpEvent || event is FlPointerExitEvent) {
              if (_isDragging) {
                _handleDragEnd(sortedRecords);
                _isDragging = false;
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildSugarChart(List<HealthRecord> sortedRecords) {
    final sugarRecords = sortedRecords.where((r) => r.sugar != null).toList();
    if (sugarRecords.isEmpty) {
      return const Center(child: Text('Немає даних про цукор'));
    }

    return BarChart(
      key: ValueKey('sugar_${sugarRecords.length}_${_selectedPeriod}_${_customRange?.start}'),
      BarChartData(
        barGroups: sugarRecords.asMap().entries.map((e) {
          final isHighlighted = _isHighlighted(e.key);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.sugar!.toDouble(),
                color: isHighlighted ? Colors.teal.withAlpha(150) : Colors.teal,
                width: 12,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 0 && idx < sugarRecords.length) {
                  final r = sugarRecords[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('dd.MM').format(r.timestamp),
                          style: const TextStyle(fontSize: 9),
                        ),
                        Icon(
                          r.period == 'morning' ? Icons.wb_sunny : Icons.nightlight_round,
                          size: 10,
                          color: r.period == 'morning' ? Colors.orange : Colors.indigo,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final r = sugarRecords[groupIndex];
              final dateStr = DateFormat('dd.MM').format(r.timestamp);
              final periodStr = r.period == 'morning' ? '☀️' : '🌙';
              return BarTooltipItem(
                '$dateStr $periodStr\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Sugar: ${rod.toY}',
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (event, response) {
            if (event is FlPanStartEvent || event is FlTapDownEvent) {
              _isDragging = true;
            }

            if (_isDragging && response != null && response.spot != null) {
              _handleDragUpdate(response.spot!.touchedBarGroupIndex);
            }

            if (event is FlPanEndEvent || event is FlTapUpEvent || event is FlPointerExitEvent) {
              if (_isDragging) {
                _handleDragEnd(sugarRecords);
                _isDragging = false;
              }
            }
          },
        ),
      ),
    );
  }
}

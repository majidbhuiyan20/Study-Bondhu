import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../models/class_slot.dart';
import '../view_models/timetable_view_model.dart';

class TimetableView extends ConsumerStatefulWidget {
  const TimetableView({super.key});

  @override
  ConsumerState<TimetableView> createState() => _State();
}

class _State extends ConsumerState<TimetableView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(timetableViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _showAddEditSheet({ClassSlot? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SlotSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(timetableViewModelProvider);
    final subjects = ref.watch(subjectsViewModelProvider).subjects;
    final isBn = l10n.isBangla;
    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'ক্লাস রুটিন' : 'Class routine'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: isBn ? 'সাপ্তাহিক' : 'Weekly'),
            Tab(text: isBn ? 'তালিকা' : 'List'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-timetable',
        onPressed: () => _showAddEditSlot(context, null),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.slots.isEmpty
              ? AppEmptyState(
                  title: isBn
                      ? 'কোনো ক্লাস সেট করা হয়নি'
                      : 'No classes scheduled',
                  message: isBn
                      ? 'সাপ্তাহিক ক্লাস টাইমটেবল যোগ করুন'
                      : 'Add your weekly class schedule',
                  icon: Icons.calendar_view_week_rounded,
                )
              : TabBarView(
                  controller: _tab,
                  children: [
                    _WeeklyView(
                        slots: state.slots,
                        subjects: subjects,
                        onTap: (s) => _showAddEditSlot(context, s)),
                    _ListView(
                        slots: state.slots,
                        subjects: subjects,
                        onTap: (s) => _showAddEditSlot(context, s)),
                  ],
                ),
    );
  }

  void _showAddEditSlot(BuildContext context, ClassSlot? existing) {
    _showAddEditSheet(existing: existing);
  }
}

class _WeeklyView extends StatelessWidget {
  const _WeeklyView({
    required this.slots,
    required this.subjects,
    required this.onTap,
  });
  final List<ClassSlot> slots;
  final List<Subject> subjects;
  final ValueChanged<ClassSlot> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final byDay = <int, List<ClassSlot>>{};
    for (final s in slots) {
      byDay.putIfAbsent(s.dayOfWeek, () => []).add(s);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: 7,
      itemBuilder: (ctx, i) {
        final day = i + 1;
        final labels = isBn
            ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
            : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final daySlots = byDay[day] ?? const [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labels[i],
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (daySlots.isEmpty)
                  Text(
                    isBn ? 'কোনো ক্লাস নেই' : 'No classes',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  )
                else
                  ...daySlots.map((s) => _SlotRow(
                        slot: s,
                        subjectName: _subjectName(subjects, s.subjectId),
                        onTap: () => onTap(s),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.slots,
    required this.subjects,
    required this.onTap,
  });
  final List<ClassSlot> slots;
  final List<Subject> subjects;
  final ValueChanged<ClassSlot> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final labels = isBn
        ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = [...slots]..sort((a, b) {
        final c = a.dayOfWeek.compareTo(b.dayOfWeek);
        return c != 0 ? c : a.startMinutes.compareTo(b.startMinutes);
      });
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = sorted[i];
        return AppCard(
          onTap: () => onTap(s),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _subjectColor(subjects, s.subjectId)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: _subjectColor(subjects, s.subjectId)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _subjectName(subjects, s.subjectId),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${labels[s.dayOfWeek - 1]} · ${s.startTime}–${s.endTime}',
                      style: TextStyle(
                          color: ThemeColors.textSecondary(context),
                          fontSize: 12),
                    ),
                    if (s.location != null && s.location!.isNotEmpty)
                      Text(s.location!,
                          style: TextStyle(
                              color: ThemeColors.textTertiary(context),
                              fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined,
                  color: ThemeColors.textSecondary(context), size: 18),
            ],
          ),
        );
      },
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slot,
    required this.subjectName,
    required this.onTap,
  });
  final ClassSlot slot;
  final String subjectName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(slot, context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subjectName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    '${slot.startTime}–${slot.endTime}'
                    '${slot.location != null && slot.location!.isNotEmpty ? ' · ${slot.location}' : ''}',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(ClassSlot _, BuildContext context) {
    return AppColors.primary;
  }
}

Color _subjectColor(List<Subject> subjects, int subjectId) {
  for (final s in subjects) {
    if (s.id == subjectId) {
      try {
        final hex = s.color.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        return AppColors.primary;
      }
    }
  }
  return AppColors.primary;
}

String _subjectName(List<Subject> subjects, int subjectId) {
  for (final s in subjects) {
    if (s.id == subjectId) return s.name;
  }
  return 'Subject';
}

class _SlotSheet extends ConsumerStatefulWidget {
  const _SlotSheet({this.existing});
  final ClassSlot? existing;

  @override
  ConsumerState<_SlotSheet> createState() => _SlotSheetState();
}

class _SlotSheetState extends ConsumerState<_SlotSheet> {
  late int _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late TextEditingController _location;
  int? _subjectId;

  @override
  void initState() {
    super.initState();
    _day = widget.existing?.dayOfWeek ?? DateTime.now().weekday;
    final s = widget.existing?.startTime.split(':') ?? const ['09', '00'];
    final e = widget.existing?.endTime.split(':') ?? const ['10', '00'];
    _start = TimeOfDay(
        hour: int.tryParse(s[0]) ?? 9, minute: int.tryParse(s[1]) ?? 0);
    _end = TimeOfDay(
        hour: int.tryParse(e[0]) ?? 10, minute: int.tryParse(e[1]) ?? 0);
    _location =
        TextEditingController(text: widget.existing?.location ?? '');
    _subjectId = widget.existing?.subjectId;
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(BuildContext ctx, bool isStart) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final subjects = ref.watch(subjectsViewModelProvider).subjects;
    _subjectId ??= subjects.isNotEmpty ? subjects.first.id : null;
    final dayLabels = isBn
        ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null
                ? (isBn ? 'নতুন ক্লাস' : 'New class')
                : (isBn ? 'ক্লাস এডিট' : 'Edit class'),
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _subjectId,
            decoration: InputDecoration(
              labelText: isBn ? 'বিষয়' : 'Subject',
            ),
            items: subjects
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _subjectId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDay(),
                  child: Text(isBn ? 'দিন: ${dayLabels[_day - 1]}'
                      : 'Day: ${dayLabels[_day - 1]}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(context, true),
                  child: Text(
                      isBn ? 'শুরু: ${_fmt(_start)}' : 'Start: ${_fmt(_start)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(context, false),
                  child: Text(
                      isBn ? 'শেষ: ${_fmt(_end)}' : 'End: ${_fmt(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: InputDecoration(
              labelText: isBn ? 'রুম/লোকেশন (ঐচ্ছিক)' : 'Room/location (optional)',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.existing != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                  label: Text(isBn ? 'মুছুন' : 'Delete'),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await ref
                        .read(timetableViewModelProvider.notifier)
                        .deleteSlot(widget.existing!.id!);
                    if (!mounted) return;
                    navigator.pop();
                  },
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isBn ? 'বাতিল' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (_subjectId == null) return;
                  final slot = ClassSlot(
                    id: widget.existing?.id,
                    subjectId: _subjectId!,
                    dayOfWeek: _day,
                    startTime: _fmt(_start),
                    endTime: _fmt(_end),
                    location: _location.text.trim().isEmpty
                        ? null
                        : _location.text.trim(),
                    createdAt: widget.existing?.createdAt ?? DateTime.now(),
                  );
                  final vm = ref.read(timetableViewModelProvider.notifier);
                  final navigator = Navigator.of(context);
                  if (widget.existing == null) {
                    await vm.addSlot(slot);
                  } else {
                    await vm.updateSlot(slot);
                  }
                  if (!mounted) return;
                  navigator.pop();
                },
                child: Text(isBn ? 'সংরক্ষণ' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickDay() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (i) {
              final labels = context.l10n.isBangla
                  ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
                  : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return ListTile(
                title: Text(labels[i]),
                onTap: () {
                  setState(() => _day = i + 1);
                  Navigator.pop(ctx);
                },
              );
            }),
          ),
        );
      },
    );
  }
}
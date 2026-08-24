import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart'
    show
        AppLocalizations,
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../models/profile.dart';
import '../view_models/profile_view_model.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final _pageController = PageController();
  int _page = 0;

  // ---- Profile step ----
  final _nameCtl = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  ProfileLevel _level = ProfileLevel.school;
  String? _classLabel;
  final _institutionCtl = TextEditingController();

  // ---- Subject step ----
  final _subjectsFormKey = GlobalKey<FormState>();
  final List<_SubjectDraft> _subjects = [
    _SubjectDraft(color: '4CAF50'),
    _SubjectDraft(color: '2196F3'),
  ];

  // ---- Daily goal ----
  int _dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes;

  // ---- Language ----
  Locale _locale = const Locale('en');

  // ---- Theme ----
  ThemeMode _themeMode = ThemeMode.system;

  // Per-page inline error states.
  String? _pageError;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtl.dispose();
    _institutionCtl.dispose();
    for (final s in _subjects) {
      s.dispose();
    }
    super.dispose();
  }

  /// Returns true when the current page's data is valid. Used to gate
  /// the Next/Finish button so the user can't advance with empty required
  /// fields.
  bool _isCurrentPageValid() {
    switch (_page) {
      case 1: // Profile
        if (_nameCtl.text.trim().isEmpty) return false;
        if (_classLabel == null) return false;
        return true;
      case 3: // Subjects — at least one row with a non-empty name.
        return _subjects.any((s) => s.titleCtl.text.trim().isNotEmpty);
      default:
        return true;
    }
  }

  void _next() {
    setState(() => _pageError = null);

    // Per-page gate. We require the page to validate before advancing so
    // the user can't finish onboarding with an empty name or no subjects.
    if (!_isCurrentPageValid()) {
      setState(() {
        switch (_page) {
          case 1:
            _pageError = context.l10n.isBangla
                ? 'নাম এবং ক্লাস/বর্ষ দিন'
                : 'Please enter your name and pick a class/year';
            break;
          case 3:
            _pageError = context.l10n.onboardingSubjectRequired;
            break;
        }
      });
      // Trigger form validation visuals on the relevant page.
      if (_page == 1) _nameFormKey.currentState?.validate();
      if (_page == 3) _subjectsFormKey.currentState?.validate();
      return;
    }

    if (_page < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    setState(() => _pageError = null);
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    // Defense in depth — _next() already gated, but re-validate before
    // writing data so a stale state can't slip through.
    if (!_isCurrentPageValid()) {
      setState(() => _pageError = context.l10n.onboardingSubjectRequired);
      return;
    }

    final name = _nameCtl.text.trim();
    final institution = _institutionCtl.text.trim().isEmpty
        ? null
        : _institutionCtl.text.trim();
    // Create the profile AND mark it active in one step so the home
    // greeting, drawer header, and dedicated profile screen all see it
    // immediately after onboarding finishes.
    await ref.read(profileViewModelProvider.notifier).addProfile(
          Profile(
            name: name,
            level: _level,
            classLabel: _classLabel,
            institution: institution,
            createdAt: DateTime.now(),
          ),
          setAsActive: true,
        );

    // Subjects — drop any blank rows defensively (UI prevents them but
    // a partially-edited draft could still be empty).
    final notifier = ref.read(subjectsViewModelProvider.notifier);
    for (final s in _subjects) {
      final t = s.titleCtl.text.trim();
      if (t.isEmpty) continue;
      await notifier.addSubject(Subject(
        name: t,
        code: s.codeCtl.text.trim().isEmpty
            ? null
            : s.codeCtl.text.trim(),
        color: s.color,
        createdAt: DateTime.now(),
      ));
    }

    await ref
        .read(settingsViewModelProvider.notifier)
        .setDailyGoalMinutes(_dailyGoalMinutes);
    await ref.read(settingsViewModelProvider.notifier).setLocale(_locale);
    await ref.read(settingsViewModelProvider.notifier).setThemeMode(_themeMode);

    await LocalStorageService.instance.setOnboardingDone(true);
    if (!mounted) return;
    // Land on the subjects screen so the user sees the rows they just
    // created and can add more without having to navigate.
    context.go(AppRoutes.subjects);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: List.generate(7, (i) {
                  final active = i == _page;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : ThemeColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(l10n: l10n),
                  _ProfilePage(
                    nameCtl: _nameCtl,
                    nameFormKey: _nameFormKey,
                    level: _level,
                    classLabel: _classLabel,
                    onLevelChanged: (l) =>
                        setState(() => _level = l),
                    onClassChanged: (c) =>
                        setState(() => _classLabel = c),
                    institutionCtl: _institutionCtl,
                    onChanged: () => setState(() {}),
                  ),
                  _SemesterPage(),
                  _SubjectsPage(
                    formKey: _subjectsFormKey,
                    subjects: _subjects,
                    onAdd: () => setState(
                      () => _subjects.add(_SubjectDraft(
                        color: _pickColor(_subjects.length),
                      )),
                    ),
                    onRemove: (i) => setState(() {
                      _subjects.removeAt(i).dispose();
                    }),
                    onChanged: () => setState(() {}),
                  ),
                  _DailyGoalPage(
                    minutes: _dailyGoalMinutes,
                    onChanged: (m) =>
                        setState(() => _dailyGoalMinutes = m),
                  ),
                  _LanguagePage(
                    locale: _locale,
                    onChanged: (l) => setState(() => _locale = l),
                  ),
                  _ThemePage(
                    mode: _themeMode,
                    onChanged: (m) => setState(() => _themeMode = m),
                  ),
                ],
              ),
            ),
            // Inline error banner for the current page.
            if (_pageError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _pageError!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // Nav buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: _back,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_page == 6 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pickColor(int idx) {
    const palette = [
      '4CAF50',
      '2196F3',
      'FF9800',
      '9C27B0',
      'F44336',
      '00BCD4',
    ];
    return palette[idx % palette.length];
  }
}

class _SubjectDraft {
  final TextEditingController titleCtl;
  final TextEditingController codeCtl;
  String color;
  _SubjectDraft({required this.color, String? title, String? code})
      : titleCtl = TextEditingController(text: title),
        codeCtl = TextEditingController(text: code);
  void dispose() {
    titleCtl.dispose();
    codeCtl.dispose();
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.l10n});
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded,
              size: 96, color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            l10n.isBangla
                ? 'স্টাডি বন্ধুতে স্বাগতম'
                : 'Welcome to StudyBondhu',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isBangla
                ? 'আপনার পড়াশোনা সাজানো শুরু করি।'
                : "Let's set up your studies in under a minute.",
            style: AppTextStyles.bodyLarge.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.nameCtl,
    required this.nameFormKey,
    required this.level,
    required this.classLabel,
    required this.onLevelChanged,
    required this.onClassChanged,
    required this.institutionCtl,
    required this.onChanged,
  });
  final TextEditingController nameCtl;
  final GlobalKey<FormState> nameFormKey;
  final ProfileLevel level;
  final String? classLabel;
  final ValueChanged<ProfileLevel> onLevelChanged;
  final ValueChanged<String?> onClassChanged;
  final TextEditingController institutionCtl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: nameFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.isBangla ? 'আপনার পরিচয়' : 'About you',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.isBangla ? '* আবশ্যক' : '* Required',
            style: AppTextStyles.bodySmall.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameCtl,
            decoration: InputDecoration(
              labelText: '${l10n.isBangla ? 'নাম' : 'Name'} *',
              hintText: l10n.isBangla ? 'যেমন: রাকিব' : 'e.g. Rakib',
            ),
            // Trigger a parent rebuild so the Next button can re-evaluate.
            onChanged: (_) => onChanged(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.onboardingNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProfileLevel>(
            value: level,
            decoration: InputDecoration(
              labelText: l10n.isBangla ? 'শিক্ষার স্তর' : 'Education level',
            ),
            items: ProfileLevel.values
                .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l10n.isBangla ? l.bn : l.en),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onLevelChanged(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: classLabel,
            decoration: InputDecoration(
              labelText:
                  '${l10n.isBangla ? 'ক্লাস/বর্ষ' : 'Class / year'} *',
            ),
            items: level.classOptions
                .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => onClassChanged(v),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return l10n.onboardingClassRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: institutionCtl,
            decoration: InputDecoration(
              labelText:
                  l10n.isBangla ? 'প্রতিষ্ঠান (ঐচ্ছিক)' : 'Institution (optional)',
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;
    String semesterLabel;
    if (month <= 4) {
      semesterLabel = '$year Spring';
    } else if (month <= 8) {
      semesterLabel = '$year Summer';
    } else {
      semesterLabel = '$year Fall';
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded,
              size: 80, color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            l10n.isBangla ? 'আপনার সেমিস্টার' : 'Your semester',
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            semesterLabel,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.isBangla
                ? 'আপনি যেকোনো সময় সেমিস্টার পরিবর্তন করতে পারবেন।'
                : 'You can change this anytime from Settings.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SubjectsPage extends StatelessWidget {
  const _SubjectsPage({
    required this.formKey,
    required this.subjects,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });
  final GlobalKey<FormState> formKey;
  final List<_SubjectDraft> subjects;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.isBangla ? 'প্রথম বিষয়গুলো' : 'First subjects',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.isBangla
                ? 'অন্তত একটি বিষয় যোগ করুন *'
                : 'Add at least one subject *',
            style: AppTextStyles.bodySmall.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < subjects.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF${subjects[i].color}',
                          radix: 16)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: subjects[i].titleCtl,
                      decoration: InputDecoration(
                        hintText:
                            l10n.isBangla ? 'বিষয়ের নাম *' : 'Subject name *',
                      ),
                      onChanged: (_) => onChanged(),
                      validator: (v) {
                        // Only the last row can be left blank (it represents
                        // the "add another" affordance). Earlier rows are
                        // required once they've been touched.
                        if (i < subjects.length - 1) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.onboardingSubjectNameRequired;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: subjects[i].codeCtl,
                      decoration: const InputDecoration(hintText: 'CSE-101'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(i),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.isBangla ? 'আরেকটি যোগ' : 'Add another'),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalPage extends StatelessWidget {
  const _DailyGoalPage({required this.minutes, required this.onChanged});
  final int minutes;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hours = (minutes / 60).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            l10n.isBangla ? 'দৈনিক লক্ষ্য' : 'Daily goal',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 6),
          Text('$hours h',
              style: AppTextStyles.numericHuge.copyWith(
                color: AppColors.primary,
              )),
          const SizedBox(height: 8),
          Text(
            l10n.isBangla
                ? 'প্রতিদিন কত সময় পড়তে চান?'
                : 'How much do you want to study each day?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            min: 30,
            max: 600,
            divisions: 19,
            value: minutes.toDouble().clamp(30, 600),
            label: '$minutes',
            onChanged: (v) => onChanged(v.round()),
          ),
          const SizedBox(width: 280),
        ],
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.locale, required this.onChanged});
  final Locale locale;
  final ValueChanged<Locale> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language_rounded,
              size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            l10n.isBangla ? 'ভাষা' : 'Language',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          SegmentedButton<Locale>(
            segments: const [
              ButtonSegment(
                value: Locale('en'),
                label: Text('English'),
              ),
              ButtonSegment(
                value: Locale('bn'),
                label: Text('বাংলা'),
              ),
            ],
            selected: {locale},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _ThemePage extends StatelessWidget {
  const _ThemePage({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.brightness_6_rounded,
              size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            l10n.isBangla ? 'থিম' : 'Theme',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}
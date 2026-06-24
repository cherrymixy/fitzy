import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../services/image_store_service.dart';
import '../theme/app_colors.dart';
import '../widgets/local_image.dart';

/// 인증 플로우(Codex SSOT-2): start → 온보딩 4 → 회원가입 6 → 계정 만들기, + 로그인.
/// 절대좌표는 SSOT(393×852, 풀프레임) 기준. 입력 수집 후 ProfileProvider로 생성/로그인.
enum _Step {
  start,
  onb1,
  onb2,
  onb3,
  onb4,
  suNick,
  suId,
  suPw,
  suGender,
  suTags,
  suImage,
  login,
  recover,
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _Step _step = _Step.start;

  final _nick = TextEditingController();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _tags = TextEditingController();
  final _loginId = TextEditingController();
  final _loginPw = TextEditingController();
  final _newPw = TextEditingController();

  bool _agreedTerms = false;
  String? _gender; // 'boy' | 'girl'
  bool _genderPrivate = false;
  String? _imagePath;
  bool _submitting = false;
  bool _forward = true; // 전환 방향(다음=오른쪽에서, 뒤로=왼쪽에서)

  @override
  void dispose() {
    _nick.dispose();
    _id.dispose();
    _pw.dispose();
    _tags.dispose();
    _loginId.dispose();
    _loginPw.dispose();
    _newPw.dispose();
    super.dispose();
  }

  void _go(_Step s, {bool forward = true}) => setState(() {
        _forward = forward;
        _step = s;
      });

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  void _back() {
    const prev = {
      _Step.onb1: _Step.start,
      _Step.onb2: _Step.onb1,
      _Step.onb3: _Step.onb2,
      _Step.onb4: _Step.onb3,
      _Step.suNick: _Step.onb4,
      _Step.suId: _Step.suNick,
      _Step.suPw: _Step.suId,
      _Step.suGender: _Step.suPw,
      _Step.suTags: _Step.suGender,
      _Step.suImage: _Step.suTags,
      _Step.login: _Step.start,
      _Step.recover: _Step.login,
    };
    final p = prev[_step];
    if (p != null) _go(p, forward: false);
  }

  Future<void> _checkId() async {
    final err = ProfileProvider.validateUserId(_id.text.trim());
    if (err != null) {
      _toast(err);
      return;
    }
    final taken =
        await context.read<ProfileProvider>().isUserIdTaken(_id.text.trim());
    if (!mounted) return;
    _toast(taken ? '이미 사용 중인 아이디예요.' : '사용 가능한 아이디예요.');
  }

  Future<void> _pickProfile() async {
    final store = context.read<ImageStoreService>();
    final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f == null) return;
    final saved = await store.save(f.path, dateKey: 'profile', categoryId: 'avatar');
    if (!mounted) return;
    setState(() => _imagePath = saved);
  }

  Future<void> _create() async {
    setState(() => _submitting = true);
    final tags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final err = await context.read<ProfileProvider>().createProfile(
          userId: _id.text.trim(),
          password: _pw.text,
          nickname: _nick.text.trim(),
          gender: _gender ?? '',
          genderPrivate: _genderPrivate,
          tags: tags,
          profileImagePath: _imagePath,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() => _submitting = false);
      _toast(err);
    }
    // 성공 시: ProfileProvider notify → RootGate가 메인으로 전환.
  }

  Future<void> _doLogin() async {
    setState(() => _submitting = true);
    final err = await context
        .read<ProfileProvider>()
        .login(_loginId.text.trim(), _loginPw.text);
    if (!mounted) return;
    if (err != null) {
      setState(() => _submitting = false);
      _toast(err);
    }
  }

  void _next() {
    switch (_step) {
      case _Step.onb1:
        _go(_Step.onb2);
      case _Step.onb2:
        _go(_Step.onb3);
      case _Step.onb3:
        _go(_Step.onb4);
      case _Step.onb4:
        _go(_Step.suNick);
      case _Step.suNick:
        final e = ProfileProvider.validateNickname(_nick.text);
        if (e != null) return _toast(e);
        if (!_agreedTerms) return _toast('약관에 동의해 주세요.');
        _go(_Step.suId);
      case _Step.suId:
        final e = ProfileProvider.validateUserId(_id.text.trim());
        if (e != null) return _toast(e);
        _go(_Step.suPw);
      case _Step.suPw:
        final e = ProfileProvider.validatePassword(_pw.text);
        if (e != null) return _toast(e);
        _go(_Step.suGender);
      case _Step.suGender:
        if (_gender == null) return _toast('성별을 선택해 주세요.');
        _go(_Step.suTags);
      case _Step.suTags:
        _go(_Step.suImage);
      case _Step.suImage:
        _create();
      case _Step.login:
        _doLogin();
      case _Step.start:
      case _Step.recover:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
            ? Duration.zero
            : const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) {
          if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
            return child;
          }
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_forward ? 0.10 : -0.10, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: switch (_step) {
        _Step.start => _start(),
        _Step.onb1 => _onboarding(
            0.25, '하루에 하나,\n코인을 받을 수 있어요.', '다음', false),
        _Step.onb2 => _onboarding(
            0.50, '코인을 넣고\n오늘의 추구미를 뽑아요.', '다음', false),
        _Step.onb3 => _onboarding(
            0.75, '추구미대로 하루를 살며\n9칸 보드를 채워요', '다음', false),
        _Step.onb4 => _onboarding(
            1.0, '캘린더를 채워가며 추구미를\n도달가능미로 만들어요.', '시작하기', true),
        _Step.suNick => _suNick(),
        _Step.suId => _suId(),
        _Step.suPw => _suPw(),
        _Step.suGender => _suGender(),
        _Step.suTags => _suTags(),
        _Step.suImage => _suImage(),
        _Step.login => _login(),
        _Step.recover => _recover(),
          },
        ),
      ),
    );
  }

  // ---------- 공통 요소 ----------

  Widget _backBtn() => Positioned(
        left: 12,
        top: 63,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Color(0xFF202020)),
          onPressed: _back,
        ),
      );

  Widget _bottomBtn(String label, bool dark, VoidCallback onTap, {double top = 774}) {
    return Positioned(
      left: 20,
      right: 20,
      top: top,
      child: GestureDetector(
        onTap: _submitting ? null : onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? AppColors.text : AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.112,
              color: dark ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subtitle(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppColors.grayBold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
            letterSpacing: 0.032,
            color: AppColors.grayBold,
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    int? maxLen,
    bool obscure = false,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: c,
              obscureText: obscure,
              maxLength: maxLen,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                counterText: '',
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.graySubtle,
                ),
              ),
            ),
          ),
          if (maxLen != null)
            Row(
              children: [
                Text('${c.text.characters.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayNormal)),
                Text('/$maxLen',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.graySubtle)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _checkbox(bool value, VoidCallback onTap, Widget label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.text : Colors.transparent,
              border: Border.all(color: AppColors.graySubtle, width: 1.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(child: label),
        ],
      ),
    );
  }

  Widget _formScaffold(String title, String desc, List<Widget> fields,
      String button, VoidCallback onNext, {bool dark = false}) {
    return Stack(
      children: [
        _backBtn(),
        Positioned(
          left: 20,
          top: 129,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subtitle(title, desc),
              const SizedBox(height: 40),
              ...fields,
            ],
          ),
        ),
        _bottomBtn(button, dark, onNext),
      ],
    );
  }

  // ---------- 화면들 ----------

  Widget _start() {
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 340,
          child: Text(
            'Pick Your Fit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.3,
              color: AppColors.text,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 382,
          child: Center(
            child: SvgPicture.asset('assets/images/logo.svg', width: 189),
          ),
        ),
        _bottomBtn('회원가입', false, () => _go(_Step.onb1), top: 726),
        Positioned(
          left: 0,
          right: 0,
          top: 780,
          child: GestureDetector(
            onTap: () => _go(_Step.login),
            child: const Text(
              '이미 회원이신가요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _onboarding(double pct, String title, String button, bool dark) {
    return Stack(
      children: [
        _backBtn(),
        Positioned(
          left: 20,
          top: 116,
          child: Container(
            width: 353,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.text,
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 29,
          top: 661,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 27.4,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.text,
            ),
          ),
        ),
        _bottomBtn(button, dark, _next),
      ],
    );
  }

  Widget _suNick() => _formScaffold(
        '닉네임을 입력해주세요',
        '마이페이지에서 언제든지 바꿀 수 있어요.',
        [
          _field(_nick, '닉네임', maxLen: 12),
          const SizedBox(height: 12),
          _checkbox(
            _agreedTerms,
            () => setState(() => _agreedTerms = !_agreedTerms),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grayBold,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                      text: '서비스이용약관',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                  TextSpan(text: '과 '),
                  TextSpan(
                      text: '개인정보취급방침',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                  TextSpan(text: '에 동의합니다.'),
                ],
              ),
            ),
          ),
        ],
        '다음',
        _next,
      );

  Widget _suId() => _formScaffold(
        '아이디를 입력해주세요',
        '한 번 정하면 바꿀 수 없으니 신중히 만들어 주세요.',
        [
          _field(_id, 'ID (영소문자, 숫자 조합)', maxLen: 20),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _checkId,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('중복 검사',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ),
          ),
        ],
        '다음',
        _next,
      );

  Widget _suPw() => _formScaffold(
        '패스워드를 입력해주세요',
        '잃어버리면 찾을 수 없어요.',
        [_field(_pw, 'Password (영문, 특수문자, 숫자 조합)', obscure: true)],
        '다음',
        _next,
      );

  Widget _suGender() => _formScaffold(
        '성별을 선택해 주세요',
        '자판기 속 이미지의 모델 성별에 반영돼요.',
        [
          Row(
            children: [
              Expanded(child: _genderChoice('남자', 'boy')),
              const SizedBox(width: 7),
              Expanded(child: _genderChoice('여자', 'girl')),
            ],
          ),
          const SizedBox(height: 12),
          _checkbox(
            _genderPrivate,
            () => setState(() => _genderPrivate = !_genderPrivate),
            const Text('성별을 공개하고 싶지 않아요.',
                style: TextStyle(fontSize: 16, color: AppColors.grayBold)),
          ),
        ],
        '다음',
        _next,
      );

  Widget _genderChoice(String label, String value) {
    final sel = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? AppColors.text : AppColors.background,
          border: Border.all(color: sel ? AppColors.text : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: sel ? Colors.white : const Color(0xFF202020),
          ),
        ),
      ),
    );
  }

  Widget _suTags() => _formScaffold(
        '나를 표현하는 태그를 입력해주세요',
        '쉼표로 구분해서 작성해 주세요.',
        [_field(_tags, '러블리, 미니멀')],
        '다음',
        _next,
      );

  Widget _suImage() {
    final store = context.read<ImageStoreService>();
    return Stack(
      children: [
        _backBtn(),
        Positioned(
          left: 20,
          right: 20,
          top: 129,
          child: Column(
            children: [
              _subtitle('프로필 이미지를 올려주세요', '마이페이지에서 언제든지 바꿀 수 있어요.'),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _pickProfile,
                child: SizedBox(
                  width: 171,
                  height: 171,
                  child: Stack(
                    children: [
                      Container(
                        width: 171,
                        height: 171,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF7F7F7),
                        ),
                        child: _imagePath == null
                            ? null
                            : localImage(store.resolve(_imagePath!),
                                fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 129,
                        top: 131,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkButton,
                          ),
                          child: SvgPicture.asset(
                            'assets/images/icons/pen.svg',
                            width: 22,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _bottomBtn('계정 만들기', true, _next),
      ],
    );
  }

  Widget _login() {
    return Stack(
      children: [
        _backBtn(),
        Positioned(
          left: 20,
          right: 20,
          top: 129,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subtitle('로그인 해주세요', '가입할 때 정한 아이디와 패스워드를 입력해 주세요.'),
              const SizedBox(height: 40),
              _field(_loginId, 'ID'),
              const SizedBox(height: 12),
              _field(_loginPw, 'Password', obscure: true),
            ],
          ),
        ),
        _bottomBtn('로그인', true, _next, top: 747),
        Positioned(
          left: 0,
          right: 0,
          top: 801,
          child: GestureDetector(
            onTap: () => _go(_Step.recover),
            child: const Text(
              'ID/패스워드를 까먹으셨나요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _doReset() async {
    final err =
        await context.read<ProfileProvider>().resetPassword(_newPw.text);
    if (!mounted) return;
    if (err != null) {
      _toast(err);
      return;
    }
    _toast('패스워드를 변경했어요. 새 패스워드로 로그인해 주세요.');
    _newPw.clear();
    _go(_Step.login, forward: false);
  }

  Widget _recover() {
    final id = context.read<ProfileProvider>().registeredUserId;
    return _formScaffold(
      '계정을 잊으셨나요?',
      '가입된 아이디를 확인하고 패스워드를 새로 정할 수 있어요.',
      [
        Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.coin,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            id == null ? '가입된 계정이 없어요.' : '가입된 아이디 · $id',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: id == null ? AppColors.graySubtle : AppColors.grayBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _field(_newPw, '새 패스워드 (영문, 특수문자, 숫자 조합)', obscure: true),
      ],
      '패스워드 재설정',
      _doReset,
      dark: true,
    );
  }
}

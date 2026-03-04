import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cashier/bottom_controls.dart';
import 'cashier/models.dart';
import 'cashier/register_panel.dart';
import 'cashier/right_panel.dart';
import 'cashier/store_panel.dart';

class _StoreItem extends StoreItem {
  const _StoreItem({
    required super.id,
    required super.name,
    required super.icon,
    required super.priceCents,
  });
}

class _CustomerOrder extends CustomerOrder {
  const _CustomerOrder({
    required super.id,
    required super.name,
    required super.emoji,
    required super.items,
    required super.paidCents,
  });
}

class _MoneyToken extends MoneyToken {
  _MoneyToken({
    required super.id,
    required super.cents,
    required super.position,
  });
}

enum _CheckoutStage {
  scanning,
  paymentInfo,
  makingChange,
  checkedOut,
  sessionComplete,
}

class CashierGameScreen extends StatefulWidget {
  const CashierGameScreen({super.key});

  @override
  State<CashierGameScreen> createState() => _CashierGameScreenState();
}

class _CashierGameScreenState extends State<CashierGameScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  SharedPreferences? _preferences;

  final Map<String, String> originalTexts = {
    'title': 'Decimal Cashier',
    'score': 'Score',
    'best': 'Best',
    'streak': 'Streak',
    'storeScene': 'Store Counter Scene',
    'register': 'Register',
    'questionPanel': 'Question Panel',
    'scanLane': 'Scan Lane',
    'basket': 'Basket Items',
    'subtotal': 'Subtotal',
    'paid': 'Paid',
    'changeDue': 'Change Due',
    'remaining': 'Remaining Items',
    'scanned': 'Scanned Items',
    'scanAll': 'Scan all items first.',
    'openRegister': 'Open Register',
    'checkChange': 'Check Change',
    'nextCustomer': 'Next Customer',
    'replay': 'Replay',
    'hint': 'Hint',
    'restart': 'Restart Session',
    'sessionDone': 'All 3 customers checked out!',
    'aisle': 'Aisle 5 • Grocery',
    'scanPrompt': 'Drag item to scanner',
    'drawerOpen': 'Drawer Open',
    'drawerClosed': 'Drawer Closed',
    'customerTray': 'Customer Tray',
    'customerCard': 'Current Customer',
    'cashierCard': 'Cashier',
    'promptScan': 'Customer {name} is ready. Drag each item across the scanner.',
    'promptPay': 'Total is {total}. Customer pays {paid}.',
    'promptChange': 'Give exact change: {change}. Use the register and tray.',
    'promptDone': 'Great! Customer {name} checked out.',
    'hintScan': 'Drag every item card into the scanner lane.',
    'hintChange': 'Change = paid - total. Build that amount in the tray.',
    'correct': 'Perfect change. Checkout complete!',
    'incorrect': 'Not exact yet. Try adjusting coins/bills.',
  };

  Map<String, String> translatedTexts = {};
  bool translated = false;

  final List<_StoreItem> _catalog = const [
    _StoreItem(id: 'milk', name: 'Milk', icon: '🥛', priceCents: 150),
    _StoreItem(id: 'bread', name: 'Bread', icon: '🍞', priceCents: 225),
    _StoreItem(id: 'apple', name: 'Apple', icon: '🍎', priceCents: 75),
    _StoreItem(id: 'juice', name: 'Juice', icon: '🧃', priceCents: 125),
    _StoreItem(id: 'cereal', name: 'Cereal', icon: '🥣', priceCents: 340),
    _StoreItem(id: 'eggs', name: 'Eggs', icon: '🥚', priceCents: 260),
    _StoreItem(id: 'banana', name: 'Banana', icon: '🍌', priceCents: 90),
    _StoreItem(id: 'cheese', name: 'Cheese', icon: '🧀', priceCents: 315),
    _StoreItem(id: 'chips', name: 'Chips', icon: '🍟', priceCents: 185),
  ];

  final List<int> _denominations = [100, 50, 25, 10, 5, 1];
  final List<_MoneyToken> _registerTokens = [];
  final Map<int, int> _drawerStock = {
    100: 8,
    50: 10,
    25: 14,
    10: 16,
    5: 18,
    1: 50,
  };

  final List<String> _customerNames = ['Mia', 'Leo', 'Ava', 'Noah', 'Ella'];
  final List<String> _customerEmojis = ['🙂', '😀', '🛒', '👧', '👦'];

  final List<_CustomerOrder> _customers = [];
  int _currentCustomerIndex = 0;
  _CheckoutStage _stage = _CheckoutStage.scanning;

  final Set<String> _scannedItemIds = <String>{};
  int _subtotalCents = 0;
  int _changeDueCents = 0;

  int _score = 0;
  int _bestScore = 0;
  int _streak = 0;

  Size _registerSize = Size.zero;
  int _tokenIdCounter = 0;
  int? _activeTokenId;
  final Map<int, Offset> _dragVisualByTokenId = <int, Offset>{};
  double _drawerScrollOffset = 0;
  bool _speechEnabled = true;

  late AnimationController _characterController;
  late Animation<double> _characterFloat;

  _CustomerOrder get _currentCustomer => _customers[_currentCustomerIndex];

  int get _trayTotalCents => _registerTokens
      .where((token) => token.inTray)
      .fold(0, (sum, token) => sum + token.cents);

  @override
  void initState() {
    super.initState();
    _speechEnabled = true;
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _characterFloat = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.easeInOut),
    );

    _loadBestScore();
    _startNewSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speak(_instructionText());
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _characterController.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = _preferences?.getInt('cashier_session_best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = _preferences;
    if (prefs == null) {
      return;
    }
    if (_score > _bestScore) {
      setState(() {
        _bestScore = _score;
      });
      await prefs.setInt('cashier_session_best_score', _score);
    }
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (_) {}
  }

  Future<void> _speak(String text, {bool userInitiated = false}) async {
    if (!_speechEnabled || text.trim().isEmpty) {
      return;
    }
    if (kIsWeb && !userInitiated) {
      return;
    }
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setPitch(1.00);
      await _flutterTts.speak(text);
    } catch (_) {
      _speechEnabled = false;
    }
  }

  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': originalTexts.values.toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedTexts = {
            for (int index = 0; index < originalTexts.keys.length; index++)
              originalTexts.keys.elementAt(index): data['translations'][index],
          };
          translated = true;
        });
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
    }
  }

  String _t(String key) {
    if (translated) {
      return translatedTexts[key] ?? originalTexts[key] ?? key;
    }
    return originalTexts[key] ?? key;
  }

  String _template(String key, Map<String, String> values) {
    String text = _t(key);
    for (final entry in values.entries) {
      if (!text.contains('{${entry.key}}')) {
        text = originalTexts[key] ?? text;
        break;
      }
    }
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  int _wholeDollarPaymentAbove(int totalCents) {
    final int baseDollars = (totalCents / 100).ceil();
    final int extraDollars = 1 + _random.nextInt(2);
    return (baseDollars + extraDollars) * 100;
  }

  void _startNewSession() {
    _customers.clear();
    _score = 0;
    _streak = 0;
    _currentCustomerIndex = 0;

    for (int customerId = 0; customerId < 3; customerId++) {
      final int itemCount = 2 + _random.nextInt(3);
      final List<_StoreItem> shuffled = [..._catalog]..shuffle(_random);
      final List<_StoreItem> selected = shuffled.take(itemCount).toList();
      final int total = selected.fold(0, (sum, item) => sum + item.priceCents);
      final int paid = _wholeDollarPaymentAbove(total);

      _customers.add(
        _CustomerOrder(
          id: customerId,
          name: _customerNames[_random.nextInt(_customerNames.length)],
          emoji: _customerEmojis[_random.nextInt(_customerEmojis.length)],
          items: selected,
          paidCents: paid,
        ),
      );
    }

    _prepareCurrentCustomer();
  }

  void _prepareCurrentCustomer() {
    _scannedItemIds.clear();
    _subtotalCents = 0;
    _changeDueCents = 0;
    _registerTokens.clear();
    _dragVisualByTokenId.clear();
    _drawerScrollOffset = 0;
    _stage = _CheckoutStage.scanning;
    _activeTokenId = null;
    setState(() {});
  }

  void _scanItem(StoreItem item) async {
    if (_stage != _CheckoutStage.scanning) {
      return;
    }
    if (_scannedItemIds.contains(item.id)) {
      return;
    }

    setState(() {
      _scannedItemIds.add(item.id);
      _subtotalCents += item.priceCents;
    });

    await _playSound('sounds/success.mp3');

    final bool allScanned = _scannedItemIds.length == _currentCustomer.items.length;
    if (allScanned) {
      setState(() {
        _changeDueCents = _currentCustomer.paidCents - _subtotalCents;
        _stage = _CheckoutStage.paymentInfo;
      });
      await _speak(_instructionText());
    }
  }

  Rect _drawerRect(Size size) {
    final double drawerHeight = (size.height * 0.30).clamp(132.0, 200.0);
    final double top = _registerSectionTop(size, drawerHeight);
    final double drawerWidth = size.width * 0.40;
    return Rect.fromLTWH(
      18,
      top,
      drawerWidth,
      drawerHeight,
    );
  }

  Rect _trayRect(Size size) {
    final double trayHeight = (size.height * 0.30).clamp(132.0, 200.0);
    final double top = _registerSectionTop(size, trayHeight);
    final double left = size.width * 0.54;
    final double width = max(120.0, size.width - left - 18);
    return Rect.fromLTWH(
      left,
      top,
      width,
      trayHeight,
    );
  }

  double _registerSectionTop(Size size, double sectionHeight) {
    final double maxVisibleTop = size.height - sectionHeight - 12;
    final double compactness = ((520 - size.height) / 220).clamp(0.0, 1.0);
    final double targetFactor = 0.42 - (0.14 * compactness);
    final double desiredTop = size.height * targetFactor;
    const double minTop = 170;

    if (maxVisibleTop <= minTop) {
      return max(16.0, maxVisibleTop);
    }
    return desiredTop.clamp(minTop, maxVisibleTop).toDouble();
  }

  Offset _tokenSettledVisualPosition(_MoneyToken token) {
    if (token.inTray) {
      return token.position;
    }
    return Offset(token.position.dx, token.position.dy - _drawerScrollOffset);
  }

  Offset _tokenVisualPosition(_MoneyToken token) {
    return _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
  }

  Offset _drawerContentPositionFromVisual(Offset visualPosition) {
    return Offset(visualPosition.dx, visualPosition.dy + _drawerScrollOffset);
  }

  bool _tokenWouldBeInTrayAt(Offset visualPosition) {
    const double tokenSize = 34;
    final tray = _trayRect(_registerSize).inflate(10);
    final center = visualPosition + const Offset(tokenSize / 2, tokenSize / 2);
    return tray.contains(center);
  }

  Offset _clampVisualTokenPosition(Offset visualPosition) {
    const double tokenSize = 34;
    final double clampedX = visualPosition.dx.clamp(6.0, _registerSize.width - tokenSize - 6);
    final double clampedY = visualPosition.dy.clamp(6.0, _registerSize.height - tokenSize - 6);
    return Offset(clampedX, clampedY);
  }

  List<Offset> _traySlots(Rect tray) {
    const double tokenSize = 34;
    final slotX = <double>[0.18, 0.40, 0.62, 0.84]
        .map((factor) => tray.left + (tray.width * factor) - (tokenSize / 2))
        .toList();
    final slotY = <double>[0.20, 0.42, 0.64, 0.84]
        .map((factor) => tray.top + (tray.height * factor) - (tokenSize / 2))
        .toList();

    final slots = <Offset>[];
    for (final y in slotY) {
      for (final x in slotX) {
        slots.add(Offset(x, y));
      }
    }
    return slots;
  }

  List<Offset> _drawerSlots(Rect drawer, int slotCount) {
    const double tokenSize = 34;
    const double gap = 5;
    final int columns = max(4, ((drawer.width - 16) / (tokenSize + gap)).floor());
    final slots = <Offset>[];

    for (int index = 0; index < slotCount; index++) {
      final int col = index % columns;
      final int row = index ~/ columns;
      final double x = drawer.left + 10 + (col * (tokenSize + gap));
      final double y = drawer.top + 10 + (row * (tokenSize + gap));
      slots.add(Offset(x, y));
    }
    return slots;
  }

  Offset _nearestFreeSlot({
    required Offset target,
    required List<Offset> candidates,
    required List<Offset> occupied,
    required double minDistance,
  }) {
    Offset best = candidates.first;
    double bestDistance = double.infinity;

    for (final candidate in candidates) {
      final bool isOccupied = occupied.any(
        (point) => (point - candidate).distance < minDistance,
      );
      if (isOccupied) {
        continue;
      }
      final double distance = (candidate - target).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = candidate;
      }
    }

    if (bestDistance.isFinite) {
      return best;
    }

    return candidates.reduce(
      (a, b) => (a - target).distance < (b - target).distance ? a : b,
    );
  }

  void _settleTokenFromVisual(
    _MoneyToken token,
    Offset releaseVisualPosition,
    Offset releaseVelocity,
  ) {
    final Offset momentumAdjusted = _clampVisualTokenPosition(
      releaseVisualPosition +
          Offset(
            (releaseVelocity.dx * 0.008).clamp(-18.0, 18.0),
            (releaseVelocity.dy * 0.008).clamp(-18.0, 18.0),
          ),
    );

    if (_tokenWouldBeInTrayAt(momentumAdjusted)) {
      final Rect tray = _trayRect(_registerSize);
      final List<Offset> slots = _traySlots(tray);
      final List<Offset> occupied = _registerTokens
          .where((other) => other.id != token.id && other.inTray)
          .map((other) => other.position)
          .toList();

      token.inTray = true;
      token.position = _nearestFreeSlot(
        target: momentumAdjusted,
        candidates: slots,
        occupied: occupied,
        minDistance: 26,
      );
      return;
    }

    final Rect drawer = _drawerRect(_registerSize);
    final Offset contentTarget = _drawerContentPositionFromVisual(momentumAdjusted);
    final int drawerTokenCount = _registerTokens.where((other) => !other.inTray).length;
    final List<Offset> slots = _drawerSlots(drawer, max(drawerTokenCount + 8, 24));
    final List<Offset> occupied = _registerTokens
        .where((other) => other.id != token.id && !other.inTray)
        .map((other) => other.position)
        .toList();

    token.inTray = false;
    token.position = _nearestFreeSlot(
      target: contentTarget,
      candidates: slots,
      occupied: occupied,
      minDistance: 20,
    );
  }

  void _buildRegisterTokens() {
    _registerTokens.clear();
    _dragVisualByTokenId.clear();
    final drawer = _drawerRect(_registerSize);

    final List<int> drawerContents = <int>[];
    for (final denomination in _denominations) {
      final int count = _drawerStock[denomination] ?? 0;
      for (int index = 0; index < count; index++) {
        drawerContents.add(denomination);
      }
    }

    final List<Offset> drawerSlots = _drawerSlots(drawer, drawerContents.length + 12);

    for (int i = 0; i < drawerContents.length; i++) {
      _registerTokens.add(
        _MoneyToken(
          id: _tokenIdCounter++,
          cents: drawerContents[i],
          position: drawerSlots[i],
        ),
      );
    }

    _drawerScrollOffset = 0;
  }

  double _drawerScrollMaxExtent() {
    if (_registerSize == Size.zero) {
      return 0;
    }

    final drawer = _drawerRect(_registerSize);
    const double tokenSize = 34;
    const double gap = 5;
    final int columns = max(4, ((drawer.width - 16) / (tokenSize + gap)).floor());
    final int tokenCount = _registerTokens.where((token) => !token.inTray).length;
    final int rows = (tokenCount / columns).ceil();
    final double contentHeight = 10 + (rows * (tokenSize + gap));
    final double viewportHeight = drawer.height - 16;
    return max(0.0, contentHeight - viewportHeight);
  }

  void _scrollDrawerBy(double delta) {
    final double maxExtent = _drawerScrollMaxExtent();
    if (maxExtent <= 0) {
      return;
    }
    setState(() {
      _drawerScrollOffset = (_drawerScrollOffset + delta).clamp(0.0, maxExtent);
    });
  }

  void _openRegister() {
    if (_stage != _CheckoutStage.paymentInfo) {
      return;
    }

    setState(() {
      _stage = _CheckoutStage.makingChange;
      if (_registerSize != Size.zero) {
        _buildRegisterTokens();
      }
    });
    _speak(_instructionText(), userInitiated: true);
  }

  void _applyTokenMomentum(_MoneyToken token, Offset velocity) {
    final Offset releaseVisual = _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
    _settleTokenFromVisual(token, releaseVisual, velocity);
  }

  void _checkChange() async {
    if (_stage != _CheckoutStage.makingChange) {
      return;
    }

    final bool correct = _trayTotalCents == _changeDueCents;
    if (correct) {
      setState(() {
        _stage = _CheckoutStage.checkedOut;
        _score += 20;
        _streak += 1;
      });
      _saveBestScore();
      await _playSound('sounds/success.mp3');
      await _speak(_t('correct'));
    } else {
      setState(() {
        _streak = 0;
      });
      await _playSound('sounds/error.mp3');
      await _speak(_t('incorrect'));
    }
  }

  void _nextCustomer() {
    if (_stage != _CheckoutStage.checkedOut) {
      return;
    }

    if (_currentCustomerIndex < _customers.length - 1) {
      setState(() {
        _currentCustomerIndex += 1;
      });
      _prepareCurrentCustomer();
      _speak(_instructionText());
    } else {
      setState(() {
        _stage = _CheckoutStage.sessionComplete;
      });
      _saveBestScore();
      _speak(_t('sessionDone'));
    }
  }

  String _instructionText() {
    switch (_stage) {
      case _CheckoutStage.scanning:
        return _template(
          'promptScan',
          {'name': _currentCustomer.name},
        );
      case _CheckoutStage.paymentInfo:
        return _template(
          'promptPay',
          {
            'total': _money(_subtotalCents),
            'paid': _money(_currentCustomer.paidCents),
          },
        );
      case _CheckoutStage.makingChange:
        return _template(
          'promptChange',
          {'change': _money(_changeDueCents)},
        );
      case _CheckoutStage.checkedOut:
        return _template(
          'promptDone',
          {'name': _currentCustomer.name},
        );
      case _CheckoutStage.sessionComplete:
        return _t('sessionDone');
    }
  }

  String _hintText() {
    if (_stage == _CheckoutStage.scanning) {
      return _t('hintScan');
    }
    return _t('hintChange');
  }

  Widget _buildTopBadges() {
    Widget badge(String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        badge(_t('score'), '$_score', Colors.indigo),
        badge(_t('best'), '$_bestScore', Colors.teal),
        badge(_t('streak'), '$_streak', Colors.deepOrange),
      ],
    );
  }

  Widget _buildStoreScene() {
    return CashierStorePanel(
      aisleLabel: _t('aisle'),
      basketLabel: _t('basket'),
      cashierCardLabel: _t('cashierCard'),
      storeSceneLabel: _t('storeScene'),
      customerCardLabel: _t('customerCard'),
      scanLaneLabel: _t('scanLane'),
      scanPromptLabel: _t('scanPrompt'),
      customer: _currentCustomer,
      scannedItemIds: _scannedItemIds,
      isScanningStage: _stage == _CheckoutStage.scanning,
      characterFloat: _characterFloat,
      onScanItem: _scanItem,
      moneyText: _money,
    );
  }

  Widget _buildRegisterScene() {
    return CashierRegisterPanel(
      registerLabel: _t('register'),
      drawerClosedLabel: _t('drawerClosed'),
      customerTrayLabel: _t('customerTray'),
      trayTotalText: '${_money(_trayTotalCents)} / ${_money(_changeDueCents)}',
      drawerRectForSize: _drawerRect,
      trayRectForSize: _trayRect,
      drawerOpen:
          _stage == _CheckoutStage.makingChange || _stage == _CheckoutStage.checkedOut,
      showTokens:
          _stage == _CheckoutStage.makingChange || _stage == _CheckoutStage.checkedOut,
      registerTokens: _registerTokens,
      buildToken: (token) => _buildRegisterToken(token as _MoneyToken),
      drawerScrollOffset: _drawerScrollOffset,
      drawerScrollMaxExtent: _drawerScrollMaxExtent,
      onScrollDrawerBy: _scrollDrawerBy,
      onDrawerScrollSet: (offset) {
        setState(() {
          _drawerScrollOffset = offset;
        });
      },
      onSizeChanged: (size) {
        if (_registerSize != size) {
          _registerSize = size;
          if (_stage == _CheckoutStage.makingChange && _registerTokens.isEmpty) {
            _buildRegisterTokens();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
    );
  }

  Widget _buildRegisterToken(_MoneyToken token) {
    const double tokenSize = 34;
    final bool isBill = token.cents >= 100;
    final drawer = _drawerRect(_registerSize);
    final bool inDrawer = !token.inTray;
    final Offset visualPosition = _tokenVisualPosition(token);
    final bool hiddenInDrawer = inDrawer &&
      token.id != _activeTokenId &&
      (visualPosition.dy + tokenSize < drawer.top || visualPosition.dy > drawer.bottom);

    if (hiddenInDrawer) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: visualPosition.dx,
      top: visualPosition.dy,
      child: GestureDetector(
        onPanStart: (_) {
          if (_stage != _CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            _activeTokenId = token.id;
            _dragVisualByTokenId[token.id] = _tokenSettledVisualPosition(token);
          });
        },
        onPanUpdate: (details) {
          if (_stage != _CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            final Offset baseVisual =
                _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
            _dragVisualByTokenId[token.id] =
                _clampVisualTokenPosition(baseVisual + details.delta);
          });
        },
        onPanEnd: (details) {
          if (_stage != _CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            _applyTokenMomentum(token, details.velocity.pixelsPerSecond);
            _dragVisualByTokenId.remove(token.id);
            _activeTokenId = null;
          });
        },
        onPanCancel: () {
          setState(() {
            if (_activeTokenId == token.id) {
              _applyTokenMomentum(token, Offset.zero);
              _dragVisualByTokenId.remove(token.id);
            }
            _activeTokenId = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: tokenSize,
          height: tokenSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isBill
                  ? [const Color(0xFFB9E6AF), const Color(0xFF76B96D)]
                  : [const Color(0xFFF2D46D), const Color(0xFFDCAF34)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isBill ? 8 : 22),
            border: Border.all(
              color: token.inTray ? Colors.deepPurple : Colors.brown.shade700,
              width: token.inTray || _activeTokenId == token.id ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              token.cents >= 100 ? '\$${token.cents ~/ 100}' : '${token.cents}¢',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return CashierRightPanel(
      questionPanelLabel: _t('questionPanel'),
      instructionText: _instructionText(),
      subtotalLabel: _t('subtotal'),
      paidLabel: _t('paid'),
      changeDueLabel: _t('changeDue'),
      scannedLabel: _t('scanned'),
      remainingLabel: _t('remaining'),
      sessionDoneLabel: _t('sessionDone'),
      customer: _currentCustomer,
      scannedItemIds: _scannedItemIds,
      subtotalCents: _subtotalCents,
      changeDueCents: _changeDueCents,
      isSessionComplete: _stage == _CheckoutStage.sessionComplete,
      moneyText: _money,
    );
  }

  Widget _buildBottomControls() {
    return CashierBottomControls(
      replayLabel: _t('replay'),
      hintLabel: _t('hint'),
      openRegisterLabel: _t('openRegister'),
      checkChangeLabel: _t('checkChange'),
      nextCustomerLabel: _t('nextCustomer'),
      restartLabel: _t('restart'),
      onReplay: () => _speak(_instructionText(), userInitiated: true),
      onHint: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_hintText())),
        );
      },
      onOpenRegister: _openRegister,
      onCheckChange: _checkChange,
      onNextCustomer: _nextCustomer,
      onRestart: _startNewSession,
      canOpenRegister: _stage == _CheckoutStage.paymentInfo,
      canCheckChange: _stage == _CheckoutStage.makingChange,
      canNextCustomer: _stage == _CheckoutStage.checkedOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title')),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            onPressed: translateTexts,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 86,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildTopBadges(),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: _buildStoreScene()),
                      const SizedBox(width: 10),
                      Expanded(flex: 5, child: _buildRegisterScene()),
                      const SizedBox(width: 10),
                      Expanded(flex: 4, child: _buildRightPanel()),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

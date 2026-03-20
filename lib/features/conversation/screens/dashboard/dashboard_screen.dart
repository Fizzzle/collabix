import 'dart:math' as math;
import 'package:collabix/features/conversation/screens/dashboard/dashboards_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class DashBoardColor {
  static const bg = Color(0xFF0F0F13);
  static const surface = Color(0xFF1A1A22);
  static const border = Color(0xFF2A2A38);
  static const text = Color(0xFFEEEEF5);
  static const textMuted = Color(0xFF6B6B80);
  static const stickerGreen = Color(0xFF9AE600);
  static const stickerCyan = Color(0xFF52E8F5);
  static const stickerPurple = Color(0xFFED6AFF);
}

enum StickerColor { green, cyan, purple }

extension StickerColorExt on StickerColor {
  Color get color {
    switch (this) {
      case StickerColor.green:
        return DashBoardColor.stickerGreen;
      case StickerColor.cyan:
        return DashBoardColor.stickerCyan;
      case StickerColor.purple:
        return DashBoardColor.stickerPurple;
    }
  }

  String get lottiePath {
    switch (this) {
      case StickerColor.green:
        return 'assets/anim/green_stick.json';
      case StickerColor.cyan:
        return 'assets/anim/blue_stick.json';
      case StickerColor.purple:
        return 'assets/anim/purple_stick.json';
    }
  }
}

class StickerModel {
  final String id;
  String title;
  Offset position;
  StickerColor stickerColor;
  final DateTime createdAt;

  StickerModel({
    required this.id,
    required this.title,
    required this.position,
    required this.stickerColor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => stickerColor.color;
}

class ConnectionModel {
  final String fromId;
  final String toId;
  ConnectionModel({required this.fromId, required this.toId});
}

enum ToolMode { move, create }

class _LottieLayer {
  final StickerColor color;
  final AnimationController ctrl;

  bool isBase;

  _LottieLayer({required this.color, required this.ctrl, required this.isBase});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Offset _boardOffset = Offset.zero;
  double _boardScale = 1.0;
  Offset _focalStart = Offset.zero;
  Offset _boardOffsetAtStart = Offset.zero;
  double _scaleAtStart = 1.0;
  int _activePointers = 0;

  final List<StickerModel> _stickers = [
    StickerModel(
      id: '1',
      title: 'Gen Z marketing strategy',
      position: const Offset(160, 100),
      stickerColor: StickerColor.green,
    ),
    StickerModel(
      id: '2',
      title: 'TikTok campaigns',
      position: const Offset(380, 80),
      stickerColor: StickerColor.cyan,
    ),
    StickerModel(
      id: '3',
      title: 'Influencer outreach',
      position: const Offset(240, 290),
      stickerColor: StickerColor.purple,
    ),
  ];

  final List<ConnectionModel> _connections = [
    ConnectionModel(fromId: '1', toId: '2'),
    ConnectionModel(fromId: '1', toId: '3'),
  ];

  ToolMode _mode = ToolMode.move;
  String? _draggingId;
  Offset _dragLocalOffset = Offset.zero;
  String? _connectingFromId;
  Offset? _connectingEndWorld;
  String? _selectedStickerId;
  String? _hoveredStickerId;

  late AnimationController _pulseCtrl;
  int _stickerCount = 4;

  final Map<String, List<_LottieLayer>> _lottieLayers = {};

  final Map<String, StickerColor> _animatingTo = {};

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    for (final s in _stickers) {
      _buildBaseLayer(s.id, s.stickerColor);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    for (final layers in _lottieLayers.values) {
      for (final l in layers) {
        l.ctrl.dispose();
      }
    }
    super.dispose();
  }

  void _buildBaseLayer(String id, StickerColor color) {
    final ctrl = AnimationController(vsync: this, value: 1.0);
    _lottieLayers[id] = [_LottieLayer(color: color, ctrl: ctrl, isBase: true)];
  }

  Offset _toBoard(Offset screen) => (screen - _boardOffset) / _boardScale;
  Offset _toScreen(Offset board) => board * _boardScale + _boardOffset;
  Offset _stickerCenter(StickerModel s) => s.position + const Offset(90, 90);

  StickerModel? _findSticker(String id) {
    try {
      return _stickers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void _changeStickerColor(String id, StickerColor newColor) {
    final sticker = _findSticker(id);
    if (sticker == null) return;

    final targetColor = _animatingTo[id] ?? sticker.stickerColor;
    if (targetColor == newColor) return;

    final layers = _lottieLayers[id];
    if (layers == null) return;

    if (layers.length > 1) {
      for (int i = 1; i < layers.length; i++) {
        layers[i].ctrl.dispose();
      }
      layers.removeRange(1, layers.length);
    }

    _animatingTo[id] = newColor;

    final overlayCtrl = AnimationController(vsync: this);

    setState(() {
      layers.add(
        _LottieLayer(color: newColor, ctrl: overlayCtrl, isBase: false),
      );
    });

    overlayCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          sticker.stickerColor = newColor;
          _animatingTo.remove(id);

          final currentLayers = _lottieLayers[id];
          if (currentLayers == null || currentLayers.isEmpty) return;

          for (int i = 0; i < currentLayers.length - 1; i++) {
            currentLayers[i].ctrl.dispose();
          }

          final promoted = currentLayers.last;
          promoted.isBase = true;
          _lottieLayers[id] = [promoted];
        });
      }
    });
  }

  void _flyToSticker(StickerModel s) {
    final size = MediaQuery.of(context).size;
    final target = Offset(
      size.width / 2 - _stickerCenter(s).dx * _boardScale,
      size.height / 2 - _stickerCenter(s).dy * _boardScale,
    );
    final from = _boardOffset;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
    ctrl.addListener(
      () =>
          setState(() => _boardOffset = Offset.lerp(from, target, anim.value)!),
    );
    ctrl.addStatusListener((st) {
      if (st == AnimationStatus.completed) ctrl.dispose();
    });
    ctrl.forward();
  }

  void _addSticker(StickerColor color) {
    final rng = math.Random();
    final center = _toBoard(
      Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
    );
    final newId = '${++_stickerCount}';

    final sticker = StickerModel(
      id: newId,
      title: 'New note',
      position:
          center +
          Offset((rng.nextDouble() - .5) * 120, (rng.nextDouble() - .5) * 120),
      stickerColor: color,
    );

    final baseCtrl = AnimationController(vsync: this, value: 0.0);
    final overlayCtrl = AnimationController(vsync: this);

    _animatingTo[newId] = color;
    _lottieLayers[newId] = [
      _LottieLayer(color: color, ctrl: baseCtrl, isBase: true),
      _LottieLayer(color: color, ctrl: overlayCtrl, isBase: false),
    ];

    setState(() {
      _stickers.add(sticker);
      _mode = ToolMode.move;
    });

    overlayCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _animatingTo.remove(newId);
          final currentLayers = _lottieLayers[newId];
          if (currentLayers == null || currentLayers.isEmpty) return;

          for (int i = 0; i < currentLayers.length - 1; i++) {
            currentLayers[i].ctrl.dispose();
          }
          final promoted = currentLayers.last;
          promoted.isBase = true;
          _lottieLayers[newId] = [promoted];
        });
      }
    });
  }

  void _deleteSticker(String id) {
    final layers = _lottieLayers.remove(id);
    if (layers != null) {
      for (final l in layers) {
        l.ctrl.dispose();
      }
    }
    _animatingTo.remove(id);
    setState(() {
      _stickers.removeWhere((s) => s.id == id);
      _connections.removeWhere((c) => c.fromId == id || c.toId == id);
      if (_selectedStickerId == id) _selectedStickerId = null;
    });
  }

  void _startConnecting(String fromId) {
    final s = _findSticker(fromId);
    if (s == null) return;
    setState(() {
      _connectingFromId = fromId;
      _connectingEndWorld = _stickerCenter(s);
    });
  }

  void _finishConnectionTo(String toId) {
    if (_connectingFromId == null || _connectingFromId == toId) {
      setState(() {
        _connectingFromId = null;
        _connectingEndWorld = null;
      });
      return;
    }
    final exists = _connections.any(
      (c) =>
          (c.fromId == _connectingFromId && c.toId == toId) ||
          (c.fromId == toId && c.toId == _connectingFromId),
    );
    if (!exists) {
      setState(
        () => _connections.add(
          ConnectionModel(fromId: _connectingFromId!, toId: toId),
        ),
      );
    }
    setState(() {
      _connectingFromId = null;
      _connectingEndWorld = null;
    });
  }

  void _cancelConnecting() => setState(() {
    _connectingFromId = null;
    _connectingEndWorld = null;
  });

  void _confirmRemoveConnection(String fromId, String toId) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: DashBoardColor.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: DashBoardColor.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link_off_rounded,
                size: 36.sp,
                color: const Color(0xFFFF6B6B),
              ),
              SizedBox(height: 14.h),
              Text(
                'Remove connection?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrot',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to disconnect these stickers?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DashBoardColor.textMuted,
                  fontSize: 13.sp,
                  fontFamily: 'SpaceGrot',
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: DashBoardColor.bg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: DashBoardColor.border),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: DashBoardColor.text,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SpaceGrot',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(
                          () => _connections.removeWhere(
                            (c) =>
                                (c.fromId == fromId && c.toId == toId) ||
                                (c.fromId == toId && c.toId == fromId),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Remove',
                            style: TextStyle(
                              color: const Color(0xFFFF6B6B),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrot',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _openDetail(StickerModel sticker) {
  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (_, anim, __) => StickerDetailScreen(
  //         sticker: sticker,
  //         onUpdate: (_) => setState(() {}),
  //       ),
  //       transitionsBuilder: (_, anim, __, child) => SlideTransition(
  //         position: Tween<Offset>(
  //           begin: const Offset(0, 1),
  //           end: Offset.zero,
  //         ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
  //         child: child,
  //       ),
  //     ),
  //   );
  // }
  void _openDetail(StickerModel sticker) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => StickerDetailScreen(
          sticker: sticker,
          onUpdate: (_) => setState(() {}),
          onColorChange: (id, newColor) => _changeStickerColor(id, newColor),
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashBoardColor.bg,
      body: Stack(
        children: [
          Listener(
            onPointerDown: (_) => _activePointers++,
            onPointerUp: (_) =>
                _activePointers = math.max(0, _activePointers - 1),
            onPointerCancel: (_) =>
                _activePointers = math.max(0, _activePointers - 1),
            child: GestureDetector(
              onTap: () {
                if (_connectingFromId != null) {
                  _cancelConnecting();
                  return;
                }
                setState(() => _selectedStickerId = null);
              },
              onScaleStart: (d) {
                _focalStart = d.focalPoint;
                _boardOffsetAtStart = _boardOffset;
                _scaleAtStart = _boardScale;
              },
              onScaleUpdate: (d) {
                if (_activePointers < 2) return;
                setState(() {
                  final newScale = (_scaleAtStart * d.scale).clamp(0.25, 4.0);
                  _boardOffset =
                      d.focalPoint -
                      ((_focalStart - _boardOffsetAtStart) / _scaleAtStart) *
                          newScale;
                  _boardScale = newScale;
                });
              },
              child: ClipRect(
                child: CustomPaint(
                  painter: _GridPainter(
                    offset: _boardOffset,
                    scale: _boardScale,
                  ),
                  child: SizedBox.expand(
                    child: Stack(
                      children: [
                        Listener(
                          onPointerMove: (e) {
                            if (_connectingFromId != null) {
                              setState(
                                () => _connectingEndWorld = _toBoard(
                                  e.localPosition,
                                ),
                              );
                            }
                            if (_draggingId != null) {
                              final s = _findSticker(_draggingId!);
                              if (s != null) {
                                setState(
                                  () => s.position =
                                      _toBoard(e.localPosition) -
                                      _dragLocalOffset,
                                );
                              }
                            }
                          },
                          onPointerUp: (_) {
                            if (_connectingFromId != null) _cancelConnecting();
                            setState(() => _draggingId = null);
                          },
                          child: CustomPaint(
                            painter: _ConnectionsPainter(
                              stickers: _stickers,
                              connections: _connections,
                              boardOffset: _boardOffset,
                              boardScale: _boardScale,
                              draftFromWorld: _connectingFromId != null
                                  ? _stickerCenter(
                                      _findSticker(_connectingFromId!)!,
                                    )
                                  : null,
                              draftToWorld: _connectingEndWorld,
                              connectingFromId: _connectingFromId,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        ..._stickers.map((s) => _buildSticker(s)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
          _buildStickerIndicators(),
        ],
      ),
    );
  }

  Widget _buildSticker(StickerModel sticker) {
    final sp = _toScreen(sticker.position);
    final sz = 180.0 * _boardScale;
    final isSelected = _selectedStickerId == sticker.id;
    final isConnectTarget =
        _connectingFromId != null && _connectingFromId != sticker.id;
    final isDragging = _draggingId == sticker.id;
    final isHovered = _hoveredStickerId == sticker.id;
    final myConns = _connections
        .where((c) => c.fromId == sticker.id || c.toId == sticker.id)
        .toList();
    final layers = _lottieLayers[sticker.id] ?? [];

    return Positioned(
      left: sp.dx,
      top: sp.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredStickerId = sticker.id),
        onExit: (_) => setState(() => _hoveredStickerId = null),
        child: GestureDetector(
          onTap: () {
            if (_connectingFromId != null && _connectingFromId != sticker.id) {
              _finishConnectionTo(sticker.id);
              return;
            }
            setState(() {
              _selectedStickerId = _selectedStickerId == sticker.id
                  ? null
                  : sticker.id;
            });
          },
          onLongPress: () => _openDetail(sticker),
          onPanStart: (d) {
            if (_mode == ToolMode.move && _connectingFromId == null) {
              setState(() {
                _draggingId = sticker.id;
                _dragLocalOffset = d.localPosition / _boardScale;
              });
            }
          },
          onPanUpdate: (d) {
            if (_draggingId == sticker.id) {
              setState(() => sticker.position += d.delta / _boardScale);
            }
          },
          onPanEnd: (_) => setState(() => _draggingId = null),
          child: AnimatedScale(
            scale: isDragging ? 1.06 : ((isSelected || isHovered) ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              width: sz,
              height: sz,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            20.r * _boardScale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: sticker.color.withOpacity(
                                isDragging ? 0.6 : 0.25,
                              ),
                              blurRadius: isDragging ? 36 : 16,
                              offset: const Offset(0, 8),
                            ),
                            if (isSelected)
                              BoxShadow(
                                color: sticker.color.withOpacity(0.5),
                                blurRadius: 44,
                                spreadRadius: 4,
                              ),
                            if (isConnectTarget)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r * _boardScale),
                    child: SizedBox(
                      width: sz,
                      height: sz,
                      child: Stack(
                        children: [
                          for (final layer in layers)
                            Positioned.fill(
                              child: Lottie.asset(
                                layer.color.lottiePath,
                                controller: layer.ctrl,
                                fit: BoxFit.cover,
                                onLoaded: (composition) {
                                  if (!mounted) return;
                                  layer.ctrl.duration = composition.duration;
                                  if (!layer.isBase) {
                                    layer.ctrl.forward(from: 0);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (isSelected || isConnectTarget)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            20.r * _boardScale,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                20.r * _boardScale,
                              ),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2.5)
                                  : Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 2,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          14 * _boardScale,
                          44 * _boardScale,
                          14 * _boardScale,
                          14 * _boardScale,
                        ),
                        child: Center(
                          child: Text(
                            sticker.title.length > 40
                                ? '${sticker.title.substring(0, 40)}…'
                                : sticker.title,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.75),
                              fontSize: 14.sp * _boardScale,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpaceGrot',
                              height: 1.35,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (isSelected ||
                      isHovered ||
                      _connectingFromId == sticker.id)
                    Positioned(
                      right: -20.0 * _boardScale,
                      top: sz / 2 - 20 * _boardScale,
                      child: _buildConnectButton(sticker),
                    ),

                  if (isSelected && myConns.isNotEmpty)
                    ...myConns.asMap().entries.map((e) {
                      final otherId = e.value.fromId == sticker.id
                          ? e.value.toId
                          : e.value.fromId;
                      return Positioned(
                        left: -20.0 * _boardScale,
                        top: (36 + e.key * 40) * _boardScale,
                        child: _buildDisconnectButton(sticker.id, otherId),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(StickerModel sticker) {
    final isActive = _connectingFromId == sticker.id;
    final outerSz = 44.0 * _boardScale;
    final innerSz = 32.0 * _boardScale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_connectingFromId == null) {
          _startConnecting(sticker.id);
        } else if (_connectingFromId != sticker.id) {
          _finishConnectionTo(sticker.id);
        } else {
          _cancelConnecting();
        }
      },
      onPanStart: (_) => _startConnecting(sticker.id),
      onPanUpdate: (d) {
        if (_connectingFromId != null) {
          setState(
            () => _connectingEndWorld =
                (_connectingEndWorld ?? _stickerCenter(sticker)) +
                d.delta / _boardScale,
          );
        }
      },
      onPanEnd: (_) => _cancelConnecting(),
      child: SizedBox(
        width: outerSz,
        height: outerSz,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: innerSz,
            height: innerSz,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.92),
              shape: BoxShape.circle,
              border: Border.all(
                color: sticker.color,
                width: 2.5 * _boardScale.clamp(0.8, 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: sticker.color.withOpacity(isActive ? 0.8 : 0.5),
                  blurRadius: isActive ? 20 : 12,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              isActive ? Icons.close_rounded : Icons.add_rounded,
              size: 18 * _boardScale.clamp(0.7, 1.4),
              color: sticker.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectButton(String fromId, String toId) {
    final outerSz = 40.0 * _boardScale;
    final innerSz = 28.0 * _boardScale;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _confirmRemoveConnection(fromId, toId),
      child: SizedBox(
        width: outerSz,
        height: outerSz,
        child: Center(
          child: Container(
            width: innerSz,
            height: innerSz,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.link_off_rounded,
              size: 13 * _boardScale.clamp(0.7, 1.4),
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final hasSelected = _selectedStickerId != null;
    final createMode = _mode == ToolMode.create;

    final colorOptions = [
      StickerColor.green,
      StickerColor.cyan,
      StickerColor.purple,
    ];

    return Positioned(
      left: 16.w,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 56.w,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: DashBoardColor.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: DashBoardColor.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolBtn(
                icon: Icons.near_me_rounded,
                active: _mode == ToolMode.move && !hasSelected,
                onTap: () => setState(() {
                  _mode = ToolMode.move;
                  _selectedStickerId = null;
                }),
                tooltip: 'Move',
              ),
              SizedBox(height: 6.h),
              _toolBtn(
                icon: Icons.add_rounded,
                active: createMode,
                onTap: () => setState(
                  () => _mode = createMode ? ToolMode.move : ToolMode.create,
                ),
                tooltip: 'Add sticker',
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: (hasSelected || createMode)
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _divider(),
                          ...colorOptions.map((sc) {
                            final c = sc.color;
                            final selectedSticker = hasSelected
                                ? _findSticker(_selectedStickerId!)
                                : null;
                            final effectiveColor = hasSelected
                                ? (_animatingTo[_selectedStickerId!] ??
                                      selectedSticker?.stickerColor)
                                : null;
                            final isCurrentColor =
                                hasSelected && effectiveColor == sc;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: GestureDetector(
                                onTap: isCurrentColor
                                    ? null
                                    : () {
                                        if (hasSelected) {
                                          _changeStickerColor(
                                            _selectedStickerId!,
                                            sc,
                                          );
                                        } else {
                                          _addSticker(sc);
                                        }
                                      },
                                child: AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (_, __) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    width: 30.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      color: c.withOpacity(
                                        isCurrentColor ? 0.35 : 1.0,
                                      ),
                                      shape: BoxShape.circle,
                                      border: isCurrentColor
                                          ? Border.all(
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ),
                                              width: 2,
                                            )
                                          : null,
                                      boxShadow: isCurrentColor
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: c.withOpacity(
                                                  createMode
                                                      ? 0.3 +
                                                            0.15 *
                                                                _pulseCtrl.value
                                                      : 0.25,
                                                ),
                                                blurRadius: createMode
                                                    ? 10 + 5 * _pulseCtrl.value
                                                    : 6,
                                              ),
                                            ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (hasSelected) ...[
                            _divider(),
                            GestureDetector(
                              onTap: () => _deleteSticker(_selectedStickerId!),
                              child: Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withOpacity(0.35),
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18.sp,
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                          ],
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: active ? DashBoardColor.bg : DashBoardColor.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
    child: Container(height: 1, color: DashBoardColor.border),
  );

  Widget _buildStickerIndicators() {
    final size = MediaQuery.of(context).size;
    const r = 18.0;
    const margin = 32.0;
    return Stack(
      children: _stickers.map((s) {
        final sp = _toScreen(_stickerCenter(s));
        final stickerSz = 180.0 * _boardScale;
        final inView =
            sp.dx + stickerSz > 0 &&
            sp.dx - stickerSz < size.width &&
            sp.dy + stickerSz > 0 &&
            sp.dy - stickerSz < size.height;
        if (inView) return const SizedBox.shrink();

        final angle = math.atan2(
          sp.dy - size.height / 2,
          sp.dx - size.width / 2,
        );
        final cx =
            (size.width / 2 + math.cos(angle) * (size.width / 2 - margin - r))
                .clamp(margin + r, size.width - margin - r);
        final cy =
            (size.height / 2 + math.sin(angle) * (size.height / 2 - margin - r))
                .clamp(margin + 80 + r, size.height - margin - r);

        return Positioned(
          left: cx - r,
          top: cy - r,
          child: GestureDetector(
            onTap: () => _flyToSticker(s),
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withOpacity(0.35 + 0.2 * _pulseCtrl.value),
                      blurRadius: 12 + 6 * _pulseCtrl.value,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  size: 12,
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ConnectionsPainter extends CustomPainter {
  final List<StickerModel> stickers;
  final List<ConnectionModel> connections;
  final Offset boardOffset;
  final double boardScale;
  final Offset? draftFromWorld;
  final Offset? draftToWorld;
  final String? connectingFromId;

  _ConnectionsPainter({
    required this.stickers,
    required this.connections,
    required this.boardOffset,
    required this.boardScale,
    this.draftFromWorld,
    this.draftToWorld,
    this.connectingFromId,
  });

  Offset _ws(Offset w) => w * boardScale + boardOffset;
  Offset _center(String id) {
    final s = stickers.firstWhere(
      (s) => s.id == id,
      orElse: () => stickers.first,
    );
    return s.position + const Offset(90, 90);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in connections) {
      try {
        _drawBezier(canvas, _ws(_center(c.fromId)), _ws(_center(c.toId)));
      } catch (_) {}
    }
    if (draftFromWorld != null && draftToWorld != null) {
      _drawDraft(canvas, _ws(draftFromWorld!), _ws(draftToWorld!));
    }
  }

  void _drawBezier(Canvas canvas, Offset from, Offset to) {
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final ctrl1 = Offset(from.dx + (mid.dx - from.dx) * 0.5, from.dy);
    final ctrl2 = Offset(to.dx - (to.dx - mid.dx) * 0.5, to.dy);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, to.dx, to.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2A2A38)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.28)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(mid, 3.5, Paint()..color = Colors.white.withOpacity(0.5));
  }

  void _drawDraft(Canvas canvas, Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final nx = dx / dist;
    final ny = dy / dist;
    final paint = Paint()
      ..color = DashBoardColor.stickerGreen.withOpacity(0.85)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    double drawn = 0;
    bool drawing = true;
    while (drawn < dist) {
      final end = math.min(drawn + (drawing ? 8.0 : 5.0), dist);
      if (drawing)
        canvas.drawLine(
          Offset(from.dx + nx * drawn, from.dy + ny * drawn),
          Offset(from.dx + nx * end, from.dy + ny * end),
          paint,
        );
      drawn = end;
      drawing = !drawing;
    }
    final angle = math.atan2(dy, dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(
          to.dx - 12 * math.cos(angle - 0.42),
          to.dy - 12 * math.sin(angle - 0.42),
        )
        ..lineTo(
          to.dx - 12 * math.cos(angle + 0.42),
          to.dy - 12 * math.sin(angle + 0.42),
        )
        ..close(),
      Paint()
        ..color = DashBoardColor.stickerGreen.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ConnectionsPainter old) => true;
}

class _GridPainter extends CustomPainter {
  final Offset offset;
  final double scale;
  const _GridPainter({required this.offset, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final step = 40.0 * scale;
    final startX = offset.dx % step;
    final startY = offset.dy % step;
    final lp = Paint()
      ..color = const Color(0xFF1A1A24)
      ..strokeWidth = 0.5;
    final dp = Paint()
      ..color = const Color(0xFF252530)
      ..style = PaintingStyle.fill;
    for (double x = startX; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lp);
    for (double y = startY; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lp);
    for (double x = startX; x < size.width; x += step)
      for (double y = startY; y < size.height; y += step)
        canvas.drawCircle(Offset(x, y), 1.5 * scale.clamp(0.5, 1.5), dp);
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.offset != offset || old.scale != scale;
}

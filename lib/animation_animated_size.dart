import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AnimationAnimatedSize extends StatefulWidget {
  const AnimationAnimatedSize({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.curve = Curves.linear,
    required this.controller,
    this.clipBehavior = Clip.hardEdge,
    this.onEnd,
  });

  final Widget child;

  final Curve curve;

  final AlignmentGeometry alignment;

  final TabController controller;

  final Clip clipBehavior;

  final VoidCallback? onEnd;

  @override
  State<AnimationAnimatedSize> createState() => _AnimationAnimatedSizeState();
}

class _AnimationAnimatedSizeState extends State<AnimationAnimatedSize>
  with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => _AnimationAnimatedSize(
    controller: widget.controller,
    vsync: this,
    child: widget.child,
    // TODO
  );
}


class _AnimationAnimatedSize extends SingleChildRenderObjectWidget {
  const _AnimationAnimatedSize({super.key,
    super.child,
    this.alignment = Alignment.center,
    required this.controller,
    this.clipBehavior = Clip.hardEdge,
    this.onEnd,
    required this.vsync
  });

  final TickerProvider vsync;

  final AlignmentGeometry alignment;

  final TabController controller;

  final Clip clipBehavior;

  final VoidCallback? onEnd;

  @override
  RenderControllerAnimatedSize createRenderObject(BuildContext context) {
    return RenderControllerAnimatedSize(
      alignment: alignment,
      tabController: controller,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
      onEnd: onEnd,
      vsync: vsync,
      duration: controller.animationDuration,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderControllerAnimatedSize renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior
      ..onEnd = onEnd;
    // TODO
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment, defaultValue: Alignment.topCenter));
    //properties.add(IntProperty('animation', animation.value.round()));
    // TODO
  }
}

/// A [RenderControllerAnimatedSize] can be in exactly one of these states.
@visibleForTesting
enum RenderAnimatedSizeState {
  /// The initial state, when we do not yet know what the starting and target
  /// sizes are to animate.
  ///
  /// The next state is [stable].
  start,

  /// At this state the child's size is assumed to be stable and we are either
  /// animating, or waiting for the child's size to change.
  ///
  /// If the child's size changes, the state will become [changed]. Otherwise,
  /// it remains [stable].
  stable,

  /// At this state we know that the child has changed once after being assumed
  /// [stable].
  ///
  /// The next state will be one of:
  ///
  /// * [stable] if the child's size stabilized immediately. This is a signal
  ///   for the render object to begin animating the size towards the child's new
  ///   size.
  ///
  /// * [unstable] if the child's size continues to change.
  changed,

  /// At this state the child's size is assumed to be unstable (changing each
  /// frame).
  ///
  /// Instead of chasing the child's size in this state, the render object
  /// tightly tracks the child's size until it stabilizes.
  ///
  /// The render object remains in this state until a frame where the child's
  /// size remains the same as the previous frame. At that time, the next state
  /// is [stable].
  unstable,
}

class RenderControllerAnimatedSize extends RenderAligningShiftedBox {
  /// Creates a render object that animates its size to match its child.
  /// The [duration] and [curve] arguments define the animation.
  ///
  /// The [alignment] argument is used to align the child when the parent is not
  /// (yet) the same size as the child.
  ///
  /// The [duration] is required.
  ///
  /// The [vsync] should specify a [TickerProvider] for the animation
  /// controller.
  ///
  /// The arguments [duration], [curve], [alignment], and [vsync] must
  /// not be null.
  RenderControllerAnimatedSize({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    Curve curve = Curves.linear,
    super.alignment,
    super.textDirection,
    super.child,
    Clip clipBehavior = Clip.hardEdge,
    VoidCallback? onEnd,
    this.tabController,
  }) : _vsync = vsync,
        _clipBehavior = clipBehavior {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    )..addListener(() {
      if (_controller.value != _lastValue) {
        markNeedsLayout();
      }
    });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
    _onEnd = onEnd;

    // If a TabController is provided, sync its animation with our controller
    if (tabController != null) {
      _tabAnimationListener = () {
        _lastValue = tabController!.animation!.value;
        //_controller.value = tabController!.animation!.value;
        _controller.forward(from: tabController!.animation!.value);
        //print(tabController!.animation!.value);
      };
      tabController!.animation!.addListener(_tabAnimationListener!);
    }
  }

  final TabController? tabController;
  VoidCallback? _tabAnimationListener;

  /// When asserts are enabled, returns the animation controller that is used
  /// to drive the resizing.
  ///
  /// Otherwise, returns null.
  ///
  /// This getter is intended for use in framework unit tests. Applications must
  /// not depend on its value.
  @visibleForTesting
  AnimationController? get debugController {
    AnimationController? controller;
    assert(() {
      controller = _controller;
      return true;
    }());
    return controller;
  }

  /// When asserts are enabled, returns the animation that drives the resizing.
  ///
  /// Otherwise, returns null.
  ///
  /// This getter is intended for use in framework unit tests. Applications must
  /// not depend on its value.
  @visibleForTesting
  CurvedAnimation? get debugAnimation {
    CurvedAnimation? animation;
    assert(() {
      animation = _animation;
      return true;
    }());
    return animation;
  }

  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  final SizeTween _sizeTween = SizeTween();
  late bool _hasVisualOverflow;
  double? _lastValue;

  /// The state this size animation is in.
  ///
  /// See [RenderAnimatedSizeState] for possible states.
  @visibleForTesting
  RenderAnimatedSizeState get state => _state;
  RenderAnimatedSizeState _state = RenderAnimatedSizeState.start;

  /// The duration of the animation.
  Duration get duration => _controller.duration!;
  set duration(Duration value) {
    if (value == _controller.duration) {
      return;
    }
    _controller.duration = value;
  }

  /// The duration of the animation when running in reverse.
  Duration? get reverseDuration => _controller.reverseDuration;
  set reverseDuration(Duration? value) {
    if (value == _controller.reverseDuration) {
      return;
    }
    _controller.reverseDuration = value;
  }

  /// The curve of the animation.
  Curve get curve => _animation.curve;
  set curve(Curve value) {
    if (value == _animation.curve) {
      return;
    }
    _animation.curve = value;
  }

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.hardEdge;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  /// Whether the size is being currently animated towards the child's size.
  ///
  /// See [RenderAnimatedSizeState] for situations when we may not be animating
  /// the size.
  bool get isAnimating => _controller.isAnimating;

  /// The [TickerProvider] for the [AnimationController] that runs the animation.
  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _controller.resync(vsync);
  }

  /// Called every time an animation completes.
  ///
  /// This can be useful to trigger additional actions (e.g. another animation)
  /// at the end of the current animation.
  VoidCallback? get onEnd => _onEnd;
  VoidCallback? _onEnd;
  set onEnd(VoidCallback? value) {
    if (value == _onEnd) {
      return;
    }
    _onEnd = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    switch (state) {
      case RenderAnimatedSizeState.start:
      case RenderAnimatedSizeState.stable:
        break;
      case RenderAnimatedSizeState.changed:
      case RenderAnimatedSizeState.unstable:
      // Call markNeedsLayout in case the RenderObject isn't marked dirty
      // already, to resume interrupted resizing animation.
        markNeedsLayout();
    }
    _controller.addStatusListener(_animationStatusListener);
  }

  @override
  void dispose() {
    if (_tabAnimationListener != null) {
      tabController?.animation?.removeListener(_tabAnimationListener!);
    }
    _controller.dispose();
    _animation.dispose();
    super.dispose();
  }

  Size? get _animatedSize {
    return _sizeTween.evaluate(_animation);
  }

  @override
  void performLayout() {
    _lastValue = _controller.value;
    _hasVisualOverflow = false;
    final BoxConstraints constraints = this.constraints;
    if (child == null || constraints.isTight) {
      _controller.stop();
      size = _sizeTween.begin = _sizeTween.end = constraints.smallest;
      _state = RenderAnimatedSizeState.start;
      child?.layout(constraints);
      return;
    }

    child!.layout(constraints, parentUsesSize: true);

    switch (_state) {
      case RenderAnimatedSizeState.start:
        _layoutStart();
      case RenderAnimatedSizeState.stable:
        _layoutStable();
      case RenderAnimatedSizeState.changed:
        _layoutChanged();
      case RenderAnimatedSizeState.unstable:
        _layoutUnstable();
    }

    size = constraints.constrain(_animatedSize!);
    alignChild();

    if (size.width < _sizeTween.end!.width ||
        size.height < _sizeTween.end!.height) {
      _hasVisualOverflow = true;
    }
  }

  @override
  @protected
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (child == null || constraints.isTight) {
      return constraints.smallest;
    }

    // This simplified version of performLayout only calculates the current
    // size without modifying global state. See performLayout for comments
    // explaining the rational behind the implementation.
    final Size childSize = child!.getDryLayout(constraints);
    switch (_state) {
      case RenderAnimatedSizeState.start:
        return constraints.constrain(childSize);
      case RenderAnimatedSizeState.stable:
        if (_sizeTween.end != childSize) {
          return constraints.constrain(size);
        } else if (_controller.value == _controller.upperBound) {
          return constraints.constrain(childSize);
        }
      case RenderAnimatedSizeState.unstable:
      case RenderAnimatedSizeState.changed:
        if (_sizeTween.end != childSize) {
          return constraints.constrain(childSize);
        }
    }

    return constraints.constrain(_animatedSize!);
  }

  void _restartAnimation() {
    _lastValue = 0.0;
    _controller.forward(from: 0.0);
  }

  /// Laying out the child for the first time.
  ///
  /// We have the initial size to animate from, but we do not have the target
  /// size to animate to, so we set both ends to child's size.
  void _layoutStart() {
    _sizeTween.begin = _sizeTween.end = debugAdoptSize(child!.size);
    _state = RenderAnimatedSizeState.stable;
  }

  /// At this state we're assuming the child size is stable and letting the
  /// animation run its course.
  ///
  /// If during animation the size of the child changes we restart the
  /// animation.
  void _layoutStable() {
    if (_sizeTween.end != child!.size) {
      _sizeTween.begin = size;
      _sizeTween.end = debugAdoptSize(child!.size);
      _restartAnimation();
      _state = RenderAnimatedSizeState.changed;
    } else if (_controller.value == _controller.upperBound) {
      // Animation finished. Reset target sizes.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child!.size);
    } else if (!_controller.isAnimating) {
      _controller.forward(); // resume the animation after being detached
    }
  }

  /// This state indicates that the size of the child changed once after being
  /// considered stable.
  ///
  /// If the child stabilizes immediately, we go back to stable state. If it
  /// changes again, we match the child's size, restart animation and go to
  /// unstable state.
  void _layoutChanged() {
    if (_sizeTween.end != child!.size) {
      // Child size changed again. Match the child's size and restart animation.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child!.size);
      _restartAnimation();
      _state = RenderAnimatedSizeState.unstable;
    } else {
      // Child size stabilized.
      _state = RenderAnimatedSizeState.stable;
      if (!_controller.isAnimating) {
        // Resume the animation after being detached.
        _controller.forward();
      }
    }
  }

  /// The child's size is not stable.
  ///
  /// Continue tracking the child's size until is stabilizes.
  void _layoutUnstable() {
    if (_sizeTween.end != child!.size) {
      // Still unstable. Continue tracking the child.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child!.size);
      _restartAnimation();
    } else {
      // Child size stabilized.
      _controller.stop();
      _state = RenderAnimatedSizeState.stable;
    }
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status.isCompleted) {
      _onEnd?.call();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && _hasVisualOverflow && clipBehavior != Clip.none) {
      final Rect rect = Offset.zero & size;
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        rect,
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      super.paint(context, offset);
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();
}
part of '../base.dart';

class CustomTextEditingController extends TextEditingController {
  final String defaultValue;

  CustomTextEditingController(this.defaultValue) : super(text: defaultValue);

  void reset() {
    text = defaultValue;
  }
}

mixin TextEditingControllerFactoryMixin {
  final Map<int, TextEditingController> _controllers = <int, TextEditingController>{};
  int _controllerCounter = 0;
  bool _controllersDisposed = false;

  @protected
  CustomTextEditingController useTextEditingController([String initialValue = '']) {
    assert(!_controllersDisposed, 'Cannot create controller after disposal');

    final controllerKey = _controllerCounter++;
    final controller = CustomTextEditingController(initialValue);
    _controllers[controllerKey] = controller;
    return controller;
  }

  @protected
  void resetControllers() {
    for (final controller in _controllers.values) {
      if (controller is CustomTextEditingController) {
        controller.reset();
      }
    }
  }

  @protected
  void disposeControllers() {
    if (_controllersDisposed) return;
    _controllersDisposed = true;

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    log("disposed controllers");
  }
}

import 'package:angular2/core.dart';
import 'dart:async';
import 'dart:html';
// TODO(jelbourn): Ink ripples.
// TODO(jelbourn): Make the `isMouseDown` stuff done with one global listener.

@Component(
    selector: '[md-button]:not(a), [md-raised-button]:not(a), [md-fab]:not(a)',
    templateUrl: 'button.html',
    styleUrls: const ['button.css'],
    encapsulation: ViewEncapsulation.None)
class MdButton {
  /// Whether a mousedown has occured on this element in the last 100ms.
  bool isMouseDown = false;

  /// Whether the button has focus from the keyboard (not the mouse). Used for class binding
  @HostBinding('class.md-button-focus')
  bool isKeyboardFocused = false;

  @HostListener('mousedown')
  onMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.
    // The Material Design spec is silent on this topic, and without doing this, the
    // button continues to look :active after clicking.
    // @see http://marcysutton.com/button-focus-hell/
    isMouseDown = true;

    new Future.delayed(new Duration(milliseconds: 100), () {
      isMouseDown = false;
    });
  }

  @HostListener('focus')
  onFocus() {
    isKeyboardFocused = !isMouseDown;
  }

  @HostListener('blur')
  onBlur() {
    isKeyboardFocused = false;
  }
}

@Component(
    selector: 'a[md-button], a[md-raised-button], a[md-fab]',
    inputs: const ['disabled'],
    host: const {
      '(mousedown)': 'onMousedown()',
      '(focus)': 'onFocus()',
      '(blur)': 'onBlur()',
      '[tabIndex]': 'tabIndex',
      '[class.md-button-focus]': 'isKeyboardFocused',
      '[attr.aria-disabled]': 'isAriaDisabled',
    },
    templateUrl: 'button.html',
    styleUrls: const ['button.css'],
    encapsulation: ViewEncapsulation.None)
class MdAnchor extends MdButton implements OnChanges {
  num tabIndex;
  bool disabled_;

  bool get disabled => disabled_;

  set disabled(value) {
    // The presence of *any* disabled value makes the component disabled, *except* for false.
    disabled_ = value != null && disabled != false;
  }

  @HostListener('click', const [r'$event'])
  onClick(MouseEvent event) {
    // A disabled anchor shouldn't navigate anywhere.
    if (disabled) {
      event.preventDefault();
    }
  }

  /// Invoked when a change is detected.
  ngOnChanges(Map<String, SimpleChange> changes) {
    // A disabled anchor should not be in the tab flow.
    tabIndex = disabled ? -1 : 0;
  }

  /// Gets the aria-disabled value for the component, which must be a string for Dart.
  String get isAriaDisabled => disabled ? 'true' : 'false';
}

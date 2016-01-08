import 'package:angular2/angular2.dart';
import 'package:material2/components/button/button.dart';
import 'package:test/test.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:angular2/platform/browser.dart';

/// Test component that contains an MdButton.
@Component(
    selector: 'test-app',
    directives: const [MdButton],
    template: '''
<button md-button type="button" (click)="increment()" [disabled]="isDisabled">Go</button>
''')
class TestApp {
  num clickCount = 0;
  bool isDisabled = false;

  increment() {
    clickCount++;
  }
}

main() {
  initAngularTests();

  group('MdButton', () {
    TestComponentBuilder builder;

    ngSetUp((TestComponentBuilder tcb) {
      builder = tcb;
    });

    ngTest('button[md-button]', () async {
      final fixture = await builder.createAsync(TestApp);
      final testComponent = fixture.debugElement.componentInstance;
      final buttonDebugElement = fixture.debugElement.query(By.css('button'));
      buttonDebugElement.nativeElement.click();
      expect(testComponent.clickCount, equals(1));
    });
  });
}

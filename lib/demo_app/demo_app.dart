import 'package:angular2/core.dart';

import '../components/button/button.dart';

@Component(
    selector: 'demo-app',
    providers: const [],
    templateUrl: 'demo_app.html',
    directives: const [MdButton],
    pipes: const [])
class DemoApp {}

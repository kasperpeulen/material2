import 'dart:async';
import 'dart:io';
import 'package:dart_dev/dart_dev.dart' hide Task;
import 'package:git/git.dart';
import 'package:grinder/grinder.dart';
import 'dart:convert';

void main(List<String> args) {
  grind(args);
}

@Task()
@Depends(analyze, testFormat, testTravis)
void travis() {}

@DefaultTask()
@Depends(analyze, format, test, updateDemo, coverage)
void prePush() {}

@Task()
void analyze() {
  Analyzer.analyze(existingSourceDirs);
}

@Task('Gather and send coverage data')
coverage() async {
  // coveralls doesn't seem to work for html tests
  if (Platform.environment['COVERALLS_TOKEN'] != null) {
    // report to coveralls
    Pub.global.activate('dart_coveralls');
    run('dart_coveralls', arguments: [
      'report',
      '--retry',
      '2',
      '--exclude-test-files',
      'test/button_test.dart'
    ]);
  } else {
    // run coverage locally
    config.coverage..pubServe = true;

    await dev(['coverage']);
  }
}

@Task('Apply dartfmt to all Dart source files')
void format() {
  DartFmt.format(existingSourceDirs);
}

@Task()
test() async {
  final platforms = ['firefox', 'chrome', 'dartium', 'safari', 'content-shell'];
  await runTestsWithPubServe(platforms);
}

@Task('Test dartfmt for all Dart source files')
void testFormat() {
  if (DartFmt.dryRun(existingSourceDirs)) {
    throw "dartfmt failure";
  }
}

@Task()
testTravis() async {
  // travis only supports firefox and content-shell it seems
  final platforms = ['firefox', 'content-shell'];
  await runTestsWithPubServe(platforms);
}

@Task()
Future updateDemo() async {
  await Pub.run('peanut', arguments: ['--directory', 'example']);
  await runGit(['push', 'origin', 'gh-pages']);
}

runTestsWithPubServe(List<String> platforms) async {
  final arguments = ['serve', 'test', '--port', '3000'];
  final process = await Process.start('pub', arguments);

  process.stderr.map(UTF8.decode).forEach(stderr.write);

  await process.stdout
      .map(UTF8.decode)
      .firstWhere((string) => string.contains("Build completed successfully"));

  await new TestRunner().testAsync(platformSelector: platforms, pubServe: 3000);
  process.kill();
}

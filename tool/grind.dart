import 'dart:async';
import 'dart:io';

import 'package:git/git.dart';
import 'package:grinder/grinder.dart';

void main(List<String> args) {
  grind(args);
}

@Task()
@Depends(analyze, testFormat, testTravis)
void travis() {}

@DefaultTask()
@Depends(analyze, format, test, coverage, updateDemo)
void prePush() {}

@Task()
void analyze() {
  Analyzer.analyze(existingSourceDirs);
}

@Task('Gather and send coverage data')
void coverage() {
  // coveralls doesn't seem to work for html tests
  if (Platform.environment['COVERALLS_TOKEN'] != null) {
    // report to coveralls
    Pub.global.activate('dart_coveralls');
    run('dart_coveralls', arguments: [
      'report',
      '--retry',
      '2',
      '--exclude-test-files',
      'test/test_all.dart'
    ]);
  } else {
    // run coverage locally
    Pub.run('dart_dev', arguments: ['coverage']);
  }
}

@Task('Apply dartfmt to all Dart source files')
void format() {
  DartFmt.format(existingSourceDirs);
}

@Task()
void test() {
  final platforms = ['firefox', 'chrome', 'dartium', 'safari', 'content-shell'];
  Process.run('pub', ['serve', 'test']);
  new TestRunner().test(platformSelector: platforms, pubServe: 8080);
}

@Task('Test dartfmt for all Dart source files')
void testFormat() {
  if (DartFmt.dryRun(existingSourceDirs)) {
    throw "dartfmt failure";
  }
}

@Task()
void testTravis() {
  // travis only supports firefox and content-shell it seems
  final platforms = ['firefox', 'content-shell'];
  Process.run('pub', ['serve', 'test']);
  new TestRunner().test(platformSelector: platforms, pubServe: 8080);
}

@Task()
Future updateDemo() async {
  Pub.global.run('peanut', arguments: ['--directory', 'example']);
  await runGit(['push', 'origin', 'gh-pages']);
}

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

import 'package:sqlite3/src/hook/compile/description.dart';
import 'package:sqlite3/src/hook/compile/used_symbols.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    final sqlite = SqliteBinary.forBuild(input);
    switch (sqlite) {
      case PrecompiledBinary():
        final library = sqlite.resolveLibrary(input.config.code);
        library.checkSupported();

        final downloaded = await sqlite.downloadIntoOutputDirectoryShared(
          input,
          output,
          library,
        );

        output.assets.code.add(
          CodeAsset(
            package: package,
            name: name,
            linkMode: DynamicLoadingBundled(),
            file: downloaded.uri,
          ),
        );
      case CompileSqlite(
        :final sourceFiles,
        :final defines,
        :final additionalIncludes,
        :final additionalFlags,
        :final additionalLibraryDirectories,
        :final additionalLibraries,
      ):
        // With Flutter on Linux (which already dynamically links SQLite through
        // its libgtk dependency), we run into issues where loading our SQLite
        // build causes internal symbols to be resolved against the already
        // loaded library from the system.
        // This is terrible and not what we ever want. A proper solution may be
        // to use namespaces or RTLD_DEEPBIND, but hooks don't support that yet.
        // An alternative that seems to work is to pass -Bsymbolic-functions to
        // the linker.
        // For the full discussion, see https://github.com/dart-lang/native/issues/2724

        // Patched for ohos: the host hooks package maps ohos to OS.linux, but
        // the Linux-only version-script workaround must not run for the OHOS
        // toolchain (and the Linux-only path style breaks on Windows hosts).
        final _ccForOsCheck = input.config.code.cCompiler?.compiler.toFilePath() ?? '';
        final _isRealLinux = input.config.code.targetOS == OS.linux &&
            !_ccForOsCheck.replaceAll(r'\', '/').contains('openharmony');
        String? linkerScript;
        if (_isRealLinux) {
          linkerScript = input.outputDirectory.resolve('sqlite.map').path;

          await File(linkerScript).writeAsString('''
{
  global:
${usedSqliteSymbols.map((symbol) => '    $symbol;').join('\n')}
  local:
    *;
};
''');
        }

        // Patched for ohos: the OHOS clang from the HarmonyOS SDK needs an
        // explicit target triple and sysroot (derived from the compiler path,
        // the same way the media-kit ohos patch does it).
        final ohosFlags = <String>[];
        if (!_isRealLinux &&
            input.config.code.targetOS == OS.linux) {
          final ccPath = _ccForOsCheck.replaceAll(r'\', '/');
          final llvmIdx = ccPath.indexOf('/llvm/bin/');
          if (llvmIdx > 0) {
            ohosFlags.addAll([
              '--target=aarch64-linux-ohos',
              '--sysroot=${ccPath.substring(0, llvmIdx)}/sysroot',
            ]);
          }
        }

        final library = CBuilder.library(
          name: 'sqlite3',
          packageName: 'sqlite3',
          assetName: name,
          sources: sourceFiles,
          includes: {
            for (final source in sourceFiles) p.dirname(source),
            ...additionalIncludes,
          }.toList(),
          defines: defines,
          flags: [
            ...ohosFlags,
            if (_isRealLinux) ...[
              // This avoids loading issues on Linux, see comment above.
              '-Wl,-Bsymbolic',
              // And since we already have a designated list of symbols to
              // export, we might as well strip the rest.
              // TODO: Port this to other targets too.
              '-Wl,--version-script=$linkerScript',
              '-ffunction-sections',
              '-fdata-sections',
              '-Wl,--gc-sections',
            ],
            if (input.config.code.targetOS case OS.iOS || OS.macOS) ...[
              '-headerpad_max_install_names',
              // clang would use the temporary directory passed by
              // native_toolchain_c otherwise. So this makes improves
              // reproducibility.
              '-install_name',
              '@rpath/libsqlite3.dylib',
            ],
            ...additionalFlags,
          ],
          libraryDirectories: [...additionalLibraryDirectories],
          libraries: [
            if (input.config.code.targetOS == OS.android) ...[
              // We need to link the math library on Android.
              'm',
            ],
            ...additionalLibraries,
          ],
        );

        await library.run(input: input, output: output);
      case ExternalSqliteBinary():
        output.assets.code.add(
          CodeAsset(
            package: package,
            name: name,
            linkMode: sqlite.resolveLinkMode(input),
          ),
        );
    }
  });
}

const package = 'sqlite3';
const name = 'src/ffi/libsqlite3.g.dart';

# Changelog

## device_info_plus-12.3.0-ohos-1.0.0

* release version device_info_plus-12.3.0-ohos-1.0.0

## device_info_plus-12.3.0-ohos-1.0.0-beta.3

* Consistency
The primary focus was eliminating inconsistencies in naming, types, and style to make the code self-documenting.

Filename aligned with class name: The native plugin file was originally DeviceInfoPlusOhosPlugin.ets, but the class name, pluginClass in pubspec.yaml, and the import in GeneratedPluginRegistrant.ets all referenced DeviceInfoPlusPlugin. I renamed the file to DeviceInfoPlusPlugin.ets and updated the import path in ohos/index.ets accordingly. Before making the change, I used grep to confirm that only index.ets referenced this path across the entire repository, and since the class name itself remained unchanged, the registration chain was unaffected with zero impact.

Type consistency: Changed all HashMap<string, ESObject> to HashMap<string, Object>, and changed the isEmulator return type from the boxed type Boolean to the primitive type boolean.

Semicolon style unification: The native file originally had some statements with semicolons and some without—all have been consistently added. This also fixed a latent bug: line 32 originally contained this.channel = null；, using a full-width Chinese semicolon ； (U+FF1B), which is not a valid statement terminator. This has been changed to a half-width semicolon.

Field口径 alignment: OhosDeviceInfo.toJson() actually outputs 32 keys (three deprecated fields—hardwareProfile, serial, udid—are commented out), but the documentation and Demo comments consistently stated "34". I made assertions against the actual behavior (32) and added explanatory comments to prevent future confusion.

* Memory Leaks / Resource Lifecycle
Strictly speaking, no severe runtime leaks were found in this dimension; the focus was on ensuring resources are properly cleaned up at lifecycle boundaries.

Channel reference release on plugin unload: In onDetachedFromEngine, I preserved and reinforced the pattern of setMethodCallHandler(null) + channel = null to ensure that once the plugin detaches from the engine, the engine side no longer holds a reference to it, allowing it to be garbage-collected. I also verified that the full-width semicolon null； does not affect assignment or release semantics.

Resource isolation between test cases: The global tearDown in the main plugin tests now simultaneously resets DeviceInfoPlatform.instance and clears the mock method-call handler (setMockMethodCallHandler(_kChannel, null)). The Ohos and boundary test groups each have their own setUp. This ensures that mock processors registered by each test case don't leak into subsequent cases, preventing cross-test interference.

Cache semantics: Added tests verifying "failure does not pollute the cache"—when the platform returns an error, the cached field is not written with a failed reference, and recovery allows fresh retrieval.

* Documentation Quality
Focused on JSDoc for the native plugin and "why" comments at critical points.

Native plugin JSDoc: Added complete documentation for the class, getUniqueClassName, onAttachedToEngine, onDetachedFromEngine, onMethodCall, isEmulator, and the two newly extracted private helpers (buildDeviceInfoMap/buildAccessUDIDMap). Methods include @param/@returns annotations. The class documentation explains the two exposed methods and the system permissions required for UDID access.

Constant comments: Added explanatory comments for CHANNEL_NAME, METHOD_GET_DEVICE_INFO, METHOD_GET_ACCESS_UDID, and EMULATOR_TAG.

Critical decision comments: Added comments explaining:

Where ESObject (actually changed to Object) is constrained by the framework's type Any = ESObject

Why Windows tests no longer assert buildLab.startsWith(buildNumber) (Registry BuildLab and OSVERSIONINFO buildNumber inconsistency is a machine state issue, not a plugin bug)

Why DateTime.now() was replaced with a fixed timestamp

The correct lint name for cross-package deprecated members (deprecated_member_use rather than _from_same_package)

These comments prevent future maintainers from inadvertently reverting changes.

* Test Coverage
This was the most concentrated area of changes, ultimately expanding the VM suite from a handful of initial test cases to 97 passing tests, with no test/ analysis issues.

OhosDeviceInfo full fields: New file covering all 32 fields (verified through AST-level cross-checking to ensure no omissions), plus fromMap success path, default values, explicit null handling, strict bool handling ('yes' !== true), and toJson key count, round-trip serialization, and value retrieval.

OhosAccessUDIDInfo: Added previously missing toJson tests (serialization, round-trip, key count = 2).

BaseDeviceInfo: New file covering data, the deprecated toMap(), and toString().

DeviceInfoPlusWebPlugin: Added registerWith tests (registers as platform instance) and deviceInfo() tests (returns WebBrowserInfo) in the web test suite.

DeviceInfoPlusLinuxPlugin: Added direct deviceInfo() tests, asserting return of BaseDeviceInfo and verifying that _cache ??= is evaluated only once.

Concurrency / Exceptions / Boundaries: Added in-flight concurrency tests (proving ??= cache deduplicates completed calls but does not deduplicate in-flight calls), exception propagation tests (PlatformException, generic Exception, TypeError from four cast getters, MissingPluginException, non-Map returns), and boundary cases (empty, single-field, missing fields).

* Stability
Focused on "not relying on environment, not silently swallowing errors, not hanging indefinitely."

Native exception fallback: Added try-catch in onMethodCall so failures such as insufficient permissions are returned to Flutter via result.error(...) rather than crashing the host with an uncaught exception, ensuring each branch invokes result exactly once.

Formal permission denial assertions: Added formal permission denial test cases for ohosAccessUDIDInfo, asserting that a PlatformException with code PERMISSION_DENIED and a message containing ACCESS_UDID is thrown, rather than relying solely on the try-catch in the Demo.

No hanging: Used Completer to simulate delayed method-channel responses, proving that getters remain incomplete before the channel responds, and resolve within .timeout(1s) after the response arrives—neither returning early nor hanging indefinitely.

Removed machine/time dependencies: Removed Windows test assertions relying on local registry state (e.g., buildLab.startsWith(buildNumber)), keeping only isNotEmpty. Replaced DateTime.now().isAfter(installDate) with a fixed DateTime.utc(2100) to make the assertion independent of the system clock.

* Code Quality
Constants and logic convergence: Extracted channel name, method names, and emulator tag strings into private readonly constants to eliminate hard-coded duplication. Extracted the two map-building logic blocks from onMethodCall into independent helper methods for clearer dispatch logic.

BDD structure and lifecycle: Organized main plugin tests into groups: "construction / normal returns / Ohos channel / caching / concurrency / exceptions / boundaries / deviceInfo routing." Added setUp/tearDown for model tests even when no side effects require cleanup (retained per规范 with explanatory comments).

Lint cleanup: Corrected lint name for cross-package deprecated members, removed duplicate inline // ignore: lines, removed redundant imports, removed extraneous empty statements ; in main.dart, and deleted the mistakenly committed temporary probe file _tmp_web_probe_test.dart.
* TAG device_info_plus-12.3.0-ohos-1.0.0-beta.1.
* Upgrade device_info_plus to version 12.3.0, supporting Flutter OHOS 3.35.7.
* Add `ohosAccessUDIDInfo` API for retrieving device serial and UDID (requires system-level permission `ohos.permission.sec.ACCESS_UDID`).
* Complete `OhosDeviceInfo` property list with versionId, buildUser, buildHost, buildRootHash, distributionOS* fields and isPhysicalDevice.
* Optimize README.OpenHarmony_CN.md and README.OpenHarmony.md: add usage example, permissions, FAQ and directory structure.

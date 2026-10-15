# 生命周期日志与 r / R 对照记录（步骤三）

## 一、埋点位置

日志写在 `lib/main.dart` 的 `_MyHomePageState` 里，5 个钩子各一行：

```dart
debugPrint('[lifecycle] initState');              // initState
debugPrint('[lifecycle] didChangeDependencies');  // didChangeDependencies
debugPrint('[lifecycle] didUpdateWidget');        // didUpdateWidget
debugPrint('[lifecycle] dispose');                // dispose
debugPrint('[lifecycle] build');                  // build（写在 build 里）
```

说明：这里用 `debugPrint` 而没直接用 `print`——两者都输出到同一个控制台，但 `print` 会触发 `flutter_lints` 的 `avoid_print` 规则（`flutter analyze` 会飘警告），`debugPrint` 是官方推荐的等价写法，输出效果一样。

## 二、已实测的输出顺序（`flutter test` 实跑抓到的）

```
[lifecycle] initState
[lifecycle] didChangeDependencies
[lifecycle] build
[lifecycle] build      ← 测试里 tap + pump 造成的第二次 build
[lifecycle] dispose    ← 测试结束时销毁 State
```

这段顺序能直接说明三件事：

- 首帧渲染 = `initState` → `didChangeDependencies` → `build`，三个钩子只在这一刻各出现一次；
- 之后的每次界面变化（比如点按钮、测试里的 tap），只重新执行 `build`，不会再走 `initState`；
- State 被销毁时走 `dispose`，且只走一次。

## 三、按 r / 按 R 的对照（自己在 `flutter run` 里跑一遍补实测）

先跑起来：

```
flutter run -d chrome      # 或 -d windows
```

然后按小写 `r`（热重载）观察一次，再按大写 `R`（热重启）观察一次，把真实输出抄进进度报告。预期差异如下：

- 按 `r`（热重载）：只会新增 `[lifecycle] build`。因为热重载保留 State，`initState` / `didChangeDependencies` / `didUpdateWidget` / `dispose` 都不会重新执行，计数器上的数字也不会归零。
- 按 `R`（热重启）：会新增一整套 `[lifecycle] dispose` → `[lifecycle] initState` → `[lifecycle] didChangeDependencies` → `[lifecycle] build`。因为热重启销毁全部 State 再重建，计数器会归零。
- 点一下 FAB：只会新增一次 `[lifecycle] build`（`setState` 标记 dirty → 下一帧重跑 build）。
- 退出页面 / 关闭 App：出现 `[lifecycle] dispose`。

一句话记：改样式用 `r`（保留状态、只重跑 build），改初始化逻辑用 `R`（重置状态、重走全部钩子）。

## 四、资源改造的验证点

- 图片位置：`assets/images/banner.png`（自绘 teal 渐变图）；
- 声明位置：`pubspec.yaml` 的 `flutter.assets` 下写了 `- assets/images/`；
- 使用位置：`AppBar` 的 `flexibleSpace` 里用 `Image.asset('assets/images/banner.png', fit: BoxFit.cover)` 作为背景；
- 关键点：新增资源后必须跑 `flutter pub get` 并**完整重启**（不是热重载），否则会报 `Unable to load asset`。

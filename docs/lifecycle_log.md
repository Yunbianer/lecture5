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

## 三、按 r / 按 R 的对照（2026-10-20 Chrome 实跑记录）

先跑起来：

```
flutter run -d chrome
```

### 启动后的初始输出

```
[lifecycle] initState
[lifecycle] didChangeDependencies
[lifecycle] build
[lifecycle] build      ← 首帧后框架会额外触发几次 build
[lifecycle] build
[lifecycle] build
```

### 按小写 `r`（热重载）

**实测输出（Chrome）**：

```
Performing hot restart...
Hot restarting application from main method in: org-dartlang-app:///web_entrypoint.dart (generation: 1).
Performing hot restart...                                          440ms
Restarted application in 440ms.
[lifecycle] initState
[lifecycle] didChangeDependencies
[lifecycle] build
```

⚠️ **重要发现**：在 Chrome（web）上按 `r` 实际触发的是**热重启**，不是热重载。web 端 Flutter 不支持保留 State 的热重载——整个 Dart VM 会重启，State 完整重建，计数器归零。这和桌面端 / 移动端的行为不同，需要切换到 Windows 桌面端（`flutter run -d windows`）才能观察真正的热重载。

### 按大写 `R`（热重启）

**实测输出（Chrome）**：与按 `r` 完全相同——同样的热重启日志，同样走 `initState` → `didChangeDependencies` → `build`。

### 按 FAB 加一

```
[lifecycle] build    ← setState 标记 dirty → 下一帧重跑 build，没有任何其他钩子
```

计数器数字变了（0 → 1），但 State 对象没销毁重建，`_counter` 保留。

### 关闭 App

```
[lifecycle] dispose
Lost connection to device.
```

### 预期行为（桌面/移动端，供对照）

真正的热重载（`r`）和热重启（`R`）的差异要在 Windows/Android/iOS 上才能观察到：

- 按 `r`（热重载）：**只**新增 `[lifecycle] build`。State 保留，计数器不归零。
- 按 `R`（热重启）：销毁旧 State → 新建 State，走完整 `dispose` → `initState` → `didChangeDependencies` → `build`。计数器归零。

一句话记：改样式用 `r`（保留状态、只重跑 build），改初始化逻辑用 `R`（重置状态、重走全部钩子）。

## 四、资源改造的验证点

- 图片位置：`assets/images/banner.png`（自绘 teal 渐变图）；
- 声明位置：`pubspec.yaml` 的 `flutter.assets` 下写了 `- assets/images/`；
- 使用位置：`AppBar` 的 `flexibleSpace` 里用 `Image.asset('assets/images/banner.png', fit: BoxFit.cover)` 作为背景；
- 关键点：新增资源后必须跑 `flutter pub get` 并**完整重启**（不是热重载），否则会报 `Unable to load asset`。

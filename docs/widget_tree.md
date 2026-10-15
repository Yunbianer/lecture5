# counter_deep Widget 树手绘图（步骤一）

来源：`flutter create counter_deep` 生成的模板，精读 `lib/main.dart` 后手绘。
标注规则：`[S]` = StatelessWidget，`[F]` = StatefulWidget，`[State]` = State 对象。

## 一、完整 Widget 树

```
main()
└─ runApp(const MyApp())                     ← 根 Widget 挂载，框架从此接管渲染
   │
   └─ MyApp [S]                              ← 应用根，const 构造（编译时常量，减少重建）
      │
      └─ MaterialApp [S]                     ← 应用级配置：title / theme / home
         │   · title: 'Flutter Demo'          → 系统任务切换器里显示的描述
         │   · theme: ThemeData(colorScheme 由 fromSeed 生成)
         │
         └─ MyHomePage [F]                   ← 首页，由父级构造：const MyHomePage(title: ...)
            │   · final String title          → Widget 配置项（只读，父级传入）
            │
            └─ _MyHomePageState [State]      ← createState() 产生的 State 对象
               │   · int _counter = 0        → 可变数据，界面显示的数字来自这里
               │   · void _incrementCounter() → 改 _counter 并调 setState
               │
               └─ Scaffold [S]               ← 页面骨架（本页用到 3 个坑位）
                  │
                  ├─ appBar: AppBar [S]                  ← 坑位①：顶部导航栏
                  │   ├─ backgroundColor: Theme.of(context).colorScheme.inversePrimary
                  │   └─ title: Text(widget.title) [S]  ← 读 Widget 的 title（非 State）
                  │
                  ├─ body: Center [S]                    ← 坑位②：主体内容
                  │   └─ Column [S]
                  │      ├─ Text('You have pushed the button this many times:') [S]
                  │      └─ Text('$_counter') [S]        ← 读 State 字段 _counter
                  │
                  └─ floatingActionButton: FloatingActionButton [S]  ← 坑位③：右下角悬浮按钮
                     ├─ onPressed: _incrementCounter     ← 绑到 State 的方法
                     └─ child: Icon(Icons.add) [S]
```

## 二、精读要点（自己看代码时要能对上号）

1. **两层分工**：`MyHomePage`（[F]）和 `_MyHomePageState`（[State]）是配套的——Widget 只保存不变的配置（`title`），会变的数据（`_counter`）住在 State 里。
2. **唯一可变节点**：整棵树里只有 `_counter` 会变；界面显示的 `'$_counter'` 就是「UI = f(state)」里 state 的体现，state 一变，这棵子树就重建。
3. **Stateful 的判断依据**：本页需要「用户点按钮推动数字变化」，所以必须 [F]；其余 Text / Icon / Column / Center / Scaffold / AppBar / FAB 都是纯展示，全是 [S]。
4. **const 的位置**：`MyApp()`、`MyHomePage(title: ...)`、`Icon(Icons.add)`、提示文字 Text 都是 const；只有 `'$_counter'` 那个 Text 不能 const（依赖运行时数据）。
5. **点 FAB 后发生了什么**（检查点口头题）：`onPressed` → `setState(() { _counter++ })` → 框架标记该 Element 为 dirty → 下一帧重跑 `build` → 新 Widget 树与旧的比对 → 只有 `'$_counter'` 那个 Text 真的变了并更新到屏幕。

## 三、`flutter create` 模板里值得注意的一处写法

生成的模板用了 Dart 3.13 的「点简写（dot shorthand）」语法：

```dart
colorScheme: .fromSeed(seedColor: Colors.deepPurple),   // 等价于 ColorScheme.fromSeed(...)
mainAxisAlignment: .center,                             // 等价于 MainAxisAlignment.center
```

能看懂即可，但改造阶段我统一写成 `ColorScheme.fromSeed(...)` 这种完整写法，方便阅读和抄到自己代码里。

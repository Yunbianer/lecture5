# AI 使用标注

这份文件记录 counter_deep 复现过程中 AI（TraeWork）的使用情况，按作业任务 5 的要求，附上我猜的方案和 AI 方案的对照。

## 哪些地方用了 AI

1. **步骤一画 Widget 树**：树是自己读 main.dart 画的，画完让 AI 帮忙查漏，它指出我漏标了 MyHomePage 是 StatefulWidget，已补。其余内容没动。

2. **改造一的步长功能**：这一步分歧最大。我本来想直接在页面上加三个按钮，点哪个步长就改成几。AI 给的方案是用 showModalBottomSheet 从底部弹一层，里面放 ListTile 选 1/2/5，选完用 Navigator.pop 把值带回来。对比下来 AI 的方案不占主界面空间，就采用了。弹层配合 async/await 接返回值的写法是这次照着学的。

3. **改造二的日志和资源**：日志我本来写的是 print，AI 提醒 print 会触发 flutter_lints 的 avoid_print 警告，建议换 debugPrint，试了确实如此。图片这块我一开始想把图塞给 AppBar 的 backgroundColor，AI 说背景图应该放 flexibleSpace 再配 BoxFit.cover，还提醒新增资源要完整重启否则报 Unable to load asset。这两处都按 AI 的改了。

4. **主题色和 r/R 实验**：主题色我猜的改法和 AI 一样，都是改 theme 里的 seedColor 为 teal，没有分歧。r/R 对照实验是自己跑 flutter run 按的键，输出自己抄的，这一步没用 AI。

## 总结

AI 主要帮我把「没见过的 API」补上了，比如 showModalBottomSheet、debugPrint、flexibleSpace。改哪几个文件、改完功能对不对，是自己判断和验证的，口头解释每个改动也不成问题。

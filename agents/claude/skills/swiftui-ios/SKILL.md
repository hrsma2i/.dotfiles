---
name: swiftui-ios
description: iOS SwiftUI アプリの開発タスク。View 実装、画面遷移、エラーハンドリング等を SharedUtils ライブラリでガイドする。
---

## SharedUtils

プライベートライブラリ https://github.com/hrsma2i/SwiftSharedUtils-iOS/tree/main/Sources/SharedUtils を活用する。GitHub のプライベートリポジトリを参照する場合は gh コマンドを用いる。

- ログは SharedUtils/Logger.swift にあるグローバルな logger を使う。import SharedUtils すればすぐに使える。print は使わない。
- 独自のエラーを enum などで定義せず、SharedUtils/Extensions/String/String+Error.swift で拡張された文字列をそのままエラーとして `throw "some error message"` のように投げる。
- 画面遷移には SharedUtils/SwiftUI/Navigation/\* のファイルを組み合わせて実現する。

## View

- View.sheet を使うときは https://github.com/hrsma2i/menumate-ios/blob/main/MenuMate/Presentation/Recipe/RecipeListView.swift を参考に `@State var sheet: AnyIdentifiableView?` を用いて `.sheet(item: $sheet) { $0 }` のようにする。
- タイトルとメッセージを出すだけのシンプルな View.alert を使うときは `@State var alertContent: AlertContent`（`struct AlertContent { title: String, message: String }`）を用いる。`showAlert: Bool`, `title`, `message` をバラバラに State として持たせることは禁止。
- View.onAppear ではなく View.task を用いる。
- 子 View は、なるべくメソッドや computed property として切り出し、body メソッドの見通しを良くする。
- View のメソッドは body が最上位で、呼び出し箇所が上にあるものほど上に定義する。依存関係にあるメソッドはなるべく順番を近くする。
- callback を View の引数に持たせる場合
  - デフォルト値は何もしない関数にする
  - async 関数にはしない。非同期処理をしたい場合、呼び出し側で `onPressed: { newValue in Task { await asyncFunc(newValue) }}` のようにする。そうしないと newValue に対して EXC_BAD_ACCESS でクラッシュする。
- エラーが throw されたとき、View 側でエラーログを取るだけではなく、alert 等でユーザーにもエラーを伝える。

## アーキテクチャ

- UseCase / Application Service の命名は `DoSomethingUseCase` や `DoSomethingService` のような接尾辞は不要。`DoSomething` のように動詞・目的語だけでよい。
- struct の callAsFunction メソッドにメインの処理を書き、`DoSomething()()` のように呼べるようにする。execute メソッドなどは不要。
- Repository.find するだけのような中身のない UseCase は不要。Repository.find を直接呼ぶ。

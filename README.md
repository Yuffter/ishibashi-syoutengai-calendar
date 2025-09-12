# 石橋商店街イベントカレンダー

このリポジトリは、石橋商店街の各店舗のイベント情報をカレンダー形式で確認できるFlutterウェブアプリケーションのソースコードです。

## 概要

本アプリケーションは、石橋商店街のイベント情報を集約し、ユーザーが簡単にアクセスできるプラットフォームを提供することを目的としています。ユーザーはカレンダーから日付を選択し、その日のイベント一覧を確認できます。また、店舗関係者はログインすることで、イベントの登録、編集、削除が可能です。

## 主な機能

- **イベントカレンダー**: `table_calendar` を利用してイベントが開催される日に印を表示します。
- **イベント一覧**: 日付を選択すると、その日に開催されるイベントが一覧で表示されます。
- **イベント詳細**: 各イベントをタップすると、画像、タイトル、概要などの詳細情報がモーダルで表示されます。
- **店舗関係者向け機能**:
    - **認証**: Firebase Authenticationを利用したメールアドレスとパスワードによるログイン・ログアウト機能。
    - **イベント管理**: ログインしているユーザーは、イベントの追加、編集、削除が可能です。
    - **画像アップロード**: イベント情報に画像を添付し、Firebase Storageにアップロードできます。
- **利用規約・プライバシーポリシー**: アプリケーションの利用に関する規約ページを設けています。

## 技術スタック

- **フレームワーク**: [Flutter](https://flutter.dev/)
- **バックエンド**: [Firebase](https://firebase.google.com/)
    - **認証**: Firebase Authentication
    - **データベース**: Cloud Firestore
    - **ストレージ**: Firebase Storage
- **状態管理**: [Riverpod](https://riverpod.dev/) (with `riverpod_generator`)
- **主要パッケージ**:
    - `table_calendar`: カレンダーUI
    - `flutter_riverpod`: 状態管理
    - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Firebase連携
    - `image_picker_web`: Webでの画像選択
    - `hive`: イベントデータのローカルキャッシュ
    - `google_fonts`: カスタムフォント
    - `intl`: 日付フォーマット

## プロジェクト構造 (`lib`フォルダ)

```
lib/
├── main.dart          # アプリケーションのエントリポイント
├── model/             # データモデル（StoreImage, Userなど）
│   ├── store_image.dart
│   └── ...
├── view/              # UI層（画面、ページ）
│   ├── calendar_view.dart
│   ├── login_page.dart
│   └── ...
├── view_model/        # 状態管理とビジネスロジック (Riverpod)
│   ├── store_image.dart
│   ├── login.dart
│   └── ...
└── widget/            # 再利用可能なUIコンポーネント
    ├── header.dart
    └── store_image_form_modal.dart
```

- **`model`**: アプリケーションで使用するデータ構造を定義します。（例: `StoreImageModel`）
- **`view`**: ユーザーインターフェース（UI）を構成する各画面を配置します。（例: `CalendarView`, `LoginPage`）
- **`view_model`**: Riverpodを使用してアプリケーションの状態管理とビジネスロジックを担います。`view`と`model`を接続する役割を持ちます。
- **`widget`**: アプリケーション全体で再利用される共通のUI部品（ヘッダー、フォームなど）を配置します。

## セットアップと実行方法

### 1. 前提条件

- Flutter SDKがインストールされていること。
- Firebaseプロジェクトがセットアップ済みであること。

### 2. Firebaseの設定

1.  FirebaseコンソールでWebアプリをプロジェクトに追加します。
2.  Firebase SDKの構成情報を取得し、`lib/firebase_options.dart` に設定します。このファイルは `flutterfire configure` コマンドで自動生成することが推奨されます。
3.  以下のFirebaseサービスを有効化してください。
    - **Authentication**: 「メール/パスワード」サインインプロバイダを有効化します。
    - **Firestore**: データベースを作成します。`events` コレクションが自動的に作成されます。
    - **Storage**: ストレージバケットを作成します。

### 3. アプリケーションの実行

1.  プロジェクトのルートディレクトリで、依存関係をインストールします。
    ```sh
    flutter pub get
    ```

2.  コード生成を実行します（Riverpodの`*.g.dart`ファイルを生成するため）。
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

3.  Webサーバーを起動してアプリケーションを実行します。
    ```sh
    flutter run -d chrome
    ```
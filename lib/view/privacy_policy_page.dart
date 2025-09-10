import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column( // 複数のTextウィジェットを配置するためにColumnを使う
          crossAxisAlignment: CrossAxisAlignment.start, // 左寄せにする
          children: const <Widget>[ // constにすることでパフォーマンス向上
            // プライバシーポリシーのタイトル
            Text(
              'プライバシーポリシー',
              style: TextStyle(
                fontSize: 24, // 大きな文字サイズ
                fontWeight: FontWeight.bold, // 太字
                height: 1.5, // 行間を調整
              ),
            ),
            SizedBox(height: 16), // 余白

            Text(
              '岩田安申・金本侑大・林真歩（以下、「当方」といいます。）は、当方が提供するアプリケーション「石橋商店街カレンダー」（以下、「本サービス」といいます。）における、ユーザーの個人情報の取扱いについて、以下のとおりプライバシーポリシー（以下、「本ポリシー」といいます。）を定めます。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24), // 余白

            // 第1条（取得する情報）
            Text(
              '第1条（取得する情報）',
              style: TextStyle(
                fontSize: 18, // 少し大きめの文字サイズ
                fontWeight: FontWeight.bold, // 太字
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、本サービスの提供にあたり、以下の情報を取得する場合があります。\n- 氏名、メールアドレス、パスワード等のアカウント登録情報\n- 端末情報（OS、機種名、広告ID等）\n- 本サービスの利用履歴（アクセスログ、操作履歴等）\n- その他、ユーザーからのお問い合わせ等で提供される情報',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第2条（利用目的）
            Text(
              '第2条（利用目的）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、取得した情報を以下の目的で利用します。\n- 本サービスの提供・運営のため\n- ユーザー認証およびアカウント管理のため\n- ユーザーからのお問い合わせに対応するため\n- 本サービスの改善および新規サービスの開発のため\n- 利用規約に違反する行為への対応のため\n- 上記の利用目的に付随する目的',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第3条（第三者への提供）
            Text(
              '第3条（第三者への提供）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、次に掲げる場合を除いて、あらかじめユーザーの同意を得ることなく、第三者に個人情報を提供することはありません。\n1. 法令に基づく場合\n2. 人の生命、身体または財産の保護のために必要がある場合であって、本人の同意を得ることが困難であるとき\n3. 公衆衛生の向上または児童の健全な育成の推進のために特に必要がある場合であって、本人の同意を得ることが困難であるとき\n4. 国の機関もしくは地方公共団体またはその委託を受けた者が法令の定める事務を遂行することに対して協力する必要がある場合であって、本人の同意を得ることにより当該事務の遂行に支障を及ぼすおそれがあるとき',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第4条（安全管理措置）
            Text(
              '第4条（安全管理措置）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、取り扱う個人情報の漏えい、滅失またはき損の防止その他の個人情報の安全管理のために必要かつ適切な措置を講じます。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第5条（個人情報の開示・訂正等）
            Text(
              '第5条（個人情報の開示・訂正等）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、本人から個人情報の開示、訂正、追加、削除、利用停止の請求があった場合には、本人確認を行った上で、法令に従い速やかに対応します。ご希望の場合は、下記お問い合わせ先までご連絡ください。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第6条（プライバシーポリシーの変更）
            Text(
              '第6条（プライバシーポリシーの変更）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '本ポリシーの内容は、法令その他本ポリシーに別段の定めのある事項を除いて、ユーザーに通知することなく、変更することができるものとします。変更後のプライバシーポリシーは、本ウェブサイトに掲載したときから効力を生じるものとします。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第7条（お問い合わせ先）
            Text(
              '第7条（お問い合わせ先）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '本ポリシーに関するお問い合わせは、下記の連絡先までお願いいたします。\nyuupon2005@gmail.com',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            Text(
              '以上',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            Text(
              '制定日: 2025年9月8日',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
            SizedBox(height: 16), // 最後に余白
          ],
        ),
      ),
    );
  }
}
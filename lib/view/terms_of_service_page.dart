import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
          children: const <Widget>[
            // 利用規約のタイトル
            Text(
              '利用規約',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),

            Text(
              'この利用規約（以下、「本規約」といいます。）は、岩田安申・金本侑大・林真歩（以下、「当方」といいます。）が提供するアプリケーション「石橋商店街カレンダー」（以下、「本サービス」といいます。）の利用条件を定めるものです。本サービスを利用するユーザー（以下、「ユーザー」といいます。）は、本規約に同意の上、本サービスを利用するものとします。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第1条（適用）
            Text(
              '第1条（適用）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '本規約は、ユーザーと当方との間の本サービスの利用に関わる一切の関係に適用されるものとします。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第2条（利用登録）
            Text(
              '第2条（利用登録）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. 本サービスの利用を希望する者は、本規約に同意の上、当方の定める方法によって利用登録を申請し、当方がこれを承認することによって、利用登録が完了するものとします。\n2. 当方は、利用登録の申請者に以下の事由があると判断した場合、利用登録の申請を承認しないことがあり、その理由については一切の開示義務を負わないものとします。\n   - 虚偽の事項を届け出た場合\n   - 本規約に違反したことがある者からの申請である場合\n   - その他、当方が利用登録を相当でないと判断した場合',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第3条（アカウントの管理）
            Text(
              '第3条（アカウントの管理）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. ユーザーは、自己の責任において、本サービスのユーザーIDおよびパスワードを適切に管理するものとします。\n2. ユーザーは、いかなる場合にも、ユーザーIDおよびパスワードを第三者に譲渡または貸与し、もしくは第三者と共用することはできません。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第4条（禁止事項）
            Text(
              '第4条（禁止事項）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。\n- 法令または公序良俗に違反する行為\n- 犯罪行為に関連する行為\n- 当方、本サービスの他のユーザー、または第三者のサーバーまたはネットワークの機能を破壊したり、妨害したりする行為\n- 当方のサービスの運営を妨害するおそれのある行為\n- 他のユーザーに関する個人情報等を収集または蓄積する行為\n- 不正アクセスをし、またはこれを試みる行為\n- 他のユーザーに成りすます行為\n- 当方のサービスに関連して、反社会的勢力に対して直接または間接に利益を供与する行為\n- その他、当方が不適切と判断する行為',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第5条（免責事項）
            Text(
              '第5条（免責事項）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. 当方は、本サービスに事実上または法律上の瑕疵（安全性、信頼性、正確性、完全性、有効性、特定の目的への適合性、セキュリティなどに関する欠陥、エラーやバグ、権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n2. 当方は、本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第6条（利用規約の変更）
            Text(
              '第6条（利用規約の変更）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '当方は、必要と判断した場合には、ユーザーに通知することなくいつでも本規約を変更することができるものとします。なお、本規約の変更後、本サービスの利用を開始した場合には、当該ユーザーは変更後の規約に同意したものとみなします。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            // 第7条（準拠法・裁判管轄）
            Text(
              '第7条（準拠法・裁判管轄）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. 本規約の解釈にあたっては、日本法を準拠法とします。\n2. 本サービスに関して紛争が生じた場合には、当方の本店所在地を管轄する裁判所を専属的合意管轄とします。',
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
---
description: レポートのテンプレートを作成する。
arguments: [set]
argument-hint: <set>
---

対象ファイル: `exercises/Set$set.md`
例: `/create-template 3`

## 手順

* 指定された問題の.hsファイルに対応する.mdファイルを作成する
  * Set3であれば `exercises/Set3a.hs` と `exercises/Set3b.hs` があるので、 `exercises/Set3a.md` と `exercises/Set3b.md` を作成する
* .mdファイルの先頭に `# Set$set` 見出しを作る
* 対応する.hsファイルにある問題それぞれに `## Ex n` 見出しを作り、中に `### 問題` と `### Step n` セクションを作る
  * `### Step n` は1~3まで作ること
* `### 問題` セクションの中に対応する問題の問題文を ```haskell ブロックの中に転記する

## 注意事項

* .hsファイルはいっさい編集しないこと
* set番号が指定されていない場合はユーザーに問うこと

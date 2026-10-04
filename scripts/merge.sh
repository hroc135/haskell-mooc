#!/bin/bash
#
# 指定した問題番号の演習ファイル（exercises/Set<N>*.hs, .md）のうち差分のあるものを
# ブランチにコミット・プッシュし、PR を作成してマージまで行う。
#
# 使い方: scripts/merge.sh <問題番号>

set -euo pipefail

REPO="hroc135/haskell-mooc"
BASE_BRANCH="master"
POLL_INTERVAL=2 # マージ可能かどうかを確認する間隔(秒)
POLL_TIMEOUT=20 # マージ可能になるまで待つ上限(秒)

die() {
  echo "error: $*" >&2
  exit 1
}

# 引数で問題番号を指定
[ $# -eq 1 ] || die "使い方: $0 <問題番号>"
set_num="$1"
[[ "$set_num" =~ ^[0-9]+$ ]] || die "問題番号は数字で指定してください: '$set_num'"

branch="set${set_num}"
title="Set${set_num}"

cd "$(git rev-parse --show-toplevel)"

# 対象ファイルの洗い出し
# SetNa.hs / SetNb.md / SetNaTest.hs / SetN.hs のような名前だけを拾う。
mapfile -t files < <(
  ls exercises 2>/dev/null |
    grep -E "^Set${set_num}[a-z]?(Test)?\.(hs|md)$" |
    sed 's|^|exercises/|'
)
[ "${#files[@]}" -gt 0 ] || die "exercises/ に Set${set_num} 関連のファイルが見つかりません"

# 差分があるか確認する
if [ -z $(git status --porcelain -- "${files[@]}") ]; then
  echo "Set${set_num}に差分がありません。終了します。"
  exit 0
fi

echo "コミット対象:"
git status --porcelain -- "${files[@]}"

# ブランチを作成してコミット・プッシュ
git fetch origin "$BASE_BRANCH"
git switch -C "$branch" "origin/${BASE_BRANCH}"
git add -- "${files[@]}"
git commit -m "$title"
git push -u origin "$branch"

# PR 作成
pr_url="$(gh pr list --repo "$REPO" --head "$branch" --base "$BASE_BRANCH" \
  --state open --json url --jq '.[0].url // empty')"
if [ -n "$pr_url" ]; then
  echo "既存の PR を使用します: $pr_url"
else
  pr_url="$(gh pr create --repo "$REPO" \
    --base "$BASE_BRANCH" --head "$branch" \
    --title "$title" --body "")"
  echo "PR を作成しました: $pr_url"
fi

# マージ可能になるまで待つ
echo "マージ可能になるまで待機中..."
elapsed=0
while :; do
  read -r mergeable state < <(
    gh pr view "$pr_url" --repo "$REPO" \
      --json mergeable,mergeStateStatus --jq '[.mergeable, .mergeStateStatus] | @tsv'
  )
  case "$mergeable/$state" in
  MERGEABLE/CLEAN | MERGEABLE/UNSTABLE | MERGEABLE/HAS_HOOKS)
    break
    ;;
  CONFLICTING/*)
    die "PR がコンフリクトしています: $pr_url"
    ;;
  */DIRTY)
    die "PR がマージできない状態です (state=$state): $pr_url"
    ;;
  esac

  [ "$elapsed" -lt "$POLL_TIMEOUT" ] ||
    die "タイムアウトしました (mergeable=$mergeable, state=$state): $pr_url"
  echo "  mergeable=$mergeable state=$state ... ${POLL_INTERVAL}秒後に再確認"
  sleep "$POLL_INTERVAL"
  elapsed=$((elapsed + POLL_INTERVAL))
done

# マージ
gh pr merge "$pr_url" --repo "$REPO" --merge
echo "マージしました: $pr_url"

# ローカルを master に戻して同期
git switch "$BASE_BRANCH"
git pull
echo "完了: ${BASE_BRANCH} を最新にしました。"

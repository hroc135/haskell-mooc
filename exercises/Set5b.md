# Set5b

複数の問題で使用できるヘルパー `foldTree` を定義する。

```haskell
foldTree :: (a -> b -> b -> b) -> b -> Tree a -> b
foldTree _ e Empty = e
foldTree f e (Node n l r) = f n (foldTree f e l) (foldTree f e r)
```

## Ex 1

### 問題

```haskell
-- Ex 1: implement the function valAtRoot which returns the value at
-- the root (top-most node) of the tree. The return value is Maybe a
-- because the tree might be empty (i.e. just a Empty)

valAtRoot :: Tree a -> Maybe a
valAtRoot t = todo
```

### Step 1

```haskell
valAtRoot Empty = Nothing
valAtRoot (Node n _ _) = Just n
```

### Step 2

#### 2a

最初の要素だけ取得して残りの要素を評価せずに停止してくれるので時間計算量は `O(n)` 。ただstep 1の方が素直で良い。

```haskell
valAtRoot = foldTree (\n _ _ -> Just n) Nothing
```

### Step 3

```haskell
valAtRoot Empty = Nothing
valAtRoot (Node value _ _) = Just value
```

## Ex 2

### 問題

```haskell
-- Ex 2: compute the size of a tree, that is, the number of Node
-- constructors in it
--
-- Examples:
--   treeSize (Node 3 (Node 7 Empty Empty) Empty)  ==>  2
--   treeSize (Node 3 (Node 7 Empty Empty) (Node 1 Empty Empty))  ==>  3

treeSize :: Tree a -> Int
treeSize t = todo
```

### Step 1

```haskell
treeSize Empty = 0
treeSize (Node node left right) = 1 + treeSize left + treeSize right
```

### Step 2

#### 2a

`foldTree` を使ってみたが、わざわざ使う必要もないという感想。step 1の方が素直。パフォーマンスはどちらも `1+(1+(1+...))+(1+(1+...))` のように評価スタックが木の高さだけ積み上がる。

```haskell
treeSize = foldTree (\_ lSize rSize -> 1 + lSize + rSize) 0
```

### Step 3

```haskell
treeSize Empty = 0
treeSize (Node value left right) = 1 + treeSize left + treeSize right
```

## Ex 3

### 問題

```haskell
-- Ex 3: get the largest value in a tree of positive Ints. The
-- largest value of an empty tree should be 0.
--
-- Examples:
--   treeMax Empty  ==>  0
--   treeMax (Node 3 (Node 5 Empty Empty) (Node 4 Empty Empty))  ==>  5

treeMax :: Tree Int -> Int
treeMax = todo
```

### Step 1

BangPatternsを使って都度走査中のノードの値を `max` で評価することでサンクが蓄積しないようにしている。

```haskell
treeMax = go 0
  where
    go mx Empty = mx
    go !mx (Node node right left) = let nextMx = max mx node in max (go nextMx left) (go nextMx right)
```

### Step 2

#### 2a

すべてのノードを探索するまでサンクが積み上がり続けてしまうので、step 1の方が良い。

```haskell
treeMax Empty = 0
treeMax (Node node left right) = max node (max (treeMax left) (treeMax right))
```

#### 2b

```haskell
treeMax = foldTree (\n lMax rMax -> max n (max lMax rMax)) 0
```

### Step 3

```haskell
treeMax Empty = 0
treeMax (Node value left right) = max value (max (treeMax left) (treeMax right))
```

## Ex 4

### 問題

```haskell
-- Ex 4: implement a function that checks if all tree values satisfy a
-- condition.
--
-- Examples:
--   allValues (>0) Empty  ==>  True
--   allValues (>0) (Node 1 Empty (Node 2 Empty Empty))  ==>  True
--   allValues (>0) (Node 1 Empty (Node 0 Empty Empty))  ==>  False

allValues :: (a -> Bool) -> Tree a -> Bool
allValues condition tree = todo
```

### Step 1

`&&` は短絡評価してくれるし、 `foldTree` は遅延評価されるので、最初に `condition v` が `False` になった時点で停止してくれる。

```haskell
allValues condition = foldTree (\v l r -> condition v && l && r) True
```

### Step 2

#### 2a

```haskell
allValues _ Empty = True
allValues condition (Node value left right) = condition value && allValues condition left && allValues condition right
```

#### 2b

`go` を定義して `condition` をSATする。GHCはデフォルトでは静的引数の最適化をしてくれない。

```haskell
allValues condition = go
  where
    go Empty = True
    go (Node value left right) = condition value && go left && go right
```

#### 2c

`foldTree` に対してもSATする。

```haskell
foldTree f e = go e
  where
    go e Empty = e
    go e (Node n l r) = f n (go e l) (go e r)

allValues condition = foldTree (\v l r -> condition v && l && r) True
```

#### 2d

step 1のラムダ関数の順序によって木の走査順が変わる。

```
(\v l r -> condition v && l && r) -> pre-order
(\v l r -> l && condition v && r) -> in-order
(\v l r -> l && r && condition v) -> post-order
```

### Step 3

```haskell
allValues condition = foldTree (\v l r -> condition v && l && r) True
```

## Ex 5

### 問題

```haskell
-- Ex 5: implement map for trees.
--
-- Examples:
--
-- mapTree (+1) Empty  ==>  Empty
-- mapTree (+2) (Node 0 (Node 1 Empty Empty) (Node 2 Empty Empty))
--   ==> (Node 2 (Node 3 Empty Empty) (Node 4 Empty Empty))

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree f t = todo
```

### Step 1

pre-orderに新しい木を構築する。

```haskell
mapTree f = foldTree (\v l r -> Node (f v) l r) Empty
```

### Step 2

#### 2a

```haskell
mapTree f Empty = Empty
mapTree f (Node value left right) = Node (f value) (mapTree f left) (mapTree f right)
```

#### 2b

SATする。

```haskell
mapTree f = go
  where
    go Empty = Empty
    go (Node value left right) = Node (f value) (go left) (go right)
```

#### 2c

step 1のeta簡約する。

```haskell
mapTree f = foldTree (Node . f) Empty
```

### Step 3

```haskell
mapTree f = foldTree (Node . f) Empty
```

## Ex 6

### 問題

```haskell
-- Ex 6: given a value and a tree, build a new tree that is the same,
-- except all nodes that contain the value have been removed. Also
-- remove the subnodes of the removed nodes.
--
-- Examples:
--
--     1          1
--    / \   ==>    \
--   2   0          0
--
--  cull 2 (Node 1 (Node 2 Empty Empty)
--                 (Node 0 Empty Empty))
--     ==> (Node 1 Empty
--                 (Node 0 Empty Empty))
--
--      1           1
--     / \           \
--    2   0   ==>     0
--   / \
--  3   4
--
--  cull 2 (Node 1 (Node 2 (Node 3 Empty Empty)
--                         (Node 4 Empty Empty))
--                 (Node 0 Empty Empty))
--     ==> (Node 1 Empty
--                 (Node 0 Empty Empty)
--
--    1              1
--   / \              \
--  0   3    ==>       3
--   \   \
--    2   0
--
--  cull 0 (Node 1 (Node 0 Empty
--                         (Node 2 Empty Empty))
--                 (Node 3 Empty
--                         (Node 0 Empty Empty)))
--     ==> (Node 1 Empty
--                 (Node 3 Empty Empty))

cull :: Eq a => a -> Tree a -> Tree a
cull val tree = todo
```

### Step 1

```haskell
cull _ Empty = Empty
cull val (Node value left right) = if val == value then Empty else Node value (cull val left) (cull val right)
```

### Step 2

#### 2a

引数 `val` をSATしてコールスタックのサイズを抑える（たかだか `2 words2 * (count of nodes)` 程度の貢献しかないけど）。

upward funarg problemというのがあるらしい。

* funargはfunctionとargumentを組み合わせた造語
* クロージャ（ `g` とする）を返す関数（ `f` とする）のローカル変数をメモリ上にどのように保存するかという問題
* スタック領域に保存すると、fがreturnした時点でfのローカル変数はメモリ上から消える。もしgでfのローカル変数を使用している場合、gが参照すべき値が消えてしまい、壊れる
* 戦略
  * 変数をヒープにおいてGCに任せる
    * ex) Haskell
  * スタックとヒープをハイブリッドに使う
    * ex) Goのエスケープ解析（コンパイラが変数をスタックに置くかヒープに逃がすか判断する最適化）
  * クロージャを作った時点で変数の値をクロージャ内にコピーする
    * ex) C++のラムダの値キャプチャ（ `[=]` ）、Rustの `move` クロージャ

```haskell
cull val = go
  where
    go Empty = Empty
    go (Node v l r) = if v == val then Empty else Node v (go l) (go r)
```

#### 2b

```haskell
cull val = foldTree (\v l r -> if v == val then Empty else Node v l r) Empty
```

### Step 3

```haskell
cull val = go
  where
    go Empty = Empty
    go (Node v l r) = if v == val
                      then Empty
                      else Node v (go l) (go r)
```

## Ex 7

### 問題

```haskell
-- Ex 7: check if a tree is ordered. A tree is ordered if:
--  * all values to the left of the root are smaller than the root value
--  * all of the values to the right of the root are larger than the root value
--  * and the left and right subtrees are ordered.
--
-- Hint: allValues will help you here!
--
-- Examples:
--         1
--        / \   is ordered:
--       0   2
--   isOrdered (Node 1 (Node 0 Empty Empty)
--                     (Node 2 Empty Empty))   ==>   True
--
--         1
--        / \   is not ordered:
--       2   3
--   isOrdered (Node 1 (Node 2 Empty Empty)
--                     (Node 3 Empty Empty))   ==>   False
--
--           2
--         /   \
--        1     3   is not ordered:
--         \
--          0
--   isOrdered (Node 2 (Node 1 Empty
--                             (Node 0 Empty Empty))
--                     (Node 3 Empty Empty))   ==>   False
--
--           2
--         /   \
--        0     3   is ordered:
--         \
--          1
--   isOrdered (Node 2 (Node 0 Empty
--                             (Node 1 Empty Empty))
--                     (Node 3 Empty Empty))   ==>   True

isOrdered :: Ord a => Tree a -> Bool
isOrdered = todo
```

### Step 1

時間計算量: `O(n logn)` 。退化木であれば `O(n^2)`

```haskell
isOrdered Empty = True
isOrdered (Node v l r) = allValues (< v) l && allValues (v <) r && isOrdered l && isOrdered r
```

### Step 2

#### 2a

```haskell
isOrdered = go Nothing Nothing
  where
    go _ _ Empty = True
    go Nothing Nothing (Node v l r) = go Nothing (Just v) l && go (Just v) Nothing r
    go Nothing (Just hi) (Node v l r) = v < hi && go Nothing (Just v) l && go (Just v) (Just hi) r
    go (Just lo) Nothing (Node v l r) = lo < v && go (Just lo) (Just v) l && go (Just v) Nothing r
    go (Just lo) (Just hi) (Node v l r) = lo < v && v < hi && go (Just lo) (Just v) l && go (Just v) (Just hi) r
```

#### 2b

```haskell
isOrdered = go Nothing Nothing
  where
    go _ _ Empty = True
    go lo hi (Node v l r) = (isNothing lo || fromMaybe v lo < v) && (isNothing hi || fromMaybe v hi > v)
                            && go lo (Just v) l && go (Just v) hi r
```

#### 2c

```haskell
maybe :: b -> (a -> b) -> Maybe a -> b

isOrdered = go Nothing Nothing
  where
    go _ _ Empty = True
    go lo hi (Node v l r) = maybe True (< v) lo && maybe True (v <) hi
                            && go lo (Just v) l && go (Just v) hi r
```

### Step 3

```haskell
isOrdered = go Nothing Nothing
  where
    go _ _ Empty = True
    go lo hi (Node v l r) = maybe True (< v) lo && maybe True (v <) hi
                            && go lo (Just v) l && go (Just v) hi r
```

## Ex 8

### 問題

```haskell
-- Ex 8: a path in a tree can be represented as a list of steps that
-- go either left or right.

data Step = StepL | StepR
  deriving (Show, Eq)

-- Define a function walk that takes a tree and a list of steps, and
-- returns the value at that point. Return Nothing if you fall of the
-- tree (i.e. hit a Empty).
--
-- Examples:
--   walk [] (Node 1 (Node 2 Empty Empty) Empty)       ==>  Just 1
--   walk [StepL] (Node 1 (Node 2 Empty Empty) Empty)  ==>  Just 2
--   walk [StepL,StepL] (Node 1 (Node 2 Empty Empty) Empty)  ==>  Nothing

walk :: [Step] -> Tree a -> Maybe a
walk = todo
```

### Step 1

```haskell
walk _ Empty = Nothing
walk [] (Node v _ _) = Just v
walk (step:steps) (Node v l r) = if step == StepL
                                 then walk steps l
                                 else walk steps r
```

### Step 2

#### 2a

```haskell
walk _ Empty = Nothing
walk [] (Node v _ _) = Just v
walk (StepL:steps) (Node v l _) = walk steps l
walk (StepR:steps) (Node v _ r) = walk steps r
```

#### 2b

DFA（決定性有限オートマトン）は `foldl` で書ける。

* 決定性：入力に対して遷移先が必ず一意に決まる
* 有限：オートマトンの状態が有限

* Q: 状態の集合
* Σ: 入力アルファベット（機械が読むことのできる記号の集合）
* δ: 遷移関数
  * δ: Q × Σ -> Q
* q0: 初期状態
* F: 受理状態

δの式がまさに `foldl` 。

stepsが木から外れても早々にNothingを返せずに、最期までstepsを走査するので、step 1や2aより定数倍パフォーマンスが悪くなるケースがある。

```haskell
walk steps node = valAtRoot $ foldl' go node steps
  where
    go Empty _ = Empty
    go (Node _ l r) step = if step == StepL then l else r
```

#### 2c

`Step` を受け取って子に行くヘルパー関数は汎用性が高いので `descend` に切り出した。

```haskell
descend :: Tree a -> Step -> Tree a
descend Empty _ = Empty
descend (Node _ l _) StepL = l
descend (Node _ _ r) StepR = r

walk :: [Step] -> Tree a -> Maybe a
walk steps tree = valAtRoot $ foldl' descend tree steps
```

#### 2d

```haskell
walk = foldr consume valAtRoot
  where
    consume _ _ Empty = Nothing
    consume StepL k (Node _ l _) = k l
    consume StepR k (Node _ _ r) = k r
```

### Step 3

foldを使っていろいろな書き方ができたが、2aが最も可読性が高くてシンプルで、かつパフォーマンスも良い。

```haskell
walk _ Empty = Nothing
walk [] (Node v _ _) = Just v
walk (StepL:steps) (Node _ l _) = walk steps l
walk (StepR:steps) (Node _ _ r) = walk steps r
```

## Ex 9

### 問題

```haskell
-- Ex 9: given a tree, a path and a value, set the value at the end of
-- the path to the given value. Since Haskell datastructures are
-- immutable, you'll need to build a new tree.
--
-- If the path falls off the tree, do nothing.
--
-- Examples:
--   set [] 1 (Node 0 Empty Empty)  ==>  (Node 1 Empty Empty)
--   set [StepL,StepL] 1 (Node 0 (Node 0 (Node 0 Empty Empty)
--                                       (Node 0 Empty Empty))
--                               (Node 0 Empty Empty))
--                  ==>  (Node 0 (Node 0 (Node 1 Empty Empty)
--                                       (Node 0 Empty Empty))
--                               (Node 0 Empty Empty))
--
--   set [StepL,StepR] 1 (Node 0 Empty Empty)  ==>  (Node 0 Empty Empty)

set :: [Step] -> a -> Tree a -> Tree a
set path val tree = todo
```

### Step 1

木の高さを `k` とすると時間計算量と空間計算量は `O(k)` 。 `steps` を走査しきるとその時点でリターンできる。

```haskell
set _ _ Empty = Empty
set [] val (Node _ l r) = Node val l r
set (StepL:steps) val (Node v l r) = Node v (set steps val l) r
set (StepR:steps) val (Node v l r) = Node v l (set steps val r)
```

### Step 2

#### 2a

`val` をSATする。

```haskell
set steps val = go steps
  where
    go _ Empty = Empty
    go [] (Node _ l r) = Node val l r
    go (StepL:steps) (Node v l r) = Node v (go steps l) r
    go (StepR:steps) (Node v l r) = Node v l (go steps r)
```

#### 2b

```haskell
set path val = foldr consume replace path
  where
    replace Empty = Empty
    replace (Node _ l r) = Node val l r

    consume _ _ Empty = Empty
    consume StepL k (Node v l r) = Node v (k l) r
    consume StepR k (Node v l r) = Node v l (k r)
```

### Step 3

```haskell
set path val = go path
  where
    go _ Empty = Empty
    go [] (Node _ l r) = Node val l r
    go (StepL:steps) (Node v l r) = Node v (go steps l) r
    go (StepR:steps) (Node v l r) = Node v l (go steps r)
```

## Ex 10

### 問題

```haskell
-- Ex 10: given a value and a tree, return a path that goes from the
-- root to the value. If the value doesn't exist in the tree, return Nothing.
--
-- You may assume the value occurs in the tree at most once.
--
-- Examples:
--   search 1 (Node 2 (Node 1 Empty Empty) (Node 3 Empty Empty))  ==>  Just [StepL]
--   search 1 (Node 2 (Node 4 Empty Empty) (Node 3 Empty Empty))  ==>  Nothing
--   search 1 (Node 2 (Node 3 (Node 4 Empty Empty)
--                            (Node 1 Empty Empty))
--                    (Node 5 Empty Empty))                     ==>  Just [StepL,StepR]

search :: Eq a => a -> Tree a -> Maybe [Step]
search = todo
```

### Step 1

二分探索木ではなく、ノード間の大小関係が定義されていないただの二分木なので、全探索する必要がある。ステップごとにリストの末尾に追加していくと計算量が悪化するので、逆順にリストを構築して最期にreverseするようにした。 `target` はSATした。

```haskell
search target = go []
  where
    go _ Empty = Nothing
    go steps (Node v l r) = if v == target
                              then Just (reverse steps)
                              else let leftSteps = go (StepL:steps) l in if not (isNothing leftSteps)
                                                                           then leftSteps
                                                                           else go (StepR:steps) r
```

`not (isNothing ...)` は `isJust ...` と書き換えられる。

### Step 2

#### 2a

step 1はifがネストしていてかつletが絡んでいるので、読みにくい。ガードと `<|>` 演算子を使うとシンプルに書き直せた。型クラス `Alternative` についてはよくわからないが、一旦 `<|>` は `Maybe` 型に対しては第一引数の結果が `Just ...` であればそれを、 `Nothing` であれば第二引数の結果を返す。

```haskell
(<|>) :: Alternative f => f a -> f a -> f a

import Control.Applicative ((<|>))

search target = go []
  where
    go _ Empty = Nothing
    go steps (Node v l r)
      | v == target = Just (reverse steps)
      | otherwise = go (StepL : steps) l <|> go (StepR : steps) r
```

#### 2b

わざわざ `reverse` しなくても `StepL/R : 残りを再帰的に構築` とすればよかった。 `fmap` はFunctor（箱）の中身に関数を適用する関数。

```haskell
fmap :: Functor f => (a -> b) -> f a -> f b

search target = go
  where
    go Empty = Nothing
    go (Node v l r)
      | v == target = Just []
      | otherwise = fmap (StepL :) (go l) <|> fmap (StepR :) (go r)
```

#### 2c

2bの `fmap` を `<$>` に置き換える。

```haskell
(<$>) :: Functor f => (a -> b) -> f a -> f b

search target = go
  where
    go Empty = Nothing
    go (Node v l r)
      | v == target = Just []
      | otherwise = (StepL :) <$> go l <|> (StepR :) <$> go r
```

### Step 3

```haskell
search target = go
  where
    go Empty = Nothing
    go (Node v l r)
      | v == target = Just []
      | otherwise = (StepL :) <$> go l <|> (StepR :) <$> go r
```

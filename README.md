# README

這是一個使用 Ruby on Rails 實作的簡單專案，目的是實作綿羊爭地盤遊戲。

This is a simple project to implement the game split(https://boardgamegeek.com/boardgame/54137/battle-sheep) by using ruby on rails.

## Game Rule

### preparation

- 一開始每位玩家有 16 隻綿羊。
- 玩家輪流放置地圖版塊。（Not support in Sprint 1）
- 玩家輪流在地圖邊緣的空格上放置自己綿羊。

### how to play

- 1. 玩家選擇自己的一疊沒被包圍的綿羊。
  - 一疊：至少有兩隻綿羊。
  - 被包圍：該疊綿羊四周都有其他綿羊或是地圖邊緣。
  - 若所有綿羊都被包圍，則跳過該玩家。
- 2. 玩家將『1 - N-1』隻綿羊沿著任意方向移動，並在遇到其他綿羊或是地圖邊緣時停止。
  - N：該疊綿羊的數量。
  - 最少必須移動一格。
- 3. 換下一位玩家。

### how to win

- 當所有玩家的綿羊都無法移動時，遊戲結束。
- 玩家獲勝的條件是佔領地圖上最多的空格。
- 若有多位玩家佔領空格數相同，則擁有最大群綿羊的玩家獲勝。
- 若最大群綿羊也相同，則共同獲勝。

## Design

### api endpoints

#### 使用者

- 註冊
- 登入
- 登出

#### 房間

- 取得房間列表
- 建立房間
- 取得房間資訊
- 加入房間
- 離開房間

#### 遊戲

- 取得遊戲資訊
- 開始遊戲
- 結束遊戲
- 放置綿羊
  - 從準備區放置『所有綿羊』到『邊緣的空格』上 （準備階段）
  - 從『格子』選擇『x』隻綿羊放置到『空格』上 （遊戲進行階段）

### Model

- 使用者
- 房間
- 遊戲

#### 使用者

- has_many :games
- name
- password_digest

#### 房間

- has_many :users as players
- has_many :games
- has_one :game as current_game
- name

#### 遊戲

- room_id: int
- is_finished: boolean
- players: color array
- current_player_color: color
- steps: json

  - original_grid
  - destination_grid

- map: grid array
- grid:
  - x
  - y
  - sheep_count
  - color

### Sprint 1

- [x] create visitor model as user
- [x] create room model

  - [x] 建立房間
  - [x] 取得房間列表
  - [x] 加入房間
  - [x] 離開房間

- [ ] create game model

  - [x] 開始遊戲
  - [ ] 放置綿羊
  - [ ] 結束遊戲

## reference

- https://phantasia0021.pixnet.net/blog/post/341239064-%E7%B6%BF%E7%BE%8A%E7%88%AD%E7%89%A7%E5%A0%B4

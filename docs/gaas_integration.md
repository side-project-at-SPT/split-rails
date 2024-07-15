# gaas integration

## Overview

## First page

the iframe window open

### request

```
GET 'https://split-sheep-spt.zeabur.app/#/games/${GAME_ID}?token=${PLAYER_JWT}'
```

### TODO

1. Ask backend to verify the token
2. The current process is, post https://spt-games-split.zeabur.app/api/v1/users/login-via-gaas-token to exchange the ++token++ for a jwt
3. In the future, we should be able to play game with auth0 token directly

#### request

```
POST 'https://spt-games-split.zeabur.app/api/v1/users/login-via-gaas-token'
Headers: 'Authorization: Bearer ${token}'
```

#### response

```json
{
  "token": "jwt to play the game"
}
```

## End of the game

Once the game is over, frontend can call the following endpoint to close the game, and close the iframe window as well.

### request

```
POST 'https://spt-games-split.zeabur.app/api/v1/games/${GAME_ID}/end-game-via-gaas-token'
Headers: 'Authorization: Bearer ${TOKEN_FROM_GAAS}'
```

### response

```json
// 200
{
  "message": "Game ended"
}

// 422
{
  "message": "Failed to end game"
}
```

import consumer from "channels/consumer";

const gameConsole = document.getElementById("game-console");
const writeMessage = (message) => {
  const msg = document.createElement("div");
  msg.innerHTML = message;
  gameConsole.insertAdjacentElement("beforeend", msg);
};
const writeError = (error) => {
  const msg = document.createElement("div");
  msg.innerHTML = error;
  msg.style.color = "red";
  gameConsole.insertAdjacentElement("beforeend", msg);
};
const prepareMap = ({ board, game_config }) => {
  board.innerHTML = "";
  const mapSize = game_config.players_number + 4;
  for (let y = 0; y < mapSize; y++) {
    for (let x = 0; x < mapSize; x++) {
      const pasture = document.createElement("div");
      pasture.classList.add("pasture");
      pasture.id = `pasture-x-${x}-y-${y}`;
      pasture.dataset.x = x;
      pasture.dataset.y = y;
      board.appendChild(pasture);
    }
    board.style.gridTemplateColumns = `repeat(${mapSize}, 1fr)`;
  }
  writeMessage("Map has been prepared");
};
const queryGameInfo = async () => {
  const res = await fetch(
    `/api/v1/games/${document.location.pathname.match(/\/games\/(\d+)/)[1]}`
  );
  const { game } = await res.json();
  return game;
};
const commandInitMapAutomatically = async () => {
  const res = await fetch(
    `/api/v1/games/${
      document.location.pathname.match(/\/games\/(\d+)/)[1]
    }/init-map-automatically`,
    {
      method: "POST",
    }
  );
  const data = await res.json();
  if (data.error) {
    writeError(data.error);
    return;
  }
};
const commandPlaceStackAutomatically = async () => {
  const res = await fetch(
    `/api/v1/games/${
      document.location.pathname.match(/\/games\/(\d+)/)[1]
    }/place-stack-automatically`,
    {
      method: "POST",
    }
  );
  const data = await res.json();
  if (data.error) {
    writeError(data.error);
    return;
  }
};
const commandSplitStackAutomatically = async () => {
  const res = await fetch(
    `/api/v1/games/${
      document.location.pathname.match(/\/games\/(\d+)/)[1]
    }/split-stack-automatically`,
    {
      method: "POST",
    }
  );
  const data = await res.json();
  if (data.error) {
    writeError(data.error);
    return;
  }
};

let GameChannel;

if (document.location.pathname.match(/\/games\/\d+/)) {
  GameChannel = consumer.subscriptions.create(
    {
      channel: "GameChannel",
      game_id: document.location.pathname.match(/\/games\/(\d+)/)[1],
    },
    {
      connected() {
        // Called when the subscription is ready for use on the server
        const msg = document.createElement("div");
        msg.innerHTML = `Connected to game ${
          document.location.pathname.match(/\/games\/(\d+)/)[1]
        }`;
        gameConsole.insertAdjacentElement("beforeend", msg);
        updateGameInfo();
        queryCurrentPlayer();
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log("Received data from GameChannel");
        console.log(data);

        const { event, game_config, game_data, game_id } = data;
        switch (event) {
          case "game_reset":
            // alert("Game has been reset");
            prepareMap({
              game_config,
              board: document.getElementById("game-map"),
            });
            break;

          case "map_ready":
            writeMessage("Map is ready");
            renderGame({ game_config, game_data });
            break;

          case "stack_placed":
            writeMessage("Stack placed");
            renderGame({ game_config, game_data });
            break;

          case "stack_splitted":
            writeMessage("Stack split");
            renderGame({ game_config, game_data });
            break;

          case "turn_started":
            writeMessage("Turn started");
            queryCurrentPlayer();
            break;

          case "game_over":
            writeMessage("Game over");
            break;

          case "game_created":
            const url = new URL(`/games/${game_id}`, document.location.origin);
            if (confirm("Game has been created. Do you want to join?")) {
              alert(`You are going to join game ${game_id}`);
              // redirect to the game page
              document.location.href = url;
            } else {
              writeMessage("You can join the game later");
              writeMessage(`url: ${url}`);
            }
            break;

          default:
            break;
        }
      },

      echo(data) {
        this.perform("echo", data);
      },

      placeStack(stack) {
        this.perform("place_stack", stack);
      },

      splitStack(step) {
        this.perform("split_stack", step);
      },
    }
  );
}

document
  .getElementById("initialize-map-btn")
  .addEventListener("click", () => commandInitMapAutomatically());

document
  .getElementById("place-stack-btn")
  .addEventListener("click", () => commandPlaceStackAutomatically());

document
  .getElementById("split-stack-btn")
  .addEventListener("click", () => commandSplitStackAutomatically());

document.getElementById("clear-console-btn").addEventListener("click", () => {
  gameConsole.innerHTML = "";
});

document
  .getElementById("reset-game-btn")
  .addEventListener("click", async () => {
    const res = await fetch(
      `/api/v1/games/${
        document.location.pathname.match(/\/games\/(\d+)/)[1]
      }/reset-game`,
      {
        method: "POST",
      }
    );
    const data = await res.json();
    if (data.error) {
      writeError(data.error);
      return;
    }

    writeMessage(data.message);
  });

const renderPastures = (pastures) => {
  if (pastures?.length > 0) {
    // - pastures: array
    //     - element: hash
    //       - x: int
    //       - y: int
    //       - is_blocked: boolean
    //       - stack: hash
    //         - color: string
    //         - amount: int
    pastures.forEach((pasture) => {
      const pastureDiv = document.getElementById(
        `pasture-x-${pasture.x}-y-${pasture.y}`
      );
      pastureDiv.classList.add(pasture.stack.color);
      pastureDiv.textContent = pasture.stack.amount;
    });
  } else {
    writeMessage("No pastures found");
    return;
  }
};

const renderGame = ({ game_data, game_config }) => {
  const gameMap = document.getElementById("game-map");
  // console.log(game_config, game_data);
  if (gameMap.childElementCount === 0) {
    prepareMap({ board: gameMap, game_config });
  }
  renderPastures(game_data.pastures);
};

const updateGameInfo = async () => {
  queryGameInfo().then(({ game_config, game_data }) => {
    renderGame({ game_config, game_data });
  });
};

const queryCurrentPlayer = async () => {
  queryGameInfo().then(({ game_data, game_config }) => {
    const player = game_config.players[game_data.current_player_index];
    writeMessage(
      `${player.color} (${player.nickname}) is going to ${game_data.phase}`
    );
  });
};

const toggleGameGridStyle = () => {
  const pastures = document.querySelectorAll(".pasture");
  pastures.forEach((pasture) => {
    pasture.classList.toggle("hex");
  });
  // alert("Grid style has been toggled"); // <alert>Grid style has been toggled
  // console.log(pastures[0]);
};

document
  .getElementById("get-game-info-btn")
  .addEventListener("click", updateGameInfo);

document
  .getElementById("toggle-game-grid-style-btn")
  .addEventListener("click", toggleGameGridStyle);

document.getElementById("ws-echo-btn").addEventListener("click", () => {
  GameChannel.echo({ message: "Hello from client" });
});

const placeStackByWebSocket = () => {
  const x = parseInt(prompt("Enter x:"));
  if (isNaN(x)) {
    alert("Invalid input");
    return;
  }
  const y = parseInt(prompt("Enter y:"));
  if (isNaN(y)) {
    alert("Invalid input");
    return;
  }
  GameChannel.placeStack({ x, y });
};

document
  .getElementById("ws-place-stack-btn")
  .addEventListener("click", placeStackByWebSocket);

const splitStackByWebSocket = () => {
  const originX = parseInt(prompt("Enter origin x:"));
  if (isNaN(originX)) {
    alert("Invalid input");
    return;
  }
  const originY = parseInt(prompt("Enter origin y:"));
  if (isNaN(originY)) {
    alert("Invalid input");
    return;
  }
  const targetX = parseInt(prompt("Enter target x:"));
  if (isNaN(targetX)) {
    alert("Invalid input");
    return;
  }
  const targetY = parseInt(prompt("Enter target y:"));
  if (isNaN(targetY)) {
    alert("Invalid input");
    return;
  }
  const target_amount = parseInt(prompt("Enter target amount:"));
  if (isNaN(target_amount)) {
    alert("Invalid input");
    return;
  }
  GameChannel.splitStack({
    origin_x: originX,
    origin_y: originY,
    target_x: targetX,
    target_y: targetY,
    target_amount,
  });
};

document
  .getElementById("ws-split-stack-btn")
  .addEventListener("click", splitStackByWebSocket);

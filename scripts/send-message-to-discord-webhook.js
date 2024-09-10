const FILE_HOST =
  "https://raw.githubusercontent.com/side-project-at-SPT/split-front/main/src/assets/images";
const avatar_url = `${FILE_HOST}/1.png`;
const piece_url = `${FILE_HOST}/1p.png`;
const pic_url = `${FILE_HOST}/papua.png`;
const discord_bot_username = "企鵝打工";
const DISCORD_WEBHOOK_URL = "";

const foo = async () => {
  const payload = {
    embeds: [
      {
        title: "#12",
        description: "Reported by: 學長",
        color: 16711680,
        footer: {
          text: "好 issue 不修嗎",
          icon_url: avatar_url,
        },
        author: {
          name: "旁觀者加入遊戲後可以關閉房間 #12",
          icon_url:
            "https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png",
        },
        fields: [],
        url: "https://github.com/side-project-at-SPT/split-rails/issues/12",
        thumbnail: {
          url: piece_url,
        },
      },
    ],
    content: "",
    username: discord_bot_username,
    avatar_url: avatar_url,
  };

  const req = new Request(DISCORD_WEBHOOK_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  const res = await fetch(req);

  if (!res.ok) {
    throw new Error(`HTTP error! status: ${res.status}`);
  }
};

foo();

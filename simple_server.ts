#!/usr/bin/env -S deno run --allow-net

let intervalId;
Deno.serve({ port: 3000 }, async (_req) => {
  intervalId = setInterval(() => { console.log("...") }, 1000);
  await new Promise((resolve) => {
    console.log("simple server called");
    setTimeout(() => {
      clearInterval(intervalId);
      resolve(null);
    }, 2000);
  });

  return new Response("Hello, World!");
});

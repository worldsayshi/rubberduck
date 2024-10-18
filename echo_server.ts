#!/usr/bin/env -S deno run --allow-net

const listener = Deno.listen({ port: 3000 });
console.log("listening on 0.0.0.0:3000");
for await (const conn of listener) {
  conn.readable.pipeTo(conn.writable);
}

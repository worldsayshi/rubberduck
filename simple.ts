

const i = setInterval(() => console.log("..."), 1000);
await new Promise((resolve) => {
  console.log("simple script called");
  setTimeout(resolve, 2000)

});

console.log("Hello, World!");

clearInterval(i);

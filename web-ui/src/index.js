import React from "react";
import ReactDOM from "react-dom/client";
import App from "./app";
import stylesheet from "./css/tailwind.css";

export const links = () => [{ rel: "stylesheet", href: stylesheet }];
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

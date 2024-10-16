import "./app.css";
import App from "./App.svelte";
import { planeteloSetup } from "./dojo/planeteloSetup";
import { dojoConfig } from "../dojoConfig";
import { accountStore, burnerStore, planeteloStore } from "./stores";

// Create a writable store for the setup result

async function initApp() {
  // Update the store with the setup result
  let setupRes = await planeteloSetup(dojoConfig)
  planeteloStore.set(setupRes);
  burnerStore.set(setupRes.burnerManager.list());
  accountStore.set(setupRes.burnerManager.getActiveAccount())

  console.log("App initialized");

  const app = new App({
    target: document.getElementById("app")!,
  });

  return app;
}

export default initApp();

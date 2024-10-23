import { get } from "svelte/store";
import { planeteloStore, accountStore, usernameStore } from "./stores";

export function connect(event: Event) {
    const target = event.target as HTMLSelectElement;
    console.log(target.value);
}
import { get } from "svelte/store";
import { planeteloStore, accountStore, burnerStore } from "./stores";
import type { BurnerManager } from "@dojoengine/create-burner";

let burnerManager: BurnerManager


export function handleBurnerChange(event: Event) {
    const target = event.target as HTMLSelectElement;
    burnerManager = get(planeteloStore).burnerManager
    burnerManager.select(target.value);
    accountStore.set(burnerManager.getActiveAccount())
}

export async function handleNewBurner(event: Event) {
    burnerManager = get(planeteloStore).burnerManager
    await burnerManager.create();
    burnerStore.set(burnerManager.list());
    accountStore.set(burnerManager.getActiveAccount())
}

export function handleClearBurners(event: Event) {
    burnerManager = get(planeteloStore).burnerManager
    burnerManager.clear();
    burnerStore.set(burnerManager.list());
    accountStore.set(null);
}
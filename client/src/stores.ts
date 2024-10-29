import { writable, derived } from "svelte/store";
import { type SetupResult as PlaneteloSetupResult } from "./dojo/planeteloSetup";
import { type SetupResult as PlanetarySetupResult } from "./dojo/planetarySetup";
import type Controller from "@cartridge/controller";
import type { Account, AccountInterface } from "starknet";

export const planeteloStore = writable<PlaneteloSetupResult>();
export const planetaryStore = writable<PlanetarySetupResult>();
export const accountStore = writable<AccountInterface | null>();

export const usernameStore = writable<string>();
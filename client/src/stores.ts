import { writable, derived } from "svelte/store";
import { type SetupResult as PlaneteloSetupResult } from "./dojo/planeteloSetup";
import { type SetupResult as PlanetarySetupResult } from "./dojo/planetarySetup";
import { Account } from "starknet";
import { type Burner } from "@dojoengine/create-burner";

export const planeteloStore = writable<PlaneteloSetupResult>();
export const planetaryStore = writable<PlanetarySetupResult>();
export const accountStore = writable<Account | null>();

export const burnerStore = writable<Burner[]>();

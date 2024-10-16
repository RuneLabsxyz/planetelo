import { overridableComponent } from "@dojoengine/recs";
import type { ContractComponents } from "./bindings/planetary/models.gen";

export type PlanetaryClientComponents = ReturnType<typeof createPlanetaryClientComponents>;

export function createPlanetaryClientComponents({
  contractComponents,
}: {
  contractComponents: ContractComponents;
}) {
  return {
    ...contractComponents,
    Planet: overridableComponent(contractComponents.Planet),
  };
}

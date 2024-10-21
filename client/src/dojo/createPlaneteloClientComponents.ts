import { overridableComponent } from "@dojoengine/recs";
import type { ContractComponents } from "./bindings/planetelo/models.gen";

export type PlaneteloClientComponents = ReturnType<typeof createPlaneteloClientComponents>;

export function createPlaneteloClientComponents({
  contractComponents,
}: {
  contractComponents: ContractComponents;
}) {
  return {
    ...contractComponents,
    Queue: overridableComponent(contractComponents.Queue),
  };
}

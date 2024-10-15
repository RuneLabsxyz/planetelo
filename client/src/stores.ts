import { writable, get } from 'svelte/store';
import type { Readable } from 'svelte/store';
import { ParsedEntity, SchemaType } from '@dojoengine/sdk';

/**
 * Represents a pending transaction for optimistic updates.
 */
interface PendingTransaction<T extends SchemaType> {
  transactionId: string;
  previousEntities: Record<string, ParsedEntity<T>>;
}

/**
 * Represents the overall game state.
 */
interface GameState<T extends SchemaType> {
  entities: Record<string, ParsedEntity<T>>;
  pendingTransactions: Record<string, PendingTransaction<T>>;
}

/**
 * Extends Svelte's Readable store to include custom methods for managing game state.
 */
interface GameStore<T extends SchemaType> extends Readable<GameState<T>> {
  setEntities: (entities: ParsedEntity<T>[]) => void;
  updateEntity: (entity: Partial<ParsedEntity<T>>) => void;
  applyOptimisticUpdate: (
    transactionId: string,
    updateFn: (currentState: GameState<T>) => GameState<T>
  ) => void;
  revertOptimisticUpdate: (transactionId: string) => void;
  confirmTransaction: (transactionId: string) => void;
  subscribeToEntity: (
    entityId: string,
    listener: (entity: ParsedEntity<T> | undefined) => void
  ) => () => void;
  waitForEntityChange: (
    entityId: string,
    predicate: (entity: ParsedEntity<T> | undefined) => boolean,
    timeout?: number
  ) => Promise<ParsedEntity<T> | undefined>;
  getEntity: (entityId: string) => ParsedEntity<T> | undefined;
  getEntities: (
    filter?: (entity: ParsedEntity<T>) => boolean
  ) => ParsedEntity<T>[];
  getEntitiesByModel: (
    namespace: string,
    model: string
  ) => ParsedEntity<T>[];
}

/**
 * Factory function to create a Svelte store based on a given SchemaType.
 *
 * @template T - The schema type.
 * @returns A Svelte store tailored to the provided schema.
 */
function createDojoStore<T extends SchemaType>(): GameStore<T> {
  const initialState: GameState<T> = {
    entities: {},
    pendingTransactions: {},
  };

  const { subscribe, update } = writable<GameState<T>>(initialState);

  const store: GameStore<T> = {
    subscribe,

    /**
     * Sets multiple entities into the store.
     *
     * @param entities - Array of ParsedEntity to set.
     */
    setEntities: (entities: ParsedEntity<T>[]) => {
      update((currentState) => {
        const newEntities = { ...currentState.entities };
        entities.forEach((entity) => {
          newEntities[entity.entityId] = entity;
        });
        return {
          ...currentState,
          entities: newEntities,
        };
      });
    },

    /**
     * Updates a single entity in the store.
     *
     * @param entity - Partial ParsedEntity with updates.
     */
    updateEntity: (entity: Partial<ParsedEntity<T>>) => {
      if (!entity.entityId) return;
      update((currentState) => {
        const existingEntity = currentState.entities[entity.entityId!];
        if (!existingEntity) return currentState;
        const updatedEntity = { ...existingEntity, ...entity };
        return {
          ...currentState,
          entities: {
            ...currentState.entities,
            [entity.entityId!]: updatedEntity,
          },
        };
      });
    },

    /**
     * Applies an optimistic update to the store.
     *
     * @param transactionId - Unique identifier for the transaction.
     * @param updateFn - Function that returns the updated state.
     */
    applyOptimisticUpdate: (
      transactionId: string,
      updateFn: (currentState: GameState<T>) => GameState<T>
    ) => {
      update((currentState) => {
        // Take a snapshot of current entities before update
        const previousEntities: Record<string, ParsedEntity<T>> = {};
        for (const [id, entity] of Object.entries(currentState.entities)) {
          previousEntities[id] = { ...entity };
        }

        // Apply the update function to get the new state
        const updatedState = updateFn(currentState);

        // Add the pending transaction
        const newPendingTransactions = {
          ...currentState.pendingTransactions,
          [transactionId]: {
            transactionId,
            previousEntities,
          },
        };

        return {
          ...updatedState,
          pendingTransactions: newPendingTransactions,
        };
      });
    },

    /**
     * Reverts an optimistic update.
     *
     * @param transactionId - Unique identifier for the transaction.
     */
    revertOptimisticUpdate: (transactionId: string) => {
      update((currentState) => {
        const transaction = currentState.pendingTransactions[transactionId];
        if (!transaction) return currentState;

        const revertedEntities = { ...currentState.entities };
        // Restore previous entities
        for (const [id, entity] of Object.entries(transaction.previousEntities)) {
          revertedEntities[id] = entity;
        }

        const { [transactionId]: _, ...remainingTransactions } =
          currentState.pendingTransactions;

        return {
          ...currentState,
          entities: revertedEntities,
          pendingTransactions: remainingTransactions,
        };
      });
    },

    /**
     * Confirms an optimistic update, removing it from pending transactions.
     *
     * @param transactionId - Unique identifier for the transaction.
     */
    confirmTransaction: (transactionId: string) => {
      update((currentState) => {
        const { [transactionId]: _, ...remaining } =
          currentState.pendingTransactions;
        return {
          ...currentState,
          pendingTransactions: remaining,
        };
      });
    },

    /**
     * Subscribes to changes of a specific entity.
     *
     * @param entityId - ID of the entity to subscribe to.
     * @param listener - Callback invoked with the entity data.
     * @returns Unsubscribe function.
     */
    subscribeToEntity: (
      entityId: string,
      listener: (entity: ParsedEntity<T> | undefined) => void
    ): (() => void) => {
      const unsubscribe = subscribe((state) => {
        const entity = state.entities[entityId];
        listener(entity);
      });
      return unsubscribe;
    },

    /**
     * Waits for a specific entity to satisfy a predicate.
     *
     * @param entityId - ID of the entity to watch.
     * @param predicate - Condition to fulfill.
     * @param timeout - Maximum time to wait in milliseconds.
     * @returns Promise that resolves with the entity or undefined.
     */
    waitForEntityChange: (
      entityId: string,
      predicate: (entity: ParsedEntity<T> | undefined) => boolean,
      timeout: number = 6000
    ): Promise<ParsedEntity<T> | undefined> => {
      return new Promise((resolve, reject) => {
        const timer = setTimeout(() => {
          unsubscribe();
          reject(
            new Error(
              `waitForEntityChange: Timeout of ${timeout}ms exceeded for entity ${entityId}`
            )
          );
        }, timeout);

        const unsubscribe = subscribe(
          (state) => state.entities[entityId],
          (state) => {
            const entity = state!.entities[entityId];
            if (predicate(entity)) {
              clearTimeout(timer);
              unsubscribe();
              resolve(entity);
            }
          }
        );
      });
    },

    getEntity: (entityId: string) => {
      return get(store).entities[entityId];
    },

    /**
     * Retrieves all entities, optionally filtered by a predicate.
     *
     * @param filter - Optional filter function.
     * @returns Array of ParsedEntity.
     */
    getEntities: (
      filter?: (entity: ParsedEntity<T>) => boolean
    ): ParsedEntity<T>[] => {
      const state = get(store);
      const entities = Object.values(state.entities);
      return filter ? entities.filter(filter) : entities;
    },

    /**
     * Retrieves entities by specific model and namespace.
     *
     * @param namespace - The namespace of the model.
     * @param model - The model name.
     * @returns Array of ParsedEntity matching the criteria.
     */
    getEntitiesByModel: (
      namespace: string,
      model: string
    ): ParsedEntity<T>[] => {
      return store.getEntities((entity) => !!entity.models[namespace]?.[model]);
    },
  };

  return store;
}

export default createDojoStore;
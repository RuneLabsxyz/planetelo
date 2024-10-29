
// Generated by dojo-bindgen on Thu, 24 Oct 2024 16:34:29 +0000. Do not modify this file manually.
// Import the necessary types from the recs SDK
// generate again with `sozo build --typescript` 
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<ReturnType<typeof defineContractComponents>>;



// Type definition for `dojo::model::layout::Layout` enum
export type Layout = { type: 'Fixed'; value: RecsType.NumberArray; } | { type: 'Struct'; value: RecsType.StringArray; } | { type: 'Tuple'; value: RecsType.StringArray; } | { type: 'Array'; value: RecsType.StringArray; } | { type: 'ByteArray'; } | { type: 'Enum'; value: RecsType.StringArray; };

export const LayoutDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
// Type definition for `core::byte_array::ByteArray` struct
export interface ByteArray {
    data: String[];
    pending_word: BigInt;
    pending_word_len: Number;
    
}
export const ByteArrayDefinition = {
    data: RecsType.StringArray,
    pending_word: RecsType.BigInt,
    pending_word_len: RecsType.Number,
    
};

// Type definition for `planetelo::models::Elo` struct
export interface Elo {
    player: BigInt;
    game: BigInt;
    playlist: BigInt;
    value: Number;
    
}
export const EloDefinition = {
    player: RecsType.BigInt,
    game: RecsType.BigInt,
    playlist: RecsType.BigInt,
    value: RecsType.Number,
    
};

// Type definition for `dojo::model::layout::FieldLayout` struct
export interface FieldLayout {
    selector: BigInt;
    layout: Layout;
    
}
export const FieldLayoutDefinition = {
    selector: RecsType.BigInt,
    layout: LayoutDefinition,
    
};


// Type definition for `planetelo::models::Game` struct
export interface Game {
    game: BigInt;
    id: BigInt;
    playlist: BigInt;
    player1: BigInt;
    player2: BigInt;
    timestamp: Number;
    
}
export const GameDefinition = {
    game: RecsType.BigInt,
    id: RecsType.BigInt,
    playlist: RecsType.BigInt,
    player1: RecsType.BigInt,
    player2: RecsType.BigInt,
    timestamp: RecsType.Number,
    
};


// Type definition for `planetelo::models::Player` struct
export interface Player {
    player: BigInt;
    games_played: Number;
    queues_joined: Number;
    
}
export const PlayerDefinition = {
    player: RecsType.BigInt,
    games_played: RecsType.Number,
    queues_joined: RecsType.Number,
    
};


// Type definition for `planetelo::models::QueueStatus` enum
export type QueueStatus = { type: 'None'; } | { type: 'Queued'; } | { type: 'InGame'; value: RecsType.BigInt; };

export const QueueStatusDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
// Type definition for `planetelo::models::PlayerStatus` struct
export interface PlayerStatus {
    player: BigInt;
    game: BigInt;
    playlist: BigInt;
    status: QueueStatus;
    index: Number;
    
}
export const PlayerStatusDefinition = {
    player: RecsType.BigInt,
    game: RecsType.BigInt,
    playlist: RecsType.BigInt,
    status: QueueStatusDefinition,
    index: RecsType.Number,
    
};


// Type definition for `planetelo::models::Queue` struct
export interface Queue {
    game: BigInt;
    playlist: BigInt;
    length: Number;
    
}
export const QueueDefinition = {
    game: RecsType.BigInt,
    playlist: RecsType.BigInt,
    length: RecsType.Number,
    
};


// Type definition for `planetelo::models::QueueIndex` struct
export interface QueueIndex {
    game: BigInt;
    playlist: BigInt;
    index: Number;
    player: BigInt;
    timestamp: Number;
    elo: Number;
    
}
export const QueueIndexDefinition = {
    game: RecsType.BigInt,
    playlist: RecsType.BigInt,
    index: RecsType.Number,
    player: RecsType.BigInt,
    timestamp: RecsType.Number,
    elo: RecsType.Number,
    
};


export function defineContractComponents(world: World) {
    return {

        // Model definition for `planetelo::models::Elo` model
        Elo: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    game: RecsType.BigInt,
                    playlist: RecsType.BigInt,
                    value: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "Elo",
                        types: ["ContractAddress", "felt252", "u128", "u64"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `planetelo::models::Game` model
        Game: (() => {
            return defineComponent(
                world,
                {
                    game: RecsType.BigInt,
                    id: RecsType.BigInt,
                    playlist: RecsType.BigInt,
                    player1: RecsType.BigInt,
                    player2: RecsType.BigInt,
                    timestamp: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "Game",
                        types: ["felt252", "u128", "u128", "ContractAddress", "ContractAddress", "u64"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `planetelo::models::Player` model
        Player: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    games_played: RecsType.Number,
                    queues_joined: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "Player",
                        types: ["ContractAddress", "u32", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `planetelo::models::PlayerStatus` model
        PlayerStatus: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    game: RecsType.BigInt,
                    playlist: RecsType.BigInt,
                    status: RecsType.String,
                    index: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "PlayerStatus",
                        types: ["ContractAddress", "felt252", "u128", "QueueStatus", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `planetelo::models::Queue` model
        Queue: (() => {
            return defineComponent(
                world,
                {
                    game: RecsType.BigInt,
                    playlist: RecsType.BigInt,
                    length: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "Queue",
                        types: ["felt252", "u128", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `planetelo::models::QueueIndex` model
        QueueIndex: (() => {
            return defineComponent(
                world,
                {
                    game: RecsType.BigInt,
                    playlist: RecsType.BigInt,
                    index: RecsType.Number,
                    player: RecsType.BigInt,
                    timestamp: RecsType.Number,
                    elo: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "planetelo",
                        name: "QueueIndex",
                        types: ["felt252", "u128", "u32", "ContractAddress", "u64", "u64"],
                        customTypes: [],
                    },
                }
            );
        })(),
    };
}

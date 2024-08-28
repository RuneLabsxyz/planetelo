
// Generated by dojo-bindgen on Wed, 28 Aug 2024 13:49:07 +0000. Do not modify this file manually.
// Import the necessary types from the recs SDK
// generate again with `sozo build --typescript` 
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<ReturnType<typeof defineContractComponents>>;



// Type definition for `pistols64::types::cards::tactics::TacticsCard` enum
export type TacticsCard = { type: 'Null'; } | { type: 'Insult'; } | { type: 'CoinToss'; } | { type: 'Vengeful'; } | { type: 'ThickCoat'; } | { type: 'Reversal'; } | { type: 'Bananas'; };

export const TacticsCardDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
// Type definition for `pistols64::types::cards::blades::BladesCard` enum
export type BladesCard = { type: 'Null'; } | { type: 'Seppuku'; } | { type: 'RunAway'; } | { type: 'Behead'; } | { type: 'Grapple'; };

export const BladesCardDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
// Type definition for `pistols64::types::cards::paces::PacesCard` enum
export type PacesCard = { type: 'Null'; } | { type: 'Paces1'; } | { type: 'Paces2'; } | { type: 'Paces3'; } | { type: 'Paces4'; } | { type: 'Paces5'; } | { type: 'Paces6'; } | { type: 'Paces7'; } | { type: 'Paces8'; } | { type: 'Paces9'; } | { type: 'Paces10'; };

export const PacesCardDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
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

// Type definition for `pistols64::models::round::Shot` struct
export interface Shot {
    card_paces: PacesCard;
    card_dodge: PacesCard;
    card_tactics: TacticsCard;
    card_blades: BladesCard;
    initial_chances: Number;
    initial_damage: Number;
    initial_health: Number;
    final_chances: Number;
    final_damage: Number;
    final_health: Number;
    dice_crit: Number;
    win: Number;
    
}
export const ShotDefinition = {
    card_paces: PacesCardDefinition,
    card_dodge: PacesCardDefinition,
    card_tactics: TacticsCardDefinition,
    card_blades: BladesCardDefinition,
    initial_chances: RecsType.Number,
    initial_damage: RecsType.Number,
    initial_health: RecsType.Number,
    final_chances: RecsType.Number,
    final_damage: RecsType.Number,
    final_health: RecsType.Number,
    dice_crit: RecsType.Number,
    win: RecsType.Number,
    
};

// Type definition for `pistols64::models::round::Round` struct
export interface Round {
    duel_id: BigInt;
    round_number: Number;
    shot_a: Shot;
    shot_b: Shot;
    
}
export const RoundDefinition = {
    duel_id: RecsType.BigInt,
    round_number: RecsType.Number,
    shot_a: ShotDefinition,
    shot_b: ShotDefinition,
    
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


// Type definition for `pistols64::types::state::ChallengeState` enum
export type ChallengeState = { type: 'Null'; } | { type: 'InProgress'; } | { type: 'Resolved'; } | { type: 'Draw'; } | { type: 'Canceled'; };

export const ChallengeStateDefinition = {
    type: RecsType.String,
    value: RecsType.String
};
        
// Type definition for `pistols64::models::challenge::Challenge` struct
export interface Challenge {
    duel_id: BigInt;
    address_a: BigInt;
    address_b: BigInt;
    duelist_name_a: BigInt;
    duelist_name_b: BigInt;
    message: BigInt;
    state: ChallengeState;
    winner: Number;
    
}
export const ChallengeDefinition = {
    duel_id: RecsType.BigInt,
    address_a: RecsType.BigInt,
    address_b: RecsType.BigInt,
    duelist_name_a: RecsType.BigInt,
    duelist_name_b: RecsType.BigInt,
    message: RecsType.BigInt,
    state: ChallengeStateDefinition,
    winner: RecsType.Number,
    
};


export function defineContractComponents(world: World) {
    return {

        // Model definition for `pistols64::models::round::Round` model
        Round: (() => {
            return defineComponent(
                world,
                {
                    duel_id: RecsType.BigInt,
                    round_number: RecsType.Number,
                    shot_a: ShotDefinition,
                    shot_b: ShotDefinition,
                },
                {
                    metadata: {
                        namespace: "pistols64",
                        name: "Round",
                        types: ["u128", "u8"],
                        customTypes: ["Shot", "Shot"],
                    },
                }
            );
        })(),

        // Model definition for `pistols64::models::challenge::Challenge` model
        Challenge: (() => {
            return defineComponent(
                world,
                {
                    duel_id: RecsType.BigInt,
                    address_a: RecsType.BigInt,
                    address_b: RecsType.BigInt,
                    duelist_name_a: RecsType.BigInt,
                    duelist_name_b: RecsType.BigInt,
                    message: RecsType.BigInt,
                    state: RecsType.String,
                    winner: RecsType.Number,
                },
                {
                    metadata: {
                        namespace: "pistols64",
                        name: "Challenge",
                        types: ["u128", "ContractAddress", "ContractAddress", "felt252", "felt252", "felt252", "ChallengeState", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),
    };
}


// Generated by dojo-bindgen on Wed, 16 Oct 2024 14:59:51 +0000. Do not modify this file manually.
// Import the necessary types from the recs SDK
// generate again with `sozo build --typescript` 
import { Account, byteArray } from "starknet";
import { DojoProvider } from "@dojoengine/core";
import * as models from "./models.gen";

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export async function setupWorld(provider: DojoProvider) {
    // System definitions for `planetary-planetary_actions` contract
    function planetary_actions() {
        const contract_name = "planetary_actions";

        
        // Call the `world` system with the specified Account and calldata
        const world = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "world",
                        calldata: [],
                    },
                    "planetary"
                );
            } catch (error) {
                console.error("Error executing world:", error);
                throw error;
            }
        };
            

    
        // Call the `register` system with the specified Account and calldata
        const register = async (props: { account: Account, name: bigint, world_address: bigint }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "register",
                        calldata: [props.name,
                props.world_address],
                    },
                    "planetary"
                );
            } catch (error) {
                console.error("Error executing register:", error);
                throw error;
            }
        };
            

    
        // Call the `unregister` system with the specified Account and calldata
        const unregister = async (props: { account: Account, name: bigint }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "unregister",
                        calldata: [props.name],
                    },
                    "planetary"
                );
            } catch (error) {
                console.error("Error executing unregister:", error);
                throw error;
            }
        };
            

    
        // Call the `get_world_address` system with the specified Account and calldata
        const get_world_address = async (props: { account: Account, name: bigint }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "get_world_address",
                        calldata: [props.name],
                    },
                    "planetary"
                );
            } catch (error) {
                console.error("Error executing get_world_address:", error);
                throw error;
            }
        };
            

    
        // Call the `name` system with the specified Account and calldata
        const name = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "name",
                        calldata: [],
                    },
                    "planetary"
                );
            } catch (error) {
                console.error("Error executing name:", error);
                throw error;
            }
        };
            

        return {
            world, register, unregister, get_world_address, name
        };
    }

    // System definitions for `vulcan-salute` contract
    function salute() {
        const contract_name = "salute";

        
        // Call the `name` system with the specified Account and calldata
        const name = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "name",
                        calldata: [],
                    },
                    "vulcan"
                );
            } catch (error) {
                console.error("Error executing name:", error);
                throw error;
            }
        };
            

    
        // Call the `world` system with the specified Account and calldata
        const world = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "world",
                        calldata: [],
                    },
                    "vulcan"
                );
            } catch (error) {
                console.error("Error executing world:", error);
                throw error;
            }
        };
            

    
        // Call the `live_long` system with the specified Account and calldata
        const live_long = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    {
                        contractName: contract_name,
                        entrypoint: "live_long",
                        calldata: [],
                    },
                    "vulcan"
                );
            } catch (error) {
                console.error("Error executing live_long:", error);
                throw error;
            }
        };
            

        return {
            name, world, live_long
        };
    }

    return {
        planetary_actions: planetary_actions(),
        salute: salute()
    };
}

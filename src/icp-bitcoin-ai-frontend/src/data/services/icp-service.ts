import { createActor } from "../../../../declarations/mempool"
const actor = createActor(import.meta.env.VITE_MEMPOOL_CANISTER_ID);

const IcpService = {
  setblock: async () => {
    try {
      const response = await actor.set_block_hash("000000000000000015dc777b3ff2611091336355d3f0ee9766a2cf3be8e4b1ce")
      return response
    } catch (error) {
      return error
    }
  },
  getBlockInfo: async () => {
    try {
      const response = await actor.get_bitcoin_block_info()
      return response
    } catch (error) {
      return error
    }
  },
  getHashblocks: async (count: bigint) => {
    try {
      const response = await actor.fetch_bitcoin_blocks(count)
      return response
    }
    catch (error) {
      return error
    }
  }
}

export default IcpService
import React, { useEffect, useState } from 'react'
import styles from './home-styles.module.scss'
import Sidebar from '../../components/sidebar/sidebar'
import Hashblocks from '../../components/hashblocks/hashblocks'
import Network, { NetworkData } from '../../components/network/network'
import CustomTabs from '../../components/custom-tabs/custom-tabs'
import IcpService from '../../../data/services/icp-service'
import { jsonParseBigint } from '../../../utils/json-parse-bigint'
import Header from '../../components/header/header'

const Home: React.FC = () => {
  const [actual, setActual] = useState('Bitcoin')
  const [hashblocks, setHashblocks] = useState()
  const [data, setData] = useState<NetworkData>(
    {
      description: "Bitcoin is the first decentralized cryptocurrency. Nodes in the peer-to-peer bitcoin network verify transactions through cryptography and record them in a public distributed ledger, called a blockchain, without central",
      transactionsCount: '2020749',
      transactionsValue: '2980937292746 BTC',
      address: '12300289033',
      token: 'BTC USD'
    }
  )

  useEffect(() => {
    const getHashblocks = async (): Promise<void> => {
      const cache = localStorage.getItem('hashblocks')
      if (cache) {
        console.log('cache')
        setHashblocks(JSON.parse(cache))
        // localStorage.clear()
      }
      else {
        const block = await IcpService.setblock()
        console.log(block)

        const info = await IcpService.getBlockInfo()
        console.log(info)

        const response: any = await IcpService.getHashblocks(BigInt(50))
        console.log(response)

        if (response.ok) {
          const json = jsonParseBigint(response.ok)
          setHashblocks(json)
          localStorage.setItem('hashblocks', JSON.stringify(json))
        }
      }
    }

    getHashblocks()
  }, [])

  return (
    <div className={styles.home}>
      <Sidebar actual={actual} onChange={(coin) => setActual(coin)} />
      <div className={styles.container}>
        <Header onSubmit={() => { }} />
        <Hashblocks coin={actual} data={hashblocks} />
        <div className={styles.info}>
          <Network data={data} />
          <CustomTabs
            hashblocks={hashblocks}
            labels={['by hashblocks', 'by time']} />
        </div>
      </div>
    </div>
  )
}

export default Home
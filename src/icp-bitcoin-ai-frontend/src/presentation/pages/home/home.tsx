import React, { useState } from 'react'
import styles from './home-styles.module.scss'
import Sidebar from '../../components/sidebar/sidebar'
import Hashblocks from '../../components/hashblocks/hashblocks'
import Network, { NetworkData } from '../../components/network/network'

const Home: React.FC = () => {
  const [actual, setActual] = useState('Bitcoin')
  const [data, setData] = useState<NetworkData>(
    {
      description: "Bitcoin is the first decentralized cryptocurrency. Nodes in the peer-to-peer bitcoin network verify transactions through cryptography and record them in a public distributed ledger, called a blockchain, without central",
      transactionsCount: '2020749',
      transactionsValue: '2980937292746 BTC',
      address: '12300289033',
      token: 'BTC USD'
    }
  )

  return (
    <div className={styles.home}>
      <Sidebar actual={actual} onChange={(coin) => setActual(coin)} />
      <div className={styles.container}>
        <Hashblocks coin={actual} />
        <Network data={data} />
      </div>
    </div>
  )
}

export default Home
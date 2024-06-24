import React, { useEffect, useState } from 'react'
import styles from './home-styles.module.scss'
import Sidebar from '../../components/sidebar/sidebar'
import Hashblocks from '../../components/hashblocks/hashblocks'
import Network, { NetworkData } from '../../components/network/network'
import CustomTabs from '../../components/custom-tabs/custom-tabs'
import IcpService from '../../../data/services/icp-service'
import { jsonParseBigint } from '../../../utils/json-parse-bigint'
import Header from '../../components/header/header'
import InfoModal from '../../components/info-modal/info-modal'
import TransactionInfo from './components/transaction-info/transaction-info'
import AddressInfo from './components/address-info/address-info'
import { dayInterval } from '../../../utils/day-interval'

const Home: React.FC = () => {
  const [actual, setActual] = useState('Bitcoin')
  const [hashblocks, setHashblocks] = useState()
  const [modalOpened, setModalOpened] = useState(false)
  const [info, setInfo] = useState<any>()
  const [data, setData] = useState<NetworkData>(
    {
      description: "Bitcoin is the first decentralized cryptocurrency. Nodes in the peer-to-peer bitcoin network verify transactions through cryptography and record them in a public distributed ledger, called a blockchain.",
      transactionsCount: '2020749',
      transactionsValue: '2980937292746 BTC',
      address: '12300289033',
      token: 'BTC USD'
    }
  )

  const verifyCacheInterval = (cache: any) => {
    if (cache.date) {
      const interval = dayInterval(Date.now(), cache.date)

      if (interval >= 0 && interval < 1) {
        return true
      }
    }
    return false
  }

  useEffect(() => {
    const getHashblocks = async (): Promise<void> => {
      const cache = localStorage.getItem('hashblocks')
      if (cache && verifyCacheInterval(JSON.parse(cache))) {
        console.log('cache')

        setHashblocks(JSON.parse(cache).ok)
      }
      else {
        const response: any = await IcpService.getHashblocks()

        if (response.ok) {
          localStorage.clear()
          const json = jsonParseBigint(response)
          json.date = Date.now()
          setHashblocks(json.ok)
          localStorage.setItem('hashblocks', JSON.stringify(json))
        }
      }
    }

    getHashblocks()
  }, [])

  const handleGetInfo = async (type: string, value: string) => {
    setModalOpened(true)

    if (type === 'address') {
      const response: any = await IcpService.getAddressInfo(value)
      response.type = type
      setInfo(response)
    }
    else if (type === 'transaction') {
      const response: any = await IcpService.getTransactionInfo(value)
      response.type = type
      setInfo(response)
    }
  }

  const handleClose = () => {
    setInfo(null)
    setModalOpened(false)
  }

  return (
    <div className={styles.home}>
      <Sidebar actual={actual} onChange={(coin) => setActual(coin)} />
      <div className={styles.container}>
        <Header onSubmit={handleGetInfo} />
        <Hashblocks coin={actual} data={hashblocks} />
        <div className={styles.info}>
          <Network data={data} />
          <CustomTabs
            hashblocks={hashblocks}
            labels={['by hashblocks', 'by time']} />
        </div>
      </div>

      {
        modalOpened && <InfoModal data={info} onClose={() => handleClose()}>
          {
            info?.type === 'address' ? <AddressInfo title="Address Information" data={info?.['ok']} />
              : <TransactionInfo title="Transaction Information" data={info?.['ok'] && info?.['ok'][0] !== 'Invalid hex string' && JSON.parse(info?.['ok'][0])} />
          }
        </InfoModal>
      }
    </div>
  )
}

export default Home
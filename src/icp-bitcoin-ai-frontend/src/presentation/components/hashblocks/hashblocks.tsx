import React, { ReactElement, useRef, useState } from 'react'
import styles from './hashblocks-styles.module.scss'

type Props = {
  coin: string
}

type HashblockProps = {
  id: string
  value: string
  date: string
}

const Hashblocks: React.FC<Props> = ({ coin }: Props) => {
  const hashblocksRef = useRef<any>(null)
  const [data, setData] = useState<HashblockProps[]>([
    {
      id: '[124012901249]',
      value: '845,982',
      date: 'Today, 16:54'
    },
    {
      id: '[124012901249]',
      value: '1234,513',
      date: 'Yesterday, 18:24'
    },
    {
      id: '[124012901249]',
      value: '687,213',
      date: '2 days ago, 17:21'
    },
    {
      id: '[124012901249]',
      value: '764,576',
      date: '3 days ago, 12:46'
    },
    {
      id: '[124012901249]',
      value: '845,154',
      date: '4 days ago, 16:26'
    },
    {
      id: '[124012901249]',
      value: '542,133',
      date: '4 days ago, 04:23'
    },
    {
      id: '[124012901249]',
      value: '875,361',
      date: '5 days ago, 17:41'
    },
    {
      id: '[124012901249]',
      value: '237,618',
      date: '5 days ago, 16:47'
    },
    {
      id: '[124012901249]',
      value: '571,541',
      date: '6 days ago, 16:16'
    },

  ])
  const [isMouseDown, setIsMouseDown] = useState(false)
  const [startX, setStartX] = useState(0)
  const [scrollLeft, setScrollLeft] = useState(0)

  const handleMouseDown = (e: any) => {
    setIsMouseDown(true)
    setStartX(e.pageX - hashblocksRef.current.offsetLeft)
    setScrollLeft(hashblocksRef.current.scrollLeft)
  }

  const handleMouseUp = () => {
    setIsMouseDown(false)
  }

  const handleMouseLeave = () => {
    setIsMouseDown(false)

  }

  const handleMouseMove = (e: any) => {
    if (!isMouseDown) return
    e.preventDefault()
    const x = e.pageX - hashblocksRef.current.offsetLeft
    const walk = (x - startX) * 2
    hashblocksRef.current.scrollLeft = scrollLeft - walk
  }

  const getCoin = (): ReactElement => {
    switch (coin) {
      case 'Bitcoin':
        return <img src="/coins/bitcoin.png" alt="" />
      case 'Etherum':
        return <img src="/coins/eth.png" alt="" />
      case 'Solana':
        return <img src="/coins/solana.png" alt="" />
      case 'ICP':
        return <img src="/coins/icp.png" alt="" />
      default:
        return <img src="/coins/icp.png" alt="" />
    }
  }

  return (
    <div className={styles.container}>
      <h2>HASHBLOCKS</h2>
      <div
        className={styles.hashblocks}
        ref={hashblocksRef}
        onMouseDown={handleMouseDown}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
        onMouseMove={handleMouseMove}
      >

        {data && data.map((item: HashblockProps, index: number) => {
          return (
            <>
              {index > 0 && < div className={styles.divider}></div >}
              <div className={styles.card}>
                <div className={styles.info}>
                  <p className={styles.id}>id {item.id}</p>
                  <div className={styles.value}>
                    <p>{item.value}</p>
                  </div>
                  <div className={styles.graph}>
                    <img src="/graph.png" alt="" />
                  </div>
                </div>

                <p className={styles.title}>Details</p>

                <div className={styles.details}>
                  <div className={styles.coin}>
                    {getCoin()}
                  </div>
                  <div className={styles.date}>
                    <h3>{coin}</h3>
                    <p>{item.date}</p>
                  </div>
                </div>
              </div>
            </>
          )
        })}
      </div>
    </div >
  )
}

export default Hashblocks
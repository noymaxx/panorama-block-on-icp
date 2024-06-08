import React from 'react'
import styles from './network-styles.module.scss'

export type NetworkData = {
  description: string
  transactionsCount: string
  transactionsValue: string
  address: string
  token: string
}

type Props = {
  data: NetworkData
}

const Network: React.FC<Props> = ({ data }: Props) => {
  return (
    <div className={styles.network}>
      <h2 className={styles.title}>Network Informations</h2>
      <p className={styles.description}>
        {data.description}
      </p>
      <div className={styles.divider}></div>
      <div className={styles.info}>
        <div className={styles.row}>
          <p className={styles.label}>All Transactions:</p>
          <p className={styles.value}>{data.transactionsCount}</p>
        </div>
        <div className={styles.row}>
          <p className={styles.label}>Active Address: </p>
          <p className={styles.value}>{data.address}</p>
        </div>
        <div className={styles.row}>
          <p className={styles.label}>Transactions Value:</p>
          <p className={styles.value}>{data.transactionsValue}</p>
        </div>
        <div className={styles.row}>
          <p className={styles.label}>Tokens: </p>
          <p className={styles.value}>{data.token}</p>
        </div>
      </div>
    </div>
  )
}

export default Network
import React, { useEffect } from 'react'
import styles from './transaction-info-styles.module.scss'

type Props = {
  data: any
  title: string
}

const TransactionInfo: React.FC<Props> = ({ title, data }: Props) => {
  return (
    <div className={styles.transactionInfo}>
      <h3 className={styles.title}>{title}</h3>

      <div className={styles.divider}></div>

      <p><b>Transaction id:</b> {data.txid}</p>
      <p><b>Size:</b> {data.size}</p>
      <p><b>Value:</b>  {(data.weight / 100000).toFixed(2)} BTC</p>
      <p><b>Fee:</b>  {data.fee}</p>
    </div>
  )
}

export default TransactionInfo
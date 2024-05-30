import React from 'react'
import styles from './button-styles.module.scss'

type Props = {
  title: string
  type: 'wallet' | "primary" | "secundary"
}

const Button: React.FC<Props> = ({ title, type }: Props) => {
  return (
    <div className={styles.container}>
      <button className={`${styles.button} ${styles[type]}`}>{title}</button>
    </div>
  )
}

export default Button
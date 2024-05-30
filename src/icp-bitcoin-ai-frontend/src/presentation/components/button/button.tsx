import React from 'react'
import styles from './button-styles.module.scss'

const Button: React.FC = () => {
  return (
    <div className={styles.button}>
      <button>Acessar</button>
    </div>
  )
}

export default Button
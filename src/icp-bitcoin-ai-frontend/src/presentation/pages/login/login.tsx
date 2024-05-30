import React from 'react'
import styles from './login-styles.module.scss'
import Button from '../../components/button/button'

const Login: React.FC = () => {
  return (
    <div className={styles.login}>
      <div className={styles.main}>
      </div>
      <div className={styles.start}>
        <div className={styles.container}>
          <div className={styles.intro}>
            <h2>Nice to see you!</h2>
            <p>Enter you wallet to start</p>
          </div>
          <Button title="CONNECT WALLET" type="wallet" />
        </div>
      </div>
    </div>
  )
}

export default Login

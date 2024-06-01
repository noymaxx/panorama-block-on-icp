import React, { useState } from 'react'
import styles from './home-styles.module.scss'
import Sidebar from '../../components/sidebar/sidebar'

const Home: React.FC = () => {
  const [actual, setActual] = useState('Bitcoin')
  return (
    <div className={styles.home}>
      <Sidebar actual={actual} onChange={(coin) => setActual(coin)} />
    </div>
  )
}

export default Home
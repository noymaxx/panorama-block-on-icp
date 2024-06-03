import React, { useState } from 'react'
import styles from './home-styles.module.scss'
import Sidebar from '../../components/sidebar/sidebar'
import Hashblocks from '../../components/hashblocks/hashblocks'

const Home: React.FC = () => {
  const [actual, setActual] = useState('Bitcoin')
  return (
    <div className={styles.home}>
      <Sidebar actual={actual} onChange={(coin) => setActual(coin)} />
      <div className={styles.container}>
        <Hashblocks coin={actual} />
      </div>
    </div>
  )
}

export default Home
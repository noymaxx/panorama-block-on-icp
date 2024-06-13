import React, { useState } from 'react'
import styles from './landing-header-styles.module.scss'
import Button from '../../../../components/button/button'
import { useNavigate } from 'react-router-dom'

type Item = {
  title: string
  url: string
}

const navItems: Item[] = [
  {
    title: 'Home',
    url: '/#home'
  },
  {
    title: "About",
    url: "#about"
  }
]

const LandingHeader: React.FC = () => {
  const [active, setActive] = useState(0)
  const navigate = useNavigate()

  return (
    <div className={styles.header}>
      <img className={styles.logo} src="/Logo.png" alt="" />

      <nav className={styles.navigation}>
        {navItems.map((item: Item, index: number) => {
          return (
            <div className={`${styles.navItem} ${active === index && styles.active}`} onClick={() => { index === 1 && window.scrollTo({ top: 600, behavior: "smooth" }) }}>
              {item.title}
            </div>
          )
        })}
      </nav>

      <div className={styles.connect}>
        <Button type='wallet' title='Go to App' onClick={() => { navigate('/home') }} />
      </div>
    </div>
  )
}

export default LandingHeader
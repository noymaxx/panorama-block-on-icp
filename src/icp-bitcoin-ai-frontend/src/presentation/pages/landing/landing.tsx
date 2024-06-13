import React, { useEffect, useState } from 'react'
import styles from './landing-styles.module.scss'
import LandingHeader from './components/landing-header/landing-header'
import HubOutlinedIcon from '@mui/icons-material/HubOutlined'
import BusinessIcon from '@mui/icons-material/Business'
import CurrencyExchangeIcon from '@mui/icons-material/CurrencyExchange'
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp'
import LandingFooter from './components/landing-footer/landing-footer'

const Landing: React.FC = () => {
  const [scrollPosition, setScrollPosition] = useState(0)
  const handleScroll = () => {
    const position = window.pageYOffset
    setScrollPosition(position)
  }

  useEffect(() => {
    window.addEventListener('scroll', handleScroll, { passive: true })

    return () => {
      window.removeEventListener('scroll', handleScroll)
    }
  }, [])

  return (
    <div className={styles.landing}>
      <div id='home' className={styles.container}>
        <LandingHeader />
        <div className={`${styles.section} ${styles.intro}`}>
          <h1 className={styles.title}>
            On-chain data availability on the <span className={styles.highlight}>ICP blockchain</span>
          </h1>
          <p className={styles.description}>
            <b className={styles.highlight}>Panorama Block</b> is a decentralized hub focused on making data available on-chain. Our mission is to <b className={styles.highlight}>democratize access</b> to Web3, making it transparent and <b className={styles.highlight}>profitable for everyone.</b>
          </p>
        </div>

        <div id='about' className={`${styles.section} ${styles.about}`}>
          <div className={styles.sectionTitle}>
            <h2>Our vision</h2>
          </div>
          <div className={styles.sectionBody}>
            <div className={styles.topic}>
              <div className={styles.icon}>
                <HubOutlinedIcon />
              </div>

              <h2>Leveraging ICP for Interconnectivity</h2>

              <p>Panorama Block utilizes Internet Computer Protocol (ICP) to connect various blockchains, enabling seamless data exchange across Web3 and Web2 platforms. This interconnectivity fosters a unified digital ecosystem.</p>
            </div>

            <div className={styles.topic}>
              <div className={styles.icon}>
                <BusinessIcon />
              </div>

              <h2>Building Data Infrastructure</h2>

              <p>Panorama Block is focused on constructing critical data infrastructure to facilitate seamless interoperability. By systematically managing diverse data from various sources, the company ensures smooth and secure data flow across platforms, which is essential for the development of advanced decentralized applications.</p>
            </div>

            <div className={styles.topic}>
              <div className={styles.icon}>
                <CurrencyExchangeIcon />
              </div>

              <h2>Empowering and Democratizing DeFi</h2>

              <p>Expanding into a data and analytics powerhouse, Panora Block empowers third-party developers to create AI and Machine Learning tools. By democratizing access to top DeFi products and services, Panora Block enables broader participation and innovation within the decentralized finance space.</p>
            </div>
          </div>
        </div>

        <LandingFooter />

        {
          scrollPosition >= 100 && <div className={styles.goToTop} onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}>
            <KeyboardArrowUpIcon />
          </div>
        }
      </div>
    </div >
  )
}

export default Landing